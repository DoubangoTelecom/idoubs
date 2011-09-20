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
#import "NgnSoundService.h"

#if TARGET_OS_IPHONE
#	import <AVFoundation/AVFoundation.h>
#elif TARGET_OS_MAC
#endif

#undef TAG
#define kTAG @"NgnSoundService///: "
#define TAG kTAG

//
// private implementation
//
@interface NgnSoundService(Private)
#if TARGET_OS_IPHONE
+(AVAudioPlayer*) initPlayerWithPath:(NSString*)path;
#elif TARGET_OS_MAC
+(NSSound*) initSoundWithPath:(NSString*)path;
#endif
@end

@implementation NgnSoundService(Private)

#if TARGET_OS_IPHONE
+(AVAudioPlayer*) initPlayerWithPath:(NSString*)path{
	NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], path]];
		
	NSError *error;
	AVAudioPlayer *player = [[[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error] autorelease];
	if (player == nil){
		NSLog(@"Failed to create audio player(%@): %@", path, error);
	}
	
	return player;
}
#elif TARGET_OS_MAC
+(NSSound*) initSoundWithPath:(NSString*)path
{
	NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], path]];
	NSSound *sound = [[[NSSound alloc] initWithContentsOfURL:url byReference:NO] autorelease];
	return sound;
}
#endif

@end


//
// default implementation
//
@implementation NgnSoundService

-(NgnSoundService*)init{
	if((self = [super init])){
		
	}
	return self;
}

-(void)dealloc{
	
	if(dtmfLastSoundId){
		AudioServicesDisposeSystemSoundID(dtmfLastSoundId);
		dtmfLastSoundId = 0;
	}
#if TARGET_OS_IPHONE
#define RELEASE_PLAYER(player) \
	if(player){ \
		if(player.playing){ \
			[player stop]; \
		} \
		[player release]; \
	}
	RELEASE_PLAYER(playerKeepAwake);
	RELEASE_PLAYER(playerRingBackTone);
	RELEASE_PLAYER(playerRingTone);
	RELEASE_PLAYER(playerEvent);
	RELEASE_PLAYER(playerConn);
	
#undef RELEASE_PLAYER
	
	
#elif TARGET_OS_MAC
	
#define RELEASE_SOUND(sound) \
	if(sound){ \
		if([sound isPlaying]){ \
			[sound stop]; \
		} \
		[sound release]; \
	}

	RELEASE_SOUND(soundRingBackTone);
	RELEASE_SOUND(soundRingTone);
	RELEASE_SOUND(soundEvent);
	RELEASE_SOUND(soundConn);
				  
#undef RELEASE_SOUND
	   
#endif
	
	[super dealloc];
}

//
// INgnBaseService
//

-(BOOL) start{
	NgnNSLog(TAG, @"Start()");
	return YES;
}

-(BOOL) stop{
	NgnNSLog(TAG, @"Stop()");
	return YES;
}


//
// INgnSoundService
//
-(BOOL) setSpeakerEnabled:(BOOL)enabled{
#if TARGET_OS_IPHONE
	UInt32 audioRouteOverride = enabled ? kAudioSessionOverrideAudioRoute_Speaker : kAudioSessionOverrideAudioRoute_None;
	if(AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride),&audioRouteOverride) == 0){
		speakerOn = enabled;
		return YES;
	}
	return NO;
#else
	return NO;
#endif
}

-(BOOL) isSpeakerEnabled{
	return speakerOn;
}

-(BOOL) playRingTone{
#if TARGET_OS_IPHONE
	if(!playerRingTone){
		playerRingTone = [[NgnSoundService initPlayerWithPath:@"ringtone.mp3"] retain];
	}
	if(playerRingTone){
		playerRingTone.numberOfLoops = -1;
		[playerRingTone play];
		return YES;
	}
#elif TARGET_OS_MAC
	if(!soundRingTone){
		soundRingTone = [[NgnSoundService initSoundWithPath:@"ringtone.mp3"] retain];
	}
	if(soundRingTone){
		[soundRingTone setLoops:YES];
		[soundRingTone play];
		return YES;
	}
#endif
	return NO;
}

-(BOOL) stopRingTone{
#if TARGET_OS_IPHONE
	if(playerRingTone && playerRingTone.playing){
		[playerRingTone stop];
	}
#elif TARGET_OS_MAC
	if(soundRingTone && [soundRingTone isPlaying]){
		[soundRingTone stop];
	}
#endif
	return YES;
}

-(BOOL) playRingBackTone{
#if TARGET_OS_IPHONE
	if(!playerRingBackTone){
		playerRingBackTone = [[NgnSoundService initPlayerWithPath:@"ringbacktone.wav"] retain];
	}
	if(playerRingBackTone){
		playerRingBackTone.numberOfLoops = -1;
		[playerRingBackTone play];
		return YES;
	}
#elif TARGET_OS_MAC
	if(!soundRingBackTone){
		soundRingBackTone = [[NgnSoundService initSoundWithPath:@"ringbacktone.wav"] retain];
	}
	if(soundRingBackTone){
		[soundRingBackTone setLoops:YES];
		[soundRingBackTone play];
		return YES;
	}
#endif
	return NO;
}

-(BOOL) stopRingBackTone{
#if TARGET_OS_IPHONE
	if(playerRingBackTone && playerRingBackTone.playing){
		[playerRingBackTone stop];
	}
#elif TARGET_OS_MAC
	if(soundRingBackTone && [soundRingBackTone isPlaying]){
		[soundRingBackTone stop];
	}
#endif
	return YES;
}

-(BOOL) playDtmf:(int)digit{
	NSString* code = nil;
	BOOL ok = NO;
	switch(digit){
		case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8: case 9: code = [NSString stringWithFormat:@"%i", digit]; break; 
		case 10: code = @"pound"; break;
		case 11: code = @"star"; break;
		default: code = @"0";
	}
	
	CFURLRef soundUrlRef = (CFURLRef) [[[NSBundle mainBundle] URLForResource:[@"dtmf-" stringByAppendingString:code]
															   withExtension:@"wav"] retain];
	
    if(dtmfLastSoundId){
		AudioServicesDisposeSystemSoundID(dtmfLastSoundId);
		dtmfLastSoundId = 0;
	}
	
    if(soundUrlRef && AudioServicesCreateSystemSoundID(soundUrlRef, &dtmfLastSoundId) == 0){
		AudioServicesPlaySystemSound(dtmfLastSoundId);
		ok = YES;
	}
	
	if(soundUrlRef){
		CFRelease(soundUrlRef);
	}
	
	return ok;
}

#if TARGET_OS_IPHONE

-(BOOL) vibrate{
	AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
	return YES;
}

-(BOOL) playKeepAwakeSoundLooping: (BOOL)looping{
	
	if(!playerKeepAwake){
		playerKeepAwake = [[NgnSoundService initPlayerWithPath:@"keepawake.wav"] retain];
	}
	if(playerKeepAwake){
		UInt32 doSetProperty = TRUE;
		[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
		AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(doSetProperty), &doSetProperty);
		
		playerKeepAwake.numberOfLoops = looping ? -1 : +1;
		[playerKeepAwake play];
		return YES;
	}
	return NO;
}

-(BOOL) stopKeepAwakeSound{
	if(playerKeepAwake && playerKeepAwake.playing){
		UInt32 doSetProperty = FALSE;
		[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
		AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(doSetProperty), &doSetProperty);
		
		[playerKeepAwake stop];
	}
	return YES;
}

#endif /* TARGET_OS_IPHONE */

@end
