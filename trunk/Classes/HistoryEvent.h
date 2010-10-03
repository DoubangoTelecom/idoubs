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

typedef enum HistoryEventStatus_e
{
	HistoryEventStatus_Outgoing,
	HistoryEventStatus_Incoming,
	HistoryEventStatus_Missed,
	HistoryEventStatus_Failed
}
HistoryEventStatus_t;

typedef enum HistoryEventType_e
{
	HistoryEventType_Audio,
	HistoryEventType_AudioVideo,
	HistoryEventType_SMS,
	HistoryEventType_Chat,
	HistoryEventType_FileTransfer
}
HistoryEventType_t;

@interface HistoryEvent : NSObject {
	HistoryEventType_t type;
	BOOL seen;
	HistoryEventStatus_t status;
	NSString* remoteParty;
	NSTimeInterval start;
	NSTimeInterval end;
}

@property(readonly,assign) HistoryEventType_t type;
@property(readwrite,assign) BOOL seen;
@property(readwrite,assign) HistoryEventStatus_t status;
@property(readonly,retain) NSString* remoteParty;
@property(readwrite,assign) NSTimeInterval start;
@property(readwrite,assign) NSTimeInterval end;

-(HistoryEvent*)initWithType: (HistoryEventType_t)type andRemoteParty: (NSString*)remoteParty;

@end


@interface HistoryAVCallEvent : HistoryEvent {
}

-(HistoryAVCallEvent*)initAudioCallEvent: (NSString*)remoteParty;
-(HistoryAVCallEvent*)initAudioVideoCallEvent: (NSString*)remoteParty;

@end
