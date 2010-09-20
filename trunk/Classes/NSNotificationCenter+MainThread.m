//
//  NSNotificationCenterMainThread.m
//  iDoubs
//
//  Created by Mamadou DIOP on 9/11/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import "NSNotificationCenter+MainThread.h"


#import "NSNotificationCenter+MainThread.h"

// Partial Copyright: http://www.drobnik.com/touch/2010/05/nsnotifications-and-background-threads/

@implementation NSNotificationCenter (MainThread)

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