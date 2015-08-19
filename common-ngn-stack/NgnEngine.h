/* Copyright (C) 2010-2011, Mamadou Diop.
 * Copyright (c) 2011, Doubango Telecom. All rights reserved.
 *
 * Contact: Mamadou Diop <diopmamadou(at)doubango(dot)org>
 *       
 * This file is part of iDoubs Project ( http://code.google.com/p/idoubs )
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

#import "services/impl/NgnBaseService.h"

#import "services/INgnSipService.h"
#import "services/INgnConfigurationService.h"
#import "services/INgnContactService.h"
#import "services/INgnHttpClientService.h"
#import "services/INgnHistoryService.h"
#import "services/INgnSoundService.h"
#import "services/INgnNetworkService.h"
#import "services/INgnStorageService.h"

@interface NgnEngine : NSObject {
#if TARGET_OS_IPHONE
@private
	NSTimer		*keepAwakeTimer;
#endif /* TARGET_OS_IPHONE */
@protected
	BOOL mStarted;
	NgnBaseService<INgnSipService>* mSipService;
	NgnBaseService<INgnConfigurationService>* mConfigurationService;
	NgnBaseService<INgnContactService>* mContactService;
	NgnBaseService<INgnHttpClientService>* mHttpClientService;
	NgnBaseService<INgnHistoryService>* mHistoryService;
	NgnBaseService<INgnSoundService>* mSoundService;
	NgnBaseService<INgnNetworkService>* mNetworkService;
	NgnBaseService<INgnStorageService>* mStorageService;
}

@property(readonly,getter=getSipService) NgnBaseService<INgnSipService>* sipService;
@property(readonly, getter=getConfigurationService) NgnBaseService<INgnConfigurationService>* configurationService;
@property(readonly, getter=getContactService) NgnBaseService<INgnContactService>* contactService;
@property(readonly, getter=getHttpClientService) NgnBaseService<INgnHttpClientService>* httpClientService;
@property(readonly, getter=getHistoryService) NgnBaseService<INgnHistoryService>* historyService;
@property(readonly, getter=getSoundService) NgnBaseService<INgnSoundService>* soundService;
@property(readonly, getter=getNetworkService) NgnBaseService<INgnNetworkService>* networkService;
@property(readonly, getter=getStorageService) NgnBaseService<INgnStorageService>* storageService;

-(BOOL)start;
-(BOOL)stop;
-(NgnBaseService<INgnSipService>*)getSipService;
-(NgnBaseService<INgnConfigurationService>*)getConfigurationService;
-(NgnBaseService<INgnContactService>*)getContactService;
-(NgnBaseService<INgnHttpClientService>*) getHttpClientService;
-(NgnBaseService<INgnHistoryService>*)getHistoryService;
-(NgnBaseService<INgnSoundService>* )getSoundService;
-(NgnBaseService<INgnNetworkService>*)getNetworkService;
-(NgnBaseService<INgnStorageService>*)getStorageService;

#if TARGET_OS_IPHONE
-(BOOL) startKeepAwake;
-(BOOL) stopKeepAwake;
#endif /* TARGET_OS_IPHONE */

+(BOOL)initialize;
+(NgnEngine*)getInstance __attribute__ ((deprecated)); // Replaced by "+(NgnEngine*)sharedInstance"
+(NgnEngine*)sharedInstance;

@end
