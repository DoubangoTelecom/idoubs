#import <Foundation/Foundation.h>

#import "NgnInviteSession.h"

@interface NgnMsrpSession : NgnInviteSession {

}

+(void) releaseSession: (NgnMsrpSession**) session;
+(NgnMsrpSession*) getSessionWithId: (long) sessionId;

@end
