//
//  PSipService.h
//  iDoubs
//
//  Created by Mamadou DIOP on 8/29/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PService.h"

@class DWSipStack;

@protocol PSipService <PService>

-(BOOL)stopStack;
-(BOOL)registerIdentity;
-(BOOL)unRegisterIdentity;
-(BOOL)publish;
-(BOOL)isRegistered;

-(DWSipStack*) sipStack;

@end
