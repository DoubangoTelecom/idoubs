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
#import "UIHistory.h"

//
//	Private
//

@interface UIHistory(Private)
-(void)refreshData;
-(void)reloadData;
-(void)refreshDataAndReload;
-(void)onHistoryEvent:(NSNotification*)notification;
@end

@implementation UIHistory(Private)

-(void)refreshData
{
	@synchronized(events){
		NSString *textFilter = [self.searchField stringValue];
		[events removeAllObjects];
		NSArray* events_ = [[[[NgnEngine sharedInstance].historyService events] allValues] sortedArrayUsingSelector:@selector(compareHistoryEventByDateASC:)];
		for (NgnHistoryEvent* event in events_) {
			if(!event || !(event.mediaType & MediaType_AudioVideo) || !(event.status & statusFilter) || (![NgnStringUtils isNullOrEmpty:textFilter] && [event.remotePartyDisplayName rangeOfString:textFilter options:NSCaseInsensitiveSearch].location == NSNotFound)){
				continue;
			}
			[events addObject:event];
		}
	}
}

-(void)reloadData
{
	[arrayController setContent:events];
}

-(void) refreshDataAndReload
{
	[self refreshData];
	[self reloadData];
}

-(void) onHistoryEvent:(NSNotification*)notification
{
	NgnHistoryEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case HISTORY_EVENT_ITEM_ADDED:
		{
			if((eargs.mediaType & MediaType_AudioVideo)){
				NgnHistoryEvent* event = [[[NgnEngine sharedInstance].historyService events] objectForKey: [NSNumber numberWithLongLong: eargs.eventId]];
				if(event){
					[events insertObject:event atIndex:0];
					[self reloadData];
				}
			}
			break;
		}
			
		case HISTORY_EVENT_ITEM_MOVED:
		case HISTORY_EVENT_ITEM_UPDATED:
		{
			[self reloadData];
			break;
		}
			
		case HISTORY_EVENT_ITEM_REMOVED:
		{
			if((eargs.mediaType & MediaType_AudioVideo)){
				for (NgnHistoryEvent* event in events) {
					if(event.id == eargs.eventId){
						[events removeObject: event];
						[self reloadData];
						break;
					}
				}
			}
			break;
		}
			
		case HISTORY_EVENT_RESET:
		default:
		{
			[self refreshDataAndReload];
			break;
		}
	}
}

-(void) onTextChangedEvent:(NSNotification*)notification
{
	[self refreshDataAndReload];
}

@end





//
// Default
//

@implementation UIHistory

@synthesize arrayController;
@synthesize collectionView;
@synthesize comboBoxFilter;
@synthesize searchField;
@synthesize events;

- (void)loadView
{
	[super loadView];
}

- (void)awakeFromNib 
{
	[super awakeFromNib];
	
	if(!events){
		events = [[NgnHistoryEventMutableArray alloc] init];
	}
	statusFilter = HistoryEventStatus_All;
	[self.comboBoxFilter selectItemAtIndex:0];
	
	[self.collectionView setMaxItemSize:NSMakeSize(4000.f, 60.f)];
	[self.collectionView setMinItemSize:NSMakeSize(300.f, 60.f)];
	[self.collectionView setAutoresizingMask:NSViewWidthSizable];
	[self.collectionView setMaxNumberOfColumns:1];
	
	[self refreshDataAndReload];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onTextChangedEvent:) name:NSControlTextDidChangeNotification object:self.searchField];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onHistoryEvent:) name:kNgnHistoryEventArgs_Name object:nil];
}


#pragma mark -
#pragma mark NSComboBoxDelegate methods

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
	#define kFilterIndexAll 0
	#define kFilterIndexOutgoing 1
	#define kFilterIndexIncoming 2
	#define kFilterIndexMissed 3
	
	HistoryEventStatus_t newStatusFilter;
	
	switch ([comboBoxFilter indexOfSelectedItem]) {
		case kFilterIndexAll:
		default:
			newStatusFilter = HistoryEventStatus_All;
			break;
		case kFilterIndexOutgoing:
			newStatusFilter = HistoryEventStatus_Outgoing;
			break;
		case kFilterIndexIncoming:
			newStatusFilter = HistoryEventStatus_Incoming;
			break;
		case kFilterIndexMissed:
			newStatusFilter = HistoryEventStatus_Missed;
			break;
	}
	
	if(newStatusFilter != statusFilter){
		statusFilter = newStatusFilter;
		[self refreshDataAndReload];
	}
}

#pragma mark -
#pragma mark NSCollectionViewDelegate methods



-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[events release];
	
	[super dealloc];
}

@end
