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
#import "VideoCallViewController.h"

#import <QuartzCore/QuartzCore.h> /* cornerRadius... */

#import "idoubs2AppDelegate.h"
#import "idoubs2Constants.h"

#define degreesToRadian(x) (M_PI * (x) / 180.0)

/*=== VideoCallViewController (Private) ===*/
@interface VideoCallViewController(Private)
+(void) applyGradienWithColors: (NSArray*)colors forView: (UIView*)view_;
-(void) showBottomView: (UIView*)view_ shouldRefresh:(BOOL)refresh;
-(void) hideBottomView:(UIView*)view_;
-(void) updateViewAndState;
-(void) closeView;
-(void) updateVideoOrientation;
-(void) updateRemoteDeviceInfo;
-(void) sendDeviceInfo;
@end
/*=== VideoCallViewController (Timers) ===*/
@interface VideoCallViewController (Timers)
-(void)timerInCallTick:(NSTimer*)timer;
-(void)timerSuicideTick:(NSTimer*)timer;

@end
/*=== AudioCallViewController (SipCallbackEvents) ===*/
@interface VideoCallViewController(SipCallbackEvents)
-(void) onInviteEvent:(NSNotification*)notification;
@end

//
//	VideoCallViewController(Private)
//
@implementation VideoCallViewController(Private)

+(void) applyGradienWithColors: (NSArray*)colors forView: (UIView*)view_{
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
		
		view_.backgroundColor = [UIColor clearColor];
		[view_.layer insertSublayer:gradient atIndex:0];
	}
}

-(void) showBottomView: (UIView*)view_ shouldRefresh:(BOOL)refresh{
	if(!view_.superview){
		[self.view addSubview:view_];
		refresh = YES;
	}
	
	if(refresh){
		CGRect frame = CGRectMake(0.f, self.view.frame.size.height - view_.frame.size.height, 
								  self.view.frame.size.width, view_.frame.size.height);
		view_.frame = frame;
		[VideoCallViewController applyGradienWithColors:kColorsDarkBlack forView:view_];
		if(view_ == self.viewPickHangUp){
			// update content
		}
		else if(view_ == self.viewToolbar){
			// update content
			self.buttonToolBarVideo.selected = !self->sendingVideo;
			self.buttonToolBarMute.selected = [videoSession isMuted];
			
		}

	}
	view_.hidden = NO;
}

-(void) hideBottomView:(UIView*)view_{
	view_.hidden = YES;
}

