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
#import <UIKit/UIKit.h>
#import "ContactViewCell.h"
#import "ContactDetailsController.h"
#import "PickerViewControllerDelegate.h"

#import "iOSNgnStack.h"

typedef enum ContactsFilterGroup_e
{
	FilterGroupAll,
	FilterGroupOnline,
	FilterGroupWiPhone
}
ContactsFilterGroup_t;

typedef enum ContactsDisplayMode_e
{
	Display_None,
	Display_ChooseNumberForFavorite,
	Display_Searching
}
ContactsDisplayMode_t;


@interface ContactsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	UISearchBar *searchBar;
	UIToolbar *toolBar;
	UITableView *tableView;
	UIView *viewToolbar;
	UIBarButtonItem* barButtonItemAll;
	UIBarButtonItem* barButtonItemWiphone;
	UIBarButtonItem* barButtonItemOnline;
	UIBarButtonItem* barButtonItemAdd;
	
	ContactDetailsController* contactDetailsController;
	
	BOOL searching;
	BOOL letUserSelectRow;
	NSMutableDictionary* contacts;
	NSArray* orderedSections;
	
	ContactsFilterGroup_t filterGroup;
	ContactsDisplayMode_t displayMode;
}

@property(nonatomic,retain) IBOutlet UIView *viewToolbar;
@property(nonatomic,retain) IBOutlet UILabel *labelDisplayMode;
@property(nonatomic,retain) IBOutlet UIToolbar *toolBar;
@property(nonatomic,retain) IBOutlet UITableView *tableView;
@property(nonatomic,retain) IBOutlet UISearchBar *searchBar;
@property(nonatomic,retain) IBOutlet UIBarButtonItem* barButtonItemAll;
@property(nonatomic,retain) IBOutlet UIBarButtonItem* barButtonItemWiphone;
@property(nonatomic,retain) IBOutlet UIBarButtonItem* barButtonItemOnline;
@property(nonatomic,retain) IBOutlet UIBarButtonItem* barButtonItemAdd;

- (IBAction)onButtonToolBarItemClick: (id)sender;

@end
