#import <Foundation/Foundation.h>

#import "services/INgnBaseService.h"
#import "sip/NgnSipSession.h"
#import "sip/NgnSipStack.h"

@protocol INgnSipService <INgnBaseService>
-(NSString*)getDefaultIdentity;
-(void)setDefaultIdentity: (NSString*)identity;
-(NgnSipStack*)getSipStack;
-(BOOL)isRegistered;
-(ConnectionState_t)getRegistrationState;
-(int)getCodecs;
-(void)setCodecs: (int)codecs;
-(BOOL)stopStack;
-(BOOL)register_;
-(BOOL)unRegister;
@end