#import "ContactDetailsController.h"


@implementation ContactDetailsController

@synthesize reuseIdentifier;

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

- (void)viewDidLoad {
    [super viewDidLoad];
	
}


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

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear: animated];
	if(mContact){
		labelDisplayName.text = mContact.displayName;
		//if(mContact.picture){
			//imageViewAvatar.image = [UIImage imageWithData: mContact.picture];
		//}else{
			//imageViewAvatar.image = [UIImage imageNamed:@"noavatar_icon_48.png"];
		//}
	}
}

-(void)setContact:(NgnContact*)contact{
	[mContact release];
	mContact = [contact retain];
}

- (void)dealloc {
	[mContact release];
    [super dealloc];
}

@end
