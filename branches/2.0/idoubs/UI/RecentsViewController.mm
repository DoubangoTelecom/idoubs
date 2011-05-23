#import "RecentsViewController.h"

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
		NSArray* events = [[[mHistoryService events] allValues] sortedArrayUsingSelector:@selector(compareHistoryEventByDate:)];
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
	mContactService = [[NgnEngine getInstance].contactService retain];
	mHistoryService = [[NgnEngine getInstance].historyService retain];
	
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
			[[NgnEngine getInstance].historyService deleteEvent: event];
		}
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	@synchronized(mEvents){
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
