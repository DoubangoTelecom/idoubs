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
#import <AVFoundation/AVFoundation.h>

#undef TAG
#define kTAG @"NgnSoundService///: "
#define TAG kTAG

//
// private implementation
//
@interface NgnSoundService(Private)
+(AVAudioPlayer*) initPlayerWithPath:(NSString*)path;
@end

@implementation NgnSoundService(Private)

+(AVAudioPlayer*) initPlayerWithPath:(NSString*)path{
	NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], path]];
		
	NSError *error;
	AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	if (player == nil){
		NSLog(@"Failed to create audio player(%@): %@", path, error);
	}
	
	return player;
}

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
	if(playerKeepAwake){
		if(playerKeepAwake.playing){
			[playerKeepAwake stop];
		}
		[playerKeepAwake release];
	}
#endif
	
	if(playerRingBackTone){
		if(playerRingBackTone.playing){
			[playerRingBackTone stop];
		}
		[playerRingBackTone release];
	}
	
	if(playerRingTone){
		if(playerRingTone.playing){
			[playerRingTone stop];
		}
		[playerRingTone release];
	}
	
	if(playerEvent){
		if(playerEvent.playing){
			[playerEvent stop];
		}
		[playerEvent release];
	}
	
	if(playerConn){
		if(playerConn.playing){
			[playerConn stop];
		}
		[playerConn release];
	}
	
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
	if(!playerRingTone){
		playerRingTone = [NgnSoundService initPlayerWithPath:@"ringtone.mp3"];
	}
	if(playerRingTone){
		playerRingTone.numberOfLoops = -1;
		[playerRingTone play];
		return YES;
	}
	return NO;
}

-(BOOL) stopRingTone{
	if(playerRingTone && playerRingTone.playing){
		[playerRingTone stop];
	}
	return YES;
}

-(BOOL) playRingBackTone{
	if(!playerRingBackTone){
		playerRingBackTone = [NgnSoundService initPlayerWithPath:@"ringbacktone.wav"];
	}
	if(playerRingBackTone){
		playerRingBackTone.numberOfLoops = -1;
		[playerRingBackTone play];
		return YES;
	}
	return NO;
}

-(BOOL) stopRingBackTone{
	if(playerRingBackTone && playerRingBackTone.playing){
		[playerRingBackTone stop];
	}
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
		playerKeepAwake = [NgnSoundService initPlayerWithPath:@"keepawake.wav"];
	}
	if(playerKeepAwake){
#if 0
		UInt32 doSetProperty = 1;
		[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
		AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(doSetProperty), &doSetProperty);
#endif
		
		playerKeepAwake.numberOfLoops = looping ? -1 : +1;
		[playerKeepAwake play];
		return YES;
	}
	return NO;
}

-(BOOL) stopKeepAwakeSound{
	if(playerKeepAwake && playerKeepAwake.playing){
		[playerKeepAwake stop];
	}
	return YES;
}

#endif /* TARGET_OS_IPHONE */

@end
