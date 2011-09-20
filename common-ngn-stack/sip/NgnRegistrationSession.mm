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
#import "NgnRegistrationSession.h"
#import <Foundation/NSDictionary.h>
#import "NgnEngine.h"
#import "NgnConfigurationEntry.h"

#import "SipSession.h"

#undef kSessions
#define kSessions [NgnRegistrationSession getAllSessions]


//
//	private implementation
//

@interface NgnRegistrationSession (Private)
+(NSMutableDictionary*) getAllSessions;
-(NgnRegistrationSession*) internalInit: (NgnSipStack*)sipStack;
@end

@implementation NgnRegistrationSession (Private)

+(NSMutableDictionary*) getAllSessions{
	static NSMutableDictionary* sessions = nil;
	if(sessions == nil){
		sessions = [[NSMutableDictionary alloc] init];
	}
	return sessions;
}

-(NgnRegistrationSession*) internalInit: (NgnSipStack*)sipStack{
	if((self = (NgnRegistrationSession*)[super initWithSipStack:sipStack])){
		if(!(_mSession = new RegistrationSession(sipStack._stack))){
			TSK_DEBUG_ERROR("Failed to create session");
			return self;
		}
		[super initialize];
		[super setSigCompId: [sipStack getSigCompId]];
		[super setExpires:[[NgnEngine sharedInstance].configurationService getIntWithKey:NETWORK_REGISTRATION_TIMEOUT]];
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
        [super addCapsWithName:@"+g.3gpp.icsi-ref" andValue:@"\"urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel\""];
        [super addCapsWithName:@"+g.3gpp.icsi-ref" andValue:@"\"urn%3Aurn-7%3A3gpp-application.ims.iari.gsma-vs\""];
        // In addition, in RCS Release 3 the BA Client when used as a primary device will indicate the capability to receive SMS 
        // messages over IMS by registering the SMS over IP feature tag in accordance with [24.341]:
        [super addCapsWithName:@"+g.3gpp.cs-voice"];
	}
	return self;
}

@end




//
// default implementation
//

@implementation NgnRegistrationSession

+(NgnRegistrationSession*) createOutgoingSessionWithStack: (NgnSipStack*)sipStack andToUri: (NSString*)toUri{
	
	if(!sipStack){
		TSK_DEBUG_ERROR("Null Sip Stack");
		return nil;
	}
	NgnRegistrationSession* regSession;
	@synchronized(kSessions){
		regSession = [[[NgnRegistrationSession alloc] internalInit: sipStack] autorelease];
		if(regSession){
			if(toUri){
				[regSession setToUri:toUri];
			}
			[kSessions setObject:regSession forKey:[regSession getIdAsNumber]];
		}
	}
	return regSession;
}

+(NgnRegistrationSession*) createOutgoingSessionWithStack: (NgnSipStack*)sipStack{
	return [NgnRegistrationSession createOutgoingSessionWithStack:sipStack andToUri:nil];
}

+(NgnRegistrationSession*) getSessionWithId: (long)sessionId{
	NgnRegistrationSession *session;
	@synchronized(kSessions){
		session = [kSessions objectForKey:[NSNumber numberWithLong:sessionId]];
	}
	return session;
}

+(BOOL) hasSessionWithId: (long)sessionId{
	return [NgnRegistrationSession getSessionWithId:sessionId] != nil;
}

+(void) releaseSession: (NgnRegistrationSession**) session{
	@synchronized (kSessions){
		if (session && *session){
			if ([(*session) retainCount] == 1) {
				[kSessions removeObjectForKey:[*session getIdAsNumber]];
			}
			else {
				[(*session) release];
			}
			*session = nil;
		}
	}
}


-(void)dealloc{
	if(_mSession){
		delete _mSession, _mSession = tsk_null;
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

// Override from NgnSipSession
-(SipSession*)getSession{
	return _mSession;
}

@end
