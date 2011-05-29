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
#import "MessagesViewController.h"

#import "idoubs2AppDelegate.h"
#import "idoubs2Constants.h"

#import "ChatViewController.h"
#import "MessageCell.h"


//
//	MessageHistoryEntry
//

// private implementation
@interface MessageHistoryEntry(Private)
-(NSComparisonResult)compareEntryByDate:(MessageHistoryEntry *)otherEntry;
@end

@implementation MessageHistoryEntry(Private)

-(NSComparisonResult)compareEntryByDate:(MessageHistoryEntry *)otherEntry{
	NSTimeInterval diff = self->start - otherEntry->start;
	return diff==0 ? NSOrderedSame : (diff > 0 ?  NSOrderedAscending : NSOrderedDescending);
}

@end

// private properties
@interface MessageHistoryEntry()
@property(nonatomic,readonly) NSTimeInterval start;
@end


// default implementation
@implementation MessageHistoryEntry

@synthesize eventId;
@synthesize remoteParty;
@synthesize content;
@synthesize date;

@synthesize start;

-(MessageHistoryEntry*)initWithEvent: (NgnHistorySMSEvent*)event{
	if((self = [super init])){
		self->eventId = event.id;
		self.remoteParty = event.remoteParty;
		self->start = event.start;
		self.date = [NSDate dateWithTimeIntervalSince1970: self.start];
		self.content = event.contentAsString;
	}
	return self;
}

-(void)dealloc{
	[self.remoteParty release];
	[self.content release];
	[self.date release];
	
	[super dealloc];
}

@end


//
//	Private
//

@interface MessagesViewController(Private)
-(void) refreshData;
-(void) refreshDataAndReload;
-(void) refreshView;
-(void) onHistoryEvent:(NSNotification*)notification;
@end

@implementation MessagesViewController(Private)

-(void) refreshData{
	@synchronized(self->messages){
		NSMutableDictionary* entries = [[NSMutableDictionary alloc] init];
		NSArray* events = [[[[NgnEngine getInstance].historyService events] allValues] retain];
		
		for (NgnHistoryEvent *event in events) {
			if(!event || !(event.mediaType & MediaType_SMS)){
				continue;
			}
			
			MessageHistoryEntry* entry = [entries objectForKey:event.remoteParty];
			if(entry == nil || ((entry.start - event.start) < 0)){
				MessageHistoryEntry* newEntry = [[MessageHistoryEntry alloc] initWithEvent:(NgnHistorySMSEvent*)event];
				[entries setObject:newEntry forKey:newEntry.remoteParty];
				[newEntry release];
			}
		}
		
		NSArray* sortedEntries = [[entries allValues] sortedArrayUsingSelector:@selector(compareEntryByDate:)];
		[self->messages removeAllObjects];
		[self->messages addObjectsFromArray:sortedEntries];
		
		[entries release];
		[events release];
		
		[self refreshView];
	}
}

-(void) refreshDataAndReload{
	[self refreshData];
	[self.tableView reloadData];
}

-(void) refreshView{
	if([self->messages count] > 0){
		self.view = self.tableView;
		self.navigationItem.leftBarButtonItem = self.tableView.editing ? self->navigationItemDone : self->navigationItemEdit;
	}
	else {
		self.tableView.editing = NO;
		self.view = self.viewNoMessages;
		self.navigationItem.leftBarButtonItem = nil;
	}
}

