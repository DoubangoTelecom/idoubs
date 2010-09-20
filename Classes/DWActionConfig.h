//
//  ActionConfig.h
//  iDoubs
//
//  Created by Mamadou DIOP on 8/27/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "tinysip.h"

@interface DWActionConfig : NSObject {
}

-(BOOL) addHeaderWithName: (NSString*) name andValue: (NSString*) value;
-(DWActionConfig*) setMediaStringForType: (tmedia_type_t) type withKey: (NSString*) key withValue: (NSString*) value;
-(DWActionConfig*) setMediaIntForType: (tmedia_type_t) type withKey: (NSString*) key withValue: (int) value;

@property(readonly, assign) tsip_action_handle_t* handle;

@end
