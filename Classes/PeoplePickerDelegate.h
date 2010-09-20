//
//  PeoplePickerDelegate.h
//  iDoubs
//
//  Created by Mamadou DIOP on 9/12/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AddressBookUI/ABPeoplePickerNavigationController.h>

#import "DialerViewController.h"

@interface PeoplePickerDelegate : NSObject<ABPeoplePickerNavigationControllerDelegate> {
	NSObject<DialerViewControllerDelegate> *delegateDialer;
}

@property (retain, nonatomic) NSObject<DialerViewControllerDelegate> *delegateDialer;

@end
