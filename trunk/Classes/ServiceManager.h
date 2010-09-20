//
//  ServiceManager.h
//  iDoubs
//
//  Created by Mamadou DIOP on 8/29/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PConfigurationService.h"
#import "PContactService.h"
#import "PHistoryService.h"
#import "PNetworkService.h"
#import "PScreenService.h"
#import "PSipService.h"
#import "PSoundService.h"
#import "PStorageService.h"
#import "PXcapService.h"

#define SharedServiceManager [ServiceManager sharedManager]

@interface ServiceManager : NSObject {
	NSObject<PConfigurationService>* configurationService;
	NSObject<PSipService>* sipService;
}

-(BOOL) start;
-(BOOL) stop;

// services
@property(readonly, retain) NSObject<PConfigurationService>* configurationService;
@property(readonly, retain) NSObject<PSipService>* sipService;

// singleton
+(ServiceManager*) sharedManager;

@end
