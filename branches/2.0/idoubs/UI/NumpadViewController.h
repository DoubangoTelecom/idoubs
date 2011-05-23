#import <UIKit/UIKit.h>

#import "iOSNgnStack.h"

@interface NumpadViewController : UIViewController {
	UIActivityIndicatorView* activityIndicator;
	UILabel *labelStatus;
	UIView *viewStatus;
	UILabel *labelNumber;
	UIButton *buttonMakeAudioCall;
	
	NgnBaseService<INgnSipService>* mSipService;
	NgnBaseService<INgnConfigurationService>* mConfigurationService;
}

@property (retain, nonatomic) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (retain, nonatomic) IBOutlet UILabel *labelStatus;
@property (retain, nonatomic) IBOutlet UIView *viewStatus;
@property (retain, nonatomic) IBOutlet UILabel *labelNumber;
@property (retain, nonatomic) IBOutlet UIButton *buttonMakeAudioCall;

- (IBAction) onButtonNumpadUp: (id) sender event: (UIEvent*) e;
- (IBAction) onButtonNumpadDown: (id) sender event: (UIEvent*) e;

@end
