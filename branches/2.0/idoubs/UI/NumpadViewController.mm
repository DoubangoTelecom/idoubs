#import "NumpadViewController.h"
#import "CallViewController.h"

#import "idoubs2AppDelegate.h"
#import "idoubs2Constants.h"

#define kTAGStar		10
#define kTAGSharp		11
#define kTAGAudioCall	12
#define kTAGDelete		13
#define kTAGMessages	14
#define kTAGVideoCall	15

@interface NumpadViewController(Private)
-(void) updateStatus;
@end

@interface NumpadViewController(SipCallbacks)
-(void) onRegistrationEvent:(NSNotification*)notification;
-(void) onLongClick:(UIButton*)sender;
@end

@implementation NumpadViewController(Private)

-(void) updateStatus{
	if([mSipService isRegistered]){
		viewStatus.backgroundColor = [UIColor greenColor];
		labelStatus.text = @"Connected";
	}
	else {
		viewStatus.backgroundColor = [UIColor grayColor];
		labelStatus.text = @"Not Connected";
	}
}

@end

@implementation NumpadViewController(SipCallbacks)

//== REGISTER events == //
-(void) onRegistrationEvent:(NSNotification*)notification {
	NgnRegistrationEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
			// provisional responses
		case REGISTRATION_INPROGRESS:
		case UNREGISTRATION_INPROGRESS:
			[activityIndicator startAnimating];
			break;
			// final responses
		case REGISTRATION_OK:
		case REGISTRATION_NOK:
		case UNREGISTRATION_OK:
		case UNREGISTRATION_NOK:
		default:
			[activityIndicator stopAnimating];
			break;
	}
	[self updateStatus];
}

-(void) onLongClick:(UIButton*)sender{
	if(sender.tag == 0){
		if([labelNumber.text hasSuffix: @"0"]){
			labelNumber.text = [NSString stringWithFormat:@"%@+", [labelNumber.text substringToIndex: [labelNumber.text length]-1]];
		}
	}
}

@end


@implementation NumpadViewController

@synthesize activityIndicator;
@synthesize labelStatus;
@synthesize viewStatus;
@synthesize labelNumber;
@synthesize buttonMakeAudioCall;

/*
- (id)initWithCoder:(NSCoder *)decoder{
	self = [super initWithCoder:decoder];
    if (self) {
		for(UIView *v in self.view.subviews){
			if([v isKindOfClass: [UIButton class]]){
				switch (((UIButton*)v).tag) {
					case kTAGMessages: case kTAGAudioCall: case kTAGDelete: case kTAGStar: case kTAGSharp:
					case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8: case 9:
						[((UIButton*)v) setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d_keypad", ((UIButton*)v).tag]] forState:UIControlStateNormal];
						[((UIButton*)v) setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d_keypad_pressed", ((UIButton*)v).tag]] forState:UIControlStateSelected];
						break;
				}
			}
		}
    }
    return self;
}
*/
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NgnEngine* ngnEngine = [[NgnEngine getInstance] retain];
	mSipService = [[ngnEngine getSipService] retain];
	mConfigurationService = [[ngnEngine getConfigurationService] retain];
	[ngnEngine release];
	
	[self updateStatus];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onRegistrationEvent:) name:kNgnRegistrationEventArgs_Name object:nil];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[mSipService release];
	[mConfigurationService release];
}

- (IBAction) onButtonNumpadDown: (id) sender event: (UIEvent*) e{
	NSInteger tag = ((UIButton*)sender).tag;
	
	switch (tag) {
		case kTAGMessages:
		{
			idoubs2AppDelegate* appDelegate = ((idoubs2AppDelegate*) [[UIApplication sharedApplication] delegate]);
			[appDelegate.tabBarController presentModalViewController: appDelegate.messagesViewController animated: NO];
			break;
		}
			
		case kTAGAudioCall:
		case kTAGVideoCall:
		{
			if(tag == kTAGVideoCall){
				[CallViewController makeAudioVideoCallWithRemoteParty: labelNumber.text  andSipStack: [mSipService getSipStack]];
			}
			else{
				[CallViewController makeAudioCallWithRemoteParty: labelNumber.text  andSipStack: [mSipService getSipStack]];
			}
			labelNumber.text = @"";
			break;
		}
			
		case kTAGDelete:
		{
			NSString* number = labelNumber.text;
			if([number length] >0){
				labelNumber.text = [number substringToIndex:([number length]-1)];
			}
			break;
		}
			
		case kTAGStar:
		{
			labelNumber.text = [labelNumber.text stringByAppendingString:@"*"];
			break;
		}
			
		case kTAGSharp:
		{
			labelNumber.text = [labelNumber.text stringByAppendingString:@"#"];
			break;
		}
			
		case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8: case 9:
		{
			labelNumber.text = [labelNumber.text stringByAppendingString:[NSString stringWithFormat:@"%d", tag]];
			if(tag == 0){
				[self performSelector:@selector(onLongClick:) withObject:sender afterDelay:.5];
			}
			break;
		}
	}
}

- (IBAction) onButtonNumpadUp: (id) sender event: (UIEvent*) e{
	if(((UIButton*)sender).tag == 0){
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onLongClick:) object:sender];
	}
}

- (void)dealloc {
	[activityIndicator release];
	[labelStatus release];
	[viewStatus release];
	[labelNumber release];
	[buttonMakeAudioCall release];
	
    [super dealloc];
}


@end
