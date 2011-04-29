#import "NgnRegistrationSession.h"
#import <Foundation/NSDictionary.h>

static const NSMutableDictionary* kSessions = [[NSMutableDictionary alloc]init];

@implementation NgnRegistrationSession (Private)

-(NgnRegistrationSession*) internalInit: (NgnSipStack*)sipStack{
	if((self = (NgnRegistrationSession*)[super initWithSipStack:sipStack])){
		if(!(_mSession = new RegistrationSession([sipStack getStack]))){
			TSK_DEBUG_ERROR("Failed to create session");
			return self;
		}
		[super initialize];
		[super setSigCompId: [sipStack getSigCompId]];
		// FIXME: setExpires
		_mSession->setExpires(3600);
		/* support for 3GPP SMS over IP */
        [super addCapsWithName:@"+g.3gpp.smsip"];
        /* support for OMA Large message (as per OMA SIMPLE IM v1) */
        [super addCapsWithName:@"+g.oma.sip-im.large-message"];
		
		/* 3GPP TS 24.173
		 *
		 * 5.1 IMS communication service identifier
		 * URN used to define the ICSI for the IMS Multimedia Telephony Communication Service: urn:urn-7:3gpp-service.ims.icsi.mmtel. 
		 * The URN is registered at http://www.3gpp.com/Uniform-Resource-Name-URN-list.html.
		 * Summary of the URN: This URN indicates that the device supports the IMS Multimedia Telephony Communication Service.
		 *
		 * 5.2 Session control procedures
		 * The multimedia telephony participant shall include the g.3gpp. icsi-ref feature tag equal to the ICSI value defined 
		 * in subclause 5.1 in the Contact header field in initial requests and responses as described in 3GPP TS 24.229 [13].
		 */
        /* GSMA RCS phase 3 - 3.2 Registration */
        [super addCapsWithName:@"audio"];
        [super addCapsWithName:@"+g.3gpp.icsi-ref" andValue: @"\"urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel\""];
        [super addCapsWithName:@"+g.3gpp.icsi-ref" andValue: @"\"urn%3Aurn-7%3A3gpp-application.ims.iari.gsma-vs\""];
        // In addition, in RCS Release 3 the BA Client when used as a primary device will indicate the capability to receive SMS 
        // messages over IMS by registering the SMS over IP feature tag in accordance with [24.341]:
        [super addCapsWithName:@"+g.3gpp.cs-voice"];
	}
	return self;
}

@end


@implementation NgnRegistrationSession

+(NgnRegistrationSession*) createOutgoingSessionWithStack: (NgnSipStack*)sipStack andToUri: (NSString*)toUri{
	@synchronized(kSessions){
		NgnRegistrationSession* regSession = [[[NgnRegistrationSession alloc] internalInit:sipStack] autorelease];
		if(regSession){
			if(toUri){
				[regSession setToUri:toUri];
			}
			[kSessions setObject: regSession forKey:[regSession getIdAsNumber]];
		}
		return regSession;
	}
}

+(NgnRegistrationSession*) createOutgoingSessionWithStack: (NgnSipStack*)sipStack{
	return [NgnRegistrationSession createOutgoingSessionWithStack:sipStack andToUri:nil];
}

+(NgnRegistrationSession*) findSessionWithId: (long)sessionId{
	@synchronized(kSessions){
		return [kSessions objectForKey:[NSNumber numberWithLong:sessionId]];
	}
}

+(BOOL) hasSessionWithId: (long)sessionId{
	return [NgnRegistrationSession findSessionWithId:sessionId] != nil;
}

+(void) releaseSessionWithId: (long)sessionId{
	[kSessions removeObjectForKey:[NSNumber numberWithLong:sessionId]];
}


-(void)dealloc{
	if(_mSession){
		delete _mSession;
	}
	[super dealloc];
}

-(BOOL)register_{
	if(_mSession){
		return _mSession->register_();
	}
	TSK_DEBUG_ERROR("Null Sip Session");
	return FALSE;
}

-(BOOL)unRegister{
	if(_mSession){
		return _mSession->unRegister();
	}
	TSK_DEBUG_ERROR("Null Sip Session");
	return FALSE;
}

-(SipSession*)getSession{
	return _mSession;
}

@end
