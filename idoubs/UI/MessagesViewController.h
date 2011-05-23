#import <UIKit/UIKit.h>

#import "iOSNgnStack.h"

@interface MessageHistoryEntry : NSObject{
	long long eventId;
	NSString* remoteParty;
	NSString* content;
	NSDate* date;
}

@property(nonatomic,readonly) long long eventId;
@property(nonatomic,retain) NSString *remoteParty;
@property(nonatomic,retain) NSString *content;
@property(nonatomic,retain) NSDate *date;

@end

@interface MessagesViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	UITableView *tableView;
	NSMutableArray* messages;
}

@property(nonatomic,retain) IBOutlet UITableView *tableView;

- (IBAction) onButtonToolBarEditOrDoneClick: (id)sender;
- (IBAction) onButtonToolBarWriteClick: (id)sender;

@end
