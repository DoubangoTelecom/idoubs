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
	NSInteger tag = ((UIButton*)sender).tag;
	
	switch (tag) {
		case 10:
			self.textFieldAddress.text = [self.textFieldAddress.text stringByAppendingString:@"*"];
			break;
		case 11:
			self.textFieldAddress.text = [self.textFieldAddress.text stringByAppendingString:@"#"];
			break;
		default:
			self.textFieldAddress.text = [self.textFieldAddress.text stringByAppendingString:[NSString stringWithFormat:@"%d", tag]];
			break;
	}
}

- (IBAction) onPickContactClick: (id)sender{
	iDoubsAppDelegate *appDelegate = (iDoubsAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.tabBarController setSelectedIndex:tab_index_contacts];
}

- (IBAction) onAVCallClick: (id)sender{
	if([self.textFieldAddress.text length] ==0){
		return;
	}
	
	iDoubsAppDelegate *appDelegate = (iDoubsAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	DWActionConfig* actionConfig = [[DWActionConfig alloc] init];
	[actionConfig setMediaIntForType:(tmedia_audio|tmedia_video) withKey:@"bandwidth-level" withValue:tmedia_bl_hight];
	DWCallSession* callSession = (DWCallSession*)[[DWCallSession alloc] initWithStack:[[SharedServiceManager sipService] sipStack]];
	
	[appDelegate.inCallViewController setSession:callSession];
	
	NSMutableArray* viewControllers = [NSMutableArray arrayWithArray:appDelegate.tabBarController.viewControllers];
	[viewControllers insertObject:appDelegate.inCallViewController atIndex:3];
	[appDelegate.tabBarController setViewControllers:viewControllers animated:YES];
	[appDelegate.tabBarController setSelectedIndex:3];
	
	NSString* remoteUri = [self.textFieldAddress.text stringByReplacingOccurrencesOfString:@" " withString:@""];
	if(![remoteUri hasPrefix:@"sip:"] && ![remoteUri hasPrefix:@"tel:"]){
		remoteUri = [@"sip:" stringByAppendingString:remoteUri];
	}
	if(![remoteUri hasPrefix:@"tel:"] && [remoteUri rangeOfString:@"@"].length == 0){
		NSString* realm = [[SharedServiceManager.configurationService getString:CONFIGURATION_SECTION_NETWORK entry:CONFIGURATION_ENTRY_REALM]
						   stringByReplacingOccurrencesOfString:@"sip:" withString:@""];
		remoteUri = [remoteUri stringByAppendingFormat:@"@%@",realm];
	}
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
