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
#import "PeoplePicker.h"

#import "iOSNgnStack.h"

@interface MessageHistoryEntry : NSObject{
@private
	long long eventId;
	NSString* remoteParty;
	NSString* content;
	NSDate* date;
	NSTimeInterval start;
}

@property(nonatomic,readonly) long long eventId;
@property(nonatomic,retain) NSString *remoteParty;
@property(nonatomic,retain) NSString *content;
@property(nonatomic,retain) NSDate *date;

@end

@interface MessagesViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,PeoplePickerDelegate> {
@private
	UITableView *tableView;
	UIView *viewNoMessages;
	UIButton *buttonComposeMessage;
	NSMutableArray* messages;
	
	UIBarButtonItem *navigationItemEdit;
	UIBarButtonItem *navigationItemDone;
	UIBarButtonItem *navigationItemCompose;
	
	NgnContact *pickedContact;
	NgnPhoneNumber *pickedNumber;
}

@property(nonatomic,retain) IBOutlet UITableView *tableView;
@property(nonatomic,retain) IBOutlet UIView *viewNoMessages;
@property(nonatomic,retain) IBOutlet UIButton *buttonComposeMessage;

- (IBAction) onButtonNavivationItemClick: (id)sender;
- (IBAction) onButtonComposeClick: (id)sender;

@end
