#import "NgnNotificationCenter.h"


@implementation NgnNotificationCenter

+ (void)postNotificationOnMainThread:(NSNotification *)notification{
	[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
}

+ (void)postNotificationOnMainThreadWithName:(NSString *)aName object:(id)anObject{
	NSNotification *notification = [NSNotification notificationWithName:aName object:anObject];
	[NgnNotificationCenter postNotificationOnMainThread:notification];
}

+ (void)postNotificationOnMainThreadWithName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo{
	NSNotification *notification = [NSNotification notificationWithName:aName object:anObject userInfo:aUserInfo];
	[NgnNotificationCenter postNotificationOnMainThread:notification];
}

@end