-(void) updateViewAndState{
	if(videoSession){
		switch (videoSession.state) {
			case INVITE_STATE_INPROGRESS:
			{
				self.viewTop.hidden = NO;
				self.viewToolbar.hidden = NO;
				self.labelStatus.text = @"Video Call...";
				self.viewLocalVideo.hidden = YES;
				
				[self hideBottomView:self.viewToolbar];
				
				[self showBottomView:self.viewPickHangUp shouldRefresh:NO];
				self.buttonPick.hidden = YES;
				self.buttonHangUp.hidden = NO;
				self.buttonHangUp.frame = CGRectMake(self.buttonHangUp.frame.origin.x, 
													 self.buttonHangUp.frame.origin.y, 
													 self.viewPickHangUp.frame.size.width - (2* self.buttonHangUp.frame.origin.x), 
													 self.buttonHangUp.frame.size.height);
				[self.buttonHangUp setTitle:@"End" forState:UIControlStateNormal];
				
				self.imageSecure.hidden = ![videoSession isSecure];
				
				break;
			}
			case INVITE_STATE_INCOMING:
			{
				CGFloat pad = self.buttonHangUp.frame.origin.x/2;
				
				self.viewTop.hidden = NO;
				self.viewLocalVideo.hidden = YES;
				self.labelStatus.text = @"whould like Video Call...";
				
				[self hideBottomView:self.viewToolbar];
				
				[self showBottomView:self.viewPickHangUp shouldRefresh:NO];
				
				self.buttonHangUp.hidden = NO;
				self.buttonHangUp.frame = CGRectMake(pad, 
													 self.buttonHangUp.frame.origin.y, 
													 self.viewPickHangUp.frame.size.width/2 - (2*pad), 
													 self.buttonHangUp.frame.size.height);
				[self.buttonHangUp setTitle:@"Decline" forState:UIControlStateNormal];
				
				self.buttonPick.hidden = NO;
				[self.buttonPick setTitle:@"Accept" forState:UIControlStateNormal];
				self.buttonPick.frame = CGRectMake(pad + self.buttonHangUp.frame.size.width + pad +2.f, 
														self.buttonHangUp.frame.origin.y, 
														self.buttonHangUp.frame.size.width, 
														self.buttonHangUp.frame.size.height);
				
				
				self.imageSecure.hidden = ![videoSession isSecure];
				
				break;
			}
			case INVITE_STATE_REMOTE_RINGING:
			{
				self.viewTop.hidden = NO;
				self.viewLocalVideo.hidden = YES;
				self.labelStatus.text = @"Video Call...";
				
				[self hideBottomView:self.viewToolbar];
				
				[self showBottomView:self.viewPickHangUp shouldRefresh:NO];
				self.buttonPick.hidden = YES;
				self.buttonHangUp.hidden = NO;
				self.buttonHangUp.frame = CGRectMake(self.buttonHangUp.frame.origin.x, 
													 self.buttonHangUp.frame.origin.y, 
													 self.viewPickHangUp.frame.size.width - (2* self.buttonHangUp.frame.origin.x), 
													 self.buttonHangUp.frame.size.height);
				[self.buttonHangUp setTitle:@"End" forState:UIControlStateNormal];
				break;
			}
			case INVITE_STATE_INCALL:
			{
				self.viewTop.hidden = YES;
				self.viewLocalVideo.hidden = NO;
				
				[self showBottomView:self.viewToolbar shouldRefresh:NO];
				
				[self hideBottomView:self.viewPickHangUp];
				
				self.imageSecure.hidden = ![videoSession isSecure];
				
				[[NgnEngine sharedInstance].soundService setSpeakerEnabled:[videoSession isSpeakerEnabled]];
				break;
			}
			case INVITE_STATE_TERMINATED:
			case INVITE_STATE_TERMINATING:
			{
				self.viewTop.hidden = NO;
				self.labelStatus.text = @"Terminating...";
				self.viewLocalVideo.hidden = YES;
				
				[self hideBottomView:self.viewToolbar];
				
				[self hideBottomView:self.viewPickHangUp];
				break;
			}
			default:
				break;
		}
	}
}

-(void) closeView{
	[NgnCamera setPreview:nil];
	[[idoubs2AppDelegate sharedInstance].tabBarController dismissModalViewControllerAnimated:NO];
}

