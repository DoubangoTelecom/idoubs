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
#import "ChatViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "BaloonCell.h"
#import "idoubs2AppDelegate.h"
#import "idoubs2Constants.h"

//
//	History Data
//

@interface ChatViewController(Private)
-(void) resizeTextView;
-(void) scrollToBottom:(BOOL)animated;
-(void) refreshData;
-(void) reloadData;
-(void) refreshDataAndReload;
-(void) onHistoryEvent:(NSNotification*)notification;
@end

@implementation ChatViewController(Private)

-(void) resizeTextView{
	CGRect frame = textView.frame;
	CGFloat diff = (frame.size.height - textView.contentSize.height);
	if(diff){
		frame.size.height = textView.contentSize.height;
		textView.frame = frame;
		
		frame = viewFooter.frame, frame.size.height -= diff, frame.origin.y += diff;
		viewFooter.frame = frame;
		frame = tableView.frame, frame.size.height += diff;
		tableView.frame = frame;
		
		[self scrollToBottom: YES];
	}
}

-(void) refreshData{
	@synchronized(messages){
		[messages removeAllObjects];
		NSArray* events = [[[[NgnEngine getInstance].historyService events] allValues] sortedArrayUsingSelector:@selector(compareHistoryEventByDateDESC:)];
		for (NgnHistoryEvent* event in events) {
			if(!event || !(event.mediaType & MediaType_SMS) || ![event.remoteParty isEqualToString: self.remoteParty]){
				continue;
			}
			[messages addObject:event];
		}
	}
	
}

-(void) scrollToBottom:(BOOL)animated{
	if([messages count] >0){
		[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([messages count] - 1) inSection:0] 
						 atScrollPosition:UITableViewScrollPositionBottom animated:animated];
	}
}

-(void) reloadData{
	[tableView reloadData];
	[self scrollToBottom:NO];
} 

-(void) refreshDataAndReload{
	[self refreshData];
	[self reloadData];
}

