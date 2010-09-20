//
//  RegisteringViewController.m
//  iDoubs
//
//  Created by Mamadou DIOP on 9/10/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import "RegisteringViewController.h"
#import "iDoubsAppDelegate.h"

#import "ServiceManager.h"
#import "EventArgs.h"




@implementation RegisteringViewController

@synthesize buttonCancel;
@synthesize activityIndicatorView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		
		// Registration event
        [[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(onRegistrationEvent:)
		 name:[RegistrationEventArgs eventName] object:nil];
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated{
	[self.activityIndicatorView startAnimating];	
	
	[SharedServiceManager start];
	[[SharedServiceManager sipService]  registerIdentity];
	
	
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
	
	[self.activityIndicatorView stopAnimating];
}


- (IBAction) onbuttonCancelClick: (id)sender{
	
	iDoubsAppDelegate *appDelegate = (iDoubsAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.tabBarController dismissModalViewControllerAnimated:NO];
}


-(void) onRegistrationEvent:(NSNotification*)notification {
	RegistrationEventArgs* eargs = [notification object];
	
	switch (eargs.type) {			
		case REGISTRATION_OK:
		{
			iDoubsAppDelegate *appDelegate = (iDoubsAppDelegate *)[[UIApplication sharedApplication] delegate];
			[appDelegate.tabBarController dismissModalViewControllerAnimated:NO];
			break;
		}
			
		case UNREGISTRATION_OK:
			break;
			
		case REGISTRATION_NOK:
		{
			UIAlertView* errorView = [[UIAlertView alloc]initWithTitle:@"Failed To Register" message:eargs.phrase delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[errorView show];
			[errorView release];
			break;
		}
			
		case REGISTRATION_INPROGRESS:
		case UNREGISTRATION_NOK:
		case UNREGISTRATION_INPROGRESS:
		default:
			break;
	}
}

- (void)dealloc {
	// FIXME
	//[self.buttonCancel dealloc];
	
	// Registration event
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [super dealloc];
}



@end
