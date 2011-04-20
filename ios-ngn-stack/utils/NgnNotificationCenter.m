#import "NgnNotificationCenter.h"


@implementation NSNotificationCenter (NextGenerationNetworkStack)

- (void)postNotificationOnMainThread:(NSNotification *)notification{
	[self performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
}

- (void)postNotificationOnMainThreadWithName:(NSString *)aName object:(id)anObject{
	NSNotification *notification = [NSNotification notificationWithName:aName object:anObject];
	[self postNotificationOnMainThread:notification];
}

- (void)postNotificationOnMainThreadWithName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo{
	NSNotification *notification = [NSNotification notificationWithName:aName object:anObject userInfo:aUserInfo];
	[self postNotificationOnMainThread:notification];
}

@end