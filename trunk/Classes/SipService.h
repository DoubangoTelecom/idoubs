//
//  SipService.h
//  iDoubs
//
//  Created by Mamadou DIOP on 9/3/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Service.h"
#import "PSipService.h"

#import "DWSipStack.h"


@class DWSipStack;
@class DWRegistrationSession;

@interface SipService : Service<PSipService, DWSipStackDelegate> {

	BOOL registered;
	
	DWSipStack* sipStack;
	
	DWRegistrationSession* registrationSession;
}

@end
