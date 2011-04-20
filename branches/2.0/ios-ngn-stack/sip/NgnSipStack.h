#import <Foundation/Foundation.h>

#include "SipStack.h"

typedef enum STACK_STATE_E {
	NONE, STARTING, STARTED, STOPPING, STOPPED
}
STACK_STATE_T;

@interface NgnSipStack : NSObject {
	STACK_STATE_T mState;
	NSString* mCompId;
	SipStack* mSipStack;
}

-(NgnSipStack*) initWithSipCallback: (const SipCallback*) callback andRealmUri: (NSString*) realmUri andIMPIUri: (NSString*) impiUri andIMPUUri: (NSString*)impuUri;

-(STACK_STATE_T) getState;
-(void) setState: (STACK_STATE_T)state;

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
-(NSString*) getCompId;
-(void) setCompId: (NSString*)compId;

-(BOOL) setSTUNServerIP: (NSString*) ip andPort: (unsigned short) port;
-(BOOL) setSTUNCredLogin: (NSString*) login andPassword: (NSString*) password;

-(NSString *) dnsENUMWithService: (NSString *) service andE164Num: (NSString *) e164num andDomain: (NSString*) domain;
-(NSString *) dnsNaptrSrvWithDomain: (NSString *) domain andService: (NSString *) service andPort: (unsigned short*) port;
-(NSString *) dnsSrvWithService: (NSString *) service andPort: (unsigned short*) port;

-(BOOL) isValid;
-(BOOL) stop;

+(void) setCodecs:(tdav_codec_id_t) codecs;

@end
