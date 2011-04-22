#import <Foundation/Foundation.h>

#import "NgnSipSession.h"
#import "SipSession.h"

@interface NgnRegistrationSession : NgnSipSession {
	RegistrationSession* _mSession;
}

-(BOOL)register_;
-(BOOL)unRegister;
@end
