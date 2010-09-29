//
//  DialerViewController.m
//  iDoubs
//
//  Created by Mamadou DIOP on 9/3/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import "DialerViewController.h"

#import "ServiceManager.h"
#import "DWSipSession.h"

#import "InCallViewController.h"
#import "iDoubsAppDelegate.h"

@implementation DialerViewController

@synthesize buttonZero;
@synthesize buttonOne;
@synthesize buttonTwo;
@synthesize buttonThree;
@synthesize buttonFour;
@synthesize buttonFive;
@synthesize buttonSix;
@synthesize buttonSeven;
@synthesize buttonEight;
@synthesize buttonNine;
@synthesize buttonStar;
@synthesize buttonSharp;


@synthesize textFieldAddress;
@synthesize buttonPickContact;

@synthesize buttonVoice;
@synthesize buttonVideo;
@synthesize buttonDel;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	[self.textFieldAddress setDelegate:self];
	
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

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[textField resignFirstResponder];
	
	return YES;
	
}

- (IBAction) onKeyboardClick: (id)sender{
	if (sender == self.buttonZero) {
		self.textFieldAddress.text = [self.textFieldAddress.text stringByAppendingString:@"0"];
	}
	else if (sender == self.buttonOne) {
		self.textFieldAddress.text = [self.textFieldAddress.text stringByAppendingString:@"1"];
	}
	else if (sender == self.buttonTwo) {
		self.textFieldAddress.text = [self.textFieldAddress.text stringByAppendingString:@"2"];
	}
	else if (sender == self.buttonThree) {
		self.textFieldAddress.text = [self.textFieldAddress.text stringByAppendingString:@"3"];
	}
	else if (sender == self.buttonFour) {
		self.textFieldAddress.text = [self.textFieldAddress.text stringByAppendingString:@"4"];
	}
	else if (sender == self.buttonFive) {
		self.textFieldAddress.text = [self.textFieldAddress.text stringByAppendingString:@"5"];
	}
	else if (sender == self.buttonSix) {
		self.textFieldAddress.text = [self.textFieldAddress.text stringByAppendingString:@"6"];
	}
	else if (sender == self.buttonSeven) {
		self.textFieldAddress.text = [self.textFieldAddress.text stringByAppendingString:@"7"];
	}
	else if (sender == self.buttonEight) {
		self.textFieldAddress.text = [self.textFieldAddress.text stringByAppendingString:@"8"];
	}
	else if (sender == self.buttonNine) {
		self.textFieldAddress.text = [self.textFieldAddress.text stringByAppendingString:@"9"];
	}
	else if (sender == self.buttonStar) {
		self.textFieldAddress.text = [self.textFieldAddress.text stringByAppendingString:@"*"];
	}
	else if (sender == self.buttonSharp) {
		self.textFieldAddress.text = [self.textFieldAddress.text stringByAppendingString:@"#"];
	}
	
	//[self.textFieldAddress setText:@"4524"];
}

- (IBAction) onPickContactClick: (id)sender{
	iDoubsAppDelegate *appDelegate = (iDoubsAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.tabBarController setSelectedIndex:tab_index_contacts];
}

- (IBAction) onAVCallClick: (id)sender{	
	iDoubsAppDelegate *appDelegate = (iDoubsAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	DWActionConfig* actionConfig = [[DWActionConfig alloc] init];
	[actionConfig setMediaIntForType:(tmedia_audio|tmedia_video) withKey:@"bandwidth-level" withValue:tmedia_bl_hight];
	DWCallSession* callSession = (DWCallSession*)[[DWCallSession alloc] initWithStack:[[SharedServiceManager sipService] sipStack]];
	
	[appDelegate.inCallViewController setSession:callSession];
	
	NSMutableArray* viewControllers = [NSMutableArray arrayWithArray:appDelegate.tabBarController.viewControllers];
	[viewControllers insertObject:appDelegate.inCallViewController atIndex:3];
	[appDelegate.tabBarController setViewControllers:viewControllers animated:YES];
	[appDelegate.tabBarController setSelectedIndex:3];
	
	NSString* realm = [[SharedServiceManager.configurationService getString:CONFIGURATION_SECTION_NETWORK entry:CONFIGURATION_ENTRY_REALM]
					   stringByReplacingOccurrencesOfString:@"sip:" withString:@""];
	NSString* remoteUri = [self.textFieldAddress.text stringByReplacingOccurrencesOfString:@" " withString:@""];
	remoteUri = [@"sip:" stringByAppendingFormat:@"%@@%@",remoteUri, realm];
	callSession.remoteParty = remoteUri; // Just for UI, useless
	
	if(sender == self.buttonVideo){
		[callSession callAudioVideoWithActionConfig:actionConfig andRemoteUri: remoteUri];
	}
	else {
		[callSession callAudioWithActionConfig:actionConfig andRemoteUri: remoteUri];
	}

	
	[actionConfig release];
	[callSession release];
}

- (IBAction) onDelClick: (id)sender{
	NSString* val = self.textFieldAddress.text;
	if([val length] >0){
		self.textFieldAddress.text = [val substringToIndex:([val length]-1)];
	}
}


// DialerViewControllerDelegate
-(void)setAddress:(NSString*)address{
	if(address){
		self.textFieldAddress.text = address;
		iDoubsAppDelegate *appDelegate = (iDoubsAppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate.tabBarController setSelectedIndex:tab_index_dialer];
	}
}

- (void)dealloc {
	[buttonZero dealloc];
	[buttonOne dealloc];
	[buttonTwo dealloc];
	[buttonThree dealloc];
	[buttonFour dealloc];
	[buttonFive dealloc];
	[buttonSix dealloc];
	[buttonSeven dealloc];
	[buttonEight dealloc];
	[buttonNine dealloc];
	[buttonStar dealloc];
	[buttonSharp dealloc];
	
	[textFieldAddress dealloc];
	[buttonPickContact dealloc];
	
	[buttonVoice dealloc];
	[buttonVideo dealloc];
	[buttonDel dealloc];
	
    [super dealloc];
}


@end
