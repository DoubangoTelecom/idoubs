/*
 * Copyright (C) 2010 Mamadou Diop.
 *
 * Contact: Mamadou Diop <diopmamadou(at)doubango.org>
 *       
 * This file is part of idoubs Project (http://code.google.com/p/idoubs)
 *
 * idoubs is free software: you can redistribute it and/or modify it under the terms of 
 * the GNU General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 *       
 * idoubs is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 * See the GNU General Public License for more details.
 *       
 * You should have received a copy of the GNU General Public License along 
 * with this program; if not, write to the Free Software Foundation, Inc., 
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 */

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