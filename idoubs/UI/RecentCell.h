#import <UIKit/UIKit.h>

#import "iOSNgnStack.h"

// Don't forget to change it in interface builder and you MUST define "reuseIdentifier" property
#undef kRecentCellIdentifier
#define kRecentCellIdentifier	@"RecentCellIdentifier"

@interface RecentCell : UITableViewCell {
	UILabel *labelDisplayName;
	UILabel *labelType;
	UILabel *labelDate;
}

@property(nonatomic, readonly, copy) NSString *reuseIdentifier;
@property (retain, nonatomic) IBOutlet UILabel *labelDisplayName;
@property (retain, nonatomic) IBOutlet UILabel *labelType;
@property (retain, nonatomic) IBOutlet UILabel *labelDate;

-(void)setEvent: (NgnHistoryEvent*)event;

@end
