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

#import "NgnContact.h"

@implementation NgnContact

@synthesize id;
@synthesize displayName;
@synthesize firstName;
@synthesize lastName;
@synthesize phoneNumbers;
@synthesize picture;
@synthesize opaque;

-(NgnContact*)initWithABRecordRef: (const ABRecordRef) record{
	if((self = [super init]) && record){
		self->phoneNumbers = [[NSMutableArray alloc] init];
		
		self->id = ABRecordGetRecordID(record);
		self->displayName = (NSString *)ABRecordCopyCompositeName(record);
		self->fisrtName = (NSString*)ABRecordCopyValue(record, kABPersonFirstNameProperty);
		self->lastName = (NSString*)ABRecordCopyValue(record, kABPersonLastNameProperty);
		if(ABPersonHasImageData(record)){
			//--self->picture = (NSData*)ABPersonCopyImageData(record);
		}
		// kABPersonModificationDateProperty
		
		CFStringRef phoneNumber, phoneNumberLabel, phoneNumberLabelValue;
		NgnPhoneNumber* ngnPhoneNumber;
		ABMutableMultiValueRef multi = ABRecordCopyValue(record, kABPersonPhoneProperty);
		for (CFIndex i = 0; i < ABMultiValueGetCount(multi); i++) {
			phoneNumberLabel = ABMultiValueCopyLabelAtIndex(multi, i);
			phoneNumberLabelValue = ABAddressBookCopyLocalizedLabel(phoneNumberLabel);
			phoneNumber      = ABMultiValueCopyValueAtIndex(multi, i);
			
			ngnPhoneNumber = [[NgnPhoneNumber alloc] initWithNumber: (NSString*)phoneNumber andDescription: (NSString*)phoneNumberLabelValue];
			[self->phoneNumbers addObject: ngnPhoneNumber];
			
			[ngnPhoneNumber release];
			CFRelease(phoneNumberLabelValue);
			CFRelease(phoneNumberLabel);
			CFRelease(phoneNumber);
		}
		CFRelease(multi);
	}
	return self;
}

-(NgnPhoneNumber*) getPhoneNumberWithPredicate: (NSPredicate*)predicate{
	@synchronized(self.phoneNumbers){
		for (NgnPhoneNumber*phoneNumber in self.phoneNumbers) {
			if([predicate evaluateWithObject: phoneNumber]){
				return phoneNumber;
			}
		}
	}
	return nil;
}

-(void)dealloc{
	[self->displayName release];
	[self->fisrtName release];
	[self->lastName release];
	[self->picture release];
	
	[self->phoneNumbers release];
	
	[self->opaque release];
	[super dealloc];
}

@end

#endif /* TARGET_OS_IPHONE */
