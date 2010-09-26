//
//  HistoryViewController.m
//  iDoubs
//
//  Created by Mamadou DIOP on 8/27/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import "HistoryViewController.h"
#import "DWSipStack.h"

#import "ServiceManager.h"
#import "iDoubsAppDelegate.h"

@implementation HistoryViewController

@synthesize delegateDialer;

-(void)awakeFromNib{
	[super awakeFromNib];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(onHitoryChangedEvent:)
	 name:@"HistoryChanged" object:nil];
	
	self->dateFormatterDuration = [[NSDateFormatter alloc] init];
	[self->dateFormatterDuration setDateFormat:@"mm:ss"];
	
	self->dateFormatterDate = [[NSDateFormatter alloc] init];
	[self->dateFormatterDate setTimeStyle:NSDateFormatterNoStyle];
	[self->dateFormatterDate setDateStyle:NSDateFormatterMediumStyle];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {	
	return [[SharedServiceManager.historyService events] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	
    // Set up the cell
	HistoryEvent* event = (HistoryEvent*)[[SharedServiceManager.historyService events] objectAtIndex:indexPath.row];
	
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	cell.textLabel.text = event.remoteParty;
	
	NSString* date = [self->dateFormatterDate stringFromDate:[NSDate dateWithTimeIntervalSince1970:event.start]];
	NSString* duration = [self->dateFormatterDuration stringFromDate:[NSDate dateWithTimeIntervalSince1970:(event.end - event.start)]];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", date, duration];
	
	switch(event.type){
		case HistoryEventType_Audio:
		case HistoryEventType_AudioVideo:
		{	
			switch (event.status) {
				case HistoryEventStatus_Outgoing:
					cell.imageView.image = [UIImage imageNamed:@"call_outgoing_45.png"];
					break;
				case HistoryEventStatus_Incoming:
					cell.imageView.image = [UIImage imageNamed:@"call_incoming_45.png"];
					break;
				case HistoryEventStatus_Missed:
				case HistoryEventStatus_Failed:
				default:
					cell.imageView.image = [UIImage imageNamed:@"call_missed_45.png"];
					break;
			}
			break;
		}
		case HistoryEventType_SMS:
		case HistoryEventType_Chat:
		case HistoryEventType_FileTransfer:
		default:
			break;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	HistoryEvent* event = (HistoryEvent*)[[SharedServiceManager.historyService events] objectAtIndex:indexPath.row];
	[self.delegateDialer setAddress:event.remoteParty];
	
    iDoubsAppDelegate *appDelegate = (iDoubsAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.tabBarController setSelectedIndex:tab_index_dialer];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to add the Edit button to the navigation bar.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.title = @"History";
	

}


/*
 // Override to support editing the list
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support conditional editing of the list
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support rearranging the list
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the list
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 }
 */

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

-(void) onHitoryChangedEvent:(NSNotification*)notification {
	[self.tableView reloadData];
}

- (void)dealloc {
    	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[dateFormatterDuration release];
	[dateFormatterDate release];
	
	[super dealloc];
}


@end