-(void) onHistoryEvent:(NSNotification*)notification{
	NgnHistoryEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case HISTORY_EVENT_ITEM_ADDED:
		{
			if((eargs.mediaType & MediaType_SMS)){
				NgnHistoryEvent* event = [[[NgnEngine getInstance].historyService events] objectForKey: [NSNumber numberWithLongLong: eargs.eventId]];
				if(event && [event.remoteParty isEqualToString: self.remoteParty]){
					[messages addObject: event];
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
			if((eargs.mediaType & MediaType_SMS)){
				for (NgnHistoryEvent* event in messages) {
					if(event.id == eargs.eventId){
						[messages removeObject: event];
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
//	KeyboardNotifications
//
@interface ChatViewController (KeyboardNotifications)
-(void) keyboardWillHide:(NSNotification *)note;
-(void) keyboardWillShow:(NSNotification *)note;
-(void) keyboardNotificationWithNote:(NSNotification *)note willShow: (BOOL) showing;
@end

@implementation ChatViewController (KeyboardNotifications)

-(void) keyboardWillHide:(NSNotification *)note{
	[self keyboardNotificationWithNote:note willShow:NO];
}

-(void) keyboardWillShow:(NSNotification *)note{
	[self keyboardNotificationWithNote:note willShow:YES];
}

-(void) keyboardNotificationWithNote:(NSNotification *)note willShow: (BOOL) showing{
	CGRect keyboardBounds;
	CGRect tableViewFrame = self.tableView.frame;
	CGRect tableViewBounds = self.tableView.bounds;
	CGRect viewFooterFrame = self.viewFooter.frame;
	int sign = (showing ? -1 : +1);
	CGFloat titleHeight = 50.f; //FIXME
	
    [[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue: &keyboardBounds];
	
    // start animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
	
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
        tableViewFrame.size.height += keyboardBounds.size.height * sign + titleHeight * -sign;
		viewFooterFrame.origin.y += keyboardBounds.size.height * sign + titleHeight * -sign;
	}
    else{
        tableViewFrame.size.height += keyboardBounds.size.width * sign + titleHeight * -sign;
		viewFooterFrame.origin.y += keyboardBounds.size.width * sign + titleHeight * -sign;
	}
	
    // resize
    self.tableView.frame = tableViewFrame;
	self.viewFooter.frame = viewFooterFrame;
	
	// commit animation
    [UIView commitAnimations];
	
	// scrollt
	[self scrollToBottom:YES];
}

@end


//
// Default implementation
//

// private properties
@interface ChatViewController()
@property(nonatomic,retain) NgnContact *contact;
@property(nonatomic,retain) NSString* remotePartyUri;
@end

@implementation ChatViewController

@synthesize tableView;
@synthesize buttonSend;
@synthesize buttonAudioCall;
@synthesize buttonVideoCall;
@synthesize buttonContactInfo;
@synthesize viewTableHeader;
@synthesize textView;
@synthesize viewFooter;
@synthesize barBtnMessagesOrClear;
@synthesize remotePartyUri;

@synthesize contact;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		messages = [[NSMutableArray alloc] init];
	}
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.buttonSend.layer.borderWidth = 2.f;
	self.buttonSend.layer.borderColor = [[UIColor grayColor] CGColor];
	self.buttonSend.layer.cornerRadius = 10.f;
	
	if(self.navigationItem){
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Edit" 
											style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
		self.navigationItem.rightBarButtonItem.action = @selector(onBarBtnEditOrDoneClick:);
		self.navigationItem.rightBarButtonItem.target = self;
	}
	
	self.textView.layer.cornerRadius = 10.f;
	self.textView.clipsToBounds = YES;
	self.textView.layer.borderWidth = 1.0f;
	self.textView.layer.borderColor = [[UIColor grayColor] CGColor];
	
	self.tableView.tableHeaderView = self.viewTableHeader;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	
	[self refreshDataAndReload];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter]	addObserver:self 
												selector:@selector(onHistoryEvent:) 
												 name:kNgnHistoryEventArgs_Name 
											   object:nil];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    [messages removeAllObjects];
	[tableView reloadData];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[messages removeAllObjects];
}


-(void)viewDidAppear:(BOOL)animated{
	if(self.navigationItem){
		self.navigationItem.title = (self->contact && self->contact.displayName) ? self->contact.displayName : 
				(self.remoteParty ? self.remoteParty : @"Unknown");
		[self refreshDataAndReload];
		
	}
}

- (IBAction) onBarBtnMessagesOrClearClick: (id)sender{
	if(tableView.editing){
		//clear()
		tableView.editing = NO;
	}
	else {
		// Messages()
		[((idoubs2AppDelegate*)[[UIApplication sharedApplication] delegate]).messagesViewController dismissModalViewControllerAnimated: YES];
	}

}

- (IBAction) onBarBtnEditOrDoneClick: (id)sender{
	// [tableView beginUpdates];
	
	if(tableView.editing){
		// done()
		tableView.editing = NO;
		self.navigationItem.rightBarButtonItem.title = @"Edit";
		barBtnMessagesOrClear.title = @"Messages";
	}
	else {
		// edit()
		tableView.editing = YES;
		self.navigationItem.rightBarButtonItem.title = @"Done";
		barBtnMessagesOrClear.title = @"Clear All";
	}
	
	// [tableView endUpdates];
	
	// reload data
	[tableView reloadData];
}

- (IBAction) onButtonClick: (id)sender{
	if(sender == buttonSend){
		NSString* text = textView.text;
		[textView resignFirstResponder];
		textView.text = @"";
		
		[self resizeTextView];
		
		if(![NgnStringUtils isNullOrEmpty:text]){
			NgnHistorySMSEvent* event = [NgnHistoryEvent createSMSEventWithStatus:HistoryEventStatus_Outgoing
															   andRemoteParty: self.remoteParty
																   andContent:[text dataUsingEncoding:NSUTF8StringEncoding]];
			NgnMessagingSession* session = [NgnMessagingSession createOutgoingSessionWithStack:[[NgnEngine getInstance].sipService getSipStack] 
																				  andToUri: self.remotePartyUri];
			event.status = [session sendTextMessage:text contentType: kContentTypePlainText] ? HistoryEventStatus_Outgoing : HistoryEventStatus_Failed;
			[[NgnEngine getInstance].historyService addEvent: event];
		}
	}
	else if(sender == buttonAudioCall){
		[CallViewController makeAudioCallWithRemoteParty:self.remotePartyUri andSipStack:[[NgnEngine getInstance].sipService getSipStack]];
	}
	else if(sender == buttonVideoCall){
		[CallViewController makeAudioVideoCallWithRemoteParty:self.remotePartyUri andSipStack:[[NgnEngine getInstance].sipService getSipStack]];
	}
	else if(sender == buttonContactInfo){
		ContactDetailsController* contactDetails = [[ContactDetailsController alloc] initWithNibName:@"ContactDetails" bundle:nil];
		contactDetails.contact = self.contact;
		[self.navigationController pushViewController:contactDetails animated:YES];
		[contactDetails release];
	}
}

-(void)setRemoteParty:(NSString *) remoteParty_{
	[remoteParty release];
	remoteParty = [remoteParty_ retain];
	self.contact = [[NgnEngine getInstance].contactService getContactByPhoneNumber: remoteParty];
	self.remotePartyUri = [NgnUriUtils makeValidSipUri:self.remoteParty];
}

-(void)setRemoteParty:(NSString *)remoteParty_ andContact:(NgnContact*)contact_{
	[self->remoteParty release];
	self->remoteParty = [remoteParty_ retain];
	self.contact = contact_;
	self.remotePartyUri = [NgnUriUtils makeValidSipUri:self.remoteParty];
}

-(NSString*)remoteParty{
	return self->remoteParty;
}

- (void)dealloc {
	[tableView release];
	[viewFooter release];
	[textView release];
	[buttonSend release];
	[buttonAudioCall release];
	[buttonVideoCall release];
	[buttonContactInfo release];
	[viewTableHeader release];
	[barBtnMessagesOrClear release];
	[messages release];
	[remoteParty release];
	[remotePartyUri release];
	[contact release];
	
    [super dealloc];
}


//
//	UITextViewDelegate
//

- (void)textViewDidChange:(UITextView *)_textView{
	if(_textView == textView){
		[self resizeTextView];
	}
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
	BaloonCell *cell = (BaloonCell*)[_tableView dequeueReusableCellWithIdentifier: kBaloonCellIdentifier];
	if (cell == nil) {		
		cell = [[[NSBundle mainBundle] loadNibNamed:@"BaloonCell" owner:self options:nil] lastObject];
	}
	
	@synchronized(messages){
		[cell setEvent:[messages objectAtIndex: indexPath.row] forTableView:_tableView];
	}
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;{
	@synchronized(messages){
		return [BaloonCell getHeight:[messages objectAtIndex: indexPath.row] constrainedWidth:_tableView.frame.size.width];
	}
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	if (editingStyle == UITableViewCellEditingStyleDelete){
		NgnHistoryEvent* event = [messages objectAtIndex: indexPath.row];
        if (event) {
			[[NgnEngine getInstance].historyService deleteEvent: event];
		}
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	@synchronized(messages){
		/*
		 if([orderedSessions count] > indexPath.section){
		 NSMutableArray* values = [mContacts objectForKey: [orderedSessions objectAtIndex: indexPath.section]];
		 NgnContact* contact = [values objectAtIndex: indexPath.row];
		 if(contact && contact.displayName){
		 if(!mContactDetailsController){
		 mContactDetailsController = [[ContactDetailsController alloc] initWithNibName: @"ContactDetails" bundle:nil];
		 }
		 [mContactDetailsController setContact: contact];
		 [self.navigationController pushViewController: mContactDetailsController  animated: TRUE];
		 }
		 }*/
	}
}


@end
