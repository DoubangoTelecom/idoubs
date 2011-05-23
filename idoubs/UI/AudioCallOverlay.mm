#import "AudioCallOverlay.h"
#import <QuartzCore/QuartzCore.h>

@implementation AudioCallOverlay

@synthesize buttonMute;
@synthesize buttonKeypad;
@synthesize buttonSpeaker;
@synthesize buttonHold;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	/*
	buttonMute.layer.borderWidth = 2.f;
	buttonMute.layer.borderColor = [[UIColor whiteColor] CGColor];
	
	buttonKeypad.layer.borderWidth = 2.f;
	buttonKeypad.layer.borderColor = [[UIColor whiteColor] CGColor];
	
	buttonSpeaker.layer.borderWidth = 2.f;
	buttonSpeaker.layer.borderColor = [[UIColor whiteColor] CGColor];
	
	buttonHold.layer.borderWidth = 2.f;
	buttonHold.layer.borderColor = [[UIColor whiteColor] CGColor];
	 */
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (IBAction) onButtonHangUpClick: (id)sender{
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[buttonMute release];
	[buttonKeypad release];
	[buttonSpeaker release];
	[buttonHold release];
	
    [super dealloc];
}


@end
