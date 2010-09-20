//
//  SafeObject.m
//  iDoubs
//
//  Created by Mamadou DIOP on 8/27/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import "DWSafeObject.h"


@implementation DWSafeObject

-(DWSafeObject*) init{
	self = [super init];
	
	if(self){
		self->mutex = tsk_mutex_create();
	}
	
	return self;
}

-(BOOL) lock{
	return (tsk_mutex_lock(self->mutex) == 0);
}

-(BOOL) unlock{
	return (tsk_mutex_unlock(self->mutex) == 0);
}

-(void) dealloc{

	tsk_mutex_destroy(&self->mutex);
	[super dealloc];
}

@end
