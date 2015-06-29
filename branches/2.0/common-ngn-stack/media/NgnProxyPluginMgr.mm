///* Copyright (C) 2010-2011, Mamadou Diop.
// * Copyright (c) 2011, Doubango Telecom. All rights reserved.
// *
// * Contact: Mamadou Diop <diopmamadou(at)doubango(dot)org>
// *       
// * This file is part of iDoubs Project ( http://code.google.com/p/idoubs )
// *
// * idoubs is free software: you can redistribute it and/or modify it under the terms of 
// * the GNU General Public License as published by the Free Software Foundation, either version 3 
// * of the License, or (at your option) any later version.
// *       
// * idoubs is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
// * See the GNU General Public License for more details.
// *       
// * You should have received a copy of the GNU General Public License along 
// * with this program; if not, write to the Free Software Foundation, Inc., 
// * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
// *
// */
//#if TARGET_OS_IPHONE
//#	import "iOSNgnConfig.h"
//#elif TARGET_OS_MAC
//#	import "OSXNgnConfig.h"
//#endif
//
//#import "NgnProxyPluginMgr.h"
//#import "ProxyConsumer.h"
//#import "ProxyProducer.h"
//#import "ProxyPluginMgr.h"
//#import "MediaSessionMgr.h"
//#import "SipStack.h"
//
//#import "NgnVideoConsumer.h"
//
//#import "NgnProxyVideoConsumer.h"
//#if TARGET_OS_IPHONE
//#	import "iOSProxyVideoProducer.h"
//#   import "iOSVideoProducer.h"
//#elif TARGET_OS_MAC
//#	import "OSXProxyVideoProducer.h"
//#endif
//
//#undef TAG
//#define kTAG @"NgnProxyPluginMgr///: "
//#define TAG kTAG
//
////
////	Plugin manager implementation
////
//
//@implementation NgnProxyPluginMgr
//
//+(int)initialize{
//	// Media plugins
//    
//#if TARGET_OS_IPHONE /* opengl */
//    ProxyVideoConsumer::setDefaultChroma(tmedia_chroma_yuv420p);
//#else
//	ProxyVideoConsumer::setDefaultChroma(tmedia_chroma_rgb32);
//#endif
//	ProxyVideoConsumer::setDefaultAutoResizeDisplay(YES);
//	ProxyVideoProducer::setDefaultChroma(tmedia_chroma_nv12);
//	
//#if TARGET_OS_IPHONE
//    assert(tmedia_producer_plugin_register(ios_producer_video_plugin_def_t) == 0);
//#endif
//    assert(tmedia_consumer_plugin_register(ngn_consumer_video_plugin_def_t) == 0);
//	
//    MediaSessionMgr::defaultsSetVideoZeroArtifactsEnabled(NO);
//	MediaSessionMgr::defaultsSetBandwidthLevel(tmedia_bl_unrestricted);
//	MediaSessionMgr::defaultsSetNoiseSuppEnabled(YES);
//	MediaSessionMgr::defaultsSetVadEnabled(NO);
//#if HAVE_COREAUDIO_AUDIO_UNIT && TARGET_OS_IPHONE // already has AGC, Echo canceller, ... 
//	MediaSessionMgr::defaultsSetAgcEnabled(NO);
//	MediaSessionMgr::defaultsSetEchoSuppEnabled(NO);
//#else //if TARGET_OS_MAC
//	MediaSessionMgr::defaultsSetAgcEnabled(YES);
//	MediaSessionMgr::defaultsSetEchoSuppEnabled(YES);
//#endif
//    
//    // OPUS max sample rates
//    MediaSessionMgr::defaultsSetOpusMaxCaptureRate(16000);
//    MediaSessionMgr::defaultsSetOpusMaxPlaybackRate(16000);
//	
//	// SIP Stack
//	SipStack::initialize();
//	
//	return 0;
//}
//
//@end
//
