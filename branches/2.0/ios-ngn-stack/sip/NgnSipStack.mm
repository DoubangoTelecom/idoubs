#import "NgnSipStack.h"

#include "tsk_debug.h"

@implementation NgnSipStack

-(NgnSipStack*) initWithSipCallback: (const SipCallback*) callback andRealmUri: (NSString*) realmUri andIMPIUri: (NSString*) impiUri andIMPUUri: (NSString*)impuUri{
	self = [super init];
	if(self){
		mSipStack = new SipStack(const_cast<SipCallback*>(callback), [realmUri UTF8String], [impiUri UTF8String], [impuUri UTF8String]);
		if(mSipStack){
			// Sip headers
			mSipStack->addHeader("Allow", "INVITE, ACK, CANCEL, BYE, MESSAGE, OPTIONS, NOTIFY, PRACK, UPDATE, REFER");
			mSipStack->addHeader("Privacy", "none");
			mSipStack->addHeader("P-Access-Network-Info", "ADSL;utran-cell-id-3gpp=00000000");
			mSipStack->addHeader("User-Agent", "IM-client/OMA1.0 ios-ngn-stack/v00 (doubango r500)");
		}
		else{
			TSK_DEBUG_ERROR("Failed to create new SipStack object");
		}
	}
	return self;
}

- (void)dealloc {
	if(mSipStack){
		delete mSipStack;
	}
	[super dealloc];
}

-(STACK_STATE_T) getState{
	return mState;
}

-(void) setState: (STACK_STATE_T)state{
	mState = state;
}

-(BOOL) start{
	if(mSipStack){
		return mSipStack->start();
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setRealm: (NSString *)realmUri{
	if(mSipStack){
		return mSipStack->setRealm([realmUri UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setIMPI: (NSString *) impiUri{
	if(mSipStack){
		return mSipStack->setIMPI([impiUri UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setIMPU: (NSString *) impuUri{
	if(mSipStack){
		return mSipStack->setIMPU([impuUri UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setPassword: (NSString*) password{
	if(mSipStack){
		return mSipStack->setPassword([password UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setAMF: (NSString*) amf{
	if(mSipStack){
		return mSipStack->setAMF([amf UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setOperatorId: (NSString*) opid{
	if(mSipStack){
		return mSipStack->setOperatorId([opid UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setProxyCSCFWithFQDN: (NSString*) fqdn andPort: (unsigned short) port andTransport: (NSString*) transport andIPVersion: (NSString *) ipversion{
	if(mSipStack){
		return mSipStack->setProxyCSCF([fqdn UTF8String], port, [transport UTF8String], [ipversion UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setLocalIP: (NSString*) ip{
	if(mSipStack){
		return mSipStack->setLocalIP([ip UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setLocalPort: (unsigned short) port{
	if(mSipStack){
		return mSipStack->setLocalPort(port);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setEarlyIMS: (BOOL) enabled{
	if(mSipStack){
		return mSipStack->setEarlyIMS(enabled);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) addHeaderName: (NSString*) name andValue: (NSString*) value{
	if(mSipStack){
		return mSipStack->addHeader([name UTF8String], [value UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) removeHeader: (NSString*) name{
	if(mSipStack){
		return mSipStack->removeHeader([name UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) addDnsServer: (NSString*) ip{
	if(mSipStack){
		return mSipStack->addDnsServer([ip UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setDnsDiscovery: (BOOL) enabled{
	if(mSipStack){
		return mSipStack->setDnsDiscovery(enabled);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setAoRWithIP: (NSString*) ip andPort: (unsigned short) port{
	if(mSipStack){
		return mSipStack->setAoR([ip UTF8String], port);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}


-(BOOL) setSigCompParamsWithDMS: (unsigned) dms andSMS: (unsigned) sms andCPB: (unsigned) cpb andPresDict: (BOOL) enablePresDict{
	if(mSipStack){
		return mSipStack->setSigCompParams(dms, sms, cpb, enablePresDict);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(NSString*) getCompId{
	return mCompId;
}

-(void) setCompId: (NSString*)compId{
	if(mCompId != nil && mCompId != compId && mSipStack){
		mSipStack->removeHeader([mCompId UTF8String]);
	}
	
	[mCompId release], mCompId = [compId retain];
	if(mCompId != nil && mSipStack){
		mSipStack->addSigCompCompartment([mCompId UTF8String]);
	}
}

-(BOOL) setSTUNServerIP: (NSString*) ip andPort: (unsigned short) port{
	if(mSipStack){
		return mSipStack->setSTUNServer([ip UTF8String], port);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) setSTUNCredLogin: (NSString*) login andPassword: (NSString*) password{
	if(mSipStack){
		return mSipStack->setSTUNCred([login UTF8String], [password UTF8String]);
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}


-(NSString *) dnsENUMWithService: (NSString *) service andE164Num: (NSString *) e164num andDomain: (NSString*) domain{
	if(mSipStack){
		return [NSString stringWithCString: mSipStack->dnsENUM([service UTF8String], [e164num UTF8String], [domain UTF8String]) encoding: NSUTF8StringEncoding];
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return nil;
}

-(NSString *) dnsNaptrSrvWithDomain: (NSString *) domain andService: (NSString *) service andPort: (unsigned short*) port{
	if(mSipStack){
		return [NSString stringWithCString: mSipStack->dnsNaptrSrv([domain UTF8String], [service UTF8String], port) encoding: NSUTF8StringEncoding];
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return nil;
}

-(NSString *) dnsSrvWithService: (NSString *) service andPort: (unsigned short*) port{
	if(mSipStack){
		return [NSString stringWithCString: mSipStack->dnsSrv([service UTF8String], port) encoding: NSUTF8StringEncoding];
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return nil;
}

-(BOOL) isValid{
	if(mSipStack){
		return mSipStack->isValid();
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

-(BOOL) stop{
	if(mSipStack){
		return mSipStack->stop();
	}
	TSK_DEBUG_ERROR("Null embedded SipStack");
	return FALSE;
}

+(void) setCodecs:(tdav_codec_id_t) codecs{
	SipStack::setCodecs(codecs);
}


@end
