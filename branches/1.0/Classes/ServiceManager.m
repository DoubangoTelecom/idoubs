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

#import "ServiceManager.h"

#import "ConfigurationService.h"
//#import "ContactService.h"
#import "HistoryService.h"
//#import "NetworkService.h"
//#import "ScreenService.h"
#import "SipService.h"
#import "SoundService.h"
//#import "StorageService.h"
//#import "XcapService.h"


static ServiceManager* __sharedManager = nil;

@interface ServiceManager(Multithreading)
-(void)dummyCoCoaThread;
@end

@implementation ServiceManager(Multithreading)
-(void)dummyCoCoaThread {
}
@end


@implementation ServiceManager

@synthesize configurationService;
@synthesize sipService;
@synthesize soundService;
@synthesize historyService;

-(id) init{
	self = [super init];
	
	if(self){
		self->configurationService = [[ConfigurationService alloc] init];
		self->sipService = [[SipService alloc] init];
		self->soundService = [[SoundService alloc] init];
		self->historyService = [[HistoryService alloc] init];
	}
	
	return self;
}


-(BOOL) start{
	BOOL ret = YES;
	
	/* http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSAutoreleasePool_Class/Reference/Reference.html
	 Note: If you are creating secondary threads using the POSIX thread APIs instead of NSThread objects, you cannot use Cocoa, including NSAutoreleasePool, unless Cocoa is in multithreading mode. 
	 Cocoa enters multithreading mode only after detaching its first NSThread object. 
	 To use Cocoa on secondary POSIX threads, your application must first detach at least one NSThread object, which can immediately exit. 
	 You can test whether Cocoa is in multithreading mode with the NSThread class method isMultiThreaded.
	 */
	[NSThread detachNewThreadSelector:@selector(dummyCoCoaThread) toTarget:self withObject:nil];
	if([NSThread isMultiThreaded]){
		NSLog(@"Working in multithreaded mode ;)");
	}
	else{
		NSLog(@"NOT working in multithreaded mode ;(");
	}
	
	ret &= [self.configurationService start];
	ret &= [self.sipService start];
	ret &= [self.soundService start];
	ret &= [self.historyService start];
	
	return ret;
}

-(BOOL) stop{
	BOOL ret = YES;
	
	ret &= [self.configurationService stop];
	ret &= [self.sipService stop];
	ret &= [self.soundService stop];
	ret &= [self.historyService stop];
	
	return ret;
}

+(ServiceManager*) sharedManager{
	@synchronized(__sharedManager) {
		if(__sharedManager == nil){
			__sharedManager = [[ServiceManager alloc] init];
		}
	}
	
	return __sharedManager;
		
}

-(void)dealloc{
	[self->configurationService release];
	[self->sipService release];
	[self->soundService release];
	[self->historyService release];
	
	[super dealloc];
}

@end
