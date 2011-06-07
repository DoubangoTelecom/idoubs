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
#import "ContactsViewController.h"
#import "idoubs2AppDelegate.h"

//
// private implementation
//

@interface ContactsViewController(Private)
-(void) refreshData;
-(void) reloadData;
-(void) refreshDataAndReload;
-(void) onContactEvent:(NSNotification*)notification;
@end

@implementation ContactsViewController(Private)

-(void) refreshData{
	@synchronized(contacts){
		[contacts removeAllObjects];
		NgnContactMutableArray* contacts_ = [[[NgnEngine getInstance].contactService contacts] retain];
		NSString *lastGroup = @"$", *group;
		NSMutableArray* lastArray = nil;
		for (NgnContact* contact in contacts_) {
			if(!contact || [NgnStringUtils isNullOrEmpty: contact.displayName] || (![NgnStringUtils isNullOrEmpty: searchBar.text] && [contact.displayName rangeOfString: searchBar.text].location == NSNotFound)){
				continue;
			}
			// filter: FIXME
			if(filterGroup != FilterGroupAll){
				continue;
			}
			
			group = [contact.displayName substringToIndex: 1];
			if([group caseInsensitiveCompare: lastGroup] != NSOrderedSame){
				lastGroup = group;
				// NSLog(@"group=%@", group);
				[lastArray release];
				lastArray = [[NSMutableArray alloc] init];
				[contacts setObject: lastArray forKey: lastGroup];
			}
			[lastArray addObject: contact];
		}
		
		[lastArray release];
		[contacts_ release];
		
		[orderedSections release];
		orderedSections = [[[contacts allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] retain];
	}
}

-(void) reloadData{
	[self.tableView reloadData];
}

-(void) refreshDataAndReload{
	[self refreshData];
	[self reloadData];
}

-(void) onContactEvent:(NSNotification*)notification{
	NgnContactEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case CONTACT_RESET_ALL:
		{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 40000
			switch ([UIApplication sharedApplication].applicationState) {
				case UIApplicationStateActive:
					[self refreshDataAndReload];
					break;
				case UIApplicationStateInactive:
				case UIApplicationStateBackground:
					self->nativeContactsChangedWhileInactive = YES;
					break;
			}
#else
			[self refreshDataAndReload];
#endif
			break;
		}
		default:
			break;
	}
}

@end


//
// default implementation
//

@implementation ContactsViewController

@synthesize tableView;
@synthesize toolBar;
@synthesize searchBar;
@synthesize viewToolbar;
@synthesize labelDisplayMode;
@synthesize barButtonItemAll;
@synthesize barButtonItemWiphone;
@synthesize barButtonItemOnline;
@synthesize barButtonItemAdd;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self->nativeContactsChangedWhileInactive = NO;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	filterGroup = FilterGroupAll;
	
	if(!contacts){
		contacts = [[NSMutableDictionary alloc] init];
	}
	
	// load data and register for notifications
	[self refreshData];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onContactEvent:) name:kNgnContactEventArgs_Name object:nil];
	
	self.navigationItem.title = @"Contacts";
	
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.tableHeaderView = searchBar;
	
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	
	searching = NO;
	letUserSelectRow = YES;
}

- (void) onButtonToolBarItemClick: (id)_sender{
	UIBarButtonItem* sender = ((UIBarButtonItem*)_sender);
	
	if(sender.tag == barButtonItemAdd.tag){
	}
	else {
		barButtonItemAll.style = UIBarButtonItemStyleBordered;
		barButtonItemWiphone.style = UIBarButtonItemStyleBordered;
		barButtonItemOnline.style = UIBarButtonItemStyleBordered;
		sender.style = UIBarButtonItemStyleDone;
		
		if(sender.tag == barButtonItemAll.tag){
			filterGroup = FilterGroupAll;
		}
		else if(sender.tag == barButtonItemWiphone.tag){
			filterGroup = FilterGroupWiPhone;
		}
		else if(sender.tag == barButtonItemOnline.tag){
			filterGroup = FilterGroupOnline;
		}
		
		[self refreshDataAndReload];
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    [contacts removeAllObjects];
	[self reloadData];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear: animated];
	
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear: animated];
	[self.navigationController setNavigationBarHidden: YES];
	
	if(self->nativeContactsChangedWhileInactive){
		self->nativeContactsChangedWhileInactive = NO;
		[self refreshDataAndReload];
	}
}

