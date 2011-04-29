#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "iOSNgnStack.h"

@interface TestRegistration : NSObject <UIApplicationDelegate, AVAudioSessionDelegate> {
    UIWindow *window;
	UIButton *buttonRegister;
	UILabel *labelStatus;
	
	NgnEngine* mEngine;
	NgnBaseService<INgnSipService>* mSipService;
	NgnBaseService<INgnConfigurationService>* mConfigurationService;
	
	BOOL mScheduleRegistration;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (retain, nonatomic) IBOutlet UIButton *buttonRegister;
@property (retain, nonatomic) IBOutlet UILabel *labelStatus;

- (IBAction) onButtonRegisterClick: (id)sender;

@end
