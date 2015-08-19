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
#import "UICall.h"
#import "idoubs2AppDelegate.h"

#import <QuartzCore/QuartzCore.h>

//
// private implementation
//

@interface UICall(Private)
+(CGColorRef)whiteColor;
+(NSImage*)imageHangUp;
+(NSImage*)imageMakeCall;
+(NSImage*)imageHoldCall;
+(NSImage*)imageResumeCall;
-(void)updateStateAndView;
-(void)onWindowClosed:(NSNotification*)notification;
-(void)timerInCallTick:(NSTimer*)timer;
-(void)onInviteEvent:(NSNotification*)notification;
@end

@implementation UICall(Private)

+(CGColorRef)whiteColor
{
	static CGColorRef white = NULL;
	static CGColorSpaceRef space = NULL;
	if(!space) {
		space = CGColorSpaceCreateWithName (kCGColorSpaceGenericRGB);
	}
	if(!white) {
		CGFloat values[4] = {1.0, 1.0, 1.0, 1.0};
		white = CGColorCreate(space, values);
	}
	return white;
}


+(NSImage*)imageHangUp
{
	static NSImage *image = nil;
	if(!image){
		image = [[NSImage imageNamed:@"phone_hang_up_32"] retain];
	}
	return image;
}

+(NSImage*)imageMakeCall
{
	static NSImage *image = nil;
	if(!image){
		image = [[NSImage imageNamed:@"phone_pick_up_32"] retain];
	}	
	return image;
}

+(NSImage*)imageHoldCall
{
	static NSImage *image = nil;
	if(!image){
		image = [[NSImage imageNamed:@"call_hold_32"] retain];
	}	
	return image;
}

+(NSImage*)imageResumeCall
{
	static NSImage *image = nil;
	if(!image){
		image = [[NSImage imageNamed:@"call_resume_32"] retain];
	}	
	return image;
}

-(void)updateStateAndView
{
	if(self.avSession){
		switch (self.avSession.state) {
			case INVITE_STATE_INCOMING:
			{
				self->dateSeconds = 0.0;
				[self.textFieldDuration setStringValue:@"00:00"];
				bool isVideoCall = isVideoType(self.avSession.mediaType);
				[self.textFieldStatus setStringValue:[@"Incoming " stringByAppendingFormat:@"%@ Call from '%@'", (isVideoCall ? @"Video" : @"Audio"), self.avSession.remotePartyDisplayName]];
				
				[self.buttonEndCall setTitle:@"Answer"];
				[self.buttonEndCall setImage:[UICall imageMakeCall]];
				
				[self.buttonHoldResume setEnabled:NO];
				[self.buttonStartVideo setEnabled:NO];
				
				[[NgnEngine sharedInstance].soundService playRingTone];
				
				break;
			}
				
			case INVITE_STATE_INPROGRESS:
			{
				self->dateSeconds = 0.0;
				[self.textFieldDuration setStringValue:@"00:00"];
				[self.textFieldStatus setStringValue:@"In progress..."];
				
				[self.buttonEndCall setTitle:@"End Call"];
				[self.buttonEndCall setImage:[UICall imageHangUp]];
				
				[self.buttonHoldResume setEnabled:NO];
				[self.buttonStartVideo setEnabled:NO];
				
				[[NgnEngine sharedInstance].soundService playRingBackTone];
				
				break;
			}
				
			case INVITE_STATE_REMOTE_RINGING:
			{
				[self.textFieldStatus setStringValue:@"Remote is ringing..."];
				
				[self.buttonEndCall setTitle:@"End Call"];
				[self.buttonEndCall setImage:[UICall imageHangUp]];
				
				[self.buttonHoldResume setEnabled:NO];
				
				[[NgnEngine sharedInstance].soundService playRingBackTone];
				
				break;
			}
				
			case INVITE_STATE_INCALL:
			case INVITE_STATE_EARLY_MEDIA:
			{
				if(self.avSession.state == INVITE_STATE_EARLY_MEDIA){
					[self.textFieldStatus setStringValue:@"Early Media..."];
					
					[self.buttonHoldResume setEnabled:NO];
					[self.buttonStartVideo setEnabled:NO];
				}
				else if(self.avSession.state == INVITE_STATE_INCALL){
					[self.textFieldStatus setStringValue:@"In Call"];
					self->timerInCall = [NSTimer scheduledTimerWithTimeInterval:1.0
																		 target:self 
																	   selector:@selector(timerInCallTick:) 
																	   userInfo:nil 
																		repeats:YES];
					
					[self.buttonEndCall setTitle:@"End Call"];
					[self.buttonEndCall setImage:[UICall imageHangUp]];
					
					[self.buttonHoldResume setEnabled:YES];
					[self.buttonStartVideo setEnabled:YES];
				}
				if(isVideoType(self.avSession.mediaType)){
					[self.avSession setRemoteVideoDisplay:self.videoViewRemote];
					[self.avSession setLocalVideoDisplay:self.videoViewLocal];
					[self.buttonStartVideo setTitle:@"Stop Video"];
				}
				else {
					[self.buttonStartVideo setTitle:@"Start Video"];
				}

				
				[[NgnEngine sharedInstance].soundService stopRingTone];
				[[NgnEngine sharedInstance].soundService stopRingBackTone];
				
				break;
			}
				
			case INVITE_STATE_TERMINATED:
			case INVITE_STATE_TERMINATING:
			{
				[NgnAVSession releaseSession:&self->avSession];
				
				[[self window] setTitle:@"---"];
				
				[self.textFieldStatus setStringValue:@"Terminated"];
				
				[self->timerInCall invalidate], self->timerInCall = nil;
				
				[self.buttonEndCall setTitle:@"Make Call"];
				[self.buttonEndCall setImage:[UICall imageMakeCall]];
				
				[self.buttonHoldResume setTitle:@"Hold Call"];
				[self.buttonHoldResume setImage:[UICall imageHoldCall]];
				
				[self.buttonHoldResume setEnabled:NO];
				[self.buttonStartVideo setEnabled:NO];
				
				[self.videoViewRemote clear];
				
				[[NgnEngine sharedInstance].soundService stopRingTone];
				[[NgnEngine sharedInstance].soundService stopRingBackTone];
				
				break;
			}
				
			default:
			{
				break;
			}
		}
	}
}

