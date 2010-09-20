//
//  InCallViewController.h
//  iDoubs
//
//  Created by Mamadou DIOP on 9/12/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "DWVideoConsumer.h"
#import "DWVideoProducer.h"

#import "DWSipSession.h"

@protocol InCallViewControllerDelegate

-(void)setSession: (DWCallSession*)session;

@end


@interface InCallViewController : UIViewController<DWVideoConsumerCallback, DWVideoProducerCallback, InCallViewControllerDelegate
#if TARGET_OS_EMBEDDED
,AVCaptureVideoDataOutputSampleBufferDelegate
#endif
> {
	IBOutlet UIImageView *remoteImageView;
	IBOutlet UIView *localView;
	
	CGContextRef bitmapContext;
	void* consumerData;
	size_t consumerDataSize;
	void* producerData;
	size_t producerDataSize;
	
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
	
	IBOutlet UIButton *buttonStartVideo;
	IBOutlet UIButton *buttonHoldResume;
	IBOutlet UIButton *buttonHangUp;
	
	IBOutlet UILabel *labelState;
	IBOutlet UILabel *labelRemoteParty;
	IBOutlet UILabel *labelTime;
}


@property (retain, nonatomic) IBOutlet UIImageView *remoteImageView;
@property (retain, nonatomic) IBOutlet UIView *localView;


@property (retain, nonatomic) IBOutlet UIButton *buttonStartVideo;
@property (retain, nonatomic) IBOutlet UIButton *buttonHoldResume;
@property (retain, nonatomic) IBOutlet UIButton *buttonHangUp;

@property (retain, nonatomic) IBOutlet UILabel *labelState;
@property (retain, nonatomic) IBOutlet UILabel *labelRemoteParty;
@property (retain, nonatomic) IBOutlet UILabel *labelTime;


- (IBAction) onButtonStartVideoClick: (id)sender;
- (IBAction) onButtonHoldResumeClick: (id)sender;
- (IBAction) onButtonHangUpClick: (id)sender;

@end
