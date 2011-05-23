#import "ContactViewCell.h"

#define kContactViewCellHeight 48.f

@implementation ContactViewCell

@synthesize labelDisplayName;

-(NSString *)reuseIdentifier{
	return kContactViewCellIdentifier;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

-(void) setDisplayName: (NSString*)displayName{
	labelDisplayName.text = displayName;
}

+(CGFloat)getHeight{
	return kContactViewCellHeight;
}

- (void)dealloc {
	[labelDisplayName release];
	
    [super dealloc];
}


@end
