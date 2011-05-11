#import <UIKit/UIKit.h>

#import "iOSNgnStack.h"

@interface TestAudioCall : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UIActivityIndicatorView* activityIndicator;
	UILabel *labelStatus;
	UIView *viewStatus;
	UILabel *labelNumber;
	UILabel *labelDebugInfo;
	UIButton *buttonMakeAudioCall;
	
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
@property (retain, nonatomic) IBOutlet UILabel *labelNumber;
@property (retain, nonatomic) IBOutlet UILabel *labelDebugInfo;
@property (retain, nonatomic) IBOutlet UIButton *buttonMakeAudioCall;

- (IBAction) onButtonNumpadClick: (id)sender;

@end
