#import "NgnMsrpSession.h"


@implementation NgnMsrpSession

+(NgnMsrpSession*) getSessionWithId: (long) sessionId{
	return nil;
}

+(void) releaseSession: (NgnMsrpSession**) session{
	[NSException raise:NSInternalInconsistencyException
				format:@"You must implement %@ in a subclass", NSStringFromSelector(_cmd)];
}

@end
