#import <UIKit/UIKit.h>

#import "iOSNgnStack.h"

@interface CallViewController : UIViewController {
	long sessionId;
}

@property (nonatomic) long sessionId;

+(BOOL) makeAudioCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack;
+(BOOL) makeAudioVideoCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack;

@end
