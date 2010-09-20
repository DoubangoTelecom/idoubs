//
//  EventArgs.m
//  iDoubs
//
//  Created by Mamadou DIOP on 9/11/10.
//  Copyright 2010 doubango. All rights reserved.
//

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
