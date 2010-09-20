//
//  DWVideoConsumer.h
//  iDoubs
//
//  Created by Mamadou DIOP on 9/13/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "tinymedia/tmedia_consumer.h"

extern const tmedia_consumer_plugin_def_t *dw_videoConsumer_plugin_def_t;

@protocol DWVideoConsumerCallback

-(int)consumerPaused;
-(int)consumerPreparedWithWidth:(int) width andHeight: (int)height andFps: (int)fps;
-(int)consumerStarted;
-(int)consumerHasBuffer: (const void*)buffer withSize: (tsk_size_t)size;
-(int)consumerStopped;

@end


@interface DWVideoConsumer : NSObject {
	NSObject<DWVideoConsumerCallback>* callback;
}

+(DWVideoConsumer*)sharedInstance;

@property(readwrite, retain) NSObject<DWVideoConsumerCallback>* callback;

@end
