//
//  PeoplePickerDelegate.m
//  iDoubs
//
//  Created by Mamadou DIOP on 9/12/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import "PeoplePickerDelegate.h"

#import <AddressBook/AddressBook.h>

#import "iDoubsAppDelegate.h"

@implementation PeoplePickerDelegate

@synthesize delegateDialer;

#pragma mark ABPeoplePickerNavigationControllerDelegate methods
// Displays the information of a selected person
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
	
	ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonPhoneProperty);
	[self.delegateDialer setAddress:(NSString*)ABMultiValueCopyValueAtIndex(multi, 0)];
	return NO;
}


// Does not allow users to perform default actions such as dialing a phone number, when they select a person property.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
								property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
	
	//ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonPhoneProperty);
	//[self.delegateDialer setAddress:(NSString*)ABMultiValueCopyValueAtIndex(multi, 0)];
	
	return NO;
}


// Dismisses the people picker and shows the application when users tap Cancel. 
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;{
	//[self dismissModalViewControllerAnimated:YES];
	iDoubsAppDelegate *appDelegate = (iDoubsAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.tabBarController setSelectedIndex:tab_index_dialer];
}


@end
