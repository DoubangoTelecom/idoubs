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

#import "NgnFavorite.h"
#import "NgnEngine.h"

@implementation NgnFavorite

@synthesize id;
@synthesize number;
@synthesize mediaType;
@synthesize opaque;

-(NgnFavorite*) initWithId: (long long) id_ andNumber: (NSString*)number_ andMediaType: (NgnMediaType_t)mediatype_{
	if((self = [super init])){
		self->id = id_;
		self->number = [number_ retain];
		self->mediaType = mediatype_;
		self->contactAlreadyChecked = NO;
	}
	return self;
}

-(NgnFavorite*) initWithNumber: (NSString*)number_ andMediaType: (NgnMediaType_t)mediatype_{
	return [self initWithId:0 andNumber:number_ andMediaType:mediatype_];
}

-(NgnContact *)contact{
	if(!self->contactAlreadyChecked && self->contact == nil){
		self->contactAlreadyChecked = YES;
		self->contact = [[[NgnEngine sharedInstance].contactService getContactByPhoneNumber: self.number] retain];
	}
	return self->contact;
}

-(NSString*)displayName{
	return self.contact ? self.contact.displayName : self.number;
}

-(NSComparisonResult)compareFavoriteByDisplayName:(NgnFavorite *)otherFavorite{
	return [self.displayName compare: otherFavorite.displayName];
}

-(void)dealloc{
	[number release];
	[contact release];
	[opaque release];
	
	[super dealloc];
}

@end

