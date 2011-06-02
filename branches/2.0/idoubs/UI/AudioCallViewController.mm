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
#import "AudioCallViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "idoubs2AppDelegate.h"
#import "idoubs2Constants.h"

/*=== AudioCallViewController (Private) ===*/
@interface AudioCallViewController(Private)
+(void) applyGradienWithColors: (NSArray*)colors forView: (UIView*)view_ withBorder:(BOOL)border;
-(void) closeView;
-(void) updateViewAndState;
@end
/*=== AudioCallViewController (Timers) ===*/
@interface AudioCallViewController (Timers)
-(void)timerInCallTick:(NSTimer*)timer;
-(void)timerSuicideTick:(NSTimer*)timer;

@end
/*=== AudioCallViewController (SipCallbackEvents) ===*/
@interface AudioCallViewController(SipCallbackEvents)
-(void) onInviteEvent:(NSNotification*)notification;
@end


//
//	AudioCallViewController(Private)
//
@implementation AudioCallViewController(Private)

+(void) applyGradienWithColors: (NSArray*)colors forView: (UIView*)view_ withBorder:(BOOL)border{
	for(CALayer *ly in view_.layer.sublayers){
		if([ly isKindOfClass: [CAGradientLayer class]]){
			[ly removeFromSuperlayer];
			break;
		}
	}
	
	if(colors){
		CAGradientLayer *gradient = [CAGradientLayer layer];
		gradient.colors = colors;
		gradient.frame = CGRectMake(0.f, 0.f, view_.frame.size.width, view_.frame.size.height);
		if(border){
			gradient.cornerRadius = 8.f;
			gradient.borderWidth = 2.f;
			gradient.borderColor = [[UIColor grayColor] CGColor];
		}
		
		view_.backgroundColor = [UIColor clearColor];
		[view_.layer insertSublayer:gradient atIndex:0];
	}
}

-(void) closeView{
	[[idoubs2AppDelegate sharedInstance].tabBarController dismissModalViewControllerAnimated: NO];
}

-(void) updateViewAndState{
	if(audioSession){
		switch (audioSession.state) {
			case INVITE_STATE_INPROGRESS:
			{
				labelStatus.text = @"Calling...";
				
				buttonAccept.hidden = YES;
				
				[buttonHangup setTitle:@"End" forState:kButtonStateAll];
				buttonHangup.hidden = NO;
				buttonHangup.frame = CGRectMake(buttonHangup.frame.origin.x, buttonHangup.frame.origin.y, 
												buttonAcceptWidth + buttonHangupWidth, buttonHangup.frame.size.height);
				break;
			}
			case INVITE_STATE_INCOMING:
			{
				labelStatus.text = @"Incoming call...";
				
				[buttonAccept setTitle:@"Accept" forState:kButtonStateAll];
				buttonAccept.hidden = NO;
				buttonAccept.frame = CGRectMake(buttonAccept.frame.origin.x, buttonAccept.frame.origin.y, 
												buttonAcceptWidth, buttonAccept.frame.size.height);
				
				[buttonHangup setTitle:@"End" forState:kButtonStateAll];
				buttonHangup.hidden = NO;
				buttonHangup.frame = CGRectMake(buttonHangup.frame.origin.x, buttonHangup.frame.origin.y, 
												buttonHangupWidth, buttonHangup.frame.size.height);
				
				[[NgnEngine getInstance].soundService playRingTone];
				
				break;
			}
			case INVITE_STATE_REMOTE_RINGING:
			{
				labelStatus.text = @"Remote is ringing";
				
				buttonAccept.hidden = YES;
				buttonAccept.frame = CGRectMake(buttonAccept.frame.origin.x, buttonAccept.frame.origin.y, 
												buttonAcceptWidth, buttonAccept.frame.size.height);
				
				[buttonHangup setTitle:@"End" forState:kButtonStateAll];
				buttonHangup.hidden = NO;
				buttonHangup.frame = CGRectMake(buttonHangup.frame.origin.x, buttonHangup.frame.origin.y, 
												buttonHangupWidth + buttonHangupWidth, buttonHangup.frame.size.height);
				
				[[NgnEngine getInstance].soundService playRingBackTone];
				break;
			}
			case INVITE_STATE_INCALL:
			{
				self.labelStatus.text = @"In Call";
				
				self.buttonAccept.hidden = YES;
				
				[self.buttonHangup setTitle:@"End" forState:kButtonStateAll];
				self.buttonHangup.hidden = NO;
				self.buttonHangup.frame = CGRectMake(self.buttonHangup.frame.origin.x, self.buttonHangup.frame.origin.y, 
												buttonHangupWidth + buttonHangupWidth, self.buttonHangup.frame.size.height);
				
				[[NgnEngine getInstance].soundService stopRingBackTone];
				[[NgnEngine getInstance].soundService stopRingTone];
				break;
			}
			case INVITE_STATE_TERMINATED:
			case INVITE_STATE_TERMINATING:
			{
				self.labelStatus.text = @"Terminating...";
				
				self.buttonAccept.hidden = YES;
				self.buttonHangup.hidden = YES;
				
				[[NgnEngine getInstance].soundService stopRingBackTone];
				[[NgnEngine getInstance].soundService stopRingTone];
				break;
			}
			default:
				break;
		}
		
		[AudioCallViewController applyGradienWithColors: [[NgnEngine getInstance].soundService isSpeakerEnabled] ? kColorsBlue : nil
												forView:self.buttonSpeaker withBorder:NO];
		[AudioCallViewController applyGradienWithColors: [audioSession isLocalHeld] ? kColorsBlue : nil
												forView:self.buttonHold withBorder:NO];
		[AudioCallViewController applyGradienWithColors: [audioSession isMuted] ? kColorsBlue : nil
												forView:self.buttonMute withBorder:NO];
	}
}

