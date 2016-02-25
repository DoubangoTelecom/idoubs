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
#import "NgnEngine.h"

#import "NgnSipService.h"
#import "NgnConfigurationService.h"
#import "NgnContactService.h"
#import "NgnHttpClientService.h"
#import "NgnHistoryService.h"
#import "NgnSoundService.h"
#import "NgnNetworkService.h"
#import "NgnStorageService.h"
#import "NgnVideoConsumer.h"

#if TARGET_OS_IPHONE
#   import "iOSVideoProducer.h"
#elif TARGET_OS_MAC
#	import "OSXProxyVideoProducer.h"
#endif

#undef TAG
#define kTAG @"NgnEngine///: "
#define TAG kTAG

//
//	private implementation
//

@interface NgnEngine(Private)
-(void)dummyCoCoaThread;
#if TARGET_OS_IPHONE
-(void)keepAwakeCallback;
#endif
@end

@implementation NgnEngine(Private)

-(void)dummyCoCoaThread {
	NgnNSLog(TAG, @"dummyCoCoaThread()");
}

#if TARGET_OS_IPHONE
-(void)keepAwakeCallback{
	[self.soundService playKeepAwakeSoundLooping:
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 40000
									YES
#else
									NO
#endif
									];
	NSLog(@"keepAwakeCallback");
}
#endif

@end


//
//	default implementation
//
@implementation NgnEngine

-(NgnEngine*)init{
	if((self = [super init])){
		[NgnEngine initialize];
	}
	return self;
}

-(void)dealloc{
	[self stop];
	
	[mSipService release];
	[mConfigurationService release];
	[mContactService release];
	
	[super dealloc];
}

-(BOOL)start{
	if(mStarted){
		return TRUE;
	}
	BOOL bSuccess = TRUE;
	
	/* http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSAutoreleasePool_Class/Reference/Reference.html
	 Note: If you are creating secondary threads using the POSIX thread APIs instead of NSThread objects, you cannot use Cocoa, including NSAutoreleasePool, unless Cocoa is in multithreading mode.
	 Cocoa enters multithreading mode only after detaching its first NSThread object.
	 To use Cocoa on secondary POSIX threads, your application must first detach at least one NSThread object, which can immediately exit.
	 You can test whether Cocoa is in multithreading mode with the NSThread class method isMultiThreaded.
	 */
	[NSThread detachNewThreadSelector:@selector(dummyCoCoaThread) toTarget:self withObject:nil];
	if([NSThread isMultiThreaded]){
		NgnNSLog(TAG, @"Working in multithreaded mode :)");
	}
	else{
		NgnNSLog(TAG, @"NOT working in multithreaded mode :(");
	}
	
	// Order is important
	bSuccess &= [self.configurationService start];
	bSuccess &= [self.networkService start];
	bSuccess &= [self.storageService start];
	bSuccess &= [self.contactService start];
	bSuccess &= [self.sipService start];	
	bSuccess &= [self.httpClientService start];
	bSuccess &= [self.historyService start];
	bSuccess &= [self.soundService start];
	
	mStarted = TRUE;
	return bSuccess;
}

-(BOOL)stop{
	if(!mStarted){
		return TRUE;
	}
	
	BOOL bSuccess = TRUE;
	
	// Order is important
	bSuccess &= [self.sipService stop];
	bSuccess &= [self.contactService stop];
	bSuccess &= [self.configurationService stop];
	bSuccess &= [self.httpClientService stop];
	bSuccess &= [self.historyService stop];
	bSuccess &= [self.soundService stop];
	bSuccess &= [self.networkService stop];
	bSuccess &= [self.storageService stop];
	
	mStarted = FALSE;
	return bSuccess;
}

-(NgnBaseService<INgnSipService>*)getSipService{
	if(mSipService == nil){
		mSipService = [[NgnSipService alloc] init];
	}
	return mSipService;
}

-(NgnBaseService<INgnConfigurationService>*)getConfigurationService{
	if(mConfigurationService == nil){
		mConfigurationService = [[NgnConfigurationService alloc] init];
	}
	return mConfigurationService;
}

-(NgnBaseService<INgnContactService>*)getContactService{
	if(mContactService == nil){
		mContactService = [[NgnContactService alloc] init];
	}
	return mContactService;
}

-(NgnBaseService<INgnHttpClientService>*) getHttpClientService{
	if(mHttpClientService == nil){
		mHttpClientService = [[NgnHttpClientService alloc] init];
	}
	return mHttpClientService;
}

-(NgnBaseService<INgnHistoryService>*)getHistoryService{
	if(mHistoryService == nil){
		mHistoryService = [[NgnHistoryService alloc] init];
	}
	return mHistoryService;
}

