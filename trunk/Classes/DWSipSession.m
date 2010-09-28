//
//  DWSipSession.m
//  iDoubs
//
//  Created by Mamadou DIOP on 8/30/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import "DWSipSession.h"

#import "DWSipStack.h"

/* ======================== DWSipSession ========================*/
static NSMutableDictionary *__sessions = nil;
static NSLock* __sessionsLock = nil;

// Private

@interface DWSipSession(Private)

-(void)internalInit:(DWSipStack*)_sipStack andHandle: (tsip_ssession_handle_t*)_handle;
-(DWSipSession*)initWithType:(SESSION_TYPE_T)_type andStack: (DWSipStack*)_sipStack;
-(DWSipSession*)initWithType: (SESSION_TYPE_T)_type andStack: (DWSipStack*)_sipStack andHandle: (tsip_ssession_handle_t*)_handle;

@end

@implementation DWSipSession(Private)
-(void)internalInit:(DWSipStack*)_sipStack andHandle: (tsip_ssession_handle_t*)_handle{
	if(_handle){
		/* "server-side-session" */
		if(tsip_ssession_take_ownership(_handle)){ /* should never happen */
			TSK_DEBUG_ERROR("Failed to take ownership");
			return;
		}
		self->handle = _handle;// retained by  tsip_ssession_take_ownership()
	}
	else{
		/* "client-side-session" */
		self->handle = tsip_ssession_create((tsip_stack_handle_t*)[_sipStack handle],
											TSIP_SSESSION_SET_USERDATA(self),
											TSIP_SSESSION_SET_NULL());
	}
	
	/* set userdata (context) and ref. the stack handle */
	tsip_ssession_set(self->handle,
					  TSIP_SSESSION_SET_USERDATA(self),
					  TSIP_SSESSION_SET_NULL());
	self->sipStack = [_sipStack retain];
	self->id = tsip_ssession_get_id(self->handle);
	self->state = SESSION_STATE_NONE;
	
	/*if(!__sessions){
		__sessions = [[NSMutableDictionary alloc] init];
	}
	if(!__sessionsLock){
		__sessionsLock = [[NSLock alloc] init];
	}
	[__sessionsLock lock];
	[__sessions setObject:self forKey:[NSNumber numberWithLong:self->id]];
	[__sessionsLock unlock];*/
	
	// FIXME: Sip Expires
	
	// Sip Headers (common to all sessions)
	[self addCaps:@"+g.oma.sip-im"];
	[self addCapsWithName:@"language" andValue: @"\"en,fr\""];
}

-(DWSipSession*)initWithType:(SESSION_TYPE_T)_type andStack: (DWSipStack*)_sipStack{
	self = [super init];
	if(self){
		self->type = _type;
		[self internalInit:_sipStack andHandle:tsk_null];
	}
	return self;
}

-(DWSipSession*)initWithType: (SESSION_TYPE_T)_type andStack: (DWSipStack*)_sipStack andHandle: (tsip_ssession_handle_t*)_handle{
	self = [super init];
	if(self){
		self->type = _type;
		[self internalInit:_sipStack andHandle:_handle];
	}
	return self;
}

@end


// Public
@implementation DWSipSession

@synthesize id;
@synthesize state;
@synthesize type;

-(BOOL) haveOwnership{
	return (tsip_ssession_have_ownership(self->handle) == tsk_true);
}

-(BOOL) addHeaderWithName: (NSString*) name andValue: (NSString*) value{
	return (tsip_ssession_set(self->handle,
				TSIP_SSESSION_SET_HEADER([name UTF8String], [value UTF8String]),
				TSIP_SSESSION_SET_NULL()) == 0);
}

-(BOOL) removeHeaderWithName: (NSString*) name{
	return (tsip_ssession_set(self->handle,
				TSIP_SSESSION_UNSET_HEADER([name UTF8String]),
				TSIP_SSESSION_SET_NULL()) == 0);
}