-(void) onHistoryEvent:(NSNotification*)notification{
	NgnHistoryEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case HISTORY_EVENT_ITEM_ADDED:
		{
			if((eargs.mediaType & MediaType_SMS)){
				//NgnHistoryEvent* event = [[[NgnEngine getInstance].historyService events] objectForKey: [NSNumber numberWithLongLong: eargs.eventId]];
				//FIXME
				[self refreshDataAndReload];
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
			if((eargs.mediaType & MediaType_SMS)){
				//FIXME
				//NgnHistoryEvent* event = [[[NgnEngine getInstance].historyService events] objectForKey: [NSNumber numberWithLongLong: eargs.eventId]];
				[self refreshDataAndReload];
				// [mEvents removeObject: event];
				// [tableView reloadData];
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
	
	self.view = [self->messages count] > 0 ? self.tableView : self.viewNoMessages;
}

@end


//
//	Default
//

// private properties
@interface MessagesViewController()
@property(nonatomic,retain) NgnContact *pickedContact;
@property(nonatomic,retain) NgnPhoneNumber *pickedNumber;
@property(nonatomic,readonly) NSMutableArray *messages;
@end

// default implementation
@implementation MessagesViewController

@synthesize tableView;
@synthesize viewNoMessages;
@synthesize buttonComposeMessage;

@synthesize pickedContact;
@synthesize pickedNumber;
@synthesize messages;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if(!self.messages){
		self->messages = [[NSMutableArray alloc] init];
	}
	
	self->navigationItemEdit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																			 target:self
																			 action:@selector(onButtonNavivationItemClick:)];
	self->navigationItemDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(onButtonNavivationItemClick:)];
	self->navigationItemCompose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
																			target:self
																			action:@selector(onButtonNavivationItemClick:)];
	self.navigationItem.rightBarButtonItem = self->navigationItemCompose;
	
	self.buttonComposeMessage.layer.borderWidth = 2.f;
	self.buttonComposeMessage.layer.borderColor = [[UIColor grayColor] CGColor];
	self.buttonComposeMessage.layer.cornerRadius = 10.f;
	
	// refresh data set datasource
    [self refreshData];
	
	self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	self.modalPresentationStyle = UIModalPresentationPageSheet;
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onHistoryEvent:) name:kNgnHistoryEventArgs_Name object:nil];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    [self.messages removeAllObjects];
	[self.tableView reloadData];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self.messages removeAllObjects];
}

- (IBAction) onButtonNavivationItemClick: (id)sender{
	if(sender == self->navigationItemCompose){
		[self onButtonComposeClick:sender];
	}
	else if(sender == self->navigationItemEdit || sender == self->navigationItemDone) {
		if((self.tableView.editing = !self.tableView.editing)){
			self.navigationItem.leftBarButtonItem = self->navigationItemDone;
		}
		else {
			self.navigationItem.leftBarButtonItem = self->navigationItemEdit;
		}
	}
}


- (IBAction) onButtonComposeClick: (id)sender{
	PeoplePicker *picker = [[PeoplePicker alloc] init];
	[picker pickNumber:self];
	[picker release];
}

- (void)dealloc {
	[self.tableView release];
	[self.viewNoMessages release];
	[self.buttonComposeMessage release];
	[self.messages release];
	
	[navigationItemEdit release];
	[navigationItemDone release];
	[navigationItemCompose release];
	
	[self.pickedNumber release];
	[self.pickedContact release];
	
    [super dealloc];
}


//
//	PeoplePickerDelegate
//

-(BOOL) peoplePicker: (PeoplePicker *)picker shouldContinueAfterPickingNumber: (NgnPhoneNumber*)number{
	self.pickedNumber = number;
	[picker dismiss];
	
	if (self.pickedNumber && self.pickedContact) {
		[[idoubs2AppDelegate sharedInstance].chatViewController setRemoteParty:self.pickedNumber.number 
																	andContact:self.pickedContact];
		[self.navigationController pushViewController:[idoubs2AppDelegate sharedInstance].chatViewController 
								animated:YES];
	}
	
	return NO;
}

-(BOOL) peoplePicker: (PeoplePicker *)picker shouldContinueAfterPickingContact: (NgnContact*)contact{
	self.pickedContact = contact;
	
	return YES;
}

//
//	UITableViewDelegate
//

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	@synchronized(messages){
		return [messages count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	MessageCell *cell = (MessageCell*)[_tableView dequeueReusableCellWithIdentifier: kMessageCellIdentifier];
	if (cell == nil) {		
		cell = [[[NSBundle mainBundle] loadNibNamed:@"MessageCell" owner:self options:nil] lastObject];
	}
	
	@synchronized(messages){
		cell.entry = [messages objectAtIndex: indexPath.row];
	}
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;{
	return [MessageCell height];
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	if (editingStyle == UITableViewCellEditingStyleDelete){
		MessageHistoryEntry* entry = [messages objectAtIndex: indexPath.row];
        if (entry) {
			[[NgnEngine getInstance].historyService deleteEvents:MediaType_SMS withRemoteParty:entry.remoteParty];
		}
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	@synchronized(messages){
		MessageHistoryEntry* entry = [messages objectAtIndex: indexPath.row];
        if (entry) {
			[idoubs2AppDelegate sharedInstance].chatViewController.remoteParty = entry.remoteParty;
			[self.navigationController pushViewController:[idoubs2AppDelegate sharedInstance].chatViewController  animated:YES];
		}
	}
}


@end
