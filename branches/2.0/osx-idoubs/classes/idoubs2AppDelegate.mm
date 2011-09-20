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
#import "idoubs2AppDelegate.h"

#import "UIPreferences.h"
#import "UICall.h"

#import "MediaSessionMgr.h"

#undef TAG
#define kTAG @"idoubs2AppDelegate///: "
#define TAG kTAG

//
//	sip callback events implementation
//
@interface idoubs2AppDelegate(Sip_And_Network_Callbacks)
-(void) onNetworkEvent:(NSNotification*)notification;
-(void) onNativeContactEvent:(NSNotification*)notification;
-(void) onStackEvent:(NSNotification*)notification;
-(void) onRegistrationEvent:(NSNotification*)notification;
-(void) onMessagingEvent:(NSNotification*)notification;
-(void) onInviteEvent:(NSNotification*)notification;
@end


@implementation idoubs2AppDelegate(Sip_And_Network_Callbacks)


-(void) onNetworkEvent:(NSNotification*)notification 
{
	NgnNetworkEventArgs *eargs = [notification object];
	
	switch (eargs.eventType) {
		case NETWORK_EVENT_STATE_CHANGED:
		default:
		{
			NgnNSLog(TAG,@"NetworkEvent reachable=%@ networkType=%i", 
					 [NgnEngine sharedInstance].networkService.reachable ? @"YES" : @"NO", [NgnEngine sharedInstance].networkService.networkType);
			
			// stop stack => clean up all dialogs
			[[NgnEngine sharedInstance].sipService stopStackSynchronously];
			
			if([NgnEngine sharedInstance].networkService.reachable){
				
				[[NgnEngine sharedInstance].sipService registerIdentity];
			}
			else {
				
			}

			
			break;
		}
	}
}

-(void) onNativeContactEvent:(NSNotification*)notification
{
}

-(void) onStackEvent:(NSNotification*)notification
{
}

-(void) onRegistrationEvent:(NSNotification*)notification
{
	NgnRegistrationEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case REGISTRATION_OK:
		{
			[self.tabView removeTabViewItem:self.tabItemAuthentication];
			if(![[self.tabView tabViewItems] containsObject:self.tabItemContacts]){
				[self.tabView addTabViewItem:self.tabItemContacts];
			}
			if(![[self.tabView tabViewItems] containsObject:self.tabItemHistory]){
				[self.tabView addTabViewItem:self.tabItemHistory];
			}
			
			[self.menuItemHistoryClear setEnabled:YES];
			break;
		}
		case UNREGISTRATION_OK:
		case REGISTRATION_NOK:
		{
			if(![[self.tabView tabViewItems] containsObject:self.tabItemAuthentication]){
				[self.tabView addTabViewItem:self.tabItemAuthentication];
			}
			[self.tabView removeTabViewItem:self.tabItemContacts];
			[self.tabView removeTabViewItem:self.tabItemHistory];
			
			[self.menuItemHistoryClear setEnabled:NO];
			break;
		}
			
		default:
		{
		}
	}
}

-(void) onMessagingEvent:(NSNotification*)notification
{
}

-(void) onInviteEvent:(NSNotification*)notification {
	NgnInviteEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case INVITE_EVENT_INCOMING:
		{
			NgnAVSession* incomingSession = [[NgnAVSession getSessionWithId:eargs.sessionId] retain];

			[UICall receiveIncomingCall:incomingSession];
			
			[NgnAVSession releaseSession:&incomingSession];
			break;
		}
			
		case INVITE_EVENT_MEDIA_UPDATED:
		{
			NgnAVSession* session = [[NgnAVSession getSessionWithId:eargs.sessionId] retain];
			if(session){
				
			}
			[NgnAVSession releaseSession:&session];
			break;
		}
			
		default:
		{
			break;
		}
	}
}

@end

//
// default implementation
//
@implementation idoubs2AppDelegate

@synthesize window;
@synthesize tabView;
@synthesize textFieldDisplayName;

@synthesize menuItemPreferences;
@synthesize menuItemHistoryClear;

#pragma mark -
#pragma mark NSApplicationDelegate methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	[self.window setBackgroundColor:[NSColor whiteColor]];
	
	// add observers
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onNetworkEvent:) name:kNgnNetworkEventArgs_Name object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onNativeContactEvent:) name:kNgnContactEventArgs_Name object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onStackEvent:) name:kNgnStackEventArgs_Name object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onRegistrationEvent:) name:kNgnRegistrationEventArgs_Name object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onInviteEvent:) name:kNgnInviteEventArgs_Name object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onMessagingEvent:) name:kNgnMessagingEventArgs_Name object:nil];
	
	// start the engine
	[[NgnEngine sharedInstance] start];
	
	// add tabs and update ui
	[self.tabView addTabViewItem:self.tabItemAuthentication];
	[self.textFieldDisplayName setStringValue:[[NgnEngine sharedInstance].configurationService getStringWithKey:IDENTITY_DISPLAY_NAME]];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag 
{
	[window makeKeyAndOrderFront:self];
	
	return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[[NgnEngine sharedInstance] stop];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (IBAction)onMenuItemClick:(id)sender
{
	if(sender == self.menuItemPreferences){
		UIPreferences* uiPreferences = [[UIPreferences alloc] initWithWindowNibName:@"UIPreferences"];
		[uiPreferences showWindow:uiPreferences];
	}
	else if(sender == self.menuItemHistoryClear){
		[[NgnEngine sharedInstance].historyService clear];
	}
}

+(idoubs2AppDelegate*)sharedInstance
{
	return (idoubs2AppDelegate*)[NSApplication sharedApplication];
}
			
-(UITabViewItem *)tabItemAuthentication
{
	if(!self->tabItemAuthentication){
		self->tabItemAuthentication = [(UITabViewItem*)[UITabViewItem alloc] initWithType:UITabViewItemType_Authentication];
	}
	return self->tabItemAuthentication;
}

-(UITabViewItem *)tabItemHistory
{
	if(!self->tabItemHistory){
		self->tabItemHistory = [(UITabViewItem*)[UITabViewItem alloc] initWithType:UITabViewItemType_History];
	}
	return self->tabItemHistory;
}
			 
-(UITabViewItem *)tabItemContacts
{
	if(!self->tabItemContacts){
		self->tabItemContacts = [(UITabViewItem*)[UITabViewItem alloc] initWithType:UITabViewItemType_Contacts];
	}
	return self->tabItemContacts;
}
			 
- (void)dealloc{

	[self.tabItemHistory release];
	[self.tabItemContacts release];
	
	[super dealloc];
}

@end
