#import <UIKit/UIKit.h>

#import "iOSNgnStack.h"

@interface ChatViewController : UIViewController<UITableViewDelegate,UITableViewDataSource, UITextViewDelegate> {
	UITableView *tableView;
	UIView *viewTableHeader;
	UITextView *textView;
	UIView *viewFooter;
	UIBarButtonItem* barBtnMessagesOrClear;
	
	NSMutableArray* messages;
}

@property(nonatomic,retain) IBOutlet UITableView *tableView;
@property(nonatomic,retain) IBOutlet UIView *viewTableHeader;
@property(nonatomic,retain) IBOutlet UITextView *textView;
@property(nonatomic,retain) IBOutlet UIView *viewFooter;
@property(nonatomic,retain) IBOutlet UIBarButtonItem* barBtnMessagesOrClear;

- (IBAction) onBarBtnMessagesOrClearClick: (id)sender;
- (IBAction) onBarBtnEditOrDoneClick: (id)sender;
- (IBAction) onButtonSendClick: (id)sender;

@end
