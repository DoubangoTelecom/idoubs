//
//  DWSipSession.h
//  iDoubs
//
//  Created by Mamadou DIOP on 8/30/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "tinysip.h"
#import "tinymedia/tmedia_qos.h"
#import "DWActionConfig.h"


@class DWSipStack;
@class DWMsrpCallback;

/* ======================== DWSipSession ========================*/
typedef enum SESSION_STATE_E {
	SESSION_STATE_NONE, SESSION_STATE_CONNECTING, SESSION_STATE_CONNECTED, SESSION_STATE_DISCONNECTING, SESSION_STATE_DISCONNECTED
}
SESSION_STATE_T;

typedef enum SESSION_TYPE_E{
	SESSION_TYPE_INVITE, SESSION_TYPE_CALL, SESSION_TYPE_MSRP, SESSION_TYPE_MESSAGING, SESSION_TYPE_OPTIONS, SESSION_TYPE_REGISTRATION,
	SESSION_TYPE_SUBSCRIPTION, SESSION_TYPE_PUBLICATION
} 
SESSION_TYPE_T;

@interface DWSipSession : NSObject {
	tsip_ssession_id_t id;
	NSString* compId;
	SESSION_STATE_T state;
	SESSION_TYPE_T type;
	DWSipStack* sipStack;
	tsip_ssession_handle_t* handle;
	NSString* fromUri;
	NSString* toUri;
}

@property(readonly) tsip_ssession_id_t id;
@property(readwrite) SESSION_STATE_T state;
@property(readonly) SESSION_TYPE_T type;

-(BOOL) haveOwnership;
-(BOOL) addHeaderWithName: (NSString*) name andValue: (NSString*) value;
-(BOOL) removeHeaderWithName: (NSString*) name;
-(BOOL) addCapsWithName: (NSString*) name andValue: (NSString*) value;
-(BOOL) addCaps: (NSString*) name;
-(BOOL) removeCaps: (NSString*) name;
-(BOOL) setExpires: (unsigned) expires;
-(BOOL) setFromUri: (NSString*) fromUri;
-(NSString*) fromUri;
-(BOOL) setToUri: (NSString*) toUri;
-(NSString*) toUri;
-(BOOL) setSilentHangup: (BOOL) silent;
-(void) setSigCompId: (NSString*) compId;

+(DWSipSession*) findWithId: (tsip_ssession_id_t)id;
+(DWSipSession*) findWithId:(tsip_ssession_id_t)id andType:(SESSION_TYPE_T)type;

+(BOOL) hasSessionWithId: (tsip_ssession_id_t)id;
+(BOOL) hasSessionWithId:(tsip_ssession_id_t)id andType:(SESSION_TYPE_T)type;

@end


/* ======================== DWInviteSession ========================*/
@interface DWInviteSession : DWSipSession{
	tmedia_type_t mediaType;
}

-(DWInviteSession*)initWithStack:(DWSipStack *)sipStack;
-(DWInviteSession*)initWithStack:(DWSipStack *)sipStack andHandle: (tsip_ssession_handle_t*)handle;

-(BOOL) accept;
-(BOOL) acceptWithActionConfig: (DWActionConfig*)actionConfig;
-(BOOL) hangUp;
-(BOOL) hangUpWithActionConfig: (DWActionConfig*)actionConfig;
-(BOOL) reject;
-(BOOL) rejectWithActionConfig: (DWActionConfig*)actionConfig;

@property(readwrite, retain) NSString* remoteParty;
@property(readonly) tmedia_type_t mediaType;


@end


/* ======================== DWCallSession ========================*/
@interface DWCallSession : DWInviteSession
{
}

-(DWCallSession*)initWithStack:(DWSipStack *)sipStack;
-(DWCallSession*)initWithStack:(DWSipStack *)sipStack andHandle: (tsip_ssession_handle_t*)handle;

-(BOOL) callAudio: (NSString*)remoteUri;
-(BOOL) callAudioWithActionConfig: (DWActionConfig*)actionConfig andRemoteUri: (NSString*)remoteUri;