-(void) updateVideoOrientation{
	if(videoSession){
		if(![videoSession isConnected]){
			[NgnCamera setPreview:self.glViewVideoRemote];
		}
		
		switch ([UIDevice currentDevice].orientation) {
			case UIInterfaceOrientationPortrait:
				[videoSession setOrientation:AVCaptureVideoOrientationPortrait];
				break;
			case UIInterfaceOrientationPortraitUpsideDown:
				[videoSession setOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
				break;
			case UIInterfaceOrientationLandscapeLeft:
				[videoSession setOrientation:AVCaptureVideoOrientationLandscapeLeft];
				break;
			case UIInterfaceOrientationLandscapeRight:
				[videoSession setOrientation:AVCaptureVideoOrientationLandscapeRight];
				break;
		}
	}
    
    if(glViewVideoRemote){
        [glViewVideoRemote setOrientation:[UIDevice currentDevice].orientation];
    }
}

-(void) updateRemoteDeviceInfo{
	BOOL deviceOrientPortrait = [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown;
	switch(videoSession.remoteDeviceInfo.orientation)
	{
		case NgnDeviceInfo_Orientation_Portrait:
			[self.glViewVideoRemote setContentMode:UIViewContentModeScaleAspectFill];
			if(!deviceOrientPortrait){
#if 0
#endif
			}
			break;
		case NgnDeviceInfo_Orientation_Landscape:
			[self.glViewVideoRemote setContentMode:UIViewContentModeCenter];
			if(deviceOrientPortrait){
#if 0
				CGAffineTransform landscapeTransform = CGAffineTransformMakeRotation(degreesToRadian(90));
				landscapeTransform = CGAffineTransformTranslate(landscapeTransform, +90.0, +90.0);
				[self.view setTransform:landscapeTransform];
#endif
			}
			break;
	}
}

-(void) sendDeviceInfo{
	if([[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_SEND_DEVICE_INFO]){
		if(videoSession){
			NSString* content = nil;
			switch ([[UIDevice currentDevice] orientation]) {
				case UIDeviceOrientationPortrait:
				case UIDeviceOrientationPortraitUpsideDown:
					content = @"orientation:portrait\r\nlang:fr-FR\r\n";
					break;
				default:
					content = @"orientation:landscape\r\nlang:fr-FR\r\n";
					break;
			}
			[videoSession sendInfoWithContentString:content contentType:kContentDoubangoDeviceInfo];
		}
	}
}

@end


//
// VideoCallViewController (SipCallbackEvents)
//
@implementation VideoCallViewController(SipCallbackEvents)

-(void) onInviteEvent:(NSNotification*)notification {
	NgnInviteEventArgs* eargs = [notification object];
	
	if(!videoSession || videoSession.id != eargs.sessionId){
		return;
	}
	
	switch (eargs.eventType) {
		case INVITE_EVENT_INPROGRESS:
		case INVITE_EVENT_INCOMING:
		case INVITE_EVENT_RINGING:
		default:
		{
			// updates status info
			[self updateViewAndState];
			
			// video session
  			[NgnCamera setPreview:self.glViewVideoRemote];
			if(sendingVideo){
				[videoSession setRemoteVideoDisplay:nil];
				[videoSession setLocalVideoDisplay:nil];
			}
			break;
		}
			
		case INVITE_EVENT_CONNECTED:
		case INVITE_EVENT_EARLY_MEDIA:
		{
			// updates status info
			[self updateViewAndState];
			
			// video session
			[self updateVideoOrientation];
			if(sendingVideo){
				[videoSession setLocalVideoDisplay:viewLocalVideo];
			}
			
			[NgnCamera setPreview:nil];
            [videoSession setRemoteVideoDisplay:self.glViewVideoRemote];
            [self.glViewVideoRemote startAnimation];
			
			[self updateRemoteDeviceInfo];
			[self sendDeviceInfo];
			break;
		}
			
		case INVITE_EVENT_REMOTE_DEVICE_INFO_CHANGED:
		{
			[self updateRemoteDeviceInfo];
			break;
		}
			
		case INVITE_EVENT_TERMINATED:
		case INVITE_EVENT_TERMWAIT:
		{
			// updates status info
			[self updateViewAndState];
			
			// video session
			if(videoSession){
				[videoSession setRemoteVideoDisplay:nil];
				[videoSession setLocalVideoDisplay:nil];
			}
            [self.glViewVideoRemote stopAnimation];
			[NgnCamera setPreview:self.glViewVideoRemote];
			
			// releases session
			[NgnAVSession releaseSession:&videoSession];
			// starts timer suicide
			[NSTimer scheduledTimerWithTimeInterval:kCallTimerSuicide
											 target:self 
										   selector:@selector(timerSuicideTick:) 
										   userInfo:nil 
											repeats:NO];
			break;
		}
	}
}

@end


//
// VideoCallViewController (Timers)
//
@implementation VideoCallViewController (Timers)

-(void)timerInCallTick:(NSTimer*)timer{
	// to be implemented for the call time display
}

-(void)timerSuicideTick:(NSTimer*)timer{
    [self performSelectorOnMainThread:@selector(closeView) withObject:nil waitUntilDone:NO];
}

@end

@implementation VideoCallViewController

@synthesize viewLocalVideo;
@synthesize glViewVideoRemote;

@synthesize viewTop;
@synthesize labelRemoteParty;
@synthesize labelStatus;

@synthesize viewToolbar;
@synthesize buttonToolBarMute;
@synthesize buttonToolBarEnd;
@synthesize buttonToolBarToggle;
@synthesize buttonToolBarVideo;

@synthesize viewPickHangUp;
@synthesize buttonPick;
@synthesize buttonHangUp;

@synthesize imageSecure;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		self.modalPresentationStyle = UIModalPresentationFullScreen;
		
		self->sendingVideo = YES;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.viewLocalVideo.layer.borderWidth = 2.f;
	self.viewLocalVideo.layer.borderColor = [[UIColor whiteColor] CGColor];
	// self.viewLocalVideo.layer.cornerRadius = 0.f;
	
	self.buttonToolBarEnd.backgroundColor = 
	self.buttonToolBarMute.backgroundColor =
	self.buttonToolBarToggle.backgroundColor =
	self.buttonToolBarVideo.backgroundColor =
	[UIColor clearColor];
	
	//[self.buttonToolBarMute setImage:[UIImage imageNamed:@"facetime_mute"] forState:UIControlStateNormal];
	//[self.buttonToolBarEnd setImage:[UIImage imageNamed:@"facetime_hangup"] forState:UIControlStateNormal];
	
	self.buttonPick.layer.borderWidth = self.buttonHangUp.layer.borderWidth = 2.f;
	self.buttonPick.layer.borderColor = self.buttonHangUp.layer.borderColor = [[UIColor grayColor] CGColor];
	// self.buttonPick.layer.cornerRadius = self.buttonHangUp.layer.cornerRadius = 8.f;
	
	// apply light-black gradiens
	[VideoCallViewController applyGradienWithColors:kColorsLightBlack forView:self.viewTop];
	
	// listen to the events
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onInviteEvent:) name:kNgnInviteEventArgs_Name object:nil];
    
    // GLView
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.glViewVideoRemote = [[[iOSGLView alloc] initWithFrame:screenBounds] autorelease];
    [self.view insertSubview:self.glViewVideoRemote atIndex:0];
}

