#import "CallViewController.h"

#import "idoubs2AppDelegate.h"

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
		idoubs2AppDelegate* appDelegate = (idoubs2AppDelegate*) [[UIApplication sharedApplication] delegate];
		NgnAVSession* audioSession = [[NgnAVSession makeAudioCallWithRemoteParty: remoteUri
																 andSipStack: [[NgnEngine getInstance].sipService getSipStack]] retain];
		if(audioSession){
			appDelegate.audioCallController.sessionId = audioSession.id;
			[appDelegate.tabBarController presentModalViewController: appDelegate.audioCallController animated: YES];
			[audioSession release];
			return TRUE;
		}
	}
	return FALSE;
}

+(BOOL) makeAudioVideoCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack{
	if(![NgnStringUtils isNullOrEmpty:remoteUri]){
		idoubs2AppDelegate* appDelegate = (idoubs2AppDelegate*) [[UIApplication sharedApplication] delegate];
		NgnAVSession* videoSession = [[NgnAVSession makeAudioVideoCallWithRemoteParty: remoteUri
																	 andSipStack: [[NgnEngine getInstance].sipService getSipStack]] retain];
		if(videoSession){
			appDelegate.videoCallController.sessionId = videoSession.id;
			[appDelegate.tabBarController presentModalViewController: appDelegate.videoCallController animated: YES];
			[videoSession release];
			return TRUE;
		}
	}
	return FALSE;
}

- (void)dealloc {
    [super dealloc];
}


@end