-(BOOL) addCapsWithName: (NSString*) name andValue: (NSString*) value{
	return (tsip_ssession_set(self->handle,
				TSIP_SSESSION_SET_CAPS([name UTF8String], [value UTF8String]),
				TSIP_SSESSION_SET_NULL()) == 0);
}

-(BOOL) addCaps: (NSString*) name{
	return (tsip_ssession_set(self->handle,
				TSIP_SSESSION_SET_CAPS([name UTF8String], tsk_null),
				TSIP_SSESSION_SET_NULL()) == 0);
}

-(BOOL) removeCaps: (NSString*) name{
	return (tsip_ssession_set(self->handle,
				TSIP_SSESSION_UNSET_CAPS([name UTF8String]),
				TSIP_SSESSION_SET_NULL()) == 0);
}

-(BOOL) setExpires: (unsigned) expires{
	return (tsip_ssession_set(self->handle,
				TSIP_SSESSION_SET_EXPIRES(expires),
				TSIP_SSESSION_SET_NULL()) == 0);
}

-(BOOL) setFromUri: (NSString*) _fromUri{
	[self->fromUri release], self->fromUri = [_fromUri retain];
	return (tsip_ssession_set(self->handle,
				TSIP_SSESSION_SET_FROM([fromUri UTF8String]),
				TSIP_SSESSION_SET_NULL()) == 0);
}

-(NSString*) fromUri{
	return self->fromUri;
}

-(BOOL) setToUri: (NSString*) _toUri{
	[self->toUri release], self->toUri = [_toUri retain];
	return (tsip_ssession_set(self->handle,
				TSIP_SSESSION_SET_TO([toUri UTF8String]),
				TSIP_SSESSION_SET_NULL()) == 0);
}

-(NSString*) toUri{
	return self->toUri;
}

-(BOOL) setSilentHangup: (BOOL) silent{
	return (tsip_ssession_set(self->handle,
				TSIP_SSESSION_SET_SILENT_HANGUP(silent ? tsk_true : tsk_false),
				TSIP_SSESSION_SET_NULL()) == 0);
}

-(void) setSigCompId: (NSString*) _compId{	
	if(self->compId != nil && self->compId != _compId){
		tsip_ssession_set(self->handle,
			TSIP_SSESSION_UNSET_SIGCOMP_COMPARTMENT(),
			TSIP_SSESSION_SET_NULL());
	}
	
	[self->compId release], self->compId = [_compId retain];
	if(self->compId){
		tsip_ssession_set(self->handle,
			TSIP_SSESSION_SET_SIGCOMP_COMPARTMENT([self->compId UTF8String]),
			TSIP_SSESSION_SET_NULL());
	}
}

+(DWSipSession*) findWithId: (tsip_ssession_id_t)_id{
	[__sessionsLock lock];
	DWSipSession* session = [__sessions objectForKey:[NSNumber numberWithLong:_id]];
	[__sessionsLock unlock];
	return session;
}

+(DWSipSession*) findWithId:(tsip_ssession_id_t)_id andType:(SESSION_TYPE_T)_type{
	[__sessionsLock lock];
	DWSipSession* session = [__sessions objectForKey:[NSNumber numberWithLong:_id]];
	[__sessionsLock unlock];
	if(session && session.type == _type){
		return session;
	}
	return nil;
}

+(BOOL) hasSessionWithId: (tsip_ssession_id_t)_id{
	return ([DWSipSession findWithId:_id] != nil);
}

+(BOOL) hasSessionWithId:(tsip_ssession_id_t)_id andType:(SESSION_TYPE_T)_type{
	return ([DWSipSession findWithId:_id andType: _type] != nil);
}

-(void)dealloc{
	tsip_ssession_set(self->handle,
			TSIP_SSESSION_SET_USERDATA(tsk_null),
			TSIP_SSESSION_SET_NULL());
	TSK_OBJECT_SAFE_FREE(self->handle);
	
	//[__sessionsLock lock];
	//[__sessions removeObjectForKey:[NSNumber numberWithLong:self->id]];
	//[__sessionsLock unlock];
	
	[compId release];
	[fromUri release];
	[toUri release];
	
	[self->sipStack release];
	[super dealloc];
}

