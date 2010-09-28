//
//  DWSipMessage.m
//  iDoubs
//
//  Created by Mamadou DIOP on 8/30/10.
//  Copyright 2010 doubango. All rights reserved.
//

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