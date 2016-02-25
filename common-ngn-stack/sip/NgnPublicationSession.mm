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
#import "NgnPublicationSession.h"
#import "NgnContentType.h"
#import "ActionConfig.h"
#import "NgnStringUtils.h"
#import "tsk_uuid.h"

#undef kSessions
#define kSessions [NgnPublicationSession getAllSessions]


// impu, basic, activity, note, basic, deviceid 
#define kPublishPayload							@"<?xml version=\"1.0\" encoding=\"utf-8\"?>" \
												@"<presence xmlns:caps=\"urn:ietf:params:xml:ns:pidf:caps\" xmlns:rpid=\"urn:ietf:params:xml:ns:pidf:rpid\" xmlns:pdm=\"urn:ietf:params:xml:ns:pidf:data-model\" xmlns:op=\"urn:oma:xml:prs:pidf:oma-pres\" entity=\"%@\" xmlns=\"urn:ietf:params:xml:ns:pidf\">" \
													@"<pdm:person id=\"FPNZFGON\">" \
														@"<op:overriding-willingness>" \
														@"<op:basic>%@</op:basic>" \
														@"</op:overriding-willingness>" \
														@"<rpid:activities>" \
															@"<rpid:%@ />" \
														@"</rpid:activities>" \
														@"<pdm:note>%@</pdm:note>" \
													@"</pdm:person>" \
													@"<pdm:device id=\"d1983\">" \
														@"<status>" \
															@"<basic>%@</basic>" \
														@"</status>" \
														@"<caps:devcaps>" \
															@"<caps:mobility>" \
															@"<caps:supported>" \
															@"<caps:mobile />" \
															@"</caps:supported>" \
															@"</caps:mobility>" \
														@"</caps:devcaps>" \
														@"<op:network-availability>" \
														@"<op:network id=\"IMS\">" \
														@"<op:active />" \
														@"</op:network>" \
														@"</op:network-availability>" \
														@"<pdm:deviceID>%@</pdm:deviceID>" \
													@"</pdm:device>" \
												@"</presence>"



//
//	private implementation
//

@interface NgnPublicationSession (Private)
+(NSMutableDictionary*) getAllSessions;
-(NgnPublicationSession*) internalInitWithStack:(NgnSipStack*)sipStack andToUri:(NSString*)toUri_;
+(NSString*) deviceId;
@end


@implementation NgnPublicationSession (Private)

+(NSMutableDictionary*) getAllSessions{
	static NSMutableDictionary* sessions = nil;
	if(sessions == nil){
		sessions = [[NSMutableDictionary alloc] init];
	}
	return sessions;
}

-(NgnPublicationSession*) internalInitWithStack:(NgnSipStack*)sipStack andToUri:(NSString*)toUri_{
	if((self = (NgnPublicationSession*)[super initWithSipStack:sipStack])){
		if(!(_mSession = new PublicationSession(sipStack._stack))){
			TSK_DEBUG_ERROR("Failed to create session");
			return self;
		}
		[super initialize];
		[super setSigCompId: [sipStack getSigCompId]];
		if(toUri_){
			[super setToUri:toUri_];
			[super setFromUri:toUri_];
		}
		
		// default
		[super addHeaderWithName:@"Event" andValue:@"presence"];
		[super addHeaderWithName:@"Content-Type" andValue:kContentTypePidf];
	}
	
	return self;
}

+(NSString*) deviceId {
    static NSString* sDeviceId = nil;
    if (!sDeviceId) {
        tsk_uuidstring_t uuid;
        tsk_uuidgenerate(&uuid);
        sDeviceId = [[NgnStringUtils toNSString:(const char*)uuid] retain];
    }
    return sDeviceId;
}

@end


//
//	default implementation
//
@implementation NgnPublicationSession

+(NSData*) createPresenceContentWithEntityUri:(NSString*)entityUri andStatus:(NgnPresenceStatus_t)status  andNote:(NSString*)note{
	NSString *basic = @"open";
	NSString *activity = @"unknown";
	
	switch(status){
		case PresenceStatus_Online:
			break;
		case PresenceStatus_Busy:
			activity = @"busy";
			break;
		case PresenceStatus_Away:
			activity = @"away";
			break;
		case PresenceStatus_BeRightBack:
			activity = @"vacation";
			break;
		case PresenceStatus_OnThePhone:
			activity = @"on-the-phone";
			break;
		case PresenceStatus_Offline:
			basic = @"close";
			break;
		case PresenceStatus_HyperAvail:
			break;
	}
	
	NSString *payload = [NSString stringWithFormat:kPublishPayload,
							entityUri,
							basic,
							activity,
							note,
							basic,
                            [NgnPublicationSession deviceId]
						 ];
	return [payload dataUsingEncoding:NSUTF8StringEncoding]; 
}
																						
