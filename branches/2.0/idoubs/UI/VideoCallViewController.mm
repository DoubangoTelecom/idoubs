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

#import "idoubs2AppDelegate.h"
#import "idoubs2Constants.h"

/*=== VideoCallViewController (Private) ===*/
@interface VideoCallViewController(Private)
-(void) closeView;
-(void) updateStatus;
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

-(void) closeView{
	idoubs2AppDelegate* appDelegate = (idoubs2AppDelegate*) [[UIApplication sharedApplication] delegate];
	[appDelegate.tabBarController dismissModalViewControllerAnimated: NO];
}

-(void) updateStatus{
	if(videoSession){
		switch (videoSession.state) {
			case INVITE_STATE_INPROGRESS:
			{
				//labelStatus.text = @"Calling...";
				break;
			}
			case INVITE_STATE_INCOMING:
			{
				//labelStatus.text = @"Incoming call...";
				break;
			}
			case INVITE_STATE_REMOTE_RINGING:
			{
				//labelStatus.text = @"Remote is ringing";
			}
			case INVITE_STATE_INCALL:
			{
				//labelStatus.text = @"In Call";
				break;
			}
			case INVITE_STATE_TERMINATED:
			case INVITE_STATE_TERMINATING:
			{
				//labelStatus.text = @"Terminating...";
				break;
			}
			default:
				break;
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
			[self updateStatus];
			break;
		}
			
		case INVITE_EVENT_CONNECTED:
		case INVITE_EVENT_EARLY_MEDIA:
		{
			[videoSession setRemoteVideoDisplay: imageViewRemoteVideo];
			if(sendingVideo){
				[videoSession setLocalVideoDisplay: viewLocalVideo];
			}
			break;
		}

			
		case INVITE_EVENT_TERMINATED:
		case INVITE_EVENT_TERMWAIT:
		{
			[videoSession setRemoteVideoDisplay: nil];
			[videoSession setLocalVideoDisplay: nil];
			
			// updates status info
			[self updateStatus];
			// releases session
			[NgnAVSession releaseSession: &videoSession];
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
// VideoCallViewController (Timers)
//
@implementation VideoCallViewController (Timers)

-(void)timerInCallTick:(NSTimer*)timer{
	// to be implemented for the call time display
}

-(void)timerSuicideTick:(NSTimer*)timer{
	[self closeView];
}

@end

@implementation VideoCallViewController

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
	
	viewLocalVideo.layer.borderWidth = 2.f;
	viewLocalVideo.layer.borderColor = [[UIColor whiteColor] CGColor];
	viewLocalVideo.layer.cornerRadius = 0.f;
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onInviteEvent:) name:kNgnInviteEventArgs_Name object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
	[videoSession release];
	videoSession = [[NgnAVSession getSessionWithId: self.sessionId] retain];
	if(videoSession && [videoSession isConnected]){
		[videoSession setRemoteVideoDisplay: imageViewRemoteVideo];
		[videoSession setLocalVideoDisplay: viewLocalVideo];
	}
}

- (void)viewWillDisappear:(BOOL)animated{
	if(videoSession && [videoSession isConnected]){
		[videoSession setRemoteVideoDisplay: nil];
		[videoSession setLocalVideoDisplay: nil];
	}
	[NgnAVSession releaseSession: &videoSession];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if(videoSession){
		switch (interfaceOrientation) {
			case UIInterfaceOrientationPortrait: [videoSession setOrientation: AVCaptureVideoOrientationPortrait]; break;
			case UIInterfaceOrientationPortraitUpsideDown: [videoSession setOrientation: AVCaptureVideoOrientationPortraitUpsideDown]; break;
			case UIInterfaceOrientationLandscapeLeft: [videoSession setOrientation: AVCaptureVideoOrientationLandscapeRight]; break;
			case UIInterfaceOrientationLandscapeRight: [videoSession setOrientation: AVCaptureVideoOrientationLandscapeLeft]; break;
		}
	}
    return YES;
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

- (IBAction) onButtonHangUpClick: (id)sender{
	if(videoSession){
		[videoSession hangUpCall];
	}
}

- (IBAction) onButtonVideoOnOffClick: (id)sender{
	if(videoSession){
		if(videoSession){
			sendingVideo = !sendingVideo;
			[videoSession setLocalVideoDisplay: sendingVideo ? viewLocalVideo : nil];
			barItemVideoOnOff.style = sendingVideo ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
		}
	}
}

- (void)dealloc {
    [super dealloc];
}


@end
