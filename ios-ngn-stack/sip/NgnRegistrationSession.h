#import <Foundation/Foundation.h>

#import "NgnSipSession.h"
#import "SipSession.h"

@interface NgnRegistrationSession : NgnSipSession {
	RegistrationSession* _mSession;
}

-(BOOL)register_;
-(BOOL)unRegister;

+(NgnRegistrationSession*) createOutgoingSessionWithStack: (NgnSipStack*)sipStack andToUri: (NSString*)toUri;
+(NgnRegistrationSession*) createOutgoingSessionWithStack: (NgnSipStack*)sipStack;
+(NgnRegistrationSession*) findSessionWithId: (long)sessionId;
+(BOOL) hasSessionWithId: (long)sessionId;
+(void) releaseSessionWithId: (long)sessionId;

@end
