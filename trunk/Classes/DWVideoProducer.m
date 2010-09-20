//
//  DWVideoProducer.m
//  iDoubs
//
//  Created by Mamadou DIOP on 9/13/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import "DWVideoProducer.h"

#import "tsk_debug.h"

#define DWPRODUCER(self)                ((dw_producer_t*)(self))


// Producer callback (From Video Grabber to our plugin)
static int dw_plugin_cb(const void* callback_data, const void* buffer, tsk_size_t size)
{
	const dw_producer_t* producer = (const dw_producer_t*)callback_data;
	
	if(producer && TMEDIA_PRODUCER(producer)->callback){
		TMEDIA_PRODUCER(producer)->callback(TMEDIA_PRODUCER(producer)->callback_data, buffer, size);
	}
	
	return 0;
}


/* ============ Video Media Producer Interface ================= */
int dw_producer_prepare(tmedia_producer_t* self, const tmedia_codec_t* codec)
{
	dw_producer_t* producer = (dw_producer_t*)self;
	int ret;
	
	if(!producer || !codec && codec->plugin){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	
	if(!producer->eProducer){
		TSK_DEBUG_ERROR("Invalid embedded producer");
		return -2;
	}
	
	/* Set Capture parameters */
	producer->fps = TMEDIA_CODEC_VIDEO(codec)->fps;
	producer->width = TMEDIA_CODEC_VIDEO(codec)->width;
	producer->height = TMEDIA_CODEC_VIDEO(codec)->height;
	
	if((ret = [producer->eProducer.callback producerPreparedWithWidth:producer->width andHeight:producer->height andFps:producer->fps])){
		return ret;
	}
	return 0;
}

int dw_producer_start(tmedia_producer_t* self)
{
	dw_producer_t* producer = (dw_producer_t*)self;
	int ret;
	
	if(!producer){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	
	if(!producer->eProducer){
		TSK_DEBUG_ERROR("Invalid embedded producer");
		return -2;
	}
	
	if(producer->started){
		TSK_DEBUG_WARN("Producer already started");
		return 0;
	}
	
	
	if((ret = [producer->eProducer.callback producerStarted])){
		return ret;
	}
	
	producer->started = tsk_true;
	return 0;
}

int dw_producer_pause(tmedia_producer_t* self)
{
	dw_producer_t* producer = (dw_producer_t*)self;
	int ret;
	
	if(!producer){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	
	if(!producer->eProducer){
		TSK_DEBUG_ERROR("Invalid embedded producer");
		return -2;
	}
	
	if((ret = [producer->eProducer.callback producerPaused])){
		return ret;
	}
	
	return 0;
}

int dw_producer_stop(tmedia_producer_t* self)
{
	dw_producer_t* producer = (dw_producer_t*)self;
	int ret;
	
	if(!self){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	
	if(!producer->started){
		TSK_DEBUG_WARN("Producer not started");
		return 0;
	}
	
	if(!producer->eProducer){
		TSK_DEBUG_ERROR("Invalid embedded producer");
		return -2;
	}
	
	if((ret = [producer->eProducer.callback producerStopped])){
		return ret;
	}
	
	producer->started = tsk_false;
	return 0;
}


//
//      iOS4 Video producer object definition
//
/* constructor */
static tsk_object_t* dw_producer_ctor(tsk_object_t * self, va_list * app)
{	
	dw_producer_t *producer = (dw_producer_t *)self;
	if(producer){		
		/* init base */
		tmedia_producer_init(TMEDIA_PRODUCER(producer));
		TMEDIA_PRODUCER(producer)->video.chroma = tmedia_uyvy422;
		/* init self (default values) */
		producer->fps = 15;
		producer->width = 176;
		producer->height = 144;
		producer->eProducer = [[DWVideoProducer sharedInstance] retain];
		
		[producer->eProducer.callback producerCreated:producer];
	}
	return self;
}
/* destructor */
static tsk_object_t* dw_producer_dtor(tsk_object_t * self)
{ 
	dw_producer_t *producer = (dw_producer_t *)self;
	if(producer){
		
		/* stop */
		if(producer->started){
			dw_producer_stop((tmedia_producer_t*)self);
		}
		
		/* deinit base */
		tmedia_producer_deinit(TMEDIA_PRODUCER(producer));
		/* deinit self */
		[producer->eProducer.callback producerDestroyed:producer];
		[producer->eProducer release];
		
	}
	
	return self;
}
/* object definition */
static const tsk_object_def_t tdshow_producer_def_s = 
{
	sizeof(dw_producer_t),
	dw_producer_ctor, 
	dw_producer_dtor,
	tsk_null, 
};
/* plugin definition*/
static const tmedia_producer_plugin_def_t dw_producer_plugin_def_s = 
{
	&tdshow_producer_def_s,
	
	tmedia_video,
	"iOS4 Video producer",
	
	dw_producer_prepare,
	dw_producer_start,
	dw_producer_pause,
	dw_producer_stop
};
const tmedia_producer_plugin_def_t *dw_videoProducer_plugin_def_t = &dw_producer_plugin_def_s;



@implementation DWVideoProducer

static DWVideoProducer* instance;

+(DWVideoProducer*)sharedInstance{
	if(!instance){
		instance = [[DWVideoProducer alloc] init];
	}
	return instance;
}

-(NSObject<DWVideoProducerCallback>*) callback{
	return self->callback;
}

-(void) setCallback:(NSObject<DWVideoProducerCallback>*)_callback{
	[self->callback release];
	self->callback = [_callback retain];
}

@end
