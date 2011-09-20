/*
 * Copyright (C) 2010 Mamadou Diop.
 *
 * Contact: Mamadou Diop <diopmamadou(at)doubango.org>
 *       
 * This file is part of idoubs Project (http://code.google.com/p/idoubs)
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

#import "tinysip.h"

@interface DWSipUri : NSObject {
	tsip_uri_t* uri;
}

-(DWSipUri*)initWithUri: (NSString*)uriString;

-(NSString*)paramValue:(NSString*)pname;

+(BOOL)isValid: (NSString*)uriString;
+(NSString*)friendlyName: (NSString*)uriString;

@property(readonly) BOOL isValid;
@property(readonly) NSString* scheme;
@property(readonly) NSString* host;
@property(readonly) short port;
@property(readonly) NSString* userName;
@property(readonly) NSString* password;
@property(readonly) NSString* displayName;

@end
