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

#import "InCallViewController.h"

#import "iDoubsAppDelegate.h"

#import "tsk_debug.h"
#import "tsk_memory.h"

#import "ServiceManager.h"
#import "EventArgs.h"
#import "DWSipUri.h"

#import <AudioToolbox/AudioToolbox.h>

/*================= InCallViewController (Timers) ======================*/
@interface InCallViewController (Timers)
-(void)timerInCallTick:(NSTimer*)timer;
-(void)timerSuicideTick:(NSTimer*)timer;

@end

/*================= InCallViewController (VideoCapture) ======================*/
#if HAS_VIDEO_CAPTURE
@interface InCallViewController (VideoCapture)

- (AVCaptureDevice *)frontFacingCamera;
- (void)startVideoCapture;
- (void)stopVideoCapture:(id)arg;

@end

@implementation InCallViewController(VideoCapture)

- (AVCaptureDevice *)frontFacingCamera{
	NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in cameras){
        if (device.position == AVCaptureDevicePositionFront){
            return device;
        }
    }
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

- (void)startVideoCapture{
	[labelState setText:@"Starting Video stream"];
	if(self->avCaptureDevice || self->avCaptureSession){
		NSLog(@"Already capturing"), [labelState setText:@"Already capturing"];
		return;
	}
	
	if((self->avCaptureDevice = [self frontFacingCamera]) == nil){
		NSLog(@"Failed to get valide capture device"), [labelState setText:@"Failed to get valide capture device"];
		return;
	}
	
	NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self->avCaptureDevice error:&error];
    if (!videoInput){
        NSLog(@"Failed to get video input: %@", error), [labelState setText:@"Failed to get video input"];
		self->avCaptureDevice = nil;
        return;
    }
	
    self->avCaptureSession = [[AVCaptureSession alloc] init];
    self->avCaptureSession.sessionPreset = AVCaptureSessionPresetLow;
    [self->avCaptureSession addInput:videoInput];
	
    // Currently, the only supported key is kCVPixelBufferPixelFormatTypeKey. Recommended pixel format choices are 
	// kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange or kCVPixelFormatType_32BGRA. 
	// On iPhone 3G, the recommended pixel format choices are kCVPixelFormatType_422YpCbCr8 or kCVPixelFormatType_32BGRA.
	//
    AVCaptureVideoDataOutput *avCaptureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                              //[NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
							  [NSNumber numberWithInt:self->producerWidth], (id)kCVPixelBufferWidthKey,
                              [NSNumber numberWithInt:self->producerHeight], (id)kCVPixelBufferHeightKey,
                               
							  
							  nil];
    avCaptureVideoDataOutput.videoSettings = settings;
    [settings release];
    avCaptureVideoDataOutput.minFrameDuration = CMTimeMake(1, self->producerFps);
    
    dispatch_queue_t queue = dispatch_queue_create("org.doubango.idoubs", NULL);
    [avCaptureVideoDataOutput setSampleBufferDelegate:self queue:queue];
    [self->avCaptureSession addOutput:avCaptureVideoDataOutput];
    [avCaptureVideoDataOutput release];
    dispatch_release(queue);
	
	AVCaptureVideoPreviewLayer* previewLayer = [AVCaptureVideoPreviewLayer layerWithSession: self->avCaptureSession];
	previewLayer.frame = self->localView.bounds;
	previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[self->localView.layer addSublayer: previewLayer];
	
	self->producerFirstFrame = YES;
    [self->avCaptureSession startRunning];
	
	[labelState setText:@"Video capture started"];
	[self.buttonStartVideo setImage:[UIImage imageNamed:@"video_stop_48.png"] forState:UIControlStateNormal];
}

- (void)stopVideoCapture:(id)arg{
	if(self->avCaptureSession){
		[self->avCaptureSession stopRunning], self->avCaptureSession = nil;
		[self.buttonStartVideo setImage:[UIImage imageNamed:@"video_start_48.png"] forState:UIControlStateNormal];
		[labelState setText:@"Video capture stopped"];
	}
	self->avCaptureDevice = nil;
	
	for (UIView *view in self->localView.subviews) {
		[view removeFromSuperview];
	}
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	if(CVPixelBufferLockBaseAddress(pixelBuffer, 0) == kCVReturnSuccess){
        UInt8 *bufferPtr = (UInt8 *)CVPixelBufferGetBaseAddress(pixelBuffer);
        size_t buffeSize = CVPixelBufferGetDataSize(pixelBuffer);
		
		if(self->producerFirstFrame){ // Hope will never change
			if((self->producer = tsk_object_ref(self->producer))){
				TMEDIA_PRODUCER(self->producer)->video.width = CVPixelBufferGetWidth(pixelBuffer);
				TMEDIA_PRODUCER(self->producer)->video.height = CVPixelBufferGetHeight(pixelBuffer);
				
				int pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
				switch (pixelFormat) {
					case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
						TMEDIA_PRODUCER(producer)->video.chroma = tmedia_nv12; // iPhone 3GS or 4
						NSLog(@"Capture pixel format=NV12");
						break;
					case kCVPixelFormatType_422YpCbCr8:
						TMEDIA_PRODUCER(producer)->video.chroma = tmedia_uyvy422; // iPhone 3
						NSLog(@"Capture pixel format=UYUY422");
						break;
					default:
						TMEDIA_PRODUCER(producer)->video.chroma = tmedia_rgb32;
						NSLog(@"Capture pixel format=RGB32");
						break;
				}
				
				
				self->producerFirstFrame = NO;
				tsk_object_unref(self->producer);
			}
		}
		
		dw_producer_push(self->producer, bufferPtr, buffeSize);
		
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);		
    }
}

