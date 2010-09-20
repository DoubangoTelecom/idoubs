//
//  iDoubsAppDelegate.m
//  iDoubs
//
//  Created by Mamadou DIOP on 8/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

// http://www.drobnik.com/touch/2010/05/nsnotifications-and-background-threads/
// http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Notifications/Articles/Threading.html
// http://www.iphoneexamples.com/

#import "iDoubsAppDelegate.h"

#import "ServiceManager.h"

#import "RegisteringViewController.h"
#import "DialerViewController.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@implementation iDoubsAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize inCallViewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	// Code source for PeoplePicker comes from http://developer.apple.com/library/ios/#samplecode/QuickContacts/Introduction/Intro.html
	self->peoplePickerDelegate = [[PeoplePickerDelegate alloc] init];
	ABPeoplePickerNavigationController *peoplePickerController = [[[ABPeoplePickerNavigationController alloc] init] autorelease];
	
    peoplePickerController.peoplePickerDelegate = self->peoplePickerDelegate;
	peoplePickerController.displayedProperties = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty], 
												  [NSNumber numberWithInt:kABPersonEmailProperty],
												  [NSNumber numberWithInt:kABPersonBirthdayProperty], nil];
	peoplePickerController.tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:tab_index_contacts] tabBarItem]; 
	
	NSMutableArray* viewControllers = [NSMutableArray arrayWithArray:self.tabBarController.viewControllers];
	[viewControllers replaceObjectAtIndex:tab_index_contacts withObject:peoplePickerController];
	[self.tabBarController setViewControllers:viewControllers animated:NO];
	
	
	DialerViewController* dialerViewController = (DialerViewController*)[viewControllers objectAtIndex:tab_index_dialer];
	self->peoplePickerDelegate.delegateDialer = dialerViewController;
	
	self->inCallViewController = [[InCallViewController alloc] initWithNibName:@"InCallViewController" bundle:nil];
	UITabBarItem* tabBarItem = [[UITabBarItem alloc] initWithTitle:@"In Call" image:nil tag:1];
	self->inCallViewController.tabBarItem = tabBarItem;
	[tabBarItem release];
	
    // Add the tab bar controller's view to the window and display.
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
	
	
	RegisteringViewController *registeringViewController = [[RegisteringViewController alloc] initWithNibName:@"RegisteringViewController" bundle:nil];
	[self.tabBarController presentModalViewController:registeringViewController animated:NO];
	[registeringViewController release];
	
	
	
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	
	[SharedServiceManager stop];
}


#pragma mark -
#pragma mark UITabBarControllerDelegate methods

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [tabBarController release];
    [window release];
	[inCallViewController release];
	
	[self->peoplePickerDelegate release];
	
    [super dealloc];
}

@end

