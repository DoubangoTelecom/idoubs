#import <Foundation/Foundation.h>

#import "NgnSipSession.h"

class RegistrationSession;

@interface NgnRegistrationSession : NgnSipSession {
	RegistrationSession* _mSession;
}

-(BOOL)register_;
-(BOOL)unRegister;

+(NgnRegistrationSession*) createOutgoingSessionWithStack: (NgnSipStack*)sipStack andToUri: (NSString*)toUri;
+(NgnRegistrationSession*) createOutgoingSessionWithStack: (NgnSipStack*)sipStack;
+(NgnRegistrationSession*) getSessionWithId: (long)sessionId;
+(BOOL) hasSessionWithId: (long)sessionId;
+(void) releaseSession: (NgnRegistrationSession**) session;

@end
