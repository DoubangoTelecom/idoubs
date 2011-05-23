#import "MessagesViewController.h"

#import "idoubs2AppDelegate.h"
#import "idoubs2Constants.h"

#import "ChatViewController.h"
#import "MessageCell.h"


//
//	MessageHistoryEntry
//

@implementation MessageHistoryEntry

@synthesize eventId;
@synthesize remoteParty;
@synthesize content;
@synthesize date;

-(MessageHistoryEntry*)initWithEvent: (NgnHistorySMSEvent*)event{
	if((self = [super init])){
		self->eventId = event.id;
		self.remoteParty = event.remoteParty;
		self.date = [NSDate dateWithTimeIntervalSince1970: event.start];
		self.content = event.contentAsString;
	}
	return self;
}


-(void)dealloc{
	[remoteParty release];
	[content release];
	[date release];
	
	[super dealloc];
}

@end


//
//	Private
//

@interface MessagesViewController(Private)
-(void) refreshData;
-(void) refreshDataAndReload;
-(void) onHistoryEvent:(NSNotification*)notification;
@end

@implementation MessagesViewController(Private)

-(void) refreshData{
	@synchronized(messages){
		[messages removeAllObjects];
		NSArray* events = [[[[NgnEngine getInstance].historyService events] allValues] sortedArrayUsingSelector:@selector(compareHistoryEventByDate:)];
		for (NgnHistoryEvent* event in events) {
			if(!event || !(event.mediaType & MediaType_SMS)){
				continue;
			}
			
			MessageHistoryEntry* entry = [[MessageHistoryEntry alloc] initWithEvent:(NgnHistorySMSEvent*)event];
			[messages addObject:entry];
			[entry release];
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
			if((eargs.mediaType & MediaType_SMS)){
				//NgnHistoryEvent* event = [[[NgnEngine getInstance].historyService events] objectForKey: [NSNumber numberWithLongLong: eargs.eventId]];
				//FIXME
				[self refreshDataAndReload];
				//[messages insertObject:event atIndex:0];
				//[tableView reloadData];
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
}

@end


//
//	Default
//

@implementation MessagesViewController

@synthesize tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if(!messages){
		messages = [[NSMutableArray alloc] init];
	}
	
	// refresh data set datasource
    [self refreshData];
	tableView.delegate = self;
	tableView.dataSource = self;
	
	self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	self.modalPresentationStyle = UIModalPresentationPageSheet;
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onHistoryEvent:) name:kNgnHistoryEventArgs_Name object:nil];
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

- (IBAction) onButtonToolBarEditOrDoneClick: (id)sender{
	tableView.editing = !tableView.editing;
}

- (IBAction) onButtonToolBarWriteClick: (id)sender{
	idoubs2AppDelegate* appDelegate = ((idoubs2AppDelegate*) [[UIApplication sharedApplication] delegate]);
	if(self.navigationController){
		[self.navigationController pushViewController:appDelegate.chatViewController  animated:YES];
	}
	else {
		[self presentModalViewController: appDelegate.chatViewController animated: YES];
	}
}

- (void)dealloc {
	[messages release];
	
    [super dealloc];
}

// guidi graziella
// GUIDI GRAZIELLA

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
		[cell setEntry:[messages objectAtIndex: indexPath.row]];
	}
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;{
	return [MessageCell getHeight];
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	if (editingStyle == UITableViewCellEditingStyleDelete){
		MessageHistoryEntry* entry = [messages objectAtIndex: indexPath.row];
        if (entry) {
			[[NgnEngine getInstance].historyService deleteEventWithId: entry.eventId];
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
