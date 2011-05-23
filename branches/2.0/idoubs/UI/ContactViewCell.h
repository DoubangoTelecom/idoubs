#import <UIKit/UIKit.h>

// Don't forget to change it in interface builder and you MUST define "reuseIdentifier" property
#undef kContactViewCellIdentifier
#define kContactViewCellIdentifier	@"ContactViewCellIdentifier"


@interface ContactViewCell : UITableViewCell {
	UILabel *labelDisplayName;
}

@property (retain, nonatomic) IBOutlet UILabel *labelDisplayName;
@property(nonatomic, readonly, copy) NSString *reuseIdentifier;

-(void) setDisplayName: (NSString*)displayName;
+(CGFloat)getHeight;

@end
