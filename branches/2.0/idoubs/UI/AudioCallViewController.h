#import <UIKit/UIKit.h>
#import "CallViewController.h"
#import "AudioCallOverlay.h"

@interface AudioCallViewController : CallViewController {
	UILabel *labelStatus;
	UILabel *labelRemoteParty;
	UIView *overlayPlaceHolder;
	UIButton *buttonHangup;
	AudioCallOverlay* overlay;
	
	NgnAVSession* audioSession;
}

@property (retain, nonatomic) IBOutlet UILabel *labelStatus;
@property (retain, nonatomic) IBOutlet UILabel *labelRemoteParty;
@property (retain, nonatomic) IBOutlet UIView *overlayPlaceHolder;
@property (retain, nonatomic) IBOutlet UIButton *buttonHangup;

- (IBAction) onButtonHangUpClick: (id)sender;

@end
