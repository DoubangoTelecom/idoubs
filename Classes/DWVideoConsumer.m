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

#import "DWVideoConsumer.h"

#import "tsk_debug.h"
#import "tsk_memory.h"


#define DWCONSUMER(self)                ((dw_consumer_t*)(self))

typedef struct dw_consumer_s
{
	TMEDIA_DECLARE_CONSUMER;
	
	DWVideoConsumer* eConsumer;
	
	tsk_bool_t started;
}
dw_consumer_t;

/* ============ Media Consumer Interface ================= */
int dw_consumer_prepare(tmedia_consumer_t* self, const tmedia_codec_t* codec)
{	
	dw_consumer_t* consumer = (dw_consumer_t*)self;
	
	if(!consumer || !codec && codec->plugin){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	
	if(!consumer->eConsumer){
		TSK_DEBUG_ERROR("Invalid embedded consumer");
		return -2;
	}
	
	TMEDIA_CONSUMER(consumer)->video.fps = TMEDIA_CODEC_VIDEO(codec)->fps;
	TMEDIA_CONSUMER(consumer)->video.width = TMEDIA_CODEC_VIDEO(codec)->width;
	TMEDIA_CONSUMER(consumer)->video.height = TMEDIA_CODEC_VIDEO(codec)->height;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int ret = [consumer->eConsumer.callback consumerPreparedWithWidth:TMEDIA_CONSUMER(consumer)->video.width 
												   andHeight:TMEDIA_CONSUMER(consumer)->video.height 
												   andFps:TMEDIA_CONSUMER(consumer)->video.fps];
	[pool release];
	
	return ret;
}

int dw_consumer_start(tmedia_consumer_t* self)
{
	dw_consumer_t* consumer = (dw_consumer_t*)self;
	int ret;
	
	if(!consumer){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	
	if(!consumer->eConsumer){
		TSK_DEBUG_ERROR("Invalid embedded consumer");
		return -2;
	}
	
	if(consumer->started){
		TSK_DEBUG_WARN("Producer already started");
		return 0;
	}
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	ret = [consumer->eConsumer.callback consumerStarted];
	[pool release];
	
	consumer->started = (ret == 0);
	
	
	return ret;
}

int dw_consumer_consume(tmedia_consumer_t* self, void** buffer, tsk_size_t size, const tsk_object_t* proto_hdr)
{
	dw_consumer_t* consumer = (dw_consumer_t*)self;
	if(consumer && consumer->eConsumer && buffer){
		// up to the callback function to install pool
		int ret = [consumer->eConsumer.callback consumerHasBuffer:*buffer withSize:size];
		return ret;
	}
	else{
		TSK_DEBUG_ERROR("Invlide parameter");
		return -1;
	}
}

int dw_consumer_pause(tmedia_consumer_t* self)
{
	dw_consumer_t* consumer = (dw_consumer_t*)self;
	
	if(!consumer){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	
	if(!consumer->eConsumer){
		TSK_DEBUG_ERROR("Invalid embedded consumer");
		return -2;
	}
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int ret = [consumer->eConsumer.callback consumerPaused];
	[pool release];
	
	return ret;
}

int dw_consumer_stop(tmedia_consumer_t* self)
{
	int ret;
	dw_consumer_t* consumer = (dw_consumer_t*)self;
	
	if(!self){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	
	if(!consumer->started){
		TSK_DEBUG_WARN("Consumer not started");
		return 0;
	}
	
	if(!consumer->eConsumer){
		TSK_DEBUG_ERROR("Invalid embedded consumer");
		return -2;
	}
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	ret = [consumer->eConsumer.callback consumerStopped];
	[pool release];
	
	consumer->started = (ret == 0) ? tsk_false : tsk_true;
	return ret;
}


//
//      Doubango consumer object definition
//
/* constructor */
static tsk_object_t* dw_consumer_ctor(tsk_object_t * self, va_list * app)
{	
	dw_consumer_t *consumer = (dw_consumer_t *)self;
	if(consumer){		
		/* init base */
		tmedia_consumer_init(TMEDIA_CONSUMER(consumer));
		TMEDIA_CONSUMER(consumer)->video.chroma = tmedia_rgb32;
		/* init self (Default values)*/
		TMEDIA_CONSUMER(consumer)->video.fps = 15;
		TMEDIA_CONSUMER(consumer)->video.width = 176;
		TMEDIA_CONSUMER(consumer)->video.height = 144;
		consumer->eConsumer = [[DWVideoConsumer sharedInstance] retain];
	}
	return self;
}
/* destructor */
static tsk_object_t* dw_consumer_dtor(tsk_object_t * self)
{ 
	dw_consumer_t *consumer = (dw_consumer_t *)self;
	if(consumer){
		
		/* stop */
		if(consumer->started){
			dw_consumer_stop((tmedia_consumer_t*)self);
		}
		
		/* deinit base */
		tmedia_consumer_deinit(TMEDIA_CONSUMER(consumer));
		/* deinit self */
		[consumer->eConsumer release];		
	}
	
	return self;
}
/* object definition */
static const tsk_object_def_t dw_consumer_def_s = 
{
	sizeof(dw_consumer_t),
	dw_consumer_ctor, 
	dw_consumer_dtor,
	tsk_null, 
};
/* plugin definition*/
static const tmedia_consumer_plugin_def_t dw_consumer_plugin_def_s = 
{
	&dw_consumer_def_s,
	
	tmedia_video,
	"iOS4 Video consumer",
	
	dw_consumer_prepare,
	dw_consumer_start,
	dw_consumer_consume,
	dw_consumer_pause,
	dw_consumer_stop
};
const tmedia_consumer_plugin_def_t *dw_videoConsumer_plugin_def_t = &dw_consumer_plugin_def_s;









@implementation DWVideoConsumer

static DWVideoConsumer* instance;

+(DWVideoConsumer*)sharedInstance{
	if(!instance){
		instance = [[DWVideoConsumer alloc] init];
	}
	return instance;
}

-(NSObject<DWVideoConsumerCallback>*) callback{
	return self->callback;
}

-(void) setCallback:(NSObject<DWVideoConsumerCallback>*)_callback{
	[self->callback release];
	self->callback = [_callback retain];
}

@end
