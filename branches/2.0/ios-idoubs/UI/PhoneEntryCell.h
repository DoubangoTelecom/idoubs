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

// Don't forget to change it in interface builder and you MUST define "reuseIdentifier" property
#undef kPhoneEntryCellIdentifier
#define kPhoneEntryCellIdentifier	@"PhoneEntryCellIdentifier"

@interface PhoneEntryCell : UITableViewCell {
	UILabel *labelPhoneType;
	UILabel *labelPhoneValue;
	NgnPhoneNumber* number;
}

@property(nonatomic, readonly, copy) NSString *reuseIdentifier;
@property(nonatomic, retain) NgnPhoneNumber *number;
@property (retain, nonatomic) IBOutlet UILabel *labelPhoneType;
@property (retain, nonatomic) IBOutlet UILabel *labelPhoneValue;

@end
