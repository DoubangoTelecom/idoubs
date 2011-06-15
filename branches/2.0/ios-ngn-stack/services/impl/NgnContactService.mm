/* Copyright (C) 2010-2011, Mamadou Diop.
 * Copyright (c) 2011, Doubango Telecom. All rights reserved.
 *
 * Contact: Mamadou Diop <diopmamadou(at)doubango(dot)org>
 *       
 * This file is part of iDoubs Project ( http://code.google.com/p/idoubs )
 *
 * idoubs is free software: you can redistribute it and/or modify it under the terms of 
 * the GNU General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 *       
 * idoubs is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 * See the GNU General Public License for more details.
 *       
 * You should have received a copy of the GNU General Public License along 
 * with this program; if not, write to the Free Software Foundation, Inc., 
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 */
#if TARGET_OS_IPHONE

#import "NgnContactService.h"
#import "model/NgnContact.h"
#import "events/NgnContactEventArgs.h"
#import "utils/NgnNotificationCenter.h"

#undef TAG
#undef kNameSpace
#define kNameSpace "org.doubango.ios.services.contacts"
#define kTAG @"NgnContactService///: "
#define TAG kTAG

#undef NgnCFRelease
#define NgnCFRelease(x) if(x)CFRelease(x), x=NULL;

static void NgnAddressBookExternalChangeCallback (ABAddressBookRef addressBook, CFDictionaryRef info, void *context){
	NgnContactService *self_ = (NgnContactService*)context;
	[self_ load:YES];
}

@interface NgnContactService(Private)

@property(readonly, getter=isStarted) BOOL started;

-(BOOL) isStarted;
-(void) syncLoad;
@end


static void NgnAddressBookCallbackForElements(const void *value, void *context)
{
	NgnContactService* self_ = (NgnContactService*)context;
	if(!self_.started){
		return;
	}
	const ABRecordRef* record = (const ABRecordRef*)value;
	NgnContact* contact = [[NgnContact alloc] initWithABRecordRef: record];
	if(contact){
		for(NgnPhoneNumber *phoneNumber in contact.phoneNumbers){
			if(phoneNumber.number){
				[(NSMutableDictionary*)[self_ numbers2ContactsMapper] setObject:contact forKey:phoneNumber.number];
			}
		}
		[(NSMutableArray*)[self_ contacts] addObject: contact];
		[contact release];
	}
}

static CFComparisonResult NgnAddressBookCompareByCompositeName(ABRecordRef person1, ABRecordRef person2, ABPersonSortOrdering ordering)
{
	CFStringRef displayName1 = ABRecordCopyCompositeName(person1);
	CFStringRef displayName2 = ABRecordCopyCompositeName(person2);
	CFComparisonResult result = kCFCompareEqualTo;
	
	switch([(NSString*)displayName1 compare: (NSString*)displayName2]){
		case NSOrderedAscending:
			result = kCFCompareLessThan;
			break;
		case NSOrderedSame:
			result = kCFCompareEqualTo;
			break;
		case NSOrderedDescending:
			result = kCFCompareGreaterThan;
			break;
	}
	
	NgnCFRelease(displayName1);
	NgnCFRelease(displayName2);
	
	return result;
}

@implementation NgnContactService(Private)

-(BOOL) isStarted{
	return mStarted;
}

-(void)syncLoad{
	mLoading = TRUE;
	[mContacts removeAllObjects];
	[mNumbers2ContacstMapper removeAllObjects];
	
	if(addressBook == nil){
		addressBook = ABAddressBookCreate();
	}
	
	if(addressBook){
		CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
		CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(
										   kCFAllocatorDefault,
										   CFArrayGetCount(people),
										   people
										   );
		CFArraySortValues(
						  peopleMutable,
						  CFRangeMake(0, CFArrayGetCount(peopleMutable)),
						  (CFComparatorFunction) NgnAddressBookCompareByCompositeName,
						  (void*) ABPersonGetSortOrdering()
						  );
		
		// Create NGN contacts
		CFArrayApplyFunction(peopleMutable, CFRangeMake(0, CFArrayGetCount(peopleMutable)), NgnAddressBookCallbackForElements, self);
		
		NgnCFRelease(peopleMutable);
		NgnCFRelease(people);		
	}
	mLoading = FALSE;
	
	NgnContactEventArgs *eargs = [[[NgnContactEventArgs alloc] initWithType:CONTACT_RESET_ALL] autorelease];
	[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnContactEventArgs_Name object:eargs];
}

@end

@implementation NgnContactService

-(NgnContactService*)init{
	if((self = [super init])){
		mLoaderQueue = dispatch_queue_create(kNameSpace, NULL);
		mContacts = [[NgnContactMutableArray alloc] init];
		mNumbers2ContacstMapper = [[NSMutableDictionary alloc] init];
		addressBook = nil;
	}
	return self;
}

//
// INgnBaseService
//

-(BOOL) start{
	NgnNSLog(TAG, @"Start()");
	mStarted = TRUE;
	
	[self load: FALSE];
	ABAddressBookRegisterExternalChangeCallback(addressBook, NgnAddressBookExternalChangeCallback, self);
	
	return YES;
}

-(BOOL) stop{
	NgnNSLog(TAG, @"Stop()");
	mStarted = FALSE;
	
	[mContacts removeAllObjects];
	ABAddressBookUnregisterExternalChangeCallback(addressBook, NgnAddressBookExternalChangeCallback, self);
	
	return YES;
}

-(void)dealloc{
	[self stop];
	if(mLoaderQueue){
		dispatch_release(mLoaderQueue), mLoaderQueue = NULL;
	}
	[mContacts release];
	[mNumbers2ContacstMapper release];
	
	NgnCFRelease(addressBook);
	
	[super dealloc];
}



//
// INgnContactService
//

-(void) load: (BOOL) asyn{
	if(asyn){
		dispatch_async(mLoaderQueue, ^{
			[self syncLoad];
		});
	}
	else {
		[self syncLoad];
	}

}				   

-(BOOL) isLoading{
	return mLoading;
}

-(NSArray*) contacts{
	return mContacts;
}

-(NSDictionary*) numbers2ContactsMapper{
	return mNumbers2ContacstMapper;
}

-(NSArray*) contactsWithPredicate: (NSPredicate*)predicate{
	return [mContacts filteredArrayUsingPredicate: predicate];
}

#if TARGET_OS_IPHONE

-(NgnContact*) getContactByUri: (NSString*)uri{
	return nil;
}

// FIXME: should be optimized
// * Idea 1: create dictionary with the phone number as key and NgnContact as value
// * Idea 2: Idea 1 but only fill the dictionary when this function succeed. The advantage
// of this idea is that we will only store the most often searched contacts. If the contact
// doesn't exist we shoud store 'nil' to avoid query for it again and again. 
// Do not forget to clear the dictionary when the contacts are loaded again.
-(NgnContact*) getContactByPhoneNumber: (NSString*)phoneNumber{
	if(phoneNumber){
		return [mNumbers2ContacstMapper objectForKey:phoneNumber];
	}
	return nil;
}

#endif /* TARGET_OS_IPHONE */

@end

#endif /* TARGET_OS_IPHONE */