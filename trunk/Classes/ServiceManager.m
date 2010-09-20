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
//#import "HistoryService.h"
//#import "NetworkService.h"
//#import "ScreenService.h"
#import "SipService.h"
//#import "SoundService.h"
//#import "StorageService.h"
//#import "XcapService.h"


static ServiceManager* __sharedManager = nil;

@implementation ServiceManager

@synthesize configurationService;
@synthesize sipService;

-(id) init{
	self = [super init];
	
	if(self){
		self->configurationService = [[ConfigurationService alloc] init];
		self->sipService = [[SipService alloc] init];
	}
	
	return self;
}


-(BOOL) start{
	BOOL ret = YES;
	
	ret &= [self.configurationService start];
	ret &= [self.sipService start];
	
	return ret;
}

-(BOOL) stop{
	BOOL ret = YES;
	
	ret &= [self.configurationService stop];
	ret &= [self.sipService stop];
	
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
	[configurationService release];
	[sipService release];
	
	[super dealloc];
}

@end
