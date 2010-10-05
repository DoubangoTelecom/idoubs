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

#import "ProfileViewController.h"

#import "DWSipSession.h"

#import "ServiceManager.h"
#import "EventArgs.h"

@interface ProfileViewController(Private)
-(void)internalInit;
@end

@implementation ProfileViewController

@synthesize buttonSignInOut;
@synthesize labelDebug;
@synthesize imageViewStatus;


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
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if([[SharedServiceManager sipService] registrationState] == SESSION_STATE_CONNECTED){
		[labelDebug setText:@"Connected"];
		[self.buttonSignInOut setTitle: @"Sign Out" forState: UIControlStateNormal];
		self.buttonSignInOut.imageView.image = [UIImage imageNamed:@"sign_out_48.png"];
		self.imageViewStatus.image = [UIImage imageNamed:@"bullet_ball_glass_green_16.png"];
	}
	else{
		[labelDebug setText:@"Disconnected"];
		[self.buttonSignInOut setTitle: @"Sign In" forState: UIControlStateNormal];
		self.buttonSignInOut.imageView.image = [UIImage imageNamed:@"sign_in_48.png"];
		self.imageViewStatus.image = [UIImage imageNamed:@"bullet_ball_glass_red_16.png"];
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

- (IBAction) onbuttonSignInOutClick: (id)sender{
	switch ([[SharedServiceManager sipService] registrationState]) {
		case SESSION_STATE_CONNECTED:
			[[SharedServiceManager sipService] unRegisterIdentity];
			break;
		case SESSION_STATE_DISCONNECTED:
			[[SharedServiceManager sipService] registerIdentity];
			break;
		case SESSION_STATE_CONNECTING:
		case SESSION_STATE_DISCONNECTING:
			[[SharedServiceManager sipService] stopStack];
			break;
	}
}


-(void) onRegistrationEvent:(NSNotification*)notification {
	RegistrationEventArgs* eargs = [notification object];
	
	switch (eargs.type) {			
		case REGISTRATION_OK:
			[self.buttonSignInOut setTitle: @"Sign Out" forState: UIControlStateNormal];
			self.buttonSignInOut.imageView.image = [UIImage imageNamed:@"sign_out_48.png"];
			self.imageViewStatus.image = [UIImage imageNamed:@"bullet_ball_glass_green_16.png"];
			break;
			
		case UNREGISTRATION_OK:
			[self.buttonSignInOut setTitle: @"Sign In" forState: UIControlStateNormal];
			self.buttonSignInOut.imageView.image = [UIImage imageNamed:@"sign_in_48.png"];
			self.imageViewStatus.image = [UIImage imageNamed:@"bullet_ball_glass_red_16.png"];
			break;
			
		case REGISTRATION_INPROGRESS:
		case UNREGISTRATION_INPROGRESS:
			[self.buttonSignInOut setTitle: @"Cancel" forState: UIControlStateNormal];
			self.buttonSignInOut.imageView.image = [UIImage imageNamed:@"sign_inprogress_48.png"];
			self.imageViewStatus.image = [UIImage imageNamed:@"bullet_ball_glass_grey_16.png"];
			break;
			
		case REGISTRATION_NOK:			
		case UNREGISTRATION_NOK:
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
