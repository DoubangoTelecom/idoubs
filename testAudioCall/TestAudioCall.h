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

@interface TestAudioCall : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UIActivityIndicatorView* activityIndicator;
	UILabel *labelStatus;
	UIView *viewStatus;
	UILabel *labelNumber;
	UILabel *labelDebugInfo;
	UIButton *buttonMakeAudioCall;
	
	NgnEngine* mEngine;
	NgnBaseService<INgnSipService>* mSipService;
	NgnBaseService<INgnConfigurationService>* mConfigurationService;
	NgnAVSession* mCurrentAVSession;
	BOOL mScheduleRegistration;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (retain, nonatomic) IBOutlet UILabel *labelStatus;
@property (retain, nonatomic) IBOutlet UIView *viewStatus;
@property (retain, nonatomic) IBOutlet UILabel *labelNumber;
@property (retain, nonatomic) IBOutlet UILabel *labelDebugInfo;
@property (retain, nonatomic) IBOutlet UIButton *buttonMakeAudioCall;

- (IBAction) onButtonNumpadClick: (id)sender;

@end