- (void)viewWillDisappear:(BOOL)animate{
	[super viewWillDisappear: animate];
	[self.navigationController setNavigationBarHidden: NO];
}

- (void)dealloc {
	[tableView release];
	[toolBar release];
	[searchBar release];
	[viewToolbar release];
	[labelDisplayMode release];
	[barButtonItemAll release];
	[barButtonItemWiphone release];
	[barButtonItemOnline release];
	[barButtonItemAdd release];
	
	[contactDetailsController release], contactDetailsController = nil;
	[contacts release];
	[orderedSections release];
	
    [super dealloc];
}

//
//	Searching
//

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	searching = YES;
	letUserSelectRow = NO;
	
	tableView.scrollEnabled = NO;
	tableView.frame = CGRectMake(tableView.frame.origin.x, 
								 tableView.frame.origin.y - viewToolbar.frame.size.height, 
								 tableView.frame.size.width, 
								 tableView.frame.size.height + viewToolbar.frame.size.height);
	viewToolbar.hidden = YES;
    self.searchBar.showsCancelButton = YES;
	
	// disable indexes
	[self reloadData];
	
	return YES;
}  

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
	letUserSelectRow = YES;
	searching = NO;
	
	tableView.frame = CGRectMake(tableView.frame.origin.x, 
								 tableView.frame.origin.y + viewToolbar.frame.size.height, 
								 tableView.frame.size.width, 
								 tableView.frame.size.height - viewToolbar.frame.size.height);
	viewToolbar.hidden = NO;
    self.searchBar.showsCancelButton = NO;
	self.searchBar.text = @"";
	[self.searchBar resignFirstResponder];
	
	tableView.scrollEnabled = YES;
	
	return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
	[self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
	[self refreshDataAndReload];
}


//
//	UITableView
//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [orderedSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	@synchronized(contacts){
		if([orderedSections count] > section){
			NSMutableArray* values = [contacts objectForKey: [orderedSections objectAtIndex: section]];
			return [values count];
		}
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	@synchronized(contacts){
		return [orderedSections objectAtIndex: section];
	}
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;{
	return [ContactViewCell getHeight];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	ContactViewCell *cell = (ContactViewCell*)[_tableView dequeueReusableCellWithIdentifier: kContactViewCellIdentifier];
	if (cell == nil) {		
		cell = [[[NSBundle mainBundle] loadNibNamed:@"ContactViewCell" owner:self options:nil] lastObject];
	}
	
	@synchronized(contacts){
		if([orderedSections count] > indexPath.section){
			NSMutableArray* values = [contacts objectForKey: [orderedSections objectAtIndex: indexPath.section]];
			NgnContact* contact = [values objectAtIndex: indexPath.row];
			if(contact && contact.displayName){
				[cell setDisplayName: contact.displayName];
			}
		}
	}
	
	return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	if(searching){
		return nil;
	}
	return orderedSections;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	NSInteger i = 0;
	@synchronized(contacts){
		for(NSString *title_ in orderedSections){
			if([title_ isEqualToString: title]){
				return i;
			}
			++i;
		}
		return i;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	@synchronized(contacts){
		if([orderedSections count] > indexPath.section){
			NSMutableArray* values = [contacts objectForKey: [orderedSections objectAtIndex: indexPath.section]];
			NgnContact* contact = [values objectAtIndex: indexPath.row];
			if(contact && contact.displayName){
				if(!contactDetailsController){
					contactDetailsController = [[ContactDetailsController alloc] initWithNibName: @"ContactDetails" bundle:nil];
				}
				contactDetailsController.contact = contact;
				[self.navigationController pushViewController: contactDetailsController  animated: TRUE];
			}
		}
	}
}

- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(letUserSelectRow){
		return indexPath;
	}
	else{
		return nil;
	}
}

@end
