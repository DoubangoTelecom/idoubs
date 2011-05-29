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
#import "PeoplePicker.h"

#import <AddressBook/AddressBook.h>

#import "iDoubs2AppDelegate.h"

@implementation PeoplePicker

@synthesize delegate;

-(void) viewDidLoad{
	[super viewDidLoad];
	
	self.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
}

#pragma mark ABPeoplePickerNavigationControllerDelegate methods
// Displays the information of a selected person
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)picker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
	
	NgnContact* contact = [[NgnContact alloc] initWithABRecordRef:person];
	BOOL shoudContinue = [self.delegate peoplePicker:self  shouldContinueAfterPickingContact:contact];
	[contact release];
	
	return shoudContinue;
}


// Does not allow users to perform default actions such as dialing a phone number, when they select a person property.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)picker shouldContinueAfterSelectingPerson:(ABRecordRef)person
								property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
	
	BOOL shoudContinue = NO;
	NgnPhoneNumber* ngnPhoneNumber = nil;
	
	//if(kABPersonPhoneProperty == property && kABPersonPhoneProperty == identifier){
		ABMutableMultiValueRef multi = ABRecordCopyValue(person, property);
		CFStringRef label = ABMultiValueCopyLabelAtIndex(multi, 0);
		CFStringRef description = (CFStringRef)ABAddressBookCopyLocalizedLabel(label);
		CFStringRef number = (CFStringRef)ABMultiValueCopyValueAtIndex(multi, 0);
		
		ngnPhoneNumber = [[NgnPhoneNumber alloc] initWithNumber: (NSString*)number andDescription: (NSString*)description];
		
		CFRelease(multi);
		CFRelease(label);
		CFRelease(description);
		CFRelease(number);
	//}

	shoudContinue = [self.delegate peoplePicker:self shouldContinueAfterPickingNumber:ngnPhoneNumber];
	[ngnPhoneNumber release];
	
	return shoudContinue;
}


// Dismisses the people picker and shows the application when users tap Cancel.
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)picker;{	
	[self dismiss];
}

-(void) pickNumber: (UIViewController<PeoplePickerDelegate> *)delegate_{
	self.peoplePickerDelegate = self;
	self.delegate = delegate_;
	[self.delegate presentModalViewController:self animated:YES];
}

-(void) pickContact: (UIViewController<PeoplePickerDelegate> *)delegate_{
	self.peoplePickerDelegate = self;
	self.delegate = delegate_;
	[self.delegate presentModalViewController:self animated:YES];
}

-(void) dismiss{
	[self.delegate dismissModalViewControllerAnimated:YES];
}

-(void)dealloc{
	[self.delegate release];
	[super dealloc];
}

@end