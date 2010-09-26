//
//  ServiceManager.m
//  iDoubs
//
//  Created by Mamadou DIOP on 8/29/10.
//  Copyright 2010 doubango. All rights reserved.
//

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
