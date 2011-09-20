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

#import "SoundService.h"


@implementation SoundService


-(void) dealloc{
	if(playerDTMF){
		if(playerDTMF.playing)[playerDTMF stop];
		[playerDTMF release];
	}
	
	if(playerRingBackTone){
		if(playerRingBackTone.playing)[playerRingBackTone stop];
		[playerRingBackTone release];
	}
	
	if(playerRingTone){
		if(playerRingTone.playing)[playerRingTone stop];
		[playerRingTone release];
	}
	
	if(playerEvent){
		if(playerEvent.playing)[playerEvent stop];
		[playerEvent release];
	}
	
	if(playerConn){
		if(playerConn.playing)[playerConn stop];
		[playerConn release];
	}
	
	[super dealloc];
}

/* ================== PService ================= */
-(BOOL) start{
	return YES;
}

-(BOOL) stop{
	return YES;
}




/* ================== PSoundService ================= */
-(void) playDTMF:(int) number{
}

-(void) stopDTMF{
}


-(void) playRingTone{
	if(!playerRingTone){
		NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/ringtone.mp3", [[NSBundle mainBundle] resourcePath]]];
		
		NSError *error;
		playerRingTone = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
		if (playerRingTone == nil){
			NSLog(@"Failed to create audio player (RingTone): %@", error);
			return;
		}
	}
	
	playerRingTone.numberOfLoops = -1;
	[playerRingTone play];
}

-(void) stopRingTone{
	if(playerRingTone && playerRingTone.playing){
		[playerRingTone stop];
	}
}


-(void) playRingBackTone{
	if(!playerRingBackTone){
		NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/ringbacktone.wav", [[NSBundle mainBundle] resourcePath]]];
		
		NSError *error;
		playerRingBackTone = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
		if (playerRingBackTone == nil){
			NSLog(@"Failed to create audio player(RingBackTone): %@", error);
			return;
		}
	}
	
	playerRingBackTone.numberOfLoops = -1;
	[playerRingBackTone play];
}

-(void) stopRingBackTone{
	if(playerRingBackTone && playerRingBackTone.playing){
		[playerRingBackTone stop];
	}
}


-(void) playNewEvent{
}

-(void) stopNewEvent{
}


-(void) playConnectionChanged:(BOOL) connected{
}

-(void) stopConnectionChanged:(BOOL) connected{
}


@end
