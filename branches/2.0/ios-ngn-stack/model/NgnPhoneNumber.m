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
#import "NgnPhoneNumber.h"

@implementation NgnPhoneNumber

@synthesize number;
@synthesize description;
@synthesize opaque;
@synthesize type;

-(NgnPhoneNumber*) initWithNumber:(NSString*)number_ andDescription:(NSString*)desciption_ andType:(NgnPhoneNumberType_t)type_{
	if((self = [super init])){
		self->number = [number_ retain];
		self->description = [desciption_ retain];
		self->type = type_;
	}
	return self;
}

-(NgnPhoneNumber*) initWithNumber:(NSString*)number_ andDescription:(NSString*)desciption_{
	return [self initWithNumber:number_ andDescription:desciption_ andType:NgnPhoneNumberType_Mobile];
}

-(BOOL) emailAddress{
	return (self->type == NgnPhoneNumberType_Email);
}

-(void)dealloc{
	[self->number release];
	[self->description release];
	
	[self->opaque release];
	
	[super dealloc];
}

@end
