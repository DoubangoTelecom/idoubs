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
#ifndef WIPHONE_CONSTATNTS_H
#define WIPHONE_CONSTATNTS_H

/* == Colors == */
#define kColorBlack				0x000000
#define kColorWhite				0xFFFFFF
#define kColorViolet			0x9900FF
#define kColorGray				0x736F6E
#define kColorBaloonOutTop		0xAFD662
#define kColorBaloonOutMiddle	0xBEDF7D
#define kColorBaloonOutBottom	0xD5E7B4
#define kColorBaloonOutBorder	0xC8E490
#define kColorBaloonInTop		0xDDDDDD
#define kColorBaloonInMiddle	0xD4D4D4
#define kColorBaloonInBottom	0xBEBEBE
#define kColorBaloonInBorder	0xBCBCBC

#define kColorsDarkBlack [NSArray arrayWithObjects: \
(id)[[UIColor colorWithRed:.1f green:.1f blue:.1f alpha:0.7] CGColor], \
(id)[[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.7] CGColor], \
nil]
#define kColorsBlue [NSArray arrayWithObjects: \
(id)[[UIColor colorWithRed:.0f green:.0f blue:.5f alpha:0.7] CGColor], \
(id)[[UIColor colorWithRed:0.f green:0.f blue:1.f alpha:0.7] CGColor], \
nil]
#define kColorsLightBlack [NSArray arrayWithObjects: \
(id)[[UIColor colorWithRed:.2f green:.2f blue:.2f alpha:0.7] CGColor], \
(id)[[UIColor colorWithRed:.1f green:.1f blue:.1f alpha:0.7] CGColor], \
(id)[[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.7] CGColor], \
nil]

#define kButtonStateAll (UIControlStateSelected | UIControlStateNormal || UIControlStateHighlighted)


#define kCallTimerSuicide	1.5f

#endif /* WIPHONE_CONSTATNTS_H */

