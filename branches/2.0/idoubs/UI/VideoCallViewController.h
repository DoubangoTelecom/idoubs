#import <UIKit/UIKit.h>

#import "CallViewController.h"
#import "TransparentToolbar.h"

@interface VideoCallViewController : CallViewController {
	IBOutlet TransparentToolbar* toolbar;
	IBOutlet UIImageView* imageViewRemoteVideo;
	IBOutlet UIView* viewLocalVideo;
	IBOutlet UIBarButtonItem* barItemVideoOnOff;
	
	NgnAVSession* videoSession;
	BOOL sendingVideo;
}

- (IBAction) onButtonHangUpClick: (id)sender;
- (IBAction) onButtonVideoOnOffClick: (id)sender;

@end
