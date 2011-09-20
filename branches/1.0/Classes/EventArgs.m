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

#import "EventArgs.h"


/* ======================== EventArgs ========================*/
@implementation EventArgs

@synthesize phrase;
@synthesize sipCode;

-(EventArgs*)initWithCode: (short)code andPhrase: (NSString*)_phrase{
	if(self = [super init]){
		self->sipCode = code;
		self->phrase = [_phrase retain];
	}
	return self;
}

-(void)putExtraWithKey: (NSString*)key andValue:(NSString*)value{
	if(!extras){
		extras = [[NSMutableDictionary alloc]init];
	}
	[extras setObject:value forKey:key];
}

-(NSString*)extraValueForKey: (NSString*)key{
	return [extras objectForKey:key];
}

-(void)dealloc{
	[extras release];
	[self->phrase release];
	[super dealloc];
}
@end



/* ======================== RegistrationEventArgs ========================*/
@implementation RegistrationEventArgs

@synthesize type;

-(RegistrationEventArgs*)initWithType: (RegistrationEventTypes_t)_type andSipCode: (short)_sipCode andPhrase: (NSString*)_phrase{
	if(self = (RegistrationEventArgs*)[super initWithCode: _sipCode andPhrase: _phrase]){
		self->type = _type;
	}
	return self;
}

+(NSString* const) eventName{
	return @"RegistrationEventArgs::Event";
}

-(void)dealloc{
	[super dealloc];
}

@end





/* ======================== InviteEventArgs ========================*/
@implementation InviteEventArgs

@synthesize type;

-(InviteEventArgs*)initWithType: (InviteEventTypes_t)_type andSipCode: (short)_sipCode andPhrase: (NSString*)_phrase{
	if(self = (InviteEventArgs*)[super initWithCode: _sipCode andPhrase: _phrase]){
		self->type = _type;
	}
	return self;
}

+(NSString* const) eventName{
	return @"InviteEventArgs::Event";
}

-(void)dealloc{
	[super dealloc];
}

@end