@end

#endif


/*================= InCallViewController ======================*/
@implementation InCallViewController

@synthesize remoteImageView;
@synthesize localView;
@synthesize incomingCallView;

@synthesize buttonStartVideo;
@synthesize buttonHoldResume;
@synthesize buttonHangUp;
@synthesize buttonPickCall;

@synthesize labelState;
@synthesize labelRemoteParty;
@synthesize labelTime;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        [DWVideoConsumer sharedInstance].callback = self;
		[DWVideoProducer sharedInstance].callback = self;
		
        [[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(onCallEvent:)
		 name:[InviteEventArgs eventName] object:nil];
		
		// Initialize the audio system
		AudioSessionInitialize(NULL,NULL,NULL,NULL);
		
		self->dateFormatter = [[NSDateFormatter alloc] init];
		[self->dateFormatter setDateFormat:@"mm:ss"];
		
		[self.incomingCallView setHidden:YES];
		self.incomingCallView.layer.cornerRadius = 15;
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	if(self->session){
		switch (self->session.state) {
			case SESSION_STATE_NONE:
				[labelState setText:@"."];
				break;
			case SESSION_STATE_CONNECTING:
				[labelState setText:@"In progress..."];
				break;
			case SESSION_STATE_CONNECTED:
				[labelState setText:@"In Call"];
				break;
			case SESSION_STATE_DISCONNECTING:
				[labelState setText:@"Terminating Call..."];
				break;
			case SESSION_STATE_DISCONNECTED:
				[labelState setText:@"Call Terminated"];
				break;
			default:
				break;
		}
	}
}

-(void)viewWillAppear:(BOOL)animated{
	if(self->session){
		//[labelRemoteParty setText:[self->session toUri]];
	}
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)drawVideoFrame:(id)arg{
	CGImageRef imageRef = CGBitmapContextCreateImage(self->bitmapContext);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
	self->remoteImageView.image =  image;
}

