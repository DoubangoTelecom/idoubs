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
#import "NgnSipStack.h"
#import "NgnStringUtils.h"

#include "tsk_debug.h"

@implementation NgnSipStack

-(NgnSipStack*) initWithSipCallback: (const SipCallback*) callback andRealmUri: (NSString*) realmUri andIMPIUri: (NSString*) impiUri andIMPUUri: (NSString*)impuUri{
	if((self = [super init])){
		_mSipStack = new SipStack(const_cast<SipCallback*>(callback), [realmUri UTF8String], [impiUri UTF8String], [impuUri UTF8String]);
		if(_mSipStack){
			// Sip headers
			_mSipStack->addHeader("Allow", "INVITE, ACK, CANCEL, BYE, MESSAGE, OPTIONS, NOTIFY, PRACK, UPDATE, REFER");
			_mSipStack->addHeader("Privacy", "none");
			_mSipStack->addHeader("P-Access-Network-Info", "ADSL;utran-cell-id-3gpp=00000000");
#if TARGET_OS_IPHONE
			_mSipStack->addHeader("User-Agent", "IM-client/OMA1.0 ios-ngn-stack/v00 (doubango r000)");
#elif TARGET_OS_MAC
			_mSipStack->addHeader("User-Agent", "IM-client/OMA1.0 osx-ngn-stack/v00 (doubango r000)");
#endif
		}
		else{
			TSK_DEBUG_ERROR("Failed to create new SipStack object");
		}
	}
	return self;
}

- (void)dealloc {
	if(_mSipStack){
		delete _mSipStack;
	}
	[super dealloc];
}

-(STACK_STATE_T) getState{
	return mState;
}

-(void) setState: (STACK_STATE_T)newState{
	mState = newState;
}

-(BOOL) start{
	if(_mSipStack){
		return _mSipStack->start();
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setRealm: (NSString *)realmUri{
	if(_mSipStack){
		return _mSipStack->setRealm([realmUri UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setIMPI: (NSString *) impiUri{
	if(_mSipStack){
		return _mSipStack->setIMPI([impiUri UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setIMPU: (NSString *) impuUri{
	if(_mSipStack){
		return _mSipStack->setIMPU([impuUri UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setPassword: (NSString*) password{
	if(_mSipStack){
		return _mSipStack->setPassword([password UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setAMF: (NSString*) amf{
	if(_mSipStack){
		return _mSipStack->setAMF([amf UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setOperatorId: (NSString*) opid{
	if(_mSipStack){
		return _mSipStack->setOperatorId([opid UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setProxyCSCFWithFQDN: (NSString*) fqdn andPort: (unsigned short) port andTransport: (NSString*) transport andIPVersion: (NSString *) ipversion{
	if(_mSipStack){
		return _mSipStack->setProxyCSCF([fqdn UTF8String], port, [transport UTF8String], [ipversion UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setLocalIP: (NSString*) ip{
	if(_mSipStack){
		return _mSipStack->setLocalIP([ip UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setLocalPort: (unsigned short) port{
	if(_mSipStack){
		return _mSipStack->setLocalPort(port);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setEarlyIMS: (BOOL) enabled{
	if(_mSipStack){
		return _mSipStack->setEarlyIMS(enabled);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) addHeaderName: (NSString*) name andValue: (NSString*) value{
	if(_mSipStack){
		return _mSipStack->addHeader([name UTF8String], [value UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) removeHeader: (NSString*) name{
	if(_mSipStack){
		return _mSipStack->removeHeader([name UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) addDnsServer: (NSString*) ip{
	if(_mSipStack){
		return _mSipStack->addDnsServer([ip UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setDnsDiscovery: (BOOL) enabled{
	if(_mSipStack){
		return _mSipStack->setDnsDiscovery(enabled);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setAoRWithIP: (NSString*) ip andPort: (unsigned short) port{
	if(_mSipStack){
		return _mSipStack->setAoR([ip UTF8String], port);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}


-(BOOL) setSigCompParamsWithDMS: (unsigned) dms andSMS: (unsigned) sms andCPB: (unsigned) cpb andPresDict: (BOOL) enablePresDict{
	if(_mSipStack){
		return _mSipStack->setSigCompParams(dms, sms, cpb, enablePresDict);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(NSString*) getSigCompId{
	return mCompId;
}

-(void) setSigCompId: (NSString*)compId{
	if(mCompId != nil && mCompId != compId && _mSipStack){
		_mSipStack->removeHeader([mCompId UTF8String]);
	}
	
	[mCompId release], mCompId = [compId retain];
	if(mCompId != nil && _mSipStack){
		_mSipStack->addSigCompCompartment([mCompId UTF8String]);
	}
}

-(BOOL) setSTUNEnabled: (BOOL)enabled{
    if(_mSipStack){
		return _mSipStack->setSTUNEnabled(enabled);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setSTUNServerIP: (NSString*) ip andPort: (unsigned short) port{
	if(_mSipStack){
		return _mSipStack->setSTUNServer([ip UTF8String], port);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setSTUNCredLogin: (NSString*) login andPassword: (NSString*) password{
	if(_mSipStack){
		return _mSipStack->setSTUNCred([login UTF8String], [password UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}


-(NSString *) dnsENUMWithService: (NSString *) service andE164Num: (NSString *) e164num andDomain: (NSString*) domain{
	if(_mSipStack){
		return [NSString stringWithCString: _mSipStack->dnsENUM([service UTF8String], [e164num UTF8String], [domain UTF8String]) encoding: NSUTF8StringEncoding];
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return nil;
}

-(NSString *) dnsNaptrSrvWithDomain: (NSString *) domain andService: (NSString *) service andPort: (unsigned short*) port{
	if(_mSipStack){
		return [NSString stringWithCString: _mSipStack->dnsNaptrSrv([domain UTF8String], [service UTF8String], port) encoding: NSUTF8StringEncoding];
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return nil;
}

-(NSString *) dnsSrvWithService: (NSString *) service andPort: (unsigned short*) port{
	if(_mSipStack){
		return [NSString stringWithCString: _mSipStack->dnsSrv([service UTF8String], port) encoding: NSUTF8StringEncoding];
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return nil;
}

-(BOOL) setSSLCertificates: (NSString*)privKey andPubKey:(NSString*)pubKey andCAKey:(NSString*)caKey andVerify: (BOOL)verify{
    if(_mSipStack){
        return _mSipStack->setSSLCertificates([privKey UTF8String], [pubKey UTF8String], [caKey UTF8String], verify);
    }
    TSK_DEBUG_ERROR("Null embedded SipStack");
    return NO;
}

-(BOOL) setSSLCertificates: (NSString*)privKey andPubKey:(NSString*)pubKey andCAKey:(NSString*)caKey{
    return [self setSSLCertificates: privKey andPubKey:pubKey andCAKey:caKey andVerify:FALSE];
}

-(NSString*)getPreferredIdentity{
	char* _preferredIdentity = _mSipStack->getPreferredIdentity();
	NSString* preferredIdentity = [NgnStringUtils toNSString: _preferredIdentity];
	TSK_FREE(_preferredIdentity);
	return preferredIdentity;
}

-(BOOL) isValid{
	if(_mSipStack){
		return _mSipStack->isValid();
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(SipStack*) getStack{
	return _mSipStack;
}

-(BOOL) stop{
	if(_mSipStack){
		return _mSipStack->stop();
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

+(void) setCodecs:(tdav_codec_id_t) codecs{
	SipStack::setCodecs(codecs);
}


@end
