#import "testAudioUnit.h"

#import "tdav.h"

#include "tsk_debug.h"

#include "tinymedia/tmedia_consumer.h"
#include "tinymedia/tmedia_producer.h"
#include "tinymedia/tmedia_codec.h"

#define kFakeAudionSessionId	87
#define kFakeCodecFormat		TMEDIA_CODEC_FORMAT_G711u

static tmedia_consumer_t* consumer = tsk_null;
static tmedia_producer_t* producer = tsk_null;
static tmedia_codec_t* codec = tsk_null;

//
// TestAudioUnit
//
@implementation TestAudioUnit

@synthesize window;
@synthesize buttonPrepare;
@synthesize buttonStart;
@synthesize buttonStop;
@synthesize buttonPause;
@synthesize buttonResume;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// initialize media library
	tdav_init();
	// query for audio and video consumer and producer
	if(!(consumer = tmedia_consumer_create(tmedia_audio, kFakeAudionSessionId))){
		TSK_DEBUG_ERROR("Failed to create consumer");
	}
	if(!(producer = tmedia_producer_create(tmedia_audio, kFakeAudionSessionId))){
		TSK_DEBUG_ERROR("Failed to create producer");
	}
	// create a codec
	if(!(codec = tmedia_codec_create(kFakeCodecFormat))){
		TSK_DEBUG_ERROR("Failed to create codec with format=%s", kFakeCodecFormat);
	}
    
    [window makeKeyAndVisible];
}

- (IBAction) onButtonPrepareClick: (id)sender{
	int ret;
	if((ret = tmedia_consumer_prepare(consumer, codec))){
		TSK_DEBUG_ERROR("tmedia_consumer_prepare(consumer) failed with error code=%d", ret);
	}
	if((ret = tmedia_producer_prepare(producer, codec))){
		TSK_DEBUG_ERROR("tmedia_consumer_prepare(consumer) failed with error code=%d", ret);
	}
}

- (IBAction) onButtonStartClick: (id)sender{
	int ret;
	if((ret = tmedia_consumer_start(consumer))){
		TSK_DEBUG_ERROR("tmedia_consumer_start(consumer) failed with error code=%d", ret);
	}
	if((ret = tmedia_producer_start(producer))){
		TSK_DEBUG_ERROR("tmedia_producer_start(consumer) failed with error code=%d", ret);
	}
}

- (IBAction) onButtonStopClick: (id)sender{
	int ret;
	if((ret = tmedia_consumer_stop(consumer))){
		TSK_DEBUG_ERROR("tmedia_consumer_stop(consumer) failed with error code=%d", ret);
	}
	if((ret = tmedia_producer_stop(producer))){
		TSK_DEBUG_ERROR("tmedia_producer_stop(consumer) failed with error code=%d", ret);
	}
}

- (IBAction) onButtonPauseClick: (id)sender{
	int ret;
	if((ret = tmedia_consumer_pause(consumer))){
		TSK_DEBUG_ERROR("tmedia_consumer_pause(consumer) failed with error code=%d", ret);
	}
	if((ret = tmedia_producer_pause(producer))){
		TSK_DEBUG_ERROR("tmedia_producer_pause(consumer) failed with error code=%d", ret);
	}
}

- (IBAction) onButtonResumeClick: (id)sender{
	[self onButtonStartClick: sender];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// release audio and video consumer and producer
	TSK_OBJECT_SAFE_FREE(consumer);
	TSK_OBJECT_SAFE_FREE(producer);
	// release code
	TSK_OBJECT_SAFE_FREE(codec);
	// deinitialize the media library
	tdav_deinit();
}

- (void)dealloc {
    [window release];
    [super dealloc];
}

@end
