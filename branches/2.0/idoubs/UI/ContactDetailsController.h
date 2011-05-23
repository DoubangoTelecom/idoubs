#import <UIKit/UIKit.h>

#import "iOSNgnStack.h"

@interface ContactDetailsController : UIViewController {
	IBOutlet UILabel *labelDisplayName;
	IBOutlet UIImageView *imageViewAvatar;
	NgnContact* mContact;
}

@property(nonatomic, readonly, copy) NSString *reuseIdentifier;

-(void)setContact:(NgnContact*)contact;

@end
