#import <Foundation/Foundation.h>

#import "INgnBaseService.h"
#import "NgnSipSession.h"
#import "NgnSipStack.h"

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