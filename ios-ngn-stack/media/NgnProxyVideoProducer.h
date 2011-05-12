#if TARGET_OS_IPHONE

#undef NGN_PRODUCER_HAS_VIDEO_CAPTURE
#define NGN_PRODUCER_HAS_VIDEO_CAPTURE (__IPHONE_OS_VERSION_MIN_REQUIRED >= 40000 && TARGET_OS_EMBEDDED)

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "NgnProxyPlugin.h"

class ProxyVideoProducer;
class _NgnProxyVideoProducerCallback;

@interface NgnProxyVideoProducer : NgnProxyPlugin 
#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
<AVCaptureVideoDataOutputSampleBufferDelegate>
#endif
{
	_NgnProxyVideoProducerCallback* _mCallback;
	const ProxyVideoProducer * _mProducer;
	
	int mWidth;
	int mHeight;
	int mFps;
#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
	UIView* mPreview;
	AVCaptureSession* mCaptureSession;
	AVCaptureDevice *mCaptureDevice;
	BOOL mFirstFrame;
#endif
}

-(NgnProxyVideoProducer*) initWithId: (uint64_t)identifier andProducer:(const ProxyVideoProducer *)_producer;
-(void)setPreview: (UIView*)preview;

@end

#endif /* TARGET_OS_IPHONE */
