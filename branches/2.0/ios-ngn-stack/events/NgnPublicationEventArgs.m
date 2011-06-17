/* Copyright (C) 2010-2011, Mamadou Diop.
 * Copyright (c) 2011, Doubango Telecom. All rights reserved.
 *
 * Contact: Mamadou Diop <diopmamadou(at)doubango(dot)org>
 *       
 * This file is part of iDoubs Project ( http://code.google.com/p/idoubs )
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
#import "NgnPublicationEventArgs.h"


@implementation NgnPublicationEventArgs

@synthesize sessionId;
@synthesize eventType;
@synthesize sipCode;
@synthesize sipPhrase;

-(NgnPublicationEventArgs*) initWithSessionId:(long)sessionId_
								 andEventType:(NgnPublicationEventTypes_t)eventType_
								   andSipCode:(short)sipCode_
								 andSipPhrase:(NSString*)sipPhrase_
{
	if((self = [super init])){
		self->sessionId = sessionId_;
		self->eventType = eventType_;
		self->sipCode = sipCode_;
		self->sipPhrase = [sipPhrase_ retain];
	}
	return self;
}

-(void)dealloc{
	[self.sipPhrase release];
	
	[super dealloc];
}

@end