-(BOOL) callAudioVideo: (NSString*)remoteUri;
-(BOOL) callAudioVideoWithActionConfig: (DWActionConfig*)actionConfig andRemoteUri: (NSString*)remoteUri;

-(BOOL) setSessionTimer: (unsigned) timeout refresher:(NSString*) ref;
-(BOOL) setQoSWithType: (tmedia_qos_stype_t) type andStrength:(tmedia_qos_strength_t) strength;

-(BOOL) hold;
-(BOOL) holdWithActionConfig: (DWActionConfig*) actionConfig;

-(BOOL) resume;
-(BOOL) resumeWithActionConfig: (DWActionConfig*) actionConfig;

-(BOOL) sendDTMF: (int) number;

@property(readwrite, assign) BOOL enable100rel;

@end




/* ======================== DWMsrpSession ========================*/
@interface DWMsrpSession : DWInviteSession
{
	DWMsrpCallback* callback;
}

-(DWMsrpSession*)initWithStack:(DWSipStack *)sipStack andMsrpCallback: (DWMsrpCallback*) callback;
-(DWMsrpSession*)initWithStack:(DWSipStack *)sipStack andHandle: (tsip_ssession_handle_t*)handle;

-(BOOL) setCallback: (DWMsrpCallback*) callback;

-(BOOL) callMsrp: (NSString*)remoteUri;
-(BOOL) callMsrpWithActionConfig: (DWActionConfig*)actionConfig andRemoteUri: (NSString*)remoteUri;

-(BOOL) sendLMessage: (DWActionConfig*)actionConfig;
-(BOOL) sendFile: (DWActionConfig*) actionConfig;

@end


/* ======================== DWMessagingSession ========================*/
@interface DWMessagingSession : DWSipSession
{
}

-(DWMessagingSession*)initWithStack:(DWSipStack *)sipStack;
-(DWMessagingSession*)initWithStack:(DWSipStack *)sipStack andHandle: (tsip_ssession_handle_t*)handle;

-(BOOL) sendData: (NSData*) data;
-(BOOL) sendDataWithActionConfig: (DWActionConfig*)actionConfig andData: (NSData*) data;


-(BOOL) accept;
-(BOOL) acceptWithActionConfig: (DWActionConfig*)actionConfig;

-(BOOL) reject;
-(BOOL) rejectWithActionConfig: (DWActionConfig*)actionConfig;

@end



/* ======================== OptionsSession ========================*/
@interface DWOptionsSession : DWSipSession{
}

-(DWOptionsSession*)initWithStack:(DWSipStack *)sipStack;

-(BOOL) send;
-(BOOL) sendWithActionConfig: (DWActionConfig*)actionConfig;

@end


/* ======================== DWPublicationSession ========================*/
@interface DWPublicationSession : DWSipSession{
}

-(DWPublicationSession*)initWithStack:(DWSipStack *)sipStack;

-(BOOL) publishData: (NSData*)data;
-(BOOL) publishDataWithAtionConfig: (DWActionConfig*) actionConfig andData: (NSData*)data;

-(BOOL) unPublish;
-(BOOL) unPublishWithActionConfig: (DWActionConfig*)actionConfig;

@end


/* ======================== DWRegistrationSession ========================*/
@interface DWRegistrationSession : DWSipSession {
}

-(DWRegistrationSession*)initWithStack:(DWSipStack *)sipStack;
-(BOOL) registerIdentity;
-(BOOL) registerIdentityWithActionConfig: (DWActionConfig*)actionConfig;
-(BOOL) unRegisterIdentity;
-(BOOL) unRegisterIdentityWithActionConfig: (DWActionConfig*)actionConfig;

@end


/* ======================== DWSubscriptionSession ========================*/
@interface DWSubscriptionSession : DWSipSession{
}

-(DWSubscriptionSession*)initWithStack:(DWSipStack *)sipStack;

-(BOOL) subscribe;
-(BOOL) subscribeWithActionConfig: (DWActionConfig*)actionConfig;

-(BOOL) unSubscribe;
-(BOOL) unSubscribeWithActionConfig: (DWActionConfig*)actionConfig;

@end



 

