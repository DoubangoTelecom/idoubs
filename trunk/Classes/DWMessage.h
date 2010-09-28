//
//  DWSdpMessage.h
//  iDoubs
//
//  Created by Mamadou DIOP on 8/30/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "tinysip.h"

/* ======================== DWSdpMessage ========================*/
@interface DWSdpMessage : NSObject
{
	tsdp_message_t* message;
}

-(id) initWithMessage: (tsdp_message_t*)message;

@end

/* ======================== DWSipMessage ========================*/
@interface DWSipMessage : NSObject {

	tsip_message_t* message;
	DWSdpMessage* sdpMessage;
}

-(DWSipMessage*) initWithMessage: (tsip_message_t*)message;

-(NSString*) sipHeaderValueWithType: (tsip_header_type_t)type;
-(NSString*) sipHeaderValueWithType: (tsip_header_type_t)type atIndex: (unsigned)index;

@end




/* ======================== DWMsrpMessage ========================*/