@end



/* ======================== DWInviteSession ========================*/
@implementation DWInviteSession

@synthesize remoteParty;

-(DWInviteSession*)initWithStack:(DWSipStack *)_sipStack{
	self = (DWInviteSession*)[super initWithType:SESSION_TYPE_INVITE andStack:_sipStack];
	return self;
}

-(DWInviteSession*)initWithStack:(DWSipStack *)_sipStack andHandle: (tsip_ssession_handle_t*)_handle{
	self = (DWInviteSession*)[super initWithType:SESSION_TYPE_INVITE andStack:_sipStack andHandle:_handle];
	return self;
}


-(BOOL) accept{
	return [self acceptWithActionConfig: nil];
}

-(BOOL) acceptWithActionConfig: (DWActionConfig*)actionConfig{
	return (tsip_action_ACCEPT(self->handle,
				TSIP_ACTION_SET_CONFIG(actionConfig ? actionConfig.handle : tsk_null),
				TSIP_ACTION_SET_NULL()) == 0);
}

-(BOOL) hangUp{
	return [self hangUpWithActionConfig: nil];
}

-(BOOL) hangUpWithActionConfig: (DWActionConfig*)actionConfig{
	return (tsip_action_BYE(self->handle,
				TSIP_ACTION_SET_CONFIG(actionConfig ? actionConfig.handle : tsk_null),
				TSIP_ACTION_SET_NULL()) == 0);
}

-(BOOL) reject{
	return [self rejectWithActionConfig: nil];
}

-(BOOL) rejectWithActionConfig: (DWActionConfig*)actionConfig{
	return (tsip_action_REJECT(self->handle,
				TSIP_ACTION_SET_CONFIG(actionConfig ? actionConfig.handle : tsk_null),
				TSIP_ACTION_SET_NULL()) == 0);
}

-(tmedia_type_t) mediaType{
	return tsip_ssession_get_mediatype(self->handle);
}

-(void) dealloc{
	[self->remoteParty release];
	[super dealloc];
}

@end



/* ======================== DWCallSession ========================*/
@implementation DWCallSession

@synthesize enable100rel;

-(DWCallSession*)initWithStack:(DWSipStack *)_sipStack{
	self = (DWCallSession*)[super initWithStack:_sipStack];
	return self;
}

-(DWCallSession*)initWithStack:(DWSipStack *)_sipStack andHandle: (tsip_ssession_handle_t*)_handle{
	self = (DWCallSession*)[super initWithStack:_sipStack andHandle: _handle];
	return self;
}


-(BOOL) callAudio: (NSString*)remoteUri{
	return [self callAudioWithActionConfig: nil andRemoteUri: remoteUri];
}

-(BOOL) callAudioWithActionConfig: (DWActionConfig*)actionConfig andRemoteUri: (NSString*)remoteUri{
	[self->toUri release], self->toUri = [remoteUri retain];
	tsip_ssession_set(self->handle,
		TSIP_SSESSION_SET_TO([remoteUri UTF8String]),
		TSIP_SSESSION_SET_NULL());
	
	return (tsip_action_INVITE(self->handle, tmedia_audio,
				TSIP_ACTION_SET_CONFIG(actionConfig ? actionConfig.handle : tsk_null),
				TSIP_ACTION_SET_NULL()) == 0);
}


-(BOOL) callAudioVideo: (NSString*)remoteUri{
	return [self callAudioVideoWithActionConfig: nil andRemoteUri: remoteUri];
}

