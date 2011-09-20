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
#import "CallViewController.h"

#import "idoubs2AppDelegate.h"

//
// private implementation
//
@interface CallViewController(Private)
+(BOOL) presentSession: (NgnAVSession*)session;
@end

@implementation CallViewController(Private)

+(BOOL) presentSession: (NgnAVSession*)session{
	if(session){
		if(isVideoType(session.mediaType)){
			[idoubs2AppDelegate sharedInstance].videoCallController.sessionId = session.id;
			[[idoubs2AppDelegate sharedInstance].tabBarController presentModalViewController: [idoubs2AppDelegate sharedInstance].videoCallController animated: YES];
			return YES;
		}
		else if(isAudioType(session.mediaType)){
			[idoubs2AppDelegate sharedInstance].audioCallController.sessionId = session.id;
			[[idoubs2AppDelegate sharedInstance].tabBarController presentModalViewController: [idoubs2AppDelegate sharedInstance].audioCallController animated: YES];
			return YES;
		}
	}
	return NO;
}

@end

@implementation CallViewController

@synthesize sessionId;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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

+(BOOL) makeAudioCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack{
	if(![NgnStringUtils isNullOrEmpty:remoteUri]){
		NgnAVSession* audioSession = [[NgnAVSession makeAudioCallWithRemoteParty: remoteUri
																 andSipStack: [[NgnEngine sharedInstance].sipService getSipStack]] retain];
		if(audioSession){
			[idoubs2AppDelegate sharedInstance].audioCallController.sessionId = audioSession.id;
			[[idoubs2AppDelegate sharedInstance].tabBarController presentModalViewController: [idoubs2AppDelegate sharedInstance].audioCallController animated: YES];
			[audioSession release];
			return YES;
		}
	}
	return NO;
}

+(BOOL) makeAudioVideoCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack{
	if(![NgnStringUtils isNullOrEmpty:remoteUri]){
		NgnAVSession* videoSession = [[NgnAVSession makeAudioVideoCallWithRemoteParty: remoteUri
																	 andSipStack: [[NgnEngine sharedInstance].sipService getSipStack]] retain];
		if(videoSession){
			[idoubs2AppDelegate sharedInstance].videoCallController.sessionId = videoSession.id;
			[[idoubs2AppDelegate sharedInstance].tabBarController presentModalViewController: [idoubs2AppDelegate sharedInstance].videoCallController animated: YES];
			[videoSession release];
			return YES;
		}
	}
	return NO;
}

+(BOOL) receiveIncomingCall: (NgnAVSession*)session{
	return [CallViewController presentSession:session];
}

+(BOOL) displayCall: (NgnAVSession*)session{
	if(session){
		return [CallViewController presentSession:session];
	}
	return NO;
}

- (void)dealloc {
    [super dealloc];
}


@end
