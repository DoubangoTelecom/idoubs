//
//  SipStack.h
//  iDoubs
//
//  Created by Mamadou DIOP on 8/27/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWSafeObject.h"

#import "tinydav/tdav.h"
#import "tinysip.h"

@class DWSipEvent;

@protocol DWSipStackDelegate
- (int) onEvent: (DWSipEvent*)event;
@end

typedef enum STACK_STATE_E {
	STACK_STATE_NONE, STACK_STATE_STARTING, STACK_STATE_STARTED, STACK_STATE_STOPPING, STACK_STATE_STOPPED
}
STACK_STATE_T;

@interface DWSipStack : DWSafeObject {
	NSString* compId;
	NSObject<DWSipStackDelegate>* delegate;
}

-(DWSipStack *) initWithDelegate: (NSObject<DWSipStackDelegate>*) delegate realmUri: (NSString *)realm impiUri: (NSString *)impi impuUri: (NSString *)impu;

@property(readwrite) STACK_STATE_T state;
@property(readonly) tsip_stack_handle_t* handle;

-(BOOL) start;
-(BOOL) setRealm: (NSString *)realmUri;
-(BOOL) setIMPI: (NSString *) impiUri;
-(BOOL) setIMPU: (NSString *) impu_uri;
-(BOOL) setPassword: (NSString*) password;
-(BOOL) setAMF: (NSString*) amf;
-(BOOL) setOperatorId: (NSString*) opid;
-(BOOL) setProxyCSCFWithFQDN: (NSString*) fqdn andPort: (unsigned short) port andTransport: (NSString*) transport andIPVersion: (NSString *) ipversion;
-(BOOL) setLocalIP: (NSString*) ip;
-(BOOL) setLocalPort: (unsigned short) port;
-(BOOL) setEarlyIMS: (BOOL) enabled;
-(BOOL) addHeaderName: (NSString*) name andValue: (NSString*) value;
-(BOOL) removeHeader: (NSString*) name;
-(BOOL) addDnsServer: (NSString*) ip;
-(BOOL) setDnsDiscovery: (BOOL) enabled;
-(BOOL) setAoRWithIP: (NSString*) ip andPort: (unsigned short) port;

-(BOOL) setSigCompParamsWithDMS: (unsigned) dms andSMS: (unsigned) sms andCPB: (unsigned) cpb andPresDict: (BOOL) enablePresDict;
-(void) setSigCompId: (NSString*) compId;
-(NSString*)sigCompId;

-(BOOL) setSTUNServerIP: (NSString*) ip andPort: (unsigned short) port;
-(BOOL) setSTUNCredLogin: (NSString*) login andPassword: (NSString*) password;

-(NSString *) dnsENUMWithService: (NSString *) service andE164Num: (NSString *) e164num andDomain: (NSString*) domain;
-(NSString *) dnsNaptrSrvWithDomain: (NSString *) domain andService: (NSString *) service andPort: (unsigned short*) port;
-(NSString *) dnsSrvWithService: (NSString *) service andPort: (unsigned short*) port;

-(BOOL) isValid;
-(BOOL) stop;

@end
