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

#import "DWActionConfig.h"


@implementation DWActionConfig

@synthesize handle;

-(id)init{
	self = [super init];
	if(self){
		self->handle = tsip_action_create(tsip_atype_config,
							TSIP_ACTION_SET_NULL());
	}
	else{
		self->handle = tsk_null;
	}
	
	return self;
}

-(BOOL) addHeaderWithName: (NSString*) name andValue: (NSString*) value{
	return (tsip_action_set(self->handle, 
				TSIP_ACTION_SET_HEADER([name UTF8String], [value UTF8String]),
				TSIP_ACTION_SET_NULL()) == 0);
}

-(DWActionConfig*) setMediaStringForType: (tmedia_type_t) type withKey: (NSString*) key withValue: (NSString*) value{
	const char* _key = [key UTF8String];
	const char* _value = [value UTF8String];
	tsip_action_set(self->handle,
			TSIP_ACTION_SET_MEDIA(
					TMEDIA_SESSION_SET_STR(type, _key, _value),
					TMEDIA_SESSION_SET_NULL()),
			TSIP_ACTION_SET_NULL());
	
	return self;
}

-(DWActionConfig*) setMediaIntForType: (tmedia_type_t) type withKey: (NSString*) key withValue: (int) value{
	const char* _key = [key UTF8String];
	tsip_action_set(self->handle,
			TSIP_ACTION_SET_MEDIA(
					TMEDIA_SESSION_SET_INT32(type, _key, value),
					TMEDIA_SESSION_SET_NULL()),
			TSIP_ACTION_SET_NULL());
	return self;
}

-(void)dealloc{
	TSK_OBJECT_SAFE_FREE(self->handle);
	[super dealloc];
}
	
@end
