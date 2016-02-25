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

#import "NgnContact.h"


#define NgnRelease(x) if(x){ CFRelease(x),x=NULL; }

@implementation NgnContact

@synthesize id;
@synthesize displayName;
@synthesize firstName;
@synthesize lastName;
@synthesize phoneNumbers;
@synthesize picture;
@synthesize opaque;

#if TARGET_OS_IPHONE

-(NgnContact*)initWithABRecordRef: (const ABRecordRef) record
{
	if((self = [super init]) && record){
		self->phoneNumbers = [[NSMutableArray alloc] init];
		
		self->id = ABRecordGetRecordID(record);
		self->displayName = (NSString *)ABRecordCopyCompositeName(record);
		self->firstName = (NSString*)ABRecordCopyValue(record, kABPersonFirstNameProperty);
		self->lastName = (NSString*)ABRecordCopyValue(record, kABPersonLastNameProperty);
		//if(ABPersonHasImageData(record)){
			// self->picture = (NSData*)ABPersonCopyImageData(record);
		//}
		// kABPersonModificationDateProperty
		
		
		//
		//	Phone numbers
		//
		ABPropertyID properties[2] = { kABPersonPhoneProperty, kABPersonEmailProperty };
#define kABPersonPhonePropertyIndex 0
#define kABPersonEmailPropertyIndex 1
		for(int k=0; k< sizeof(properties)/sizeof(ABPropertyID); k++){
			CFStringRef phoneNumber, phoneNumberLabel, phoneNumberLabelValue;
			NgnPhoneNumber* ngnPhoneNumber;
			ABMutableMultiValueRef multi = ABRecordCopyValue(record, properties[k]);
			for (CFIndex i = 0; i < ABMultiValueGetCount(multi); i++) {
				phoneNumberLabel = ABMultiValueCopyLabelAtIndex(multi, i);
				phoneNumberLabelValue = ABAddressBookCopyLocalizedLabel(phoneNumberLabel);
				phoneNumber      = ABMultiValueCopyValueAtIndex(multi, i);
			
				ngnPhoneNumber = [[NgnPhoneNumber alloc] initWithNumber:(NSString*)phoneNumber 
														 andDescription:(NSString*)phoneNumberLabelValue
														 andType:(k==kABPersonEmailPropertyIndex) ? NgnPhoneNumberType_Email : NgnPhoneNumberType_Mobile
								  ];
				[self->phoneNumbers addObject: ngnPhoneNumber];
			
				[ngnPhoneNumber release];
				NgnRelease(phoneNumberLabelValue);
				NgnRelease(phoneNumberLabel);
				NgnRelease(phoneNumber);
			}
			NgnRelease(multi);
		}
	}
	return self;
}

#elif TARGET_OS_MAC

-(NgnContact*)initWithABPerson:(const ABPerson*)person
{
	if((self = [super init]) && person){
		self->phoneNumbers = [[NSMutableArray alloc] init];
		self->firstName = [[person valueForProperty:kABFirstNameProperty] retain];
		self->lastName = [[person valueForProperty:kABLastNameProperty] retain];
	}
	return self;
}

#endif

-(NgnPhoneNumber*)getPhoneNumberWithPredicate:(NSPredicate*)predicate
{
	@synchronized(self.phoneNumbers){
		for (NgnPhoneNumber*phoneNumber in self.phoneNumbers) {
			if([predicate evaluateWithObject: phoneNumber]){
				return phoneNumber;
			}
		}
	}
	return nil;
}

-(void)dealloc
{
#if TARGET_OS_IPHONE
	
#endif /* TARGET_OS_IPHONE */

#if TARGET_OS_MAC
	
#endif /* TARGET_OS_IPHONE */
	
	[self->displayName release];
	[self->firstName release];
	[self->lastName release];
	[self->picture release];
	
	[self->phoneNumbers release];
	
	[self->opaque release];
	
	
	[super dealloc];
}

@end


