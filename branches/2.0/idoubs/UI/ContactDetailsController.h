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

#import "iOSNgnStack.h"

@interface ContactDetailsController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate> {
	UILabel *labelDisplayName;
	UIImageView *imageViewAvatar;
	UITableView *tableViewPhones;
	UITableView *tableViewEmails;
	
	UIButton *buttonVideoCall;
	UIButton *buttonTextMessage;
	UIButton *buttonAddToFavorites;
	
	NgnContact *contact;
	int addToFavoritesLastIndex;
}

@property(nonatomic, readonly, copy) NSString *reuseIdentifier;
@property(nonatomic,retain) IBOutlet UILabel *labelDisplayName;
@property(nonatomic,retain) IBOutlet UIImageView *imageViewAvatar;
@property(nonatomic,retain) IBOutlet UITableView *tableViewPhones;
@property(nonatomic,retain) IBOutlet UITableView *tableViewEmails;

@property(nonatomic,retain) IBOutlet UIButton *buttonVideoCall;
@property(nonatomic,retain) IBOutlet UIButton *buttonTextMessage;
@property(nonatomic,retain) IBOutlet UIButton *buttonAddToFavorites;

@property(nonatomic,retain) NgnContact *contact;

- (IBAction) onButtonClicked: (id)sender;

@end