-(void) onCallEvent:(NSNotification*)notification {
	InviteEventArgs* eargs = [notification object];
	long long sessionId = [[eargs extraValueForKey:@"id"] longLongValue];
			   
	if(!self->session || self->session.id != sessionId){
		return;
	}
	
	switch (eargs.type) {
		case INVITE_INCOMING:
		{
			self->dateSeconds = 0;
			[self->labelTime setText:@"00:00"];
			
			[self.incomingCallView setHidden:NO];
			[self.buttonStartVideo setImage:[UIImage imageNamed:@"video_start_48.png"] forState:UIControlStateNormal];
			
			[UIDevice currentDevice].proximityMonitoringEnabled = YES;
			
			[labelRemoteParty setText:[DWSipUri friendlyName:self->session.remoteParty]];
			[labelState setText:[@"Incoming Call from " stringByAppendingFormat:@"%@", labelRemoteParty.text]];
			
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 40000
			if ([UIApplication sharedApplication].applicationState ==  UIApplicationStateBackground) {
				UILocalNotification* localNotif = [[[UILocalNotification alloc] init] autorelease];
				if (localNotif){
					localNotif.alertBody =[NSString  stringWithFormat:@"Call from %@",labelRemoteParty.text];
					localNotif.soundName = UILocalNotificationDefaultSoundName; 
					localNotif.applicationIconBadgeNumber = 0;
					localNotif.repeatInterval = 0;
					
					[[UIApplication sharedApplication]  presentLocalNotificationNow:localNotif];
				}
			}
#endif
			UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
			AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
			
			[SharedServiceManager.soundService playRingTone];
			
			[self->callEvent release], self->callEvent = nil;
			self->callEvent = [[HistoryAVCallEvent alloc] initAudioCallEvent:self->session.remoteParty];
			self->callEvent.status = HistoryEventStatus_Missed;
			break;
		}
			
		case INVITE_INPROGRESS:
		{
			self->dateSeconds = 0;
			[self->labelTime setText:@"00:00"];
			
			[self.incomingCallView setHidden:YES];
			[self.buttonStartVideo setImage:[UIImage imageNamed:@"video_start_48.png"] forState:UIControlStateNormal];
			
			[UIDevice currentDevice].proximityMonitoringEnabled = YES;
			
			[labelRemoteParty setText:[DWSipUri friendlyName:self->session.remoteParty]];
			[labelState setText:@"In progress..."];
			
			[self->callEvent release], self->callEvent = nil;
			self->callEvent = [[HistoryAVCallEvent alloc] initAudioCallEvent:self->session.remoteParty];
			self->callEvent.status = HistoryEventStatus_Outgoing;
			
			UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
			AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
			
			[SharedServiceManager.soundService playRingBackTone];
			break;
		}
			
		case INVITE_RINGING:
		{
			[labelState setText:@"Ringing"];
			
			break;
		}
			
		case INVITE_EARLY_MEDIA:
		{
			[labelState setText:@"Early Media"];
			
			[SharedServiceManager.soundService stopRingTone];
			[SharedServiceManager.soundService stopRingBackTone];
			break;
		}
			
		case INVITE_CONNECTED:
		{
			[self.incomingCallView setHidden:YES];
			
			[labelState setText:@"In Call"];
			[self->timerInCall invalidate], self->timerInCall = nil;
			
			if(self->callEvent){
				self->callEvent.start = [[NSDate date] timeIntervalSince1970];
				if(self->callEvent.status == HistoryEventStatus_Missed){
					self->callEvent.status = HistoryEventStatus_Incoming;
				}
				else{
					self->callEvent.status = HistoryEventStatus_Outgoing;
				}
			}
			
			UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
			AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
			
			[SharedServiceManager.soundService stopRingTone];
			[SharedServiceManager.soundService stopRingBackTone];
			
			self->timerInCall = [NSTimer scheduledTimerWithTimeInterval:1 
							target:self 
							selector:@selector(timerInCallTick:) 
							userInfo:nil 
							repeats:YES];
			break;
		}
			
		case INVITE_TERMWAIT:
		case INVITE_DISCONNECTED:
		{			
			[self.incomingCallView setHidden:YES];
			
			[UIDevice currentDevice].proximityMonitoringEnabled = NO;
			
			if(eargs.type == INVITE_TERMWAIT){
				[labelState setText:@"Ending Call..."];
			}
			else{
				[labelState setText:eargs.phrase];
			}
			
			if(self->callEvent){
				if(self->dateSeconds>0){
					self->callEvent.end = [[NSDate date] timeIntervalSince1970];
				}
				[SharedServiceManager.historyService addEvent:self->callEvent];
				[self->callEvent release], self->callEvent = nil;
			}
			
			UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
			AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
			
			//AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			
			[SharedServiceManager.soundService stopRingTone];
			[SharedServiceManager.soundService stopRingBackTone];
			
			[self->timerInCall invalidate], self->timerInCall = nil;
			
			[NSTimer scheduledTimerWithTimeInterval:1.5 
												target:self 
												selector:@selector(timerSuicideTick:) 
												userInfo:nil 
												repeats:NO];
			break;
		}
			
		case INVITE_LOCAL_HOLD_OK:
		case INVITE_LOCAL_HOLD_NOK:
		case INVITE_LOCAL_RESUME_OK:
		case INVITE_LOCAL_RESUME_NOK:
		case INVITE_REMOTE_HOLD:
		case INVITE_REMOTE_RESUME:
		default:
			break;
	}
}

- (IBAction) onButtonStartVideoClick: (id)sender{
#if HAS_VIDEO_CAPTURE
	NSLog(@"Video capture supported");
	if(canStreamVideo){
		if(self->avCaptureDevice){
			[self stopVideoCapture:nil];
		}
		else{
			[self startVideoCapture];
		}
	}
#else
	NSLog(@"Video capture not supported");

#endif
}

- (IBAction) onButtonHoldResumeClick: (id)sender{
}

- (IBAction) onButtonHangUpClick: (id)sender{
	[self->session hangUp];
}

- (IBAction) onButtonPickCallClick: (id)sender{
	[self->session accept];
}

-(void)timerInCallTick:(NSTimer*)timer {
	self->dateSeconds++;
	NSDate* date = [NSDate dateWithTimeIntervalSinceReferenceDate:self->dateSeconds];	
	[self->labelTime setText:[self->dateFormatter stringFromDate:date]];
}

