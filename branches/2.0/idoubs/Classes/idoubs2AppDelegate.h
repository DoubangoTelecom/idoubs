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
#import <UIKit/UIKit.h>
#import "AudioCallViewController.h"
#import "VideoCallViewController.h"
#import "MessagesViewController.h"
#import "ChatViewController.h"
#import "ContactsViewController.h"

#import "iOSNgnStack.h"

@interface idoubs2AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	ContactsViewController *contactsViewController;
	AudioCallViewController *audioCallController;
	VideoCallViewController *videoCallController;
	MessagesViewController *messagesViewController;
	ChatViewController *chatViewController;
	
	BOOL scheduleRegistration;
	
	BOOL multitaskingSupported;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ContactsViewController *contactsViewController;
@property (nonatomic, retain) IBOutlet MessagesViewController *messagesViewController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, readonly) AudioCallViewController *audioCallController;
@property (nonatomic, readonly) VideoCallViewController *videoCallController;
@property (nonatomic, readonly) ChatViewController *chatViewController;

-(void) selectTabContacts;
-(void) selectTabMessages;
+(idoubs2AppDelegate*) sharedInstance;

@end
