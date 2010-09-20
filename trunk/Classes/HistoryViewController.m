//
//  HistoryViewController.m
//  iDoubs
//
//  Created by Mamadou DIOP on 8/27/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import "HistoryViewController.h"
#import "DWSipStack.h"

#import "ServiceManager.h"
//#import "ConfigurationService.h"

@implementation HistoryViewController

-(id) init{
	self = [super init];
	
	return self;
}

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
//- (void)viewDidLoad {
//    [super viewDidLoad];
	
	//NSString* displayName = [[SharedServiceManager configurationService] getString:IDENTITY entry:DISPLAY_NAME];
	//NSLog(@"%s", displayName);
	
	//DWSipStack* stack = [[DWSipStack alloc] initWithCallback:nil realmUri:@"sip2sip.info" impiUri:@"2233392625" impuUri:@"sip:2233392625@sip2sip.info"];
	//[stack setProxyCSCFWithFQDN:@"proxy.sipthor.net" andPort:5060 andTransport:@"UDP" andIPVersion:@"IPv4"];
	//[stack start];
	
	//[[SharedServiceManager sipService] registerIdentity];
	
//}


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


- (void)dealloc {
    [super dealloc];
}


@end
