#import <UIKit/UIKit.h>

#import "iOSNgnStack.h"

@interface TestVideoCall : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UIActivityIndicatorView* activityIndicator;
	UILabel *labelStatus;
	UIView *viewStatus;
	UILabel *labelDebugInfo;
	UIButton *buttonMakeVideoCall;
	UIView* viewLocalVideo;
	UIImageView *imageViewRemoteVideo;
	
	NgnEngine* mEngine;
	NgnBaseService<INgnSipService>* mSipService;
	NgnBaseService<INgnConfigurationService>* mConfigurationService;
	NgnAVSession* mCurrentAVSession;
	BOOL mScheduleRegistration;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (retain, nonatomic) IBOutlet UILabel *labelStatus;
@property (retain, nonatomic) IBOutlet UIView *viewStatus;
@property (retain, nonatomic) IBOutlet UILabel *labelDebugInfo;
@property (retain, nonatomic) IBOutlet UIButton *buttonMakeVideoCall;
@property (retain, nonatomic) IBOutlet UIView* viewLocalVideo;
@property (retain, nonatomic) IBOutlet UIImageView *imageViewRemoteVideo;

- (IBAction) onButtonVideoCallClick: (id)sender;

@end
