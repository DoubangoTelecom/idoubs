#import <UIKit/UIKit.h>
#import "AudioCallViewController.h"
#import "VideoCallViewController.h"
#import "MessagesViewController.h"
#import "ChatViewController.h"

#import "iOSNgnStack.h"

#define kTabBarIndex_Favorites	0
#define kTabBarIndex_Recents	1
#define kTabBarIndex_Contacts	2
#define kTabBarIndex_Numpad		3
#define kTabBarIndex_Info		4

@interface idoubs2AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	AudioCallViewController *audioCallController;
	VideoCallViewController *videoCallController;
	MessagesViewController *messagesViewController;
	ChatViewController *chatViewController;
	
	NgnEngine* mEngine;
	NgnBaseService<INgnSipService>* mSipService;
	NgnBaseService<INgnConfigurationService>* mConfigurationService;
	BOOL mScheduleRegistration;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, readonly) AudioCallViewController *audioCallController;
@property (nonatomic, readonly) VideoCallViewController *videoCallController;
@property (nonatomic, readonly) MessagesViewController *messagesViewController;
@property (nonatomic, readonly) ChatViewController *chatViewController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
