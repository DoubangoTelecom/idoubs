//
//  DWSipUri.h
//  iDoubs
//
//  Created by Mamadou DIOP on 9/27/10.
//  Copyright 2010 doubango. All rights reserved.
//

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
