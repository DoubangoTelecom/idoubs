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
-(void) animateViewCenter;
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

// private properties
@interface AudioCallViewController()
@property(nonatomic) BOOL numpadIsVisible;
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
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

-(void) updateViewAndState{
	if(audioSession){
		switch (audioSession.state) {
			case INVITE_STATE_INPROGRESS:
			{
				self.labelStatus.text = @"Calling...";
				
				self.buttonAccept.hidden = YES;
				
				self.buttonHideNumpad.hidden = !self->numpadIsVisible;
				
				[self.buttonHangup setTitle:@"End" forState:kButtonStateAll];
				self.buttonHangup.hidden = NO;
				CGFloat pad = self.buttonHideNumpad.hidden ? self->bottomButtonsPadding : self->bottomButtonsPadding/2;
				self.buttonHangup.frame = CGRectMake(self.buttonHangup.frame.origin.x, 
													 self.buttonHangup.frame.origin.y, 
													 self.buttonHideNumpad.hidden ? 
														(self.viewBottom.frame.size.width - (2*pad)) : (self.viewBottom.frame.size.width/2) - (pad + pad/2),
													 self.buttonHangup.frame.size.height);
				break;
			}
			case INVITE_STATE_INCOMING:
			{
				self.labelStatus.text = @"Incoming call...";
				
				CGFloat pad = self->bottomButtonsPadding;
				
				self.numpadIsVisible = NO;
				[self.buttonHangup setTitle:@"End" forState:kButtonStateAll];
				self.buttonHangup.hidden = NO;
				self.buttonHangup.frame = CGRectMake(pad/2,
													 self.buttonHangup.frame.origin.y, 
													 self.viewBottom.frame.size.width/2 - pad, 
													 self.buttonHangup.frame.size.height);
				
				[self.buttonAccept setTitle:@"Accept" forState:kButtonStateAll];
				self.buttonAccept.hidden = NO;
				self.buttonAccept.frame = CGRectMake(pad/2 + self.buttonHangup.frame.size.width + pad/2, 
												self.buttonAccept.frame.origin.y, 
												self.buttonHangup.frame.size.width, 
												self.buttonAccept.frame.size.height);
				
				[[NgnEngine getInstance].soundService playRingTone];
				
				break;
			}
			case INVITE_STATE_REMOTE_RINGING:
			{
				self.labelStatus.text = @"Remote is ringing";
				
				self.buttonAccept.hidden = YES;
				self.buttonHideNumpad.hidden = !self->numpadIsVisible;
				
				[self.buttonHangup setTitle:@"End" forState:kButtonStateAll];
				self.buttonHangup.hidden = NO;
				CGFloat pad = self.buttonHideNumpad.hidden ? self->bottomButtonsPadding : self->bottomButtonsPadding/2;
				self.buttonHangup.frame = CGRectMake(self.buttonHangup.frame.origin.x, 
													 self.buttonHangup.frame.origin.y, 
													 self.buttonHideNumpad.hidden ? 
													 (self.viewBottom.frame.size.width - (2*pad)) : (self.viewBottom.frame.size.width/2) - (pad + pad/2),
													 self.buttonHangup.frame.size.height);
				
				[[NgnEngine getInstance].soundService playRingBackTone];
				break;
			}
			case INVITE_STATE_INCALL:
			{
				self.labelStatus.text = @"In Call";
				
				self.buttonAccept.hidden = YES;
				self.buttonHideNumpad.hidden = !self->numpadIsVisible;
				
				[self.buttonHangup setTitle:@"End" forState:kButtonStateAll];
				self.buttonHangup.hidden = NO;
				CGFloat pad = self.buttonHideNumpad.hidden ? self->bottomButtonsPadding : self->bottomButtonsPadding/2;
				self.buttonHangup.frame = CGRectMake(self.buttonHangup.frame.origin.x, 
													 self.buttonHangup.frame.origin.y, 
													 self.buttonHideNumpad.hidden ? 
													 (self.viewBottom.frame.size.width - (2*pad)) : (self.viewBottom.frame.size.width/2) - (pad + pad/2),
													 self.buttonHangup.frame.size.height);
				
				
				
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
				self.buttonHideNumpad.hidden = YES;
				
				[[NgnEngine getInstance].soundService stopRingBackTone];
				[[NgnEngine getInstance].soundService stopRingTone];
				break;
			}
			default:
				break;
		}
		
		[AudioCallViewController applyGradienWithColors: [audioSession isSpeakerEnabled] ? kColorsBlue : nil
												forView:self.buttonSpeaker withBorder:NO];
		[AudioCallViewController applyGradienWithColors: [audioSession isLocalHeld] ? kColorsBlue : nil
												forView:self.buttonHold withBorder:NO];
		[AudioCallViewController applyGradienWithColors: [audioSession isMuted] ? kColorsBlue : nil
												forView:self.buttonMute withBorder:NO];
	}
}

