/* Copyright (C) 2010-2011, Mamadou Diop.
 * Copyright (c) 2011, Doubango Telecom. All rights reserved.
 * 
 * Contact: Mamadou Diop <diopmamadou(at)doubango(dot)org>
 * 
 * This file is part of iDoubs Project ( http://code.google.com/p/idoubs )
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
 */
#import <Foundation/Foundation.h>

#include "SipStack.h"

typedef enum STACK_STATE_E {
	STACK_STATE_NONE, STACK_STATE_STARTING, STACK_STATE_STARTED, STACK_STATE_STOPPING, STACK_STATE_STOPPED
}
STACK_STATE_T;

@interface NgnSipStack : NSObject {
	STACK_STATE_T mState;
	NSString* mCompId;
	SipStack* _mSipStack;
}

-(NgnSipStack*) initWithSipCallback: (const SipCallback*) callback andRealmUri: (NSString*) realmUri andIMPIUri: (NSString*) impiUri andIMPUUri: (NSString*)impuUri;

@property(readwrite,getter=getState,setter=setState:) STACK_STATE_T state;
@property(readonly,getter=getPreferredIdentity) NSString *preferredIdentity;
@property(readonly,getter=getStack) SipStack *_stack;

-(STACK_STATE_T) getState;
-(void) setState: (STACK_STATE_T)newState;

-(BOOL) start;
-(BOOL) setRealm: (NSString *)realmUri;
-(BOOL) setIMPI: (NSString *) impiUri;
-(BOOL) setIMPU: (NSString *) impuUri;
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
-(NSString*) getSigCompId;
-(void) setSigCompId: (NSString*)compId;

-(BOOL) setSTUNEnabled: (BOOL)enabled;
-(BOOL) setSTUNServerIP: (NSString*) ip andPort: (unsigned short) port;
-(BOOL) setSTUNCredLogin: (NSString*) login andPassword: (NSString*) password;

-(NSString *) dnsENUMWithService: (NSString *) service andE164Num: (NSString *) e164num andDomain: (NSString*) domain;
-(NSString *) dnsNaptrSrvWithDomain: (NSString *) domain andService: (NSString *) service andPort: (unsigned short*) port;
-(NSString *) dnsSrvWithService: (NSString *) service andPort: (unsigned short*) port;

-(BOOL) setSSLCertificates: (NSString*)privKey andPubKey:(NSString*)pubKey andCAKey:(NSString*)caKey andVerify: (BOOL)verify;
-(BOOL) setSSLCertificates: (NSString*)privKey andPubKey:(NSString*)pubKey andCAKey:(NSString*)caKey;

-(NSString*)getPreferredIdentity;

-(BOOL) isValid;
-(SipStack*) getStack;
-(BOOL) stop;

+(void) setCodecs:(tdav_codec_id_t) codecs;

@end
