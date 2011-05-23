#import <UIKit/UIKit.h>


@interface AudioCallOverlay : UIViewController{
	UIButton *buttonMute;
	UIButton *buttonKeypad;
	UIButton *buttonSpeaker;
	UIButton *buttonHold;
}

@property (retain, nonatomic) IBOutlet UIButton *buttonMute;
@property (retain, nonatomic) IBOutlet UIButton *buttonKeypad;
@property (retain, nonatomic) IBOutlet UIButton *buttonSpeaker;
@property (retain, nonatomic) IBOutlet UIButton *buttonHold;

- (IBAction) onButtonHangUpClick: (id)sender;

@end
