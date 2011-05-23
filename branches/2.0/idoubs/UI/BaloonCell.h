#import <UIKit/UIKit.h>


#import "iOSNgnStack.h"

// Don't forget to change it in interface builder and you MUST define "reuseIdentifier" property
#undef kBaloonCellIdentifier
#undef kBaloonCellIndentValue
#define kBaloonCellIdentifier	@"BaloonCellIdentifier"

@interface BaloonCell : UITableViewCell {
	UILabel *labelContent;
	UILabel *labelDate;
}

@property(nonatomic, readonly, copy) NSString *reuseIdentifier;
@property (retain, nonatomic) IBOutlet UILabel *labelContent;
@property (retain, nonatomic) IBOutlet UILabel *labelDate;

-(void)setEvent:(NgnHistorySMSEvent*)event forTableView:(UITableView*)tableView;
+(CGFloat)getHeight:(NgnHistorySMSEvent*)event constrainedWidth:(CGFloat)width;

@end
