//
//  ContactsViewController.h
//  wiPhone
//
//  Created by Mamadou DIOP on 4/30/11.
//  Copyright 2011 Tiscali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactViewCell.h"
#import "ContactDetailsController.h"

#import "iOSNgnStack.h"

typedef enum ContactsFilterGroup_e
{
	FilterGroupAll,
	FilterGroupOnline,
	FilterGroupWiPhone
}
ContactsFilterGroup_t;

@interface ContactsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	UISearchBar *searchBar;
	UIToolbar *toolBar;
	UITableView *tableView;
	UIView *viewToolbar;
	UIBarButtonItem* barButtonItemAll;
	UIBarButtonItem* barButtonItemWiphone;
	UIBarButtonItem* barButtonItemOnline;
	UIBarButtonItem* barButtonItemAdd;
	
	ContactDetailsController* mContactDetailsController;
	
	BOOL searching;
	BOOL letUserSelectRow;
	NgnBaseService<INgnContactService>* mContactService;
	NSMutableDictionary* mContacts;
	NSArray* orderedSections;
	
	ContactsFilterGroup_e mFilterGroup;
}

@property(nonatomic,retain) IBOutlet UIView *viewToolbar;
@property(nonatomic,retain) IBOutlet UIToolbar *toolBar;
@property(nonatomic,retain) IBOutlet UITableView *tableView;
@property(nonatomic,retain) IBOutlet UISearchBar *searchBar;
@property(nonatomic,retain) IBOutlet UIBarButtonItem* barButtonItemAll;
@property(nonatomic,retain) IBOutlet UIBarButtonItem* barButtonItemWiphone;
@property(nonatomic,retain) IBOutlet UIBarButtonItem* barButtonItemOnline;
@property(nonatomic,retain) IBOutlet UIBarButtonItem* barButtonItemAdd;

- (IBAction) onButtonToolBarItemClick: (id)sender;

@end
