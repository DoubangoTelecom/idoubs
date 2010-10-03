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