-(BOOL) callAudioVideoWithActionConfig: (DWActionConfig*)actionConfig andRemoteUri: (NSString*)remoteUri{
	[self->toUri release], self->toUri = [remoteUri retain];
	tsip_ssession_set(self->handle,
		TSIP_SSESSION_SET_TO([remoteUri UTF8String]),
		TSIP_SSESSION_SET_NULL());
	
	return (tsip_action_INVITE(self->handle, (tmedia_type_t)(tmedia_audio | tmedia_video),
				TSIP_ACTION_SET_CONFIG(actionConfig ? actionConfig.handle : tsk_null),
				TSIP_ACTION_SET_NULL()) == 0);
}


-(BOOL) setSessionTimer: (unsigned) timeout refresher:(NSString*) ref{
	return (tsip_ssession_set(self->handle,
					TSIP_SSESSION_SET_MEDIA(
							TSIP_MSESSION_SET_TIMERS(timeout, [ref UTF8String]),
							TSIP_MSESSION_SET_NULL()
					),
					TSIP_SSESSION_SET_NULL()) == 0);
}

-(BOOL) setQoSWithType: (tmedia_qos_stype_t) type andStrength:(tmedia_qos_strength_t) strength{
	return (tsip_ssession_set(self->handle,
					TSIP_SSESSION_SET_MEDIA(
							TSIP_MSESSION_SET_QOS(type, strength),
							TSIP_MSESSION_SET_NULL()
					),
					TSIP_SSESSION_SET_NULL()) == 0);
}


-(BOOL) hold{
	return [self holdWithActionConfig: nil];
}

-(BOOL) holdWithActionConfig: (DWActionConfig*) actionConfig{
	return (tsip_action_HOLD(self->handle, tmedia_all,
				TSIP_ACTION_SET_CONFIG(actionConfig ? actionConfig.handle : tsk_null),
				TSIP_ACTION_SET_NULL()) ==0 );
}


-(BOOL) resume{
	return [self resumeWithActionConfig: nil];
}

-(BOOL) resumeWithActionConfig: (DWActionConfig*) actionConfig{
	return (tsip_action_RESUME(self->handle, tmedia_all,
				TSIP_ACTION_SET_CONFIG(actionConfig ? actionConfig.handle : tsk_null),
				TSIP_ACTION_SET_NULL()) == 0);
}


-(BOOL) sendDTMF: (int) number{
	return (tsip_action_DTMF(self->handle, number,
				TSIP_ACTION_SET_NULL()) == 0);
}

-(void)dealloc{
	[super dealloc];
}

@end


/* ======================== DWMsrpSession ========================*/



/* ======================== DWMessagingSession ========================*/
@implementation DWMessagingSession

-(DWMessagingSession*)initWithStack:(DWSipStack *)_sipStack{
	self = (DWMessagingSession*)[super initWithType:SESSION_TYPE_MESSAGING andStack:_sipStack];
	return self;
}

-(DWMessagingSession*)initWithStack:(DWSipStack *)_sipStack andHandle: (tsip_ssession_handle_t*)_handle{
	self = (DWMessagingSession*)[super initWithType:SESSION_TYPE_MESSAGING andStack:_sipStack andHandle: _handle];
	return self;
}


-(BOOL) sendData: (NSData*) data{
	return NO;
}

-(BOOL) sendDataWithActionConfig: (DWActionConfig*)actionConfig andData: (NSData*) data{
	return NO;
}



-(BOOL) accept{
	return [self acceptWithActionConfig: nil];
}

-(BOOL) acceptWithActionConfig: (DWActionConfig*)actionConfig{
	return (tsip_action_ACCEPT(self->handle,
				TSIP_ACTION_SET_CONFIG(actionConfig ? actionConfig.handle : tsk_null),
				TSIP_ACTION_SET_NULL()) == 0);
}


-(BOOL) reject{
	return [self rejectWithActionConfig: nil];
}

-(BOOL) rejectWithActionConfig: (DWActionConfig*)actionConfig{
	return (tsip_action_REJECT(self->handle,
				TSIP_ACTION_SET_CONFIG(actionConfig ? actionConfig.handle : tsk_null),
				TSIP_ACTION_SET_NULL()) == 0);
}


