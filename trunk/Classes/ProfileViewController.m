//
//  ProfileViewController.m
//  iDoubs
//
//  Created by Mamadou DIOP on 9/11/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import "ProfileViewController.h"

#import "ServiceManager.h"
#import "EventArgs.h"

@interface ProfileViewController(Private)
-(void)internalInit;
@end

@implementation ProfileViewController

@synthesize buttonSignInOut;
@synthesize labelDebug;


/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    }
    return self;
}*/



- (void)awakeFromNib {
	[super awakeFromNib];
	
	// Registration event
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(onRegistrationEvent:)
	 name:[RegistrationEventArgs eventName] object:nil];
	
	if([[SharedServiceManager sipService] isRegistered]){
		[labelDebug setText:@"Connected"];
	}
	else{
		[labelDebug setText:@"Disconnected"];
	}
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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

- (IBAction) onbuttonSignInOutClick: (id)sender{
	if([[SharedServiceManager sipService] isRegistered]){
		[[SharedServiceManager sipService] unRegisterIdentity];
	}
	else{
		[[SharedServiceManager sipService] registerIdentity];
	}
}


-(void) onRegistrationEvent:(NSNotification*)notification {
	RegistrationEventArgs* eargs = [notification object];
	
	switch (eargs.type) {			
		case REGISTRATION_OK:
			[self.buttonSignInOut setTitle: @"Sign Out" forState: UIControlStateNormal];
			break;
			
		case UNREGISTRATION_OK:
			[self.buttonSignInOut setTitle: @"Sign In" forState: UIControlStateNormal];
			break;
			
		case REGISTRATION_NOK:			
		case REGISTRATION_INPROGRESS:
		case UNREGISTRATION_NOK:
		case UNREGISTRATION_INPROGRESS:
		default:
			break;
	}
	
	[labelDebug setText:eargs.phrase];
}

- (void)dealloc {
	
	// Registration event
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [super dealloc];
}


@end
