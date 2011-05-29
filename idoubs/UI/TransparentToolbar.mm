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
#import "TransparentToolbar.h"


@implementation TransparentToolbar

//- (void)drawRect:(CGRect)rect {
 //   UIImage *image = [[UIImage imageNamed:@"keypad_placeholder"] retain];
  //  [image drawInRect:rect];
   // [image release];    
//}

// Override draw rect to avoid
// background coloring
//- (void)drawRect:(CGRect)rect {
    // do nothing in here
//}

// Set properties to make background
// translucent.
- (void) applyTranslucentBackground{
	self.backgroundColor = [UIColor clearColor];
	self.opaque = NO;
	self.translucent = YES;
}

- (id)initWithCoder:(NSCoder *)decoder { 
	self = [super initWithCoder:decoder]; 
	if (self) { 
		[self applyTranslucentBackground]; 
	} 
	return self; 
}

// Override init.
- (id) init{
	self = [super init];
	[self applyTranslucentBackground];
	return self;
}

// Override initWithFrame.
- (id) initWithFrame:(CGRect) frame{
	self = [super initWithFrame:frame];
	[self applyTranslucentBackground];
	return self;
}

@end
