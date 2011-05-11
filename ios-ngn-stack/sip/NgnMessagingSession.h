#import <Foundation/Foundation.h>

#import "NgnSipSession.h"

#undef NgnMessagingSessionMutableArray
#undef NgnMessagingSessionArray
#define NgnMessagingSessionMutableArray	NSMutableArray
#define NgnMessagingSessionArray	NSArray


class MessagingSession;
class ActionConfig;
class SipMessage;

@interface NgnMessagingSession : NgnSipSession {
	MessagingSession* _mSession;
}

-(BOOL) sendBinaryMessage:(NSString*) asciiText smscValue: (NSString*) smsc;
-(BOOL) sendData: (NSData*) data contentType: (NSString*) ctype actionConfig: (ActionConfig*) config;
-(BOOL) sendData: (NSData*) data contentType: (NSString*) ctype;
-(BOOL) sendTextMessage:(NSString*) asciiText contentType: (NSString*) ctype actionConfig: (ActionConfig*)config;
-(BOOL) sendTextMessage:(NSString*) asciiText contentType: (NSString*) ctype;
-(BOOL) acceptWithActionConfig: (ActionConfig*)config;
-(BOOL) accept;
-(BOOL) rejectWithActionConfig: (ActionConfig*)config;
-(BOOL) reject;

+(NgnMessagingSession*) takeIncomingSessionWithSipStack: (NgnSipStack*) sipStack andMessagingSession: (MessagingSession**) session andSipMessage: (const SipMessage*) sipMessage;
+(NgnMessagingSession*) createOutgoingSessionWithStack: (NgnSipStack*)sipStack andToUri: (NSString*)toUri;
+(NgnMessagingSession*) getSessionWithId: (long)sessionId;
+(BOOL) hasSessionWithId: (long)sessionId;
+(void) releaseSession: (NgnMessagingSession**) session;
+(NgnMessagingSession*) sendBinaryMessageWithSipStack: (NgnSipStack*)sipStack andToUri: (NSString*)uri andMessage: (NSString*) asciiText smscValue: (NSString*) smsc;
+(NgnMessagingSession*) sendDataWithSipStack: (NgnSipStack*)sipStack andToUri: (NSString*)uri andData: (NSData*) data andContentType: (NSString*) ctype andActionConfig: (ActionConfig*) config;
+(NgnMessagingSession*) sendDataWithSipStack: (NgnSipStack*)sipStack andToUri: (NSString*)uri andData: (NSData*) data andContentType: (NSString*) ctype;
+(NgnMessagingSession*) sendTextMessageWithSipStack: (NgnSipStack*)sipStack andToUri: (NSString*)uri andMessage: (NSString*) asciiText andContentType: (NSString*) ctype andActionConfig: (ActionConfig*)config;
+(NgnMessagingSession*) sendTextMessageWithSipStack: (NgnSipStack*)sipStack andToUri: (NSString*)uri andMessage: (NSString*) asciiText andContentType: (NSString*) ctype;

@end
