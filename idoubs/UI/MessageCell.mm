#import "MessageCell.h"

#define kMessageCellHeight		60.f

@implementation MessageCell

@synthesize labelDisplayName;
@synthesize labelContent;
@synthesize labelDate;

-(NSString *)reuseIdentifier{
	return kMessageCellIdentifier;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

-(void)setEntry:(MessageHistoryEntry*)entry{
	if(entry){
		// remote party
		labelDisplayName.text = entry.remoteParty ? entry.remoteParty : @"Unknown";
		
		// content
		labelContent.text =  entry.content ? entry.content : @"";
		
		// date
		labelDate.text = [[NgnDateTimeUtils historyEventDate] stringFromDate:entry.date];
	}
}

+(CGFloat)getHeight{
	return kMessageCellHeight;
}

- (void)dealloc {
	[labelDisplayName release];
	[labelContent release];
	[labelDate release];
	
    [super dealloc];
}


@end
