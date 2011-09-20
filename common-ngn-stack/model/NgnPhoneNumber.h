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
#import <Foundation/Foundation.h>

typedef enum NgnPhoneNumberType_e
{
	NgnPhoneNumberType_Unknown,
	NgnPhoneNumberType_Mobile,
	NgnPhoneNumberType_Email
}
NgnPhoneNumberType_t;


@interface NgnPhoneNumber : NSObject {
@protected
	NSString* number;
	NSString* description;
	NgnPhoneNumberType_t type;
	
@private
	// to be used for any purpose (e.g. category)
	id opaque;
}

@property(readonly) NSString* number;
@property(readonly) BOOL emailAddress;
@property(readonly) NgnPhoneNumberType_t type;
@property(readonly) NSString* description;
@property(readwrite, retain, nonatomic) id opaque;

-(NgnPhoneNumber*) initWithNumber:(NSString*)_number andDescription:(NSString*)_desciption andType:(NgnPhoneNumberType_t)type;
-(NgnPhoneNumber*) initWithNumber:(NSString*)_number andDescription:(NSString*)_desciption;

@end
