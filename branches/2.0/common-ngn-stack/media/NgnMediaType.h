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
#ifndef NGN_MEDIATYPE_H
#define NGN_MEDIATYPE_H

typedef enum NgnMediaType_e {
	// Very Important: These values are stored in the data base and MUST never
	// be changed. If you want to add new type, please add it after "MediaType_Msrp"
	MediaType_None = 0,
	MediaType_Audio = (0x01<<0),
	MediaType_Video = (0x01<<1),
	MediaType_AudioVideo = MediaType_Audio | MediaType_Video,
	MediaType_SMS = (0x01<<2),
	MediaType_Chat = (0x01<<3),
	MediaType_FileTransfer = (0x01<<4),
	MediaType_Msrp = MediaType_Chat | MediaType_FileTransfer,
	
	// --- Add you media type after THIS LINE ---
	
	// --- Add you media type before THIS LINE ---
	
	MediaType_All = MediaType_AudioVideo | MediaType_Msrp
}
NgnMediaType_t;

static bool isAudioVideoType(NgnMediaType_t type){
	return (type & MediaType_AudioVideo);
}
static bool isAudioType(NgnMediaType_t type){
	return (type & MediaType_Audio);
}
static bool isVideoType(NgnMediaType_t type){
	return (type & MediaType_Video);
}
static bool isFileTransfer(NgnMediaType_t type){
	return type == MediaType_FileTransfer;
}
static bool isChat(NgnMediaType_t type){
	return type == MediaType_Chat;
}
static bool isMsrpType(NgnMediaType_t type){
	return (type & MediaType_Msrp);
}


#endif /* NGN_MEDIATYPE_H */
