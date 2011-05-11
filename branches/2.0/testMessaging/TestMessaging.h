#import <UIKit/UIKit.h>


#import "iOSNgnStack.h"

@interface TestMessaging : NSObject <UIApplicationDelegate> {
	UILabel *labelStatus;
	UIView *viewStatus;
	UILabel *labelDebugInfo;
	UIActivityIndicatorView* activityIndicator;
	UIWindow *window;
	UITextView *messageTextView;
	UIButton *buttonSend;
	
	NgnEngine* mEngine;
	
	NgnBaseService<INgnSipService>* mSipService;
	NgnBaseService<INgnConfigurationService>* mConfigurationService;
	
	BOOL mScheduleRegistration;
}

@property (retain, nonatomic) IBOutlet UILabel *labelStatus;
@property (retain, nonatomic) IBOutlet UIView *viewStatus;
@property (retain, nonatomic) IBOutlet UILabel *labelDebugInfo;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITextView *messageTextView;
@property (nonatomic, retain) IBOutlet UIButton *buttonSend;

- (IBAction) onButtonSendClick: (id)sender;

@end
