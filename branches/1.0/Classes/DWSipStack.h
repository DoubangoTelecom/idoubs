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

+(void) setCodecs:(tdav_codec_id_t) codecs;

@end
