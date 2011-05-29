/* Copyright (C) 2010-2011, Mamadou Diop.
 * Copyright (c) 2011, Doubango Telecom. All rights reserved.
 *
 * Contact: Mamadou Diop <diopmamadou(at)doubango(dot)org>
 *       
 * This file is part of iDoubs Project ( http://code.google.com/p/idoubs )
 *
 * idoubs is free software: you can redistribute it and/or modify it under the terms of 
 * the GNU General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 *       
 * idoubs is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 * See the GNU General Public License for more details.
 *       
 * You should have received a copy of the GNU General Public License along 
 * with this program; if not, write to the Free Software Foundation, Inc., 
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 */
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
		NgnContact* contact = [[NgnEngine getInstance].contactService getContactByPhoneNumber: event.remoteParty];
		labelDisplayName.text = (contact && contact.displayName) ? contact.displayName :
									(event.remoteParty ? event.remoteParty : @"Unknown");
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
