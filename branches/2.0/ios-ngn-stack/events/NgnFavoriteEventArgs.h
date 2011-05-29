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

#import "events/NgnEventArgs.h"
#import "media/NgnMediaType.h"

#define kNgnFavoriteEventArgs_Name @"NgnFavoriteEventArgs_Name"

typedef enum NgnFavoriteEventTypes_e {
	FAVORITE_ITEM_ADDED,
	FAVORITE_ITEM_REMOVED,
	FAVORITE_ITEM_UPDATED,
	FAVORITE_ITEM_MOVED,
	
	FAVORITE_RESET,
}
NgnFavoriteEventTypes_t;

@interface NgnFavoriteEventArgs : NgnEventArgs {
	long long favoriteId;
	NgnFavoriteEventTypes_t eventType;
	NgnMediaType_t mediaType;
}

-(NgnFavoriteEventArgs*) initWithType: (NgnFavoriteEventTypes_t)type andMediaType: (NgnMediaType_t) mediaType;
-(NgnFavoriteEventArgs*) initWithFavoriteId: (long long)favoriteId andEventType:(NgnFavoriteEventTypes_t)type andMediaType: (NgnMediaType_t) mediaType;

@property(readonly) long long favoriteId;
@property(readonly) NgnFavoriteEventTypes_t eventType;
@property(readonly) NgnMediaType_t mediaType;

@end
