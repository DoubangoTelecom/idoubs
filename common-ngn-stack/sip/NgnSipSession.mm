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
 */
#import "NgnSipSession.h"
#import "NgnStringUtils.h"

#import "tsk_debug.h"

@implementation NgnSipSession

-(NgnSipSession*) initWithSipStack: (NgnSipStack*)sipStack{
	if((self = [super init])){
		mSipStack = [sipStack retain];
		mOutgoing = FALSE;
		mConnectionState = CONN_STATE_NONE;
		mId = -1;
		/* initialize must be called by the child class after session_create() */
        /* initialize(); */
	}
	return self;
}
-(void)dealloc{
	[mSipStack release];
	[mFromUri release];
    [mToUri release];
    [mCompId release];
    [mRemotePartyUri release];
    [mRemotePartyDisplayName release];
	
	[super dealloc];
}

-(void)initialize{
	// Sip Headers (common to all sessions)
	[self getSession]->addCaps("+g.oma.sip-im");
	[self getSession]->addCaps("language", "\"en,fr\"");
}

-(long)getId{
	if(mId == -1){
		mId = [self getSession]->getId(); 
	}
	return mId;
}

-(NSNumber*)getIdAsNumber{
	return [NSNumber numberWithLong: [self getId]];
}

-(BOOL)isOutgoing{
	return mOutgoing;
}

-(NgnSipStack*)getSipStack{
	return mSipStack;
}

-(BOOL)addHeaderWithName: (NSString*)name andValue: (NSString*)value{
	return [self getSession]->addHeader([name UTF8String], [value UTF8String]);
}

-(BOOL)removeHeaderWithName: (NSString*)name{
	return [self getSession]->removeHeader([name UTF8String]);
}

-(BOOL)addCapsWithName: (NSString*)name{
	return [self getSession]->addCaps([name UTF8String]);
}

-(BOOL)addCapsWithName: (NSString*)name andValue: (NSString*)value{
	return [self getSession]->addCaps([name UTF8String], [value UTF8String]);
}


-(BOOL)removeCapsWithName: (NSString*)name{
	return [self getSession]->removeCaps([name UTF8String]);
}

-(BOOL)isConnected{
	return (mConnectionState == CONN_STATE_CONNECTED);
}

-(ConnectionState_t)getConnectionState{
	return mConnectionState;
}

-(void)setConnectionState: (ConnectionState_t)state{
	mConnectionState = state;
}

-(NSString*)getFromUri{
	return mFromUri;
}

-(BOOL)setFromUri:(NSString*)uri{
	if (![self getSession]->setFromUri([uri UTF8String])){
		TSK_DEBUG_ERROR("%s is invalid as FromUri", [uri UTF8String]);
		return FALSE;
	}
	[mFromUri release], mFromUri = [uri retain];
	return TRUE;
}

-(NSString*)getToUri{
	return mToUri;
}

-(BOOL)setToUri:(NSString*)uri{
	if (![self getSession]->setToUri([uri UTF8String])){
		TSK_DEBUG_ERROR("%s is invalid as ToUri", [uri UTF8String]);
		return FALSE;
	}
	[mToUri release], mToUri = [uri retain];
	return TRUE;
}

-(NSString*)getRemotePartyUri{
	if([NgnStringUtils isNullOrEmpty:mRemotePartyUri]){
		mRemotePartyUri =  mOutgoing ? [mToUri retain] : [mFromUri retain];
	}
	return mRemotePartyUri;
}

-(void)setRemotePartyUri:(NSString*)uri{
	[mRemotePartyUri release], mRemotePartyUri = [uri retain];
}

-(void)setSigCompId:(NSString*)compId{
	if(mCompId != nil && mCompId != compId){
		[self getSession]->removeSigCompCompartment();
	}
	[mCompId release], mCompId = [compId retain];
	if(mCompId != nil){
		[self getSession]->addSigCompCompartment([mCompId UTF8String]);
	}
}

-(BOOL)setExpires:(unsigned)expires{
	return [self getSession]->setExpires(expires);
}

-(SipSession*)getSession{
	[NSException raise:NSInternalInconsistencyException
				format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
	return tsk_null;
}

@end
