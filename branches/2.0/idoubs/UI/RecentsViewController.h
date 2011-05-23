#import <UIKit/UIKit.h>

#import "iOSNgnStack.h"

@interface RecentsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate> {
	UITableView *tableView;
	UIToolbar *toolbar;
	UIBarButtonItem* barButtonItemAll;
	UIBarButtonItem* barButtonItemMissed;
	UIBarButtonItem* barButtonItemClear;
	NgnHistoryEventMutableArray* mEvents;
	HistoryEventStatus_t mStatusFilter;
	
	NgnBaseService<INgnContactService>* mContactService;
	NgnBaseService<INgnHistoryService>* mHistoryService;
}

@property(nonatomic,retain) IBOutlet UITableView *tableView;
@property(nonatomic,retain) IBOutlet UIToolbar *toolbar;
@property(nonatomic,retain) IBOutlet UIBarButtonItem* barButtonItemAll;
@property(nonatomic,retain) IBOutlet UIBarButtonItem* barButtonItemMissed;
@property(nonatomic,retain) IBOutlet UIBarButtonItem* barButtonItemClear;

- (IBAction) onButtonToolBarItemClick: (id)sender;

@end
