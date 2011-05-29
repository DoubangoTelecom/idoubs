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

-(MessageHistoryEntry*)entry{
	return self->entry;
}

-(void)setEntry:(MessageHistoryEntry*)entry_{
	[self.entry release];
	if((self->entry = [entry_ retain])){
		// remote party
		NgnContact* contact = [[NgnEngine getInstance].contactService getContactByPhoneNumber:self.entry.remoteParty];
		self.labelDisplayName.text = (contact && contact.displayName) ? contact.displayName :
						(self.entry.remoteParty ? self.entry.remoteParty : @"Unknown");
		
		// content
		self.labelContent.text =  self.entry.content ? self.entry.content : @"";
		
		// date
		self.labelDate.text = [[NgnDateTimeUtils historyEventDate] stringFromDate:self.entry.date];
	}
}

+(CGFloat)height{
	return kMessageCellHeight;
}

- (void)dealloc {
	[self.labelDisplayName release];
	[self.labelContent release];
	[self.labelDate release];
	[self.entry release];
	
    [super dealloc];
}


@end
