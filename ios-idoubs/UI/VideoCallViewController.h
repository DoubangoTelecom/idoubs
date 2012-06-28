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

#import "CallViewController.h"
#import "TransparentToolbar.h"

@interface VideoCallViewController : CallViewController {
	UIImageView *imageViewRemoteVideo;
	UIView *viewLocalVideo;
	
	UIView *viewTop;
	UILabel *labelRemoteParty;
	UILabel *labelStatus;
	
	UIView *viewToolbar;
	UIButton *buttonToolBarMute;
	UIButton *buttonToolBarEnd;
	UIButton *buttonToolBarToggle;
	UIButton *buttonToolBarVideo;
	
	UIView *viewPickHangUp;
	UIButton *buttonPick;
	UIButton *buttonHangUp;
	
	UIImageView *imageSecure;
    
    iOSGLView* glViewVideoRemote;
	
	NgnAVSession* videoSession;
	BOOL sendingVideo;
}

@property (retain, nonatomic) IBOutlet UIImageView* imageViewRemoteVideo;
@property (retain, nonatomic) IBOutlet UIView* viewLocalVideo;

@property (retain, nonatomic) IBOutlet UIView* viewTop;
@property (retain, nonatomic) IBOutlet UILabel *labelRemoteParty;
@property (retain, nonatomic) IBOutlet UILabel *labelStatus;

@property (retain, nonatomic) IBOutlet UIView* viewToolbar;
@property (retain, nonatomic) IBOutlet UIButton *buttonToolBarMute;
@property (retain, nonatomic) IBOutlet UIButton *buttonToolBarEnd;
@property (retain, nonatomic) IBOutlet UIButton *buttonToolBarToggle;
@property (retain, nonatomic) IBOutlet UIButton *buttonToolBarVideo;

@property (retain, nonatomic) IBOutlet UIView *viewPickHangUp;
@property (retain, nonatomic) IBOutlet UIButton *buttonPick;
@property (retain, nonatomic) IBOutlet UIButton *buttonHangUp;

@property (retain, nonatomic) IBOutlet UIImageView *imageSecure;

@property (retain, nonatomic) IBOutlet iOSGLView* glViewVideoRemote;

- (IBAction) onButtonClick: (id)sender;

@end
