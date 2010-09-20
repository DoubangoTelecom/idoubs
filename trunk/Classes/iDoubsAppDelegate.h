//
//  iDoubsAppDelegate.h
//  iDoubs
//
//  Created by Mamadou DIOP on 8/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PeoplePickerDelegate.h"
#import "InCallViewController.h"

typedef enum tab_indexes_e{
	tab_index_profile=0,
	tab_index_dialer=1,
	tab_index_contacts=2,
	tab_index_history=3,
	tab_index_about=4
}
tab_indexes_t;

@interface iDoubsAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	PeoplePickerDelegate* peoplePickerDelegate;
	InCallViewController* inCallViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (readonly,nonatomic, retain) IBOutlet InCallViewController *inCallViewController;

@end
