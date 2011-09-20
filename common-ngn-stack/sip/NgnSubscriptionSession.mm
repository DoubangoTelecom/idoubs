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
#import "NgnSubscriptionSession.h"
#import "NgnContentType.h"

#undef kSessions
#define kSessions [NgnSubscriptionSession getAllSessions]


//
//	private implementation
//

@interface NgnSubscriptionSession (Private)
+(NSMutableDictionary*) getAllSessions;
-(NgnSubscriptionSession*) internalInitWithStack: (NgnSipStack*)sipStack andToUri: (NSString*)toUri_ andPackage:(NgnEventPackageType_t)package;
@end

@implementation NgnSubscriptionSession (Private)

+(NSMutableDictionary*) getAllSessions{
	static NSMutableDictionary* sessions = nil;
	if(sessions == nil){
		sessions = [[NSMutableDictionary alloc] init];
	}
	return sessions;
}

-(NgnSubscriptionSession*) internalInitWithStack: (NgnSipStack*)sipStack andToUri: (NSString*)toUri_ andPackage:(NgnEventPackageType_t)package{
	if((self = (NgnSubscriptionSession*)[super initWithSipStack:sipStack])){
		if(!(_mSession = new SubscriptionSession(sipStack._stack))){
			TSK_DEBUG_ERROR("Failed to create session");
			return self;
		}
		[super initialize];
		[super setSigCompId: [sipStack getSigCompId]];
		if(toUri_){
			[super setToUri:toUri_];
		}
		
		switch ((mPackage = package)) {
			case EventPackage_Conference:
			{
				[super addHeaderWithName:@"Event" andValue:@"conference"];
				[super addHeaderWithName:@"Accept" andValue:kContentTypeConferenceInfo];
                break;
			}
			
            case EventPackage_Dialog:
			{
				[super addHeaderWithName:@"Event" andValue:@"dialog"];
				[super addHeaderWithName:@"Accept" andValue:kContentTypeDialogInfo];
                break;
			}
			
            case EventPackage_MessageSummary:
			{
				[super addHeaderWithName:@"Event" andValue:@"message-summary"];
				[super addHeaderWithName:@"Accept" andValue:kContentTypeMessageSummary];
				break;
			}
			
            case EventPackage_Presence:
            case EventPackage_PresenceList:
            default:
			{
				[super addHeaderWithName:@"Event" andValue:@"presence"];
				if(mPackage == EventPackage_PresenceList){
					[super addHeaderWithName:@"Supported" andValue:@"eventlist"];
				}
				[super addHeaderWithName:@"Accept" andValue:[NSString stringWithFormat:@"%@, %@, %@, %@",
															 kContentTypeMultipartRelated,
															 kContentTypePidf,
															 kContentTypeRlmi,
															 kContentTypeRpid
															 ]
 				 ];
                break;
			}
            case EventPackage_RegInfo:
			{
				[super addHeaderWithName:@"Event" andValue:@"reg"];
				[super addHeaderWithName:@"Accept" andValue:kContentTypeRegInfo];
                // 3GPP TS 24.229 5.1.1.6 User-initiated deregistration
				_mSession->setSilentHangup(YES);
                break;
			}
			
            case EventPackage_SipProfile:
			{
				[super addHeaderWithName:@"Event" andValue:@"sip-profile"];
                [super addHeaderWithName:@"Accept" andValue:kContentTypeOMADeferredList];
                break;
			}
			
            case EventPackage_UAProfile:
			{
				[super addHeaderWithName:@"Event" andValue:@"ua-profile"];
				[super addHeaderWithName:@"Accept" andValue:kContentTypeXcapDiff];
                break;
			}
			
            case EventPackage_WInfo:
			{
				[super addHeaderWithName:@"Event" andValue:@"presence.winfo"];
				[super addHeaderWithName:@"Accept" andValue:kContentTypeWatcherInfo];
                break;
			}
			
            case EventPackage_XcapDiff:
			{
				[super addHeaderWithName:@"Event" andValue:@"xcap-diff"];
				[super addHeaderWithName:@"Accept" andValue:kContentTypeXcapDiff];
                break;
			}
		}
	}
	return self;
}

@end


//
// default implementation
//

@implementation NgnSubscriptionSession

-(NgnEventPackageType_t) eventPackage{
	return mPackage;
}

-(BOOL)subscribe{
	if(_mSession){
		return _mSession->subscribe();
	}
	TSK_DEBUG_ERROR("Null session");
	return NO;
}

-(BOOL)unSubscribe{
	if(_mSession){
		return _mSession->unSubscribe();
	}
	TSK_DEBUG_ERROR("Null session");
	return NO;
}

+(NgnSubscriptionSession*) createOutgoingSessionWithStack: (NgnSipStack*)sipStack andToUri: (NSString*)toUri_ andPackage:(NgnEventPackageType_t)package
{
	if(!sipStack){
		TSK_DEBUG_ERROR("Null Sip Stack");
		return nil;
	}
	
	NgnSubscriptionSession* subSession;
	@synchronized(kSessions){
		subSession = [[[NgnSubscriptionSession alloc] internalInitWithStack:sipStack 
																						  andToUri:toUri_ 
																						 andPackage:package] autorelease];
		if(subSession){
			[kSessions setObject: subSession forKey:[subSession getIdAsNumber]];
		}
	}
	return subSession;
}

+(NgnSubscriptionSession*) createOutgoingSessionWithStack: (NgnSipStack*)sipStack andPackage:(NgnEventPackageType_t)package
{
	return [NgnSubscriptionSession createOutgoingSessionWithStack:sipStack 
														 andToUri:nil 
															andPackage:package];
}

+(NgnSubscriptionSession*) createOutgoingSessionWithStack: (NgnSipStack*)sipStack
{
	return [NgnSubscriptionSession createOutgoingSessionWithStack:sipStack 
														 andToUri:nil 
														andPackage:EventPackage_PresenceList];
}

+(NgnSubscriptionSession*) getSessionWithId: (long)sessionId{
	NgnSubscriptionSession *session;
	@synchronized(kSessions){
		session = [kSessions objectForKey:[NSNumber numberWithLong:sessionId]];
	}
	return session;
}

+(BOOL) hasSessionWithId: (long)sessionId{
	return [NgnSubscriptionSession getSessionWithId:sessionId] != nil;
}

+(void) releaseSession: (NgnSubscriptionSession**) session{
	@synchronized (kSessions){
		if (session && *session){
			if ([(*session) retainCount] == 1) {
				[kSessions removeObjectForKey: [*session getIdAsNumber]];
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

-(void)dealloc{
	if(_mSession){
		delete _mSession, _mSession = tsk_null;
	}
	
	[super dealloc];
}

@end
