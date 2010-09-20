//
//  PConfigurationService.h
//  iDoubs
//
//  Created by Mamadou DIOP on 8/29/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PService.h"
#import "Configuration.h"

@protocol PConfigurationService <PService>

-(NSString*) getString: (CONFIGURATION_SECTION_T) section entry:(CONFIGURATION_ENTRY_T) e;
-(int) getInt: (CONFIGURATION_SECTION_T) section  entry:(CONFIGURATION_ENTRY_T) e;
-(float) getFloat: (CONFIGURATION_SECTION_T) section entry:(CONFIGURATION_ENTRY_T) e;
-(BOOL) getBoolean: (CONFIGURATION_SECTION_T) section entry:(CONFIGURATION_ENTRY_T) e;

@end
