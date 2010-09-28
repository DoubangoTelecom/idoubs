//
//  DWSipUri.m
//  iDoubs
//
//  Created by Mamadou DIOP on 9/27/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import "DWSipUri.h"


@implementation DWSipUri


-(DWSipUri*)initWithUri: (NSString*)uriString{
	if((self = [super init])){
		const char* _uriString = [uriString UTF8String];
		self->uri = tsip_uri_parse(_uriString, tsk_strlen(_uriString));
	}
	return self;
}


-(NSString*)paramValue:(NSString*)pname{
	if(self->uri && self->uri->params){
		const char* pvalue = tsk_params_get_param_value(self->uri->params,  [pname UTF8String]);
		return [NSString stringWithUTF8String: pvalue];
	}
	return nil;
}

+(BOOL)isValid: (NSString*)uriString{
	tsip_uri_t* _uri;
	bool ret = false;
	
	const char* _uriString = [uriString UTF8String];
	if((_uri = tsip_uri_parse(_uriString, tsk_strlen(_uriString)))){
		ret = (_uri->type != uri_unknown)
		&& (!tsk_strnullORempty(_uri->host));
		TSK_OBJECT_SAFE_FREE(_uri);
	}
	return ret;
}

+(NSString*)friendlyName: (NSString*)uriString{
	tsip_uri_t* _uri;
	NSString* fName = uriString;
	const char* _uriString = [uriString UTF8String];
	if((_uri = tsip_uri_parse(_uriString, tsk_strlen(_uriString)))){
		// TODO: lookup into addressBook
		if(_uri->display_name){
			fName = [NSString stringWithUTF8String: _uri->display_name];
		}
		else if(_uri->user_name){
			fName = [NSString stringWithUTF8String: _uri->user_name];
		}
		TSK_OBJECT_SAFE_FREE(_uri);
	}
	
	return fName;
}

-(BOOL) isValid{
	return (self->uri && self->uri->type != uri_unknown)
	&& (!tsk_strnullORempty(self->uri->host));
}

-(NSString*) scheme{
	if(self->uri && self->uri->scheme){
		return [NSString stringWithUTF8String: self->uri->scheme];
	}
	return nil;
}

-(NSString*) host{
	if(self->uri && self->uri->host){
		return [NSString stringWithUTF8String: self->uri->host];
	}
	return nil;
}

-(short) port{
	return self->uri? self->uri->port : 0;
}

-(NSString*) userName{
	if(self->uri && self->uri->user_name){
		return [NSString stringWithUTF8String: self->uri->user_name];
	}
	return nil;
}

-(NSString*) password{
	if(self->uri && self->uri->password){
		return [NSString stringWithUTF8String: self->uri->password];
	}
	return nil;
}

-(NSString*) displayName{
	if(self->uri && self->uri->display_name){
		return [NSString stringWithUTF8String: self->uri->display_name];
	}
	return nil;
}


-(void)dealloc{
	TSK_OBJECT_SAFE_FREE(self->uri);
	
	[super dealloc];
}

@end