-(void)onWindowClosed:(NSNotification*)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	if(self.avSession && self.avSession.active){
		[[NgnEngine sharedInstance].soundService stopRingTone];
		[[NgnEngine sharedInstance].soundService stopRingBackTone];
		
		[self.avSession hangUpCall];
	}
	[self autorelease];
}

-(void)timerInCallTick:(NSTimer*)timer
{
	self->dateSeconds++;
	NSDate* date = [NSDate dateWithTimeIntervalSinceReferenceDate:self->dateSeconds];       
	[self.textFieldDuration setStringValue:[[NgnDateTimeUtils historyEventDuration] stringFromDate:date]];
}

-(void)onInviteEvent:(NSNotification*)notification
{
	NgnInviteEventArgs* eargs = [notification object];
	
	if(!self.avSession || self.avSession.id != eargs.sessionId){
		return;
	}
	
	switch (eargs.eventType) {
		case INVITE_EVENT_INCOMING:			
		case INVITE_EVENT_INPROGRESS:			
		case INVITE_EVENT_RINGING:
		case INVITE_EVENT_CONNECTED:
		case INVITE_EVENT_EARLY_MEDIA:
		case INVITE_EVENT_TERMINATED:
		case INVITE_EVENT_TERMWAIT:
		{
			[self updateStateAndView];
			
			break;
		}
			
		case INVITE_EVENT_MEDIA_UPDATING:
		{
			[self.textFieldStatus setStringValue:@"Trying to update session..."];
			break;
		}
			
		case INVITE_EVENT_MEDIA_UPDATED:
		{
			BOOL hasVideo = isVideoType(self.avSession.mediaType);
			[self.textFieldStatus setStringValue:[@"Media updated " stringByAppendingFormat:@"(%@)",hasVideo ? @"Video" : @"Audio"]];
			[self.videoViewRemote clear];
			
			if(hasVideo){
				[self.avSession setRemoteVideoDisplay:self.videoViewRemote];
				[self.avSession setLocalVideoDisplay:self.videoViewLocal];
				[self.buttonStartVideo setTitle:@"Stop Video"];
			}
			else {
				[self.buttonStartVideo setTitle:@"Start Video"];
			}
			
			break;
		}
			
		case INVITE_EVENT_LOCAL_HOLD_OK:
		{
			[self.textFieldStatus setStringValue:@"Call placed on hold"];
			[self.buttonHoldResume setTitle:@"Resume Call"];
			[self.buttonHoldResume setImage:[UICall imageResumeCall]];
			[self.buttonStartVideo setEnabled:NO];
			
			if(isVideoType(self.avSession.mediaType)){
				[self.avSession setLocalVideoDisplay:nil];
			}
			
			break;
		}
		case INVITE_EVENT_LOCAL_HOLD_NOK:
		{
			[self.textFieldStatus setStringValue:@"Failed to place remote party on hold"];
			
			break;
		}
		case INVITE_EVENT_LOCAL_RESUME_OK:
		{
			[self.textFieldStatus setStringValue:@"Call taken off hold"];
			[self.buttonHoldResume setTitle:@"Hold Call"];
			[self.buttonHoldResume setImage:[UICall imageHoldCall]];
			[self.buttonStartVideo setEnabled:YES];
			
			if(isVideoType(self.avSession.mediaType)){
				[self.avSession setLocalVideoDisplay:self.videoViewLocal];
			}
			
			break;
		}
		case INVITE_EVENT_LOCAL_RESUME_NOK:
		{
			[self.textFieldStatus setStringValue:@"Failed to unhold call"];
			
			break;
		}
		case INVITE_EVENT_REMOTE_HOLD:
		{
			[self.textFieldStatus setStringValue:@"Placed on hold by remote party"];
			
			break;
		}
			
		case INVITE_EVENT_REMOTE_RESUME:
		{
			[self.textFieldStatus setStringValue:@"Taken off hold by remote party"];
			
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

@implementation UICall

@synthesize videoViewRemote;
@synthesize videoViewLocal;
@synthesize buttonEndCall;
@synthesize textFieldDuration;
@synthesize textFieldStatus;
@synthesize buttonHoldResume;
@synthesize buttonStartVideo;

-(UICall*) initWithSession:(NgnAVSession*)avSession_
{
	if((self = [super init])){
		self->avSession = [avSession_ retain];
	}
	return self;
}

- (void)loadWindow
{
	[super loadWindow];
	
	//[[self window] setBackgroundColor:[NSColor whiteColor]];
	
	[self updateStateAndView];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onWindowClosed:) name:NSWindowWillCloseNotification object:[self window]];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onInviteEvent:) name:kNgnInviteEventArgs_Name object:nil];
}

