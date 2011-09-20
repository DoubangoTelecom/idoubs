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
 */
#import "UIHistoryItem.h"
#import "UIView.h"
#import "UICall.h"

#import "OSXNgnStack.h"


@implementation UIHistoryItem

@synthesize textFieldDisplayName;
@synthesize textFieldDate;
@synthesize textFieldDuration;
@synthesize imageViewStatus;
@synthesize buttonCallVoice;
@synthesize buttonCallVideo;
@synthesize menuItemCallVoice;
@synthesize menuItemCallVideo;
@synthesize menuItemDelete;

- (void) awakeFromNib 
{
	[super awakeFromNib];
}

-(id)copyWithZone:(NSZone *)zone
{
	id result = [super copyWithZone:zone];
	
	[NSBundle loadNibNamed:@"UIHistoryItem" owner:result];
	
	return result;
}

- (void)setRepresentedObject:(id)object 
{
	[super setRepresentedObject:object];
	
	if (object == nil){
		return;
	}
	
	NgnHistoryAVCallEvent* callEvent = (NgnHistoryAVCallEvent*) [self representedObject];
	
	[textFieldDisplayName setStringValue:callEvent.remotePartyDisplayName ? callEvent.remotePartyDisplayName : @"Unknown"];
	
	switch (callEvent.status) {
		case HistoryEventStatus_Outgoing:
		{
			static NSImage *image = nil;
			if(!image){
				image = [[NSImage imageNamed:@"call_outgoing_45"] retain];
			}
			[self.imageViewStatus setImage:image];
			break;
		}
		case HistoryEventStatus_Incoming:
		{
			static NSImage *image = nil;
			if(!image){
				image = [[NSImage imageNamed:@"call_incoming_45"] retain];
			}
			[self.imageViewStatus setImage:image];
			break;
		}
		case HistoryEventStatus_Missed:
		case HistoryEventStatus_Failed:
		default:
		{
			static NSImage *image = nil;
			if(!image){
				image = [[NSImage imageNamed:@"call_missed_45"] retain];
			}
			[self.imageViewStatus setImage:image];
			break;
		}
	}
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:callEvent.start];
	if([date isToday]){
		[self.textFieldDate setStringValue:[@"Today" stringByAppendingFormat:@" %@", [[NgnDateTimeUtils historyEventTime] stringFromDate:
																					  [NSDate dateWithTimeIntervalSince1970:callEvent.start]]]];
	}
	else if([date isYesterday]){
		[self.textFieldDate setStringValue:[@"Yesterday" stringByAppendingFormat:@" %@", [[NgnDateTimeUtils historyEventTime] stringFromDate:
																					  [NSDate dateWithTimeIntervalSince1970:callEvent.start]]]];
	}
	else {
		[self.textFieldDate setStringValue:[[NgnDateTimeUtils historyEventDate] stringFromDate:
											[NSDate dateWithTimeIntervalSince1970:callEvent.start]]];
	}

	NSDate *duration = [NSDate dateWithTimeIntervalSince1970:(callEvent.end - callEvent.start)];
	[self.textFieldDuration setStringValue:[[NgnDateTimeUtils historyEventDuration] stringFromDate:duration]];
}

- (void)setSelected:(BOOL)flag 
{
	[super setSelected:	flag];
	
	[(UIView* )[self view] setSelected:flag];
	
	[self.buttonCallVideo setHidden:!flag];
	[self.buttonCallVoice setHidden:!flag];
}

- (IBAction)onButtonClick:(id)sender
{
	NgnHistoryAVCallEvent* callEvent = (NgnHistoryAVCallEvent*) [self representedObject];
	
	if(sender == self.buttonCallVideo || sender == self.menuItemCallVideo){
		[UICall makeAudioVideoCallWithRemoteParty:callEvent.remoteParty andSipStack:[NgnEngine sharedInstance].sipService.stack];
	}
	else if(sender == self.buttonCallVoice || sender == self.menuItemCallVoice){
		[UICall makeAudioCallWithRemoteParty:callEvent.remoteParty andSipStack:[NgnEngine sharedInstance].sipService.stack];
	}
	else if(sender == self.menuItemDelete){
		[[NgnEngine sharedInstance].historyService deleteEventWithId:callEvent.id];
	}
}

-(void)dealloc
{
	[super dealloc];
}

@end
