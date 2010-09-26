//
//  PSoundService.h
//  iDoubs
//
//  Created by Mamadou DIOP on 8/29/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PService.h"

@protocol PSoundService <PService>

-(void) playDTMF:(int) number;
-(void) stopDTMF;

-(void) playRingTone;
-(void) stopRingTone;

-(void) playRingBackTone;
-(void) stopRingBackTone;

-(void) playNewEvent;
-(void) stopNewEvent;

-(void) playConnectionChanged:(BOOL) connected;
-(void) stopConnectionChanged:(BOOL) connected;

@end