-(NgnAVSession *)avSession
{
	return self->avSession;
}

- (IBAction)onButtonClick: (id)sender
{
	if(sender == self.buttonEndCall){
		if(self.avSession){
			if(self.avSession.state == INVITE_STATE_INCOMING){
				[self.avSession acceptCall];
			}
			else {
				[self.avSession hangUpCall];
			}
		}
		else if(self->remotePartyUri){
			NgnAVSession* session = [[NgnAVSession makeAudioVideoCallWithRemoteParty:self->remotePartyUri
																		 andSipStack:[[NgnEngine sharedInstance].sipService getSipStack]] retain];
			if(session){
				self.avSession = session;
				[NgnAVSession releaseSession:&session];
			}
		}
	}
	else if(sender == self.buttonHoldResume){
		if(self.avSession && self.avSession.active){
			[self.avSession toggleHoldResume];
		}
	}
	else if(sender == self.buttonStartVideo){
		if(self.avSession && self.avSession.connected){
			if(isVideoType(self.avSession.mediaType)){
				[self.avSession updateSession:MediaType_Audio];
			}
			else {
				[self.avSession updateSession:MediaType_AudioVideo];
			}
		}
	}


	//else if(sender == self.buttonFullScreen){
	//	if(self.avSession && [self.avSession isActive]){
	//		[self.videoViewRemote setFullScreen:YES];
	//	}
	//}
}

-(void)setAVSession:(NgnAVSession *)avSession_
{
	if(self->avSession){
		[NgnAVSession releaseSession:&self->avSession];
	}
	if((self->avSession = [avSession_ retain])){
		[[self window] setTitle:[NSString stringWithFormat:@"Talking with [%@]", self.avSession.remotePartyDisplayName]];
		if(![NgnStringUtils isNullOrEmpty:self.avSession.remotePartyUri]){
			[self->remotePartyUri release];
			self->remotePartyUri = [self.avSession.remotePartyUri retain];
		}
	}
}

+(BOOL) makeAudioCallWithRemoteParty:(NSString*)remoteUri andSipStack:(NgnSipStack*)sipStack
{
	if(![NgnStringUtils isNullOrEmpty:remoteUri]){
		NgnAVSession* audioSession = [[NgnAVSession makeAudioCallWithRemoteParty:remoteUri
																	 andSipStack:[[NgnEngine sharedInstance].sipService getSipStack]] retain];
		if(audioSession){
			UICall *uiCall = [[UICall alloc] initWithWindowNibName:@"UICall"];
			uiCall.avSession = audioSession;
			[uiCall showWindow:uiCall];
			
			[NgnAVSession releaseSession:&audioSession];
			return YES;
		}
	}
	return NO;	
}

+(BOOL) makeAudioVideoCallWithRemoteParty:(NSString*)remoteUri andSipStack:(NgnSipStack*)sipStack
{
	if(![NgnStringUtils isNullOrEmpty:remoteUri]){
		NgnAVSession* audioVideoSession = [[NgnAVSession makeAudioVideoCallWithRemoteParty:remoteUri
																	 andSipStack:[[NgnEngine sharedInstance].sipService getSipStack]] retain];
		if(audioVideoSession){
			UICall *uiCall = [[UICall alloc] initWithWindowNibName:@"UICall"];
			uiCall.avSession = audioVideoSession;
			[uiCall showWindow:uiCall];
			
			[NgnAVSession releaseSession:&audioVideoSession];
			return YES;
		}
	}
	return NO;	
}

+(BOOL) receiveIncomingCall:(NgnAVSession*)session
{
	if(session){
		UICall *uiCall = [[UICall alloc] initWithWindowNibName:@"UICall"];
		uiCall.avSession = session;
		[uiCall showWindow:uiCall];
	}
	return NO;
}

-(void)dealloc
{
	if(self.avSession){
		[NgnAVSession releaseSession:&self->avSession];
	}
	if(self->timerInCall){
		[self->timerInCall invalidate], self->timerInCall = nil;
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self->remotePartyUri release];
	
	[super dealloc];
}

@end
