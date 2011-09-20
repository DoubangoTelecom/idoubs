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

@interface ChatViewController : UIViewController<UITableViewDelegate,UITableViewDataSource, UITextViewDelegate> {
@private
	UITableView *tableView;
	UIView *viewTableHeader;
	UITextView *textView;
	UIView *viewFooter;
	UIBarButtonItem *barBtnMessagesOrClear;
	UIButton *buttonSend;
	UIButton *buttonAudioCall;
	UIButton *buttonVideoCall;
	UIButton *buttonContactInfo;
	
	NSMutableArray* messages;
	NgnContact* contact;
	NSString* remoteParty;
	NSString* remotePartyUri;
}

@property(nonatomic,retain) IBOutlet UITableView *tableView;
@property(nonatomic,retain) IBOutlet UIView *viewTableHeader;
@property(nonatomic,retain) IBOutlet UITextView *textView;
@property(nonatomic,retain) IBOutlet UIView *viewFooter;
@property(nonatomic,retain) IBOutlet UIBarButtonItem* barBtnMessagesOrClear;
@property(nonatomic,retain) IBOutlet UIButton* buttonSend;
@property(nonatomic,retain) IBOutlet UIButton* buttonAudioCall;
@property(nonatomic,retain) IBOutlet UIButton* buttonVideoCall;
@property(nonatomic,retain) IBOutlet UIButton* buttonContactInfo;

@property(nonatomic,retain) NSString *remoteParty;

- (IBAction) onBarBtnMessagesOrClearClick: (id)sender;
- (IBAction) onBarBtnEditOrDoneClick: (id)sender;
- (IBAction) onButtonClick: (id)sender;

-(void)setRemoteParty:(NSString *)remoteParty andContact:(NgnContact*)contact;

@end
