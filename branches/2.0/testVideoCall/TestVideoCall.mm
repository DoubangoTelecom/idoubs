#import "TestVideoCall.h"
#import "iOSNgnStack.h"

@implementation TestVideoCall

@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
    // Override point for customization after application launch
    [window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)dealloc {
    [window release];
    [super dealloc];
}

@end