@end


//
// AudioCallViewController (SipCallbackEvents)
//
@implementation AudioCallViewController(SipCallbackEvents)

-(void) onInviteEvent:(NSNotification*)notification {
	NgnInviteEventArgs* eargs = [notification object];
	
	if(!audioSession || audioSession.id != eargs.sessionId){
		return;
	}
	
	switch (eargs.eventType) {
		case INVITE_EVENT_INPROGRESS:
		case INVITE_EVENT_INCOMING:
		case INVITE_EVENT_RINGING:
		case INVITE_EVENT_LOCAL_HOLD_OK:
		case INVITE_EVENT_REMOTE_HOLD:
		default:
		{
			// updates view and state
			[self updateViewAndState];
			break;
		}

		case INVITE_EVENT_TERMINATED:
		case INVITE_EVENT_TERMWAIT:
		{
			// updates view and state
			[self updateViewAndState];
			// releases session
			[NgnAVSession releaseSession: &audioSession];
			// starts timer suicide
			[NSTimer scheduledTimerWithTimeInterval: kCallTimerSuicide
				target: self 
				selector: @selector(timerSuicideTick:) 
				userInfo: nil 
				repeats: NO];
			break;
		}
	}
}

@end


//
// AudioCallViewController (Timers)
//
@implementation AudioCallViewController (Timers)

-(void)timerInCallTick:(NSTimer*)timer{
	// to be implemented for the call time display
}

-(void)timerSuicideTick:(NSTimer*)timer{
	[self closeView];
}

@end

//
//	AudioCallViewController
//
@implementation AudioCallViewController

@synthesize buttonHangup;
@synthesize buttonAccept;
@synthesize buttonMute;
@synthesize buttonNumpad;
@synthesize buttonSpeaker;
@synthesize buttonHold;
@synthesize labelStatus;
@synthesize labelRemoteParty;
@synthesize viewOptions;
@synthesize viewNumpad;
@synthesize viewCenter;
@synthesize viewTop;
@synthesize viewBottom;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		
		self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	buttonHangup.layer.cornerRadius = buttonAccept.layer.cornerRadius = 10;
	buttonHangup.layer.borderWidth = buttonAccept.layer.borderWidth = 2.f;
	buttonHangup.layer.borderColor = buttonAccept.layer.borderColor = [[UIColor grayColor] CGColor];
	
	buttonAcceptWidth = buttonAccept.frame.size.width;
	buttonHangupWidth = buttonHangup.frame.size.width;
	
	[self.viewCenter addSubview:viewOptions];
	
	
	// apply gradients
	[AudioCallViewController applyGradienWithColors:kColorsLightBlack forView:self.viewOptions withBorder:YES];
	[AudioCallViewController applyGradienWithColors:kColorsDarkBlack forView:self.viewTop withBorder:NO];
	[AudioCallViewController applyGradienWithColors:kColorsLightBlack forView:self.viewBottom withBorder:NO];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onInviteEvent:) name:kNgnInviteEventArgs_Name object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
	[audioSession release];
	audioSession = [[NgnAVSession getSessionWithId: self.sessionId] retain];
	if(audioSession){
		labelRemoteParty.text = (audioSession.historyEvent && audioSession.historyEvent.remoteParty) ?
		audioSession.historyEvent.remoteParty : (audioSession.remotePartyUri ? audioSession.remotePartyUri : [NgnStringUtils nullValue]);
		
		[self updateViewAndState];
	}
}

- (void)viewWillDisappear:(BOOL)animated{
	[NgnAVSession releaseSession: &audioSession];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction) onButtonClick: (id)sender{
	if(audioSession){
		if(sender == buttonHangup){
			[audioSession hangUpCall];
		}
		else if(sender == buttonAccept) {
			[audioSession acceptCall];
		}
		else if(sender == buttonMute){
			if([audioSession setMute:![audioSession isMuted]]){
				[AudioCallViewController applyGradienWithColors: [audioSession isMuted] ? kColorsBlue : nil
													forView:self.buttonMute withBorder:NO];
			}
		}
		else if(sender == buttonSpeaker){
			if([[NgnEngine getInstance].soundService setSpeakerEnabled:![[NgnEngine getInstance].soundService isSpeakerEnabled]]){
				[AudioCallViewController applyGradienWithColors: [[NgnEngine getInstance].soundService isSpeakerEnabled] ? kColorsBlue : nil
													forView:self.buttonSpeaker withBorder:NO];
			}
		}
		else if(sender == buttonHold){
			[audioSession toggleHoldResume];
		}
		else if(sender == buttonNumpad){
			for(UIView *view in self.viewCenter.subviews){
				// [view removeFromSuperview];
			}
			// [self.viewCenter addSubview: self.viewNumpad];
		}
	}
}

- (void)dealloc {	
	[labelStatus release];
	[labelRemoteParty release];
	[buttonHangup release];
	[buttonAccept release];
	[buttonAccept release];
	[buttonMute release];
	[buttonNumpad release];
	[buttonSpeaker release];
	[buttonHold release];
	[viewCenter release];
	[viewTop release];
	[viewBottom release];
	[viewNumpad release];
	[viewOptions release];
	
    [super dealloc];
}


@end