-(void)timerSuicideTick:(NSTimer*)timer {
	[self->session release];
	self->session = nil;
	
#if HAS_VIDEO_CAPTURE
	// force camera stop()
	[self stopVideoCapture:nil];
#endif
	
	iDoubsAppDelegate *appDelegate = (iDoubsAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableArray* viewControllers = [NSMutableArray arrayWithArray:appDelegate.tabBarController.viewControllers];
	[viewControllers removeObject:self];
	[appDelegate.tabBarController setViewControllers:viewControllers animated:NO];
	
	
	[appDelegate.tabBarController setSelectedIndex:tab_index_dialer];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	TSK_FREE(self->consumerData);
	
	[self->callEvent release];
	
	[self->timerInCall invalidate], self->timerInCall = nil;
	//[self->timerSuicide invalidate], timerSuicide = nil;
	[self->dateFormatter dealloc];
	[self->session release];
    [super dealloc];
}

-(void)receiveCallOnMainThread:(DWCallSession*)_session{
	iDoubsAppDelegate *appDelegate = (iDoubsAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.inCallViewController setSession:(DWCallSession*)_session];
	
	NSMutableArray* viewControllers = [NSMutableArray arrayWithArray:appDelegate.tabBarController.viewControllers];
	[viewControllers insertObject:appDelegate.inCallViewController atIndex:3];
	[appDelegate.tabBarController setViewControllers:viewControllers animated:YES];
	[appDelegate.tabBarController setSelectedIndex:3];
}

+(int) receiveCall:(DWCallSession*) _session{
	// Check if we are already in call
	iDoubsAppDelegate *appDelegate = (iDoubsAppDelegate *)[[UIApplication sharedApplication] delegate];
	if([appDelegate.inCallViewController session]){
		NSLog(@"Already in call");
		[_session hangUp];
		return 0;
	}
	
	// Show screen
	[appDelegate.inCallViewController performSelectorOnMainThread:@selector(receiveCallOnMainThread:) withObject:_session waitUntilDone:YES];
	return 0;
}


/* ======================== InCallViewControllerDelegate ========================*/
-(void)setSession: (DWCallSession*)_session{
	[self->session release];
	self->session = [_session retain];
	// register for callbacks
}

-(DWCallSession*)session{
	return self->session;
}


/* ======================== DWVideoProducerCallback ========================*/
-(int)producerStarted:(dw_producer_t*)_producer{
	if(self->producer == _producer){
		self->canStreamVideo = YES;
		return 0;
	}
	
	NSLog(@"Not our producer");
	return -1;
}

-(int)producerPaused:(dw_producer_t*)_producer{
	if(self->producer == _producer){
		return 0;
	}
	
	NSLog(@"Not our producer");
	return -1;
}

-(int)producerStopped:(dw_producer_t*)_producer{
	if(self->producer == _producer){
		self->canStreamVideo = NO;
#if	HAS_VIDEO_CAPTURE
		[self performSelectorOnMainThread:@selector(stopVideoCapture:) withObject:nil waitUntilDone:NO];
#endif
		return 0;
	}
	
	NSLog(@"Not our producer");
	return -1;
}

-(int)producerPrepared:(dw_producer_t*)_producer{
	if(self->producer == _producer){
		self->producerHeight = _producer->negociatedHeight;
		self->producerWidth = _producer->negociatedWidth;
		self->producerFps = _producer->negociatedFps;
		return 0;
	}
	
	NSLog(@"Not our producer");
	return -1;
}

-(int)producerCreated:(dw_producer_t*)_producer{
	self->producer = _producer;
	return 0;
}

-(int)producerDestroyed:(dw_producer_t*)_producer{
	if(_producer == self->producer){
		self->producer = tsk_null;
		return 0;
	}
	
	NSLog(@"Not our producer");
	return -1;
}


/* ======================== DWVideoConsumerCallback ========================*/
-(int)consumerPaused{
	NSLog(@"InCallViewController::pause");
	return 0;
}

-(int)consumerPreparedWithWidth:(int) width andHeight: (int)height andFps: (int)fps{
	NSLog(@"InCallViewController::prepareWithWidth");
	
	CGContextRelease(self->bitmapContext), self->bitmapContext = nil;
	
	if(self->consumerDataSize != (width*height*4)){
		self->consumerDataSize = (width*height*4);
		self->consumerData = tsk_realloc(self->consumerData, self->consumerDataSize);
	}
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    self->bitmapContext = CGBitmapContextCreate(self->consumerData, width, height, 8, width * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
	
	return 0;
}

-(int)consumerStarted{
	NSLog(@"InCallViewController::start");
	return 0;
}

-(int)consumerHasBuffer: (const void*)buffer withSize: (tsk_size_t)size{
	//NSLog(@"InCallViewController::consumeWithBuffer");
	
	if(self->consumerData && self->bitmapContext /* FIXME: Check size validity */){
		memcpy(self->consumerData, buffer, size);
		[self performSelectorOnMainThread:@selector(drawVideoFrame:) withObject:nil waitUntilDone:NO];
	}
	return 0;
}

-(int)consumerStopped{
	NSLog(@"InCallViewController::stop");
	return 0;
}



@end
