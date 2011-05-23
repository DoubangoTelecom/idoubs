#import <UIKit/UIKit.h>

#import "iOSNgnStack.h"

#import "MessagesViewController.h"

// Don't forget to change it in interface builder and you MUST define "reuseIdentifier" property
#undef kMessageCellIdentifier
#undef kMessageCellHeight
#define kMessageCellIdentifier	@"MessageCellIdentifier"

@interface MessageCell : UITableViewCell {
	UILabel *labelDisplayName;
	UILabel *labelContent;
	UILabel *labelDate;
}

@property(nonatomic, readonly, copy) NSString *reuseIdentifier;
@property (retain, nonatomic) IBOutlet UILabel *labelDisplayName;
@property (retain, nonatomic) IBOutlet UILabel *labelContent;
@property (retain, nonatomic) IBOutlet UILabel *labelDate;

-(void)setEntry:(MessageHistoryEntry*)entry;
+(CGFloat)getHeight;
@end
