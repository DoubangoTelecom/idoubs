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
#if TARGET_OS_IPHONE
#	import <Foundation/Foundation.h>
#elif TARGET_OS_MAC
#endif

#import "media/NgnMediaType.h"
#import "model/NgnContact.h"

typedef struct FavoriteMediaEntry_s {
	NSString* description;
	NgnMediaType_t mediaType;
}
FavoriteMediaEntry_t;

static const FavoriteMediaEntry_t kFavoriteMediaEntries[3] = { 
	{ @"Voice Call", MediaType_Audio},
	{ @"Video Call", MediaType_AudioVideo}, 
	{ @"Text Message", MediaType_SMS}, 
};

@interface NgnFavorite : NSObject {
	long long id;
	NSString *number;
	NgnMediaType_t mediaType;
	
	BOOL contactAlreadyChecked;
	NgnContact* contact;
	
@private
	// to be used for any purpose (e.g. category)
	NSObject* opaque;
}

-(NgnFavorite*) initWithId: (long long)id andNumber: (NSString*)number andMediaType: (NgnMediaType_t)mediatype;
-(NgnFavorite*) initWithNumber: (NSString*)number andMediaType: (NgnMediaType_t)mediatype;
-(NSComparisonResult)compareFavoriteByDisplayName:(NgnFavorite *)otherFavorite;

@property(readwrite) long long id;
@property(readonly) NSString *number;
@property(readonly) NgnMediaType_t mediaType;

@property(readonly) NgnContact *contact;
@property(readonly) NSString *displayName;

@property(readwrite, retain, nonatomic) NSObject* opaque;

@end