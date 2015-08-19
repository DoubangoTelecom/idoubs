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

#import "INgnBaseService.h"

typedef enum NgnNetworkType_e
{
	NetworkType_None = 0x00,
	
	NetworkType_WLAN = 0x01 << 0, // WiFi
	NetworkType_2G = 0x01 << 1,
	NetworkType_EDGE = 0x01 << 2,
	NetworkType_3G = 0x01 << 3,
	NetworkType_4G = 0x01 << 4,
	
	NetworkType_WWAN = (NetworkType_2G | NetworkType_EDGE | NetworkType_3G | NetworkType_4G),
}
NgnNetworkType_t;

typedef enum NgnNetworkReachability_e
{
	NetworkReachability_None = 0x00,
	
	NetworkReachability_TransientConnection = 0x01 << 0,
	NetworkReachability_Reachable = 0x01 << 1,
	NetworkReachability_ConnectionRequired = 0x01 << 2,
	NetworkReachability_ConnectionAutomatic = 0x01 << 3,
	NetworkReachability_InterventionRequired = 0x01 << 4,
	NetworkReachability_IsLocalAddress = 0x01 << 5,
	NetworkReachability_IsDirect = 0x01 << 6,
}
NgnNetworkReachability_t;

@protocol INgnNetworkService <INgnBaseService>

-(NSString*)getReachabilityHostName;
-(void)setReachabilityHostName:(NSString*)hostName;
-(NgnNetworkType_t) getNetworkType;
-(NgnNetworkReachability_t) getReachability;
-(BOOL) isReachable;
-(BOOL) isReachable:(NSString*)hostName;

@property(readwrite, retain, getter=getReachabilityHostName, setter=setReachabilityHostName:) NSString* reachabilityHostName;
@property(readonly, getter=getNetworkType) NgnNetworkType_t networkType;
@property(readonly, getter=getReachability) NgnNetworkReachability_t reachability;
@property(readonly, getter=isReachable) BOOL reachable;

@end