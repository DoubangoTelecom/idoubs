#import <Foundation/Foundation.h>

@interface NgnNotificationCenter

+ (void)postNotificationOnMainThread:(NSNotification *)notification;
+ (void)postNotificationOnMainThreadWithName:(NSString *)aName object:(id)anObject;
+ (void)postNotificationOnMainThreadWithName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

@end
