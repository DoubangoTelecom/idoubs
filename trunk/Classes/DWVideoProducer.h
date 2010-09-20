//
//  DWVideoProducer.h
//  iDoubs
//
//  Created by Mamadou DIOP on 9/13/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "tinymedia/tmedia_producer.h"

@class DWVideoProducer;

typedef struct dw_producer_s
{
	TMEDIA_DECLARE_PRODUCER;
	
	DWVideoProducer* eProducer;
	int fps;
	int width;
	int height;
	
	tsk_bool_t started;
}
dw_producer_t;

extern const tmedia_producer_plugin_def_t *dw_videoProducer_plugin_def_t;

@protocol DWVideoProducerCallback
-(int)producerStarted;
-(int)producerPaused;
-(int)producerStopped;
-(int)producerPreparedWithWidth:(int) width andHeight: (int)height andFps: (int)fps;
-(int)producerCreated:(dw_producer_t*)producer;
-(int)producerDestroyed:(dw_producer_t*)producer;
@end


@interface DWVideoProducer : NSObject {
	NSObject<DWVideoProducerCallback>* callback;
}

+(DWVideoProducer*)sharedInstance;

@property(readwrite, retain) NSObject<DWVideoProducerCallback>* callback;

@end
