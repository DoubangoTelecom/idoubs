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
#import "NgnConfigurationService.h"
#import "NgnConfigurationEntry.h"

#undef TAG
#define kTAG @"NgnConfigurationService///: "
#define TAG kTAG

@implementation NgnConfigurationService(Private)
- (void)userDefaultsDidChangeNotification:(NSNotification *)note{
	
}
@end


@implementation NgnConfigurationService

-(NgnConfigurationService*)init{
	if((self = [super init])){
		mPrefs = [NSUserDefaults standardUserDefaults];
		
		// FIXME: First time for Simulator
		NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
								  
								  
								  /* === IDENTITY === */
								  DEFAULT_IDENTITY_DISPLAY_NAME, IDENTITY_DISPLAY_NAME,
								  DEFAULT_IDENTITY_IMPI, IDENTITY_IMPI,
								  DEFAULT_IDENTITY_IMPU, IDENTITY_IMPU,
								  DEFAULT_IDENTITY_PASSWORD, IDENTITY_PASSWORD,
								  
								  /* === NETWORK === */
								  [NSNumber numberWithBool:DEFAULT_NETWORK_USE_EARLY_IMS], NETWORK_USE_EARLY_IMS,
								  DEFAULT_NETWORK_IP_VERSION, NETWORK_IP_VERSION,
								  DEFAULT_NETWORK_PCSCF_HOST, NETWORK_PCSCF_HOST,
								  [NSNumber numberWithInt:DEFAULT_NETWORK_PCSCF_PORT], NETWORK_PCSCF_PORT,
								  DEFAULT_NETWORK_REALM, NETWORK_REALM,
								  [NSNumber numberWithBool:DEFAULT_NETWORK_USE_SIGCOMP], NETWORK_USE_SIGCOMP,
								  [NSNumber numberWithBool:DEFAULT_NETWORK_USE_3G], NETWORK_USE_3G,
								  [NSNumber numberWithBool:DEFAULT_NETWORK_USE_WIFI], NETWORK_USE_WIFI,
								  DEFAULT_NETWORK_TRANSPORT, NETWORK_TRANSPORT,
								  
								  /* === NATT === */
								  [NSNumber numberWithBool:DEFAULT_NATT_USE_STUN], NATT_USE_STUN,
								  [NSNumber numberWithBool:DEFAULT_NATT_STUN_DISCO], NATT_STUN_DISCO,
								  DEFAULT_NATT_STUN_SERVER, NATT_STUN_SERVER,
								  [NSNumber numberWithInt:DEFAULT_NATT_STUN_PORT], NATT_STUN_PORT,
								  
								  /* === SECURITY === */
								  DEFAULT_SECURITY_IMSAKA_OPID, SECURITY_IMSAKA_OPID,
								  
								  /* === RCS === */
								  [NSNumber numberWithBool:DEFAULT_RCS_AUTO_ACCEPT_PAGER_MODE_IM], RCS_AUTO_ACCEPT_PAGER_MODE_IM,
								  
								  nil];
		
		[mPrefs registerDefaults:defaults];
	}
	return self;
}

-(void)dealloc{
	[self stop];
	
	[super dealloc];
}

//
// INgnBaseService
//

-(BOOL) start{
	NgnNSLog(TAG, @"Start()");
	[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(userDefaultsDidChangeNotification:) name: NSUserDefaultsDidChangeNotification object: nil];
	return YES;
}

-(BOOL) stop{
	NgnNSLog(TAG, @"Stop()");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	return YES;
}


//
//	INgnConfigurationService
//

-(NSString*)getStringWithKey: (NSString*)key{
	return [mPrefs stringForKey:key];
}

-(int)getIntWithKey: (NSString*)key{
	return [mPrefs integerForKey:key];
}


-(float)getFloatWithKey: (NSString*)key{
	return [mPrefs floatForKey:key];
}


-(BOOL)getBoolWithKey: (NSString*)key{
	return [mPrefs boolForKey:key];
}

-(void)setStringWithKey: (NSString*)key andValue:(NSString*)value{
	[mPrefs setObject:value forKey:key];
}

-(void)setIntWithKey: (NSString*)key andValue:(int)value{
	[mPrefs setInteger:value forKey:key];
}

-(void)setFloatWithKey: (NSString*)key andValue:(float)value{
	[mPrefs setFloat:value forKey:key];
}

-(void)setBoolWithKey: (NSString*)key andValue:(BOOL)value{
	[mPrefs setBool:value forKey:key];
}

@end
