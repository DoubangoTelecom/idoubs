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
#import "CallViewController.h"

@interface AudioCallViewController : CallViewController {
	UILabel *labelStatus;
	UILabel *labelRemoteParty;
	UIView *viewCenter;
	UIView *viewTop;
	UIView *viewBottom;
	UIButton *buttonHangup;
	UIButton *buttonAccept;
	UIButton *buttonMute;
	UIButton *buttonNumpad;
	UIButton *buttonSpeaker;
	UIButton *buttonHold;
	UIView *viewOptions;
	UIView *viewNumpad;
	
	NgnAVSession* audioSession;
	
	CGFloat buttonHangupWidth;
	CGFloat buttonAcceptWidth;
}

@property (retain, nonatomic) IBOutlet UILabel *labelStatus;
@property (retain, nonatomic) IBOutlet UILabel *labelRemoteParty;
@property (retain, nonatomic) IBOutlet UIView *viewCenter;
@property (retain, nonatomic) IBOutlet UIView *viewTop;
@property (retain, nonatomic) IBOutlet UIView *viewBottom;
@property (retain, nonatomic) IBOutlet UIButton *buttonHangup;
@property (retain, nonatomic) IBOutlet UIButton *buttonAccept;
@property (retain, nonatomic) IBOutlet UIButton *buttonMute;
@property (retain, nonatomic) IBOutlet UIButton *buttonNumpad;
@property (retain, nonatomic) IBOutlet UIButton *buttonSpeaker;
@property (retain, nonatomic) IBOutlet UIButton *buttonHold;
@property (retain, nonatomic) IBOutlet UIView *viewOptions;
@property (retain, nonatomic) IBOutlet UIView *viewNumpad;

- (IBAction) onButtonClick: (id)sender;

@end
