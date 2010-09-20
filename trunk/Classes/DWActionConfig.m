//
//  ActionConfig.m
//  iDoubs
//
//  Created by Mamadou DIOP on 8/27/10.
//  Copyright 2010 doubango. All rights reserved.
//

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