- (void)viewWillAppear:(BOOL)animated{
	[videoSession release];
	videoSession = [[NgnAVSession getSessionWithId: self.sessionId] retain];
	if(videoSession){
		if([videoSession isConnected]){
			[videoSession setRemoteVideoDisplay:self.glViewVideoRemote];
			[videoSession setLocalVideoDisplay:self.viewLocalVideo];
		}
		labelRemoteParty.text = (videoSession.historyEvent) ? videoSession.historyEvent.remotePartyDisplayName :[NgnStringUtils nullValue];
	}
	[self updateViewAndState];
	[self updateVideoOrientation];
	[self updateRemoteDeviceInfo];
}

- (void)viewWillDisappear:(BOOL)animated{
	if(videoSession && [videoSession isConnected]){
		[videoSession setRemoteVideoDisplay:nil];
		[videoSession setLocalVideoDisplay:nil];
	}
	[NgnAVSession releaseSession: &videoSession];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	[NgnCamera setPreview:nil];
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	
	[self updateVideoOrientation];
	
	if(!self.viewToolbar.hidden){
		[self showBottomView:self.viewToolbar shouldRefresh:YES];
	}
	if(!self.viewPickHangUp.hidden){
		[self showBottomView:self.viewPickHangUp shouldRefresh:YES];
	}
	
	[self sendDeviceInfo];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction) onButtonClick: (id)sender{
	if(videoSession && sender == self.buttonToolBarVideo){
		sendingVideo = !sendingVideo;
		[videoSession setLocalVideoDisplay: sendingVideo ? viewLocalVideo :nil];
		[self showBottomView:self.viewToolbar shouldRefresh:YES];
	}
	else if(videoSession && sender == self.buttonToolBarMute){
		[videoSession setMute:![videoSession isMuted]];
		[self showBottomView:self.viewToolbar shouldRefresh:YES];
	}

	else if(videoSession && sender == self.buttonToolBarEnd || sender == self.buttonHangUp) {
		[videoSession hangUpCall];
	}
	else if(videoSession && sender == self.buttonPick){
		[videoSession acceptCall];
	}
	else if(videoSession && sender == self.buttonToolBarToggle) {
		[videoSession toggleCamera];
	}
}

- (void)dealloc {
	[self.viewLocalVideo release];
	
	[self.viewToolbar release];
	[self.labelRemoteParty release];
	[self.labelStatus release];
	
	[self.viewTop release];
	[self.buttonToolBarMute release];
	[self.buttonToolBarEnd release];
	[self.buttonToolBarToggle release];
	[self.buttonToolBarVideo release];
	
	[self.viewPickHangUp release];
	[self.buttonPick release];
	[self.buttonHangUp release];
    
    [self.glViewVideoRemote release];
	
    [super dealloc];
}


@end
