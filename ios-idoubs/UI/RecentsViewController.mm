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
#import "RecentsViewController.h"
#import "CallViewController.h"

#import "RecentCell.h"

//
//	Private
//

@interface RecentsViewController(Private)
-(void) refreshData;
-(void) refreshDataAndReload;
-(void) onHistoryEvent:(NSNotification*)notification;
@end

@implementation RecentsViewController(Private)

-(void) refreshData{
	@synchronized(mEvents){
		[mEvents removeAllObjects];
		NSArray* events = [[[mHistoryService events] allValues] sortedArrayUsingSelector:@selector(compareHistoryEventByDateASC:)];
		for (NgnHistoryEvent* event in events) {
			if(!event || !(event.mediaType & MediaType_AudioVideo) || !(event.status & mStatusFilter)){
				continue;
			}
			[mEvents addObject:event];
		}
	}
}

-(void) refreshDataAndReload{
	[self refreshData];
	[tableView reloadData];
}

-(void) onHistoryEvent:(NSNotification*)notification{
	NgnHistoryEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case HISTORY_EVENT_ITEM_ADDED:
		{
			if((eargs.mediaType & MediaType_AudioVideo)){
				NgnHistoryEvent* event = [[mHistoryService events] objectForKey: [NSNumber numberWithLongLong: eargs.eventId]];
				if(event){
					[mEvents insertObject:event atIndex:0];
					[tableView reloadData];
				}
			}
			break;
		}
		
		case HISTORY_EVENT_ITEM_MOVED:
		case HISTORY_EVENT_ITEM_UPDATED:
		{
			[tableView reloadData];
			break;
		}
		
		case HISTORY_EVENT_ITEM_REMOVED:
		{
			if((eargs.mediaType & MediaType_AudioVideo)){
				for (NgnHistoryEvent* event in mEvents) {
					if(event.id == eargs.eventId){
						[mEvents removeObject: event];
						[tableView reloadData];
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

@end




//
//	Default implementation
//
@implementation RecentsViewController

@synthesize tableView;
@synthesize toolbar;
@synthesize barButtonItemAll;
@synthesize barButtonItemMissed;
@synthesize barButtonItemClear;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if(!mEvents){
		mEvents = [[NgnHistoryEventMutableArray alloc] init];
	}
	mStatusFilter = HistoryEventStatus_All;
	
	// get contact service instance
	mContactService = [[NgnEngine sharedInstance].contactService retain];
	mHistoryService = [[NgnEngine sharedInstance].historyService retain];
	
	// refresh data
    [self refreshData];
	
	self.navigationItem.title = @"History";
	
	tableView.delegate = self;
	tableView.dataSource = self;
	
	[[NSNotificationCenter defaultCenter]
		addObserver:self selector:@selector(onHistoryEvent:) name:kNgnHistoryEventArgs_Name object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear: animated];
	[self.navigationController setNavigationBarHidden: YES];
}

- (void)viewWillDisappear:(BOOL)animate{
	[super viewWillDisappear: animate];
	[self.navigationController setNavigationBarHidden: NO];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[mEvents release], mEvents = nil;
	[mContactService release];
	[mHistoryService release];
}

- (IBAction) onButtonToolBarItemClick: (id)sender{
	if(sender == barButtonItemAll){
		mStatusFilter = HistoryEventStatus_All;
		
		barButtonItemMissed.style = UIBarButtonItemStyleBordered;
		barButtonItemAll.style = UIBarButtonItemStyleDone;
		
		[self refreshDataAndReload];
	}
	else if(sender == barButtonItemMissed){
		mStatusFilter = (HistoryEventStatus_t)(HistoryEventStatus_Missed | HistoryEventStatus_Failed);
		
		barButtonItemMissed.style = UIBarButtonItemStyleDone;
		barButtonItemAll.style = UIBarButtonItemStyleBordered;
		
		[self refreshDataAndReload];
	}
	else if(sender == barButtonItemClear){
		UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil 
													delegate:self 
													cancelButtonTitle:@"Cancel"
													destructiveButtonTitle:@"Clear All Recents" 
													otherButtonTitles:nil];
		popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		[popupQuery showInView: tableView];
		[popupQuery release];
	}
}

- (void)dealloc {
    [super dealloc];
}


//
//	UIActionSheetDelegate
//

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[mHistoryService deleteEvents: MediaType_AudioVideo];
		// will be notified by the history service
	}
	else if (buttonIndex == 1) {
	}
}

//
//	UITableViewDelegate
//

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	@synchronized(mEvents){
		return [mEvents count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	RecentCell *cell = (RecentCell*)[_tableView dequeueReusableCellWithIdentifier: kRecentCellIdentifier];
	if (cell == nil) {		
		cell = [[[NSBundle mainBundle] loadNibNamed:@"RecentCell" owner:self options:nil] lastObject];
	}
	
	@synchronized(mEvents){
		[cell setEvent:[mEvents objectAtIndex: indexPath.row]];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	if (editingStyle == UITableViewCellEditingStyleDelete){
		NgnHistoryEvent* event = [mEvents objectAtIndex: indexPath.row];
        if (event) {
			[[NgnEngine sharedInstance].historyService deleteEvent: event];
		}
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	@synchronized(mEvents){
		NgnHistoryEvent* event = [mEvents objectAtIndex: indexPath.row];
        if (event) {
			[CallViewController makeAudioCallWithRemoteParty: event.remoteParty andSipStack: [[NgnEngine sharedInstance].sipService getSipStack]];
		}
	}
}

@end
