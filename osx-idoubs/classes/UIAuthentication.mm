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
#import "UIAuthentication.h"

#import "OSXNgnStack.h"

@interface UIAuthentication(Private)
-(void) onRegistrationEvent:(NSNotification*)notification;
-(void)loadValues;
@end

@implementation UIAuthentication(Private)

-(void)loadValues
{
	[self.textFieldDisplayName setStringValue:[[NgnEngine sharedInstance].configurationService getStringWithKey:IDENTITY_DISPLAY_NAME]];
	[self.textFieldPrivateId setStringValue:[[NgnEngine sharedInstance].configurationService getStringWithKey:IDENTITY_IMPI]];
	[self.textFieldPublicId setStringValue:[[NgnEngine sharedInstance].configurationService getStringWithKey:IDENTITY_IMPU]];
	[self.textFieldPassword setStringValue:[[NgnEngine sharedInstance].configurationService getStringWithKey:IDENTITY_PASSWORD]];
	[self.textFieldRealm setStringValue:[[NgnEngine sharedInstance].configurationService getStringWithKey:NETWORK_REALM]];
	[self.checkBoxEarlyIMS setState:[[NgnEngine sharedInstance].configurationService getBoolWithKey:NETWORK_USE_EARLY_IMS] ? NSOnState : NSOffState];
}

-(void) onRegistrationEvent:(NSNotification*)notification
{
	NgnRegistrationEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case REGISTRATION_OK:
		case REGISTRATION_NOK:
		case UNREGISTRATION_NOK:
		case UNREGISTRATION_OK:
		{
			[self.progressIndicator stopAnimation:self];
			[self.buttonSignIn setTitle:@"Sign In"];
			break;
		}
		case REGISTRATION_INPROGRESS:
		case UNREGISTRATION_INPROGRESS:	
		default:
		{
			[self.progressIndicator startAnimation:self];
			[self.buttonSignIn setTitle:@"Cancel"];
			break;
		}
	}
}

@end

@implementation UIAuthentication

@synthesize textFieldDisplayName;
@synthesize textFieldPublicId;
@synthesize textFieldPrivateId;
@synthesize textFieldPassword;
@synthesize textFieldRealm;
@synthesize checkBoxEarlyIMS;
@synthesize buttonSignIn;
@synthesize progressIndicator;

- (void)loadView
{
	[super loadView];
	
	[self loadValues];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onRegistrationEvent:) name:kNgnRegistrationEventArgs_Name object:nil];
}


- (IBAction)onButtonClick:(id)sender
{
	if(sender == self.buttonSignIn){
		switch ([NgnEngine sharedInstance].sipService.registrationState) {
			case CONN_STATE_NONE:
			case CONN_STATE_TERMINATED:
			{
				[[NgnEngine sharedInstance].configurationService setStringWithKey:IDENTITY_DISPLAY_NAME andValue:[self.textFieldDisplayName stringValue]];
				[[NgnEngine sharedInstance].configurationService setStringWithKey:IDENTITY_IMPI andValue:[self.textFieldPrivateId stringValue]];
				[[NgnEngine sharedInstance].configurationService setStringWithKey:IDENTITY_IMPU andValue:[self.textFieldPublicId stringValue]];
				[[NgnEngine sharedInstance].configurationService setStringWithKey:IDENTITY_PASSWORD andValue:[self.textFieldPassword stringValue]];
				[[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_REALM andValue:[self.textFieldRealm stringValue]];
				[[NgnEngine sharedInstance].configurationService setBoolWithKey:NETWORK_USE_EARLY_IMS andValue:[self.checkBoxEarlyIMS state]==NSOnState];
				
				[[NgnEngine sharedInstance].configurationService synchronize];
				[[NgnEngine sharedInstance].sipService registerIdentity];
				
				break;
			}
			case CONN_STATE_CONNECTED:
			case CONN_STATE_CONNECTING:
			case CONN_STATE_TERMINATING:
			default:
			{
				[[NgnEngine sharedInstance].sipService stopStackSynchronously];
				break;
			}
		}				
	}
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
