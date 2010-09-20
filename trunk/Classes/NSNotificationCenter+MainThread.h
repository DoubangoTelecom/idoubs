//
//  NSNotificationCenterMainThread.h
//  iDoubs
//
//  Created by Mamadou DIOP on 9/11/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSNotificationCenter (MainThread)

- (void)postNotificationOnMainThread:(NSNotification *)notification;
- (void)postNotificationOnMainThreadWithName:(NSString *)aName object:(id)anObject;
- (void)postNotificationOnMainThreadWithName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

@end
