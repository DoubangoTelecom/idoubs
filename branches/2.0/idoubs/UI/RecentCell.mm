#import "RecentCell.h"


@implementation RecentCell

@synthesize labelDisplayName;
@synthesize labelType;
@synthesize labelDate;

-(NSString *)reuseIdentifier{
	return kRecentCellIdentifier;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

-(void)setEvent: (NgnHistoryEvent*)event{
	if(event){
		// remote party
		labelDisplayName.text = event.remoteParty ? event.remoteParty : @"Unknown";
		
		// status
		switch (event.status) {
			case HistoryEventStatus_Missed:
			case HistoryEventStatus_Failed:
			{
				labelDisplayName.textColor = [UIColor redColor];
				break;
			}
			case HistoryEventStatus_Outgoing:
			case HistoryEventStatus_Incoming:
			default:
			{
				labelDisplayName.textColor = [UIColor blackColor];
				break;
			}
		}
		
		// date
		labelDate.text = [[NgnDateTimeUtils historyEventDate] stringFromDate:
						  [NSDate dateWithTimeIntervalSince1970: event.start]];
	}
}

- (void)dealloc {
	
    [super dealloc];
}


@end
