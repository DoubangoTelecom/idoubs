//
//  SafeObject.h
//  iDoubs
//
//  Created by Mamadou DIOP on 8/27/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "tsk_mutex.h"

@interface DWSafeObject : NSObject {

	tsk_mutex_handle_t* mutex;
}

-(BOOL) lock;
-(BOOL) unlock;

@end
