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
 */
#import <Cocoa/Cocoa.h>

#import "OSXNgnStack.h"

#import "UITabViewItem.h"

@interface idoubs2AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NSTabView *tabView;
	NSTextField *textFieldDisplayName;
	
	NSMenuItem* menuItemPreferences;
	NSMenuItem* menuItemHistoryClear;
	
	UITabViewItem *tabItemAuthentication;
	UITabViewItem *tabItemHistory;
	UITabViewItem *tabItemContacts;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTabView *tabView;
@property (assign) IBOutlet NSTextField *textFieldDisplayName;
@property (assign) IBOutlet NSMenuItem* menuItemPreferences;
@property (assign) IBOutlet NSMenuItem* menuItemHistoryClear;

@property (retain,readonly) UITabViewItem *tabItemAuthentication;
@property (retain,readonly) UITabViewItem *tabItemHistory;
@property (retain,readonly) UITabViewItem *tabItemContacts;

+(idoubs2AppDelegate*)sharedInstance;

- (IBAction)onMenuItemClick:(id)sender;

@end