@end


/* ======================== OptionsSession ========================*/
@implementation DWOptionsSession


-(DWOptionsSession*)initWithStack:(DWSipStack *)_sipStack{
	self = (DWOptionsSession*)[super initWithType:SESSION_TYPE_OPTIONS andStack:_sipStack];
	return self;
}

-(BOOL) send{
	return [self sendWithActionConfig: nil];
}

-(BOOL) sendWithActionConfig: (DWActionConfig*)actionConfig{
	return (tsip_action_OPTIONS(self->handle,
				TSIP_ACTION_SET_CONFIG(actionConfig ? actionConfig.handle : tsk_null),
				TSIP_ACTION_SET_NULL()) == 0);
}

@end



/* ======================== DWPublicationSession ========================*/
@implementation DWPublicationSession


-(DWPublicationSession*)initWithStack:(DWSipStack *)_sipStack{
	self = (DWPublicationSession*)[super initWithType:SESSION_TYPE_PUBLICATION andStack:_sipStack];
	return self;
}

-(BOOL) publishData: (NSData*)data{
	return [self publishDataWithAtionConfig: nil andData: data];
}

-(BOOL) publishDataWithAtionConfig: (DWActionConfig*) actionConfig andData: (NSData*)data{
	return NO;
}


-(BOOL) unPublish{
	return [self unPublishWithActionConfig: nil];
}

-(BOOL) unPublishWithActionConfig: (DWActionConfig*)actionConfig{
	return NO;
}


@end


/* ======================== DWRegistrationSession ========================*/
@implementation DWRegistrationSession

-(DWRegistrationSession*)initWithStack:(DWSipStack *)_sipStack{
	if((self = (DWRegistrationSession*)[super initWithType:SESSION_TYPE_REGISTRATION andStack:_sipStack])){
	}
	return self;
}

-(BOOL) registerIdentity{
	return [self registerIdentityWithActionConfig:nil];
}

-(BOOL) registerIdentityWithActionConfig: (DWActionConfig*)actionConfig{
	return (tsip_action_REGISTER(self->handle,
				TSIP_ACTION_SET_CONFIG(actionConfig ? actionConfig.handle : tsk_null),
				TSIP_ACTION_SET_NULL()) == 0);
}

-(BOOL) unRegisterIdentity{
	return [self unRegisterIdentityWithActionConfig:nil];
}

-(BOOL) unRegisterIdentityWithActionConfig: (DWActionConfig*)actionConfig{
	return (tsip_action_UNREGISTER(self->handle,
				TSIP_ACTION_SET_CONFIG(actionConfig ? actionConfig.handle : tsk_null),
				TSIP_ACTION_SET_NULL()) == 0);
}

@end



/* ======================== DWSubscriptionSession ========================*/
@implementation DWSubscriptionSession

-(DWSubscriptionSession*)initWithStack:(DWSipStack *)_sipStack{
	self = (DWSubscriptionSession*)[super initWithType:SESSION_TYPE_SUBSCRIPTION andStack:_sipStack];
	return self;
}

-(BOOL) subscribe{
	return [self subscribeWithActionConfig: nil];
}

-(BOOL) subscribeWithActionConfig: (DWActionConfig*)actionConfig{
	return (tsip_action_SUBSCRIBE(self->handle,
				TSIP_ACTION_SET_CONFIG(actionConfig ? actionConfig.handle : tsk_null),
				TSIP_ACTION_SET_NULL()) == 0);
}


-(BOOL) unSubscribe{
	return [self unSubscribeWithActionConfig: nil];
}

-(BOOL) unSubscribeWithActionConfig: (DWActionConfig*)actionConfig{
	return (tsip_action_UNSUBSCRIBE(self->handle,
				TSIP_ACTION_SET_CONFIG(actionConfig ? actionConfig.handle : tsk_null),
				TSIP_ACTION_SET_NULL()) == 0);
}


@end


