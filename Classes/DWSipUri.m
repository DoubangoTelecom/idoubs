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
