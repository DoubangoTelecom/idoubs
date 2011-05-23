#import "AudioCallViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "idoubs2AppDelegate.h"
#import "idoubs2Constants.h"

/*=== AudioCallViewController (Private) ===*/
@interface AudioCallViewController(Private)
-(void) closeView;
-(void) updateStatus;
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

-(void) closeView{
	idoubs2AppDelegate* appDelegate = (idoubs2AppDelegate*) [[UIApplication sharedApplication] delegate];
	[appDelegate.tabBarController dismissModalViewControllerAnimated: NO];
}

-(void) updateStatus{
	if(audioSession){
		switch (audioSession.state) {
			case INVITE_STATE_INPROGRESS:
			{
				labelStatus.text = @"Calling...";
				break;
			}
			case INVITE_STATE_INCOMING:
			{
				labelStatus.text = @"Incoming call...";
				break;
			}
			case INVITE_STATE_REMOTE_RINGING:
			{
				labelStatus.text = @"Remote is ringing";
			}
			case INVITE_STATE_INCALL:
			{
				labelStatus.text = @"In Call";
				break;
			}
			case INVITE_STATE_TERMINATED:
			case INVITE_STATE_TERMINATING:
			{
				labelStatus.text = @"Terminating...";
				break;
			}
			default:
				break;
		}
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
		default:
		{
			// updates status info
			[self updateStatus];
			break;
		}

		case INVITE_EVENT_TERMINATED:
		case INVITE_EVENT_TERMWAIT:
		{
			// updates status info
			[self updateStatus];
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
@synthesize labelStatus;
@synthesize labelRemoteParty;
@synthesize overlayPlaceHolder;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		overlay = [[AudioCallOverlay alloc] initWithNibName:@"AudioCallOverlay" bundle:nil];
		overlay.view.alpha = 0.6f;
		overlay.view.layer.cornerRadius = 5;
		
		self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	buttonHangup.layer.cornerRadius = 10;
	buttonHangup.layer.borderWidth = 2.f;
	buttonHangup.layer.borderColor = [[UIColor grayColor] CGColor];
	
	CGRect frame = overlayPlaceHolder.layer.frame;
	frame.origin.x = 0.f, frame.origin.y = 0.f;
	overlay.view.layer.frame = frame;
	overlay.view.layer.cornerRadius = 8;
	overlay.view.layer.borderWidth = 2.f;
	overlay.view.layer.borderColor = [[UIColor whiteColor] CGColor];
	[overlayPlaceHolder addSubview: overlay.view];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onInviteEvent:) name:kNgnInviteEventArgs_Name object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
	[audioSession release];
	audioSession = [[NgnAVSession getSessionWithId: self.sessionId] retain];
	if(audioSession){
		labelRemoteParty.text = (audioSession.historyEvent && audioSession.historyEvent.remoteParty) ?
		audioSession.historyEvent.remoteParty : (audioSession.remotePartyUri ? audioSession.remotePartyUri : [NgnStringUtils nullValue]);
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

- (IBAction) onButtonHangUpClick: (id)sender{
	if(audioSession){
		[audioSession hangUpCall];
	}
}

- (void)dealloc {	
	[labelStatus release];
	[labelRemoteParty release];
	[buttonHangup release];
	[overlayPlaceHolder release];
	[overlay release];
	
    [super dealloc];
}


@end
