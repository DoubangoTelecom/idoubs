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
#import "UIVideoView.h"

@interface UICall : NSWindowController {
	UIVideoView *videoViewRemote;
	QTCaptureView *videoViewLocal;
	NgnAVSession *avSession;
	NSButton *buttonEndCall;
	NSButton *buttonHoldResume;
	NSButton *buttonStartVideo;
	NSTextField *textFieldDuration;
	NSTextField *textFieldStatus;
	NSTimer *timerInCall;
	double dateSeconds;
	NSString *remotePartyUri;
}

@property (assign) IBOutlet UIVideoView *videoViewRemote;
@property (assign) IBOutlet QTCaptureView *videoViewLocal;
@property (assign) IBOutlet NSButton *buttonEndCall;
@property (assign) IBOutlet NSButton *buttonHoldResume;
@property (assign) IBOutlet NSButton *buttonStartVideo;
@property (assign) IBOutlet NSTextField *textFieldDuration;
@property (assign) IBOutlet NSTextField *textFieldStatus;
@property (retain, readwrite,setter=setAVSession) NgnAVSession *avSession;


-(UICall*) initWithSession:(NgnAVSession*)avSession;
-(void)setAVSession:(NgnAVSession *)session;

+(BOOL) makeAudioCallWithRemoteParty:(NSString*)remoteUri andSipStack:(NgnSipStack*)sipStack;
+(BOOL) makeAudioVideoCallWithRemoteParty:(NSString*)remoteUri andSipStack:(NgnSipStack*)sipStack;
+(BOOL) receiveIncomingCall:(NgnAVSession*)session;

- (IBAction)onButtonClick:(id)sender;

@end
