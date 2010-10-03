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

#import "DWMessage.h"


/* ======================== DWSdpMessage ========================*/
@implementation DWSdpMessage

-(id) initWithMessage: (tsdp_message_t*)_message{
	self = [super init];
	if(self){
		self->message = tsk_object_ref(_message);
	}
	return self;
}

-(void) dealloc{
	TSK_OBJECT_SAFE_FREE(self->message);
	[super dealloc];
}

@end


/* ======================== DWSipMessage ========================*/
@implementation DWSipMessage

-(DWSipMessage*) initWithMessage: (tsip_message_t*)_message{
	self = [super init];
	if(self){
		self->message = tsk_object_ref(_message);
		self->sdpMessage = nil;
	}
	return self;
}

-(NSString*) sipHeaderValueWithType: (tsip_header_type_t)type{
	return [self sipHeaderValueWithType:type atIndex: 0];
}

-(NSString*) sipHeaderValueWithType: (tsip_header_type_t)type atIndex: (unsigned)index{
	const tsip_header_t* header;
	char* value = tsk_null;
	if((header = tsip_message_get_headerAt(self->message, type, index))){
		
		switch(header->type){ // Hack to avoid parameters
			case tsip_htype_From:
				value = tsip_uri_tostring(((const tsip_header_From_t*)header)->uri, tsk_false, tsk_false);
			case tsip_htype_To:
				value = tsip_uri_tostring(((const tsip_header_To_t*)header)->uri, tsk_false, tsk_false);
				break;
			case tsip_htype_P_Asserted_Identity:
				value = tsip_uri_tostring(((const tsip_header_P_Asserted_Identity_t*)header)->uri, tsk_false, tsk_false);
				break;
				
			default:
				value = tsip_header_value_tostring(header);
				break;
		}
	}
	
	NSString* stringValue = [NSString stringWithUTF8String:value];
	
	TSK_FREE(value);
	
	return stringValue;
}

-(void) dealloc{
	TSK_OBJECT_SAFE_FREE(self->message);
	[self->sdpMessage release];
	[super dealloc];
}

@end