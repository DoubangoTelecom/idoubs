#import "idoubs2AppDelegate.h"

#import "AudioCallViewController.h"
#import "VideoCallViewController.h"

static const NSString* kProxyHost = @"192.168.100.101";
static const int kProxyPort = 5060;
static const NSString* kRealm = @"doubango.org";
static const NSString* kPassword = @"1212";
static const NSString* kPrivateIdentity = @"1212";
static const NSString* kPublicIdentity = @"sip:1212@doubango.org";
static const BOOL kEnableEarlyIMS = TRUE;


@implementation idoubs2AppDelegate

@synthesize window;
@synthesize tabBarController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // take an instance of the engine
	mEngine = [[NgnEngine getInstance] retain];
	[mEngine start];// start the engine
	
	// take needed services from the engine
	mSipService = [mEngine.sipService retain];
	mConfigurationService = [mEngine.configurationService retain];
	
	// set credentials
	[mConfigurationService setStringWithKey: IDENTITY_IMPI andValue: kPrivateIdentity];
	[mConfigurationService setStringWithKey: IDENTITY_IMPU andValue: kPublicIdentity];
	[mConfigurationService setStringWithKey: IDENTITY_PASSWORD andValue: kPassword];
	[mConfigurationService setStringWithKey: NETWORK_REALM andValue: kRealm];
	[mConfigurationService setStringWithKey: NETWORK_PCSCF_HOST andValue:kProxyHost];
	[mConfigurationService setIntWithKey: NETWORK_PCSCF_PORT andValue: kProxyPort];
	[mConfigurationService setBoolWithKey: NETWORK_USE_EARLY_IMS andValue: kEnableEarlyIMS];
	
	// Initialize some default values
	[mEngine.soundService setSpeakerEnabled: NO];
	
	// Set the tab bar controller as the window's root view controller and display.
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
	
	// switch to Numpad tab
	[self.tabBarController setSelectedIndex: kTabBarIndex_Numpad];
	
	// Try to register the default identity
	[mSipService registerIdentity];
	
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [mEngine stop];
	
	[mEngine release];
	[mSipService release];
	[mConfigurationService release];
}


#pragma mark -
#pragma mark UITabBarControllerDelegate methods

/*
 // Optional UITabBarControllerDelegate method.
 - (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
 }
 */

/*
 // Optional UITabBarControllerDelegate method.
 - (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
 }
 */


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

-(AudioCallViewController *)audioCallController{
	if(!self->audioCallController){
		self->audioCallController = [[AudioCallViewController alloc] initWithNibName: @"AudioCallView" bundle:nil];;
	}
	return self->audioCallController;
}

-(VideoCallViewController *)videoCallController{
	if(!self->videoCallController){
		self->videoCallController = [[VideoCallViewController alloc] initWithNibName: @"VideoCallView" bundle:nil];;
	}
	return self->videoCallController;
}

-(MessagesViewController *)messagesViewController{
	if(!self->messagesViewController){
		self->messagesViewController = [[MessagesViewController alloc] initWithNibName: @"MessagesView" bundle:nil];
	}
	return self->messagesViewController;
}

-(ChatViewController *)chatViewController{
	if(!self->chatViewController){
		self->chatViewController = [[ChatViewController alloc] initWithNibName: @"ChatView" bundle:nil];
	}
	return self->chatViewController;
}

- (void)dealloc {
    [tabBarController release];
	[audioCallController release];
	[videoCallController release];
	[messagesViewController release];
	[chatViewController release];
	
    [window release];
    [super dealloc];
}

@end
