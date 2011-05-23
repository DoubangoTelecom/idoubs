#import "ContactsViewController.h"

@interface ContactsViewController(Private)
-(void) refreshData;
@end

@implementation ContactsViewController(Private)

-(void) refreshData{
	@synchronized(mContacts){
		[mContacts removeAllObjects];
		NgnContactMutableArray* contacts = [[mContactService contacts] retain];
		NSString *lastGroup = @"$", *group;
		NSMutableArray* lastArray = nil;
		for (NgnContact* contact in contacts) {
			if(!contact || [NgnStringUtils isNullOrEmpty: contact.displayName] || (![NgnStringUtils isNullOrEmpty: searchBar.text] && [contact.displayName rangeOfString: searchBar.text].location == NSNotFound)){
				continue;
			}
			// filter: FIXME
			if(mFilterGroup != FilterGroupAll){
				continue;
			}
			
			group = [contact.displayName substringToIndex: 1];
			if([group caseInsensitiveCompare: lastGroup] != NSOrderedSame){
				lastGroup = group;
				// NSLog(@"group=%@", group);
				[lastArray release];
				lastArray = [[NSMutableArray alloc] init];
				[mContacts setObject: lastArray forKey: lastGroup];
			}
			[lastArray addObject: contact];
		}
		
		[lastArray release];
		[contacts release];
		
		[orderedSections release];
		orderedSections = [[[mContacts allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] retain];
	}
}

@end

@implementation ContactsViewController

@synthesize tableView;
@synthesize toolBar;
@synthesize searchBar;
@synthesize viewToolbar;
@synthesize barButtonItemAll;
@synthesize barButtonItemWiphone;
@synthesize barButtonItemOnline;
@synthesize barButtonItemAdd;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	mFilterGroup = FilterGroupAll;
	
	if(!mContacts){
		mContacts = [[NSMutableDictionary alloc] init];
	}
	
	// get contact service instance
	mContactService = [[NgnEngine getInstance].contactService retain];
	
	// load data
	[self refreshData];
	
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
			mFilterGroup = FilterGroupAll;
		}
		else if(sender.tag == barButtonItemWiphone.tag){
			mFilterGroup = FilterGroupWiPhone;
		}
		else if(sender.tag == barButtonItemOnline.tag){
			mFilterGroup = FilterGroupOnline;
		}
		
		[self refreshData];
		[self.tableView reloadData];
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    [mContacts removeAllObjects];
	[self.tableView reloadData];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	[mContactDetailsController release], mContactDetailsController = nil;
	[mContactService release];
	[mContacts release];
	[orderedSections release];
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear: animated];
	[self.navigationController setNavigationBarHidden: YES];
}

- (void)viewWillDisappear:(BOOL)animate{
	[super viewWillDisappear: animate];
	[self.navigationController setNavigationBarHidden: NO];
}

- (void)dealloc {
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
	[tableView reloadData];
	
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
	[self refreshData];
	[tableView reloadData];
}


//
//	UITableView
//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [orderedSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	@synchronized(mContacts){
		if([orderedSections count] > section){
			NSMutableArray* values = [mContacts objectForKey: [orderedSections objectAtIndex: section]];
			return [values count];
		}
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	@synchronized(mContacts){
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
	
	@synchronized(mContacts){
		if([orderedSections count] > indexPath.section){
			NSMutableArray* values = [mContacts objectForKey: [orderedSections objectAtIndex: indexPath.section]];
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
	@synchronized(mContacts){
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
	@synchronized(mContacts){
		if([orderedSections count] > indexPath.section){
			NSMutableArray* values = [mContacts objectForKey: [orderedSections objectAtIndex: indexPath.section]];
			NgnContact* contact = [values objectAtIndex: indexPath.row];
			if(contact && contact.displayName){
				if(!mContactDetailsController){
					mContactDetailsController = [[ContactDetailsController alloc] initWithNibName: @"ContactDetails" bundle:nil];
				}
				[mContactDetailsController setContact: contact];
				[self.navigationController pushViewController: mContactDetailsController  animated: TRUE];
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