-(NgnBaseService<INgnSoundService>* )getSoundService{
	if(mSoundService == nil){
		mSoundService = [[NgnSoundService alloc] init];
	}
	return mSoundService;
}

-(NgnBaseService<INgnNetworkService>*)getNetworkService{
	if(mNetworkService == nil){
		mNetworkService = [[NgnNetworkService alloc] init];
	}
	return mNetworkService;
}

-(NgnBaseService<INgnStorageService>*)getStorageService{
	if(mStorageService == nil){
		mStorageService = [[NgnStorageService alloc] init];
	}
	return mStorageService;
}


#if TARGET_OS_IPHONE

-(BOOL) startKeepAwake{
	if(!keepAwakeTimer){
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 40000
		BOOL iOS4Plus = YES;
#else
		BOOL iOS4Plus = NO;
#endif
		// the iOS4 device will sleep after 10seconds of inactivity
		// On iOS4, playing the sound each 10seconds doesn't work as the system will imediately frozen  
		// if you stop playing the sound. The only solution is to play it in loop. This is why
		// the 'repeats' parameter is equal to 'NO'.
		keepAwakeTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0]
													interval:6.f
													target:self
													selector:@selector(keepAwakeCallback)
													userInfo:nil
												   repeats:iOS4Plus ? NO : YES];
		[[NSRunLoop currentRunLoop] addTimer:keepAwakeTimer forMode:NSRunLoopCommonModes];
		[keepAwakeTimer release];
		if(iOS4Plus){
			keepAwakeTimer = nil;
		}
	}
	return YES;
}

-(BOOL) stopKeepAwake{
	if(keepAwakeTimer){
		[keepAwakeTimer invalidate];
		// already released
		keepAwakeTimer = nil;
	}
	[self.soundService stopKeepAwakeSound];
	return YES;
}

#endif /* TARGET_OS_IPHONE */

+(BOOL)initialize {
	static BOOL sMediaLayerInitialized = NO;
	
	if (!sMediaLayerInitialized) {
        if (tnet_startup() != 0) {
            return NO;
        }
        
        if (thttp_startup() != 0) {
            return NO;
        }
        
        if (tdav_init() != 0) {
            return NO;
        }
        
        assert(tmedia_defaults_set_profile(tmedia_profile_default) == 0);
        assert(tmedia_defaults_set_avpf_mode(tmedia_mode_optional) == 0);
        assert(tmedia_defaults_set_srtp_type(tmedia_srtp_type_none) == 0);
        assert(tmedia_defaults_set_srtp_mode(tmedia_srtp_mode_none) == 0);
        assert(tmedia_defaults_set_ice_enabled(tsk_false) == 0);
        
        assert(tmedia_defaults_set_rtcpmux_enabled(tsk_true) == 0);
        assert(tmedia_defaults_set_rtcp_enabled(tsk_true) == 0);
        
        assert(tmedia_defaults_set_pref_video_size(tmedia_pref_video_size_cif) == 0);
        assert(tmedia_defaults_set_video_fps(15) == 0);
        assert(tmedia_defaults_set_video_zeroartifacts_enabled(tsk_false) == 0);
        
        assert(tmedia_defaults_set_webproxy_auto_detect(tsk_true) == 0);
        
#if HAVE_COREAUDIO_AUDIO_UNIT && TARGET_OS_IPHONE // iOS devices have native AEC
        assert(tmedia_defaults_set_echo_supp_enabled(tsk_false) == 0);
        assert(tmedia_defaults_set_echo_skew(0) == 0);
        assert(tmedia_defaults_set_echo_tail(0) == 0);
#else
        assert(tmedia_defaults_set_echo_supp_enabled(tsk_true) == 0);
        assert(tmedia_defaults_set_echo_skew(0) == 0);
        assert(tmedia_defaults_set_echo_tail(100) == 0);
#endif /* HAVE_COREAUDIO_AUDIO_UNIT && TARGET_OS_IPHONE */
        
        assert(tmedia_defaults_set_opus_maxcapturerate(16000) == 0);
        assert(tmedia_defaults_set_opus_maxplaybackrate(16000) == 0);
        
#if TARGET_OS_IPHONE
        assert(tmedia_producer_plugin_register(ios_producer_video_plugin_def_t) == 0);
#endif
        assert(tmedia_consumer_plugin_register(ngn_consumer_video_plugin_def_t) == 0);
        
		sMediaLayerInitialized = YES;
	}
    return sMediaLayerInitialized;
}

+(NgnEngine*) getInstance{
	return [NgnEngine sharedInstance];
}

+(NgnEngine*) sharedInstance{
	static NgnEngine* sInstance = nil;
	
	if(sInstance == nil){
		sInstance = [[NgnEngine alloc] init];
	}
	return sInstance;
}

@end
