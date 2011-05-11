#import <UIKit/UIKit.h>

#import "iOSNgnStack.h"

@interface TestRegistration : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UIActivityIndicatorView* activityIndicator;
	UIButton *buttonRegister;
	UILabel *labelStatus;
	
	NgnEngine* mEngine;
	NgnBaseService<INgnSipService>* mSipService;
	NgnBaseService<INgnConfigurationService>* mConfigurationService;
	
	BOOL mScheduleRegistration;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (retain, nonatomic) IBOutlet UIButton *buttonRegister;
@property (retain, nonatomic) IBOutlet UILabel *labelStatus;

- (IBAction) onButtonRegisterClick: (id)sender;

@end
