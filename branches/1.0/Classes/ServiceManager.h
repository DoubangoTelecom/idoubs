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
	NSObject<PSoundService>* soundService;
	NSObject<PHistoryService>* historyService;
}

-(BOOL) start;
-(BOOL) stop;

// services
@property(readonly, retain) NSObject<PConfigurationService>* configurationService;
@property(readonly, retain) NSObject<PSipService>* sipService;
@property(readonly, retain) NSObject<PSoundService>* soundService;
@property(readonly, retain) NSObject<PHistoryService>* historyService;

// singleton
+(ServiceManager*) sharedManager;

@end