-(void) animateViewCenter{
	[UIView beginAnimations:@"animateViewCenter" context:nil];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
						   forView:self.viewCenter
							 cache:YES];
	for(UIView *view in self.viewCenter.subviews){
		[view removeFromSuperview];
	}
	[self.viewCenter addSubview:numpadIsVisible ? self.viewNumpad : self.viewOptions];
	[UIView commitAnimations];
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
		
		// transilient events
		case INVITE_EVENT_MEDIA_UPDATING:
		{
			self.labelStatus.text = @"Updating...";
			break;
		}
		
		case INVITE_EVENT_MEDIA_UPDATED:
		{
			self.labelStatus.text = @"Updated";
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
@synthesize buttonHideNumpad;
@synthesize buttonMute;
@synthesize buttonNumpad;
@synthesize buttonSpeaker;
@synthesize buttonHold;
@synthesize buttonVideo;
@synthesize labelStatus;
@synthesize labelRemoteParty;
@synthesize viewOptions;
@synthesize viewNumpad;
@synthesize viewCenter;
@synthesize viewTop;
@synthesize viewBottom;

@synthesize numpadIsVisible;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		
		self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		self.modalPresentationStyle = UIModalPresentationFullScreen;
		
		numpadIsVisible = NO;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.buttonHangup.layer.cornerRadius = 
	self.buttonAccept.layer.cornerRadius = 
	self.buttonHideNumpad.layer.cornerRadius = 
	10;
	self.buttonHangup.layer.borderWidth = 
	self.buttonAccept.layer.borderWidth = 
	self.buttonHideNumpad.layer.borderWidth = 
	2.f;
	self.buttonHangup.layer.borderColor = 
	self.buttonAccept.layer.borderColor = 
	self.buttonHideNumpad.layer.borderColor = 
	[[UIColor grayColor] CGColor];
	
	self->numpadIsVisible = NO;
	self->bottomButtonsPadding = self.buttonHangup.frame.origin.x;
	[self.viewCenter addSubview:viewOptions];
	
	
	// apply gradients
	[AudioCallViewController applyGradienWithColors:kColorsLightBlack forView:self.viewOptions withBorder:YES];
	[AudioCallViewController applyGradienWithColors:kColorsLightBlack forView:self.viewNumpad withBorder:YES];
	[AudioCallViewController applyGradienWithColors:kColorsDarkBlack forView:self.viewTop withBorder:NO];
	[AudioCallViewController applyGradienWithColors:kColorsLightBlack forView:self.viewBottom withBorder:NO];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onInviteEvent:) name:kNgnInviteEventArgs_Name object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
	[audioSession release];
	audioSession = [[NgnAVSession getSessionWithId: self.sessionId] retain];
	if(audioSession){
		labelRemoteParty.text = (audioSession.historyEvent) ? audioSession.historyEvent.remotePartyDisplayName : [NgnStringUtils nullValue];
		[[NgnEngine getInstance].soundService setSpeakerEnabled:[audioSession isSpeakerEnabled]];
		[self updateViewAndState];
	}
}

-(void) viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	
	[UIDevice currentDevice].proximityMonitoringEnabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
	[NgnAVSession releaseSession: &audioSession];
	
	[UIDevice currentDevice].proximityMonitoringEnabled = NO;
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

-(void) setNumpadIsVisible:(BOOL)visible{
	self->numpadIsVisible = visible;
	self.buttonHideNumpad.hidden = !visible;
	[self animateViewCenter];
	if(visible){
		CGFloat pad = self->bottomButtonsPadding/2;
		self.buttonHangup.frame = CGRectMake(pad, 
											 self.buttonHangup.frame.origin.y, 
											 (self.viewBottom.frame.size.width/2) - (pad + pad/2), 
											 self.buttonHangup.frame.size.height);
		self.buttonHideNumpad.frame = CGRectMake(pad + self.buttonHangup.frame.size.width + pad/2 + 2.f, 
											 self.buttonHideNumpad.frame.origin.y, 
											 self.buttonHangup.frame.size.width, 
											 self.buttonHideNumpad.frame.size.height);
	}
	else {
		self.buttonHangup.frame = CGRectMake(self->bottomButtonsPadding, 
											 self.buttonHideNumpad.frame.origin.y, 
											 self.viewBottom.frame.size.width - (2*self->bottomButtonsPadding), 
											 self.buttonHangup.frame.size.height);
		
	}

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
			[audioSession setSpeakerEnabled:![audioSession isSpeakerEnabled]];
			if([[NgnEngine getInstance].soundService setSpeakerEnabled:[audioSession isSpeakerEnabled]]){
				[AudioCallViewController applyGradienWithColors: [audioSession isSpeakerEnabled] ? kColorsBlue : nil
													forView:self.buttonSpeaker withBorder:NO];
			}
		}
		else if(sender == buttonHold){
			[audioSession toggleHoldResume];
		}
		else if(sender == buttonVideo){
			// [audioSession updateSession:MediaType_AudioVideo];
		}

		else if(sender == buttonNumpad){
			self.numpadIsVisible = YES;
		}
		else if(sender == buttonHideNumpad){
			self.numpadIsVisible = NO;
		}
	}
}

- (IBAction) onButtonNumpadClick: (id)sender{
	if(audioSession){
		int tag = ((UIButton*)sender).tag;
		[audioSession sendDTMF:tag];
		[[NgnEngine getInstance].soundService playDtmf:tag];
	}
}

- (void)dealloc {	
	[labelStatus release];
	[labelRemoteParty release];
	[buttonHangup release];
	[buttonAccept release];
	[buttonHideNumpad release];
	[buttonMute release];
	[buttonNumpad release];
	[buttonSpeaker release];
	[buttonHold release];
	[buttonVideo release];
	[viewCenter release];
	[viewTop release];
	[viewBottom release];
	[viewNumpad release];
	[viewOptions release];
	
    [super dealloc];
}


@end
