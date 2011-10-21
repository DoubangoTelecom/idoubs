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
#import "NgnSipPreferences.h"
#import "NgnStringUtils.h"

@implementation NgnSipPreferences

@synthesize presence;
@synthesize xcap;
@synthesize presenceRLS;
@synthesize presencePub;
@synthesize presenceSub;
@synthesize mwi;
@synthesize impi;
@synthesize impu;
@synthesize pcscfHost;
@synthesize pcscfPort;
@synthesize transport;
@synthesize ipVersion;
@synthesize ipsecSecAgree;
@synthesize localIp;
@synthesize hackAoR;

-(NSString*)realm{
	return self->realm;
}

-(void) setRealm:(NSString*)value {
	[self->realm release], self->realm = nil;
	if(value){
		if([NgnStringUtils contains:value subString:@":"]){
			self->realm = [[@"sip:" stringByAppendingString:value] retain];
		}
		else{
			self->realm = [value retain];
		}
	}
}

-(void)dealloc{
	[self->impi dealloc];
	[self->impu dealloc];
	[self->realm dealloc];
	[self->pcscfHost dealloc];
	[self->transport dealloc];
	[self->ipVersion dealloc];
	[self->localIp dealloc];
	[super dealloc];
}

@end
