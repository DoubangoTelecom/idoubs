//
//  SoundService.h
//  iDoubs
//
//  Created by Mamadou DIOP on 9/25/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>

#import "PSoundService.h"

@interface SoundService : NSObject<PSoundService> {

	AVAudioPlayer  *playerDTMF;
	AVAudioPlayer  *playerRingBackTone;
	AVAudioPlayer  *playerRingTone;
	AVAudioPlayer  *playerEvent;
	AVAudioPlayer  *playerConn;
}

@end