+(NgnPublicationSession*) createOutgoingSessionWithStack:(NgnSipStack*)sipStack 
												andToUri:(NSString*)toUri_
												andEvent:(NSString*)event_
												andContentType:(NSString*)contentType_
{
	if(!sipStack){
		TSK_DEBUG_ERROR("Null Sip Stack");
		return nil;
	}
	@synchronized(kSessions){
		NgnPublicationSession *pubSession = [[NgnPublicationSession alloc] internalInitWithStack:sipStack 
																					andToUri:toUri_];
		if(pubSession){
			if(event_){
				pubSession.event = event_;
			}
			if(contentType_){
				pubSession.contentType = contentType_;
			}
			[kSessions setObject:pubSession forKey:[pubSession getIdAsNumber]];
			return pubSession;
		}
	}
	return nil;
}

+(NgnPublicationSession*) createOutgoingSessionWithStack:(NgnSipStack*)sipStack 
												andToUri:(NSString*)toUri
{
	return [NgnPublicationSession createOutgoingSessionWithStack:sipStack 
												 andToUri:toUri 
												 andEvent:nil 
												andContentType:nil];
}

+(NgnPublicationSession*) createOutgoingSessionWithStack:(NgnSipStack*)sipStack
{
	return [NgnPublicationSession createOutgoingSessionWithStack:sipStack 
														andToUri:nil 
														andEvent:nil 
														andContentType:nil];
}

+(NgnPublicationSession*) getSessionWithId:(long)sessionId{
	NgnPublicationSession *session;
	@synchronized(kSessions){
		session = [kSessions objectForKey:[NSNumber numberWithLong:sessionId]];
	}
	return session;
}

+(BOOL) hasSessionWithId:(long)sessionId{
	return [NgnPublicationSession getSessionWithId:sessionId] != nil;
}

+(void) releaseSession:(NgnPublicationSession**)session{
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

// Override from NgnSipSession
-(SipSession*)getSession{
	return _mSession;
}

-(BOOL)publishContent:(NSData*)content andEvent:(NSString*)event_ andContentType:(NSString*)contentType_{
	if(!_mSession || !content){
		TSK_DEBUG_ERROR("Invalid");
		return NO;
	}
	
	ActionConfig *_config = new ActionConfig();
	if(_config){
		if(event_){
			_config->addHeader("Event", [NgnStringUtils toCString:event_]);
		}
		if(contentType_){
			_config->addHeader("Content-Type", [NgnStringUtils toCString:contentType_]);
		}
	}
	// send pulish message
	BOOL ret = [self publishContent:content andActionConfig:_config];
	if(_config){
		delete _config, _config = tsk_null;
	}
	return ret;
}

-(BOOL)publishContent:(NSData*)content andActionConfig:(ActionConfig*)_config{
	if(!_mSession || !content){
		TSK_DEBUG_ERROR("Invalid parameter");
		return NO;
	}
	return _mSession->publish([content bytes], [content length], _config);
}

-(BOOL)publishContent:(NSData*)content{
	return [self publishContent:content andActionConfig:nil];
}

-(BOOL)unPublishWithConfig:(ActionConfig*)_config{
    if (_mSession) {
        return _mSession->unPublish(_config);
    }
    return NO;
}

-(BOOL)unPublish{
	return [self unPublishWithConfig:nil];
}

-(void)setContentType:(NSString *)contentType_{
	[mContentType release];
	mContentType = [contentType_ retain];
}

-(NSString *)getContentType{
	return mContentType;
}

-(void)setEvent:(NSString *)event_{
	[mEvent release];
	mEvent = [event_ retain];
}

-(NSString *)getEvent{
	return mEvent;
}

-(void)dealloc{
	if(_mSession){
		delete _mSession, _mSession = tsk_null;
	}
	
	[mContentType release];
	[mEvent release];
	[super dealloc];
}

@end
