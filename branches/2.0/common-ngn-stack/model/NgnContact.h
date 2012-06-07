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
#import <AddressBook/AddressBook.h>

#import "utils/NgnPredicate.h"
#import "model/NgnPhoneNumber.h"


typedef NSMutableArray NgnContactMutableArray;
typedef NSArray NgnContactArray;

@class NgnPhoneNumber;

@interface NgnContact : NSObject {
@protected
	int32_t id;
	NSString* displayName;
	NSString* firstName;
	NSString* lastName;
	NSMutableArray* phoneNumbers;
	NSData* picture;
	
@private
	// to be used for any purpose (e.g. category)
	NSObject* opaque;
}

#if TARGET_OS_IPHONE
-(NgnContact*)initWithABRecordRef:(const ABRecordRef)record;
#elif TARGET_OS_MAC
-(NgnContact*)initWithABPerson:(const ABPerson*)person;
#endif /* TARGET_OS_IPHONE */
-(NgnPhoneNumber*)getPhoneNumberWithPredicate:(NSPredicate*)predicate;


@property(readonly) int32_t id;
@property(readonly) NSString* displayName;
@property(readonly) NSString* firstName;
@property(readonly) NSString* lastName;
@property(readonly) NSMutableArray* phoneNumbers;
@property(readonly) NSData* picture;
@property(readwrite, retain, nonatomic) NSObject* opaque;

@end
