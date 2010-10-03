/*
 * Copyright (C) 2010 Mamadou Diop.
 *
 * Contact: Mamadou Diop <diopmamadou(at)doubango.org>
 *       
 * This file is part of idoubs Project (http://code.google.com/p/idoubs)
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

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "DWVideoConsumer.h"
#import "DWVideoProducer.h"
#import "DWSipSession.h"

#import "HistoryEvent.h"

@protocol InCallViewControllerDelegate

-(void)setSession: (DWCallSession*)session;
-(DWCallSession*)session;

@end


@interface InCallViewController : UIViewController<DWVideoConsumerCallback, DWVideoProducerCallback, InCallViewControllerDelegate
#if TARGET_OS_EMBEDDED
,AVCaptureVideoDataOutputSampleBufferDelegate
#endif
> {
	IBOutlet UIImageView *remoteImageView;
	IBOutlet UIView *localView;
	IBOutlet UIView *incomingCallView;
	
	CGContextRef bitmapContext;
	void* consumerData;
	size_t consumerDataSize;
	size_t producerWidth;
	size_t producerHeight;
	int producerFps;
	BOOL producerFirstFrame;
	
	double dateSeconds;
	NSDateFormatter *dateFormatter;
	NSTimer* timerInCall;
	//NSTimer* timerSuicide;
	
	BOOL canStreamVideo;
	
#if TARGET_OS_EMBEDDED
	AVCaptureSession* avCaptureSession;
	AVCaptureDevice *avCaptureDevice;
#endif
	
	DWCallSession* session;
	dw_producer_t* producer;
	
	HistoryAVCallEvent* callEvent;
	
	IBOutlet UIButton *buttonStartVideo;
	IBOutlet UIButton *buttonHoldResume;
	IBOutlet UIButton *buttonHangUp;
	IBOutlet UIButton *buttonPickCall;
	
	IBOutlet UILabel *labelState;
	IBOutlet UILabel *labelRemoteParty;
	IBOutlet UILabel *labelTime;
}


@property (retain, nonatomic) IBOutlet UIImageView *remoteImageView;
@property (retain, nonatomic) IBOutlet UIView *localView;
@property (retain, nonatomic) IBOutlet UIView *incomingCallView;

@property (retain, nonatomic) IBOutlet UIButton *buttonStartVideo;
@property (retain, nonatomic) IBOutlet UIButton *buttonHoldResume;
@property (retain, nonatomic) IBOutlet UIButton *buttonHangUp;
@property (retain, nonatomic) IBOutlet UIButton *buttonPickCall;

@property (retain, nonatomic) IBOutlet UILabel *labelState;
@property (retain, nonatomic) IBOutlet UILabel *labelRemoteParty;
@property (retain, nonatomic) IBOutlet UILabel *labelTime;

- (IBAction) onButtonStartVideoClick: (id)sender;
- (IBAction) onButtonHoldResumeClick: (id)sender;
- (IBAction) onButtonHangUpClick: (id)sender;
- (IBAction) onButtonPickCallClick: (id)sender;

+(int) receiveCall:(DWCallSession*) session;

@end
