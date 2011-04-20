#import <Foundation/Foundation.h>

@interface NSNotificationCenter (NextGenerationNetworkStack)

- (void)postNotificationOnMainThread:(NSNotification *)notification;
- (void)postNotificationOnMainThreadWithName:(NSString *)aName object:(id)anObject;
- (void)postNotificationOnMainThreadWithName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

@end
