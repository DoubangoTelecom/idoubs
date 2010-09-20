//
//  ConfigurationService.h
//  iDoubs
//
//  Created by Mamadou DIOP on 8/29/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Service.h"
#import "PConfigurationService.h"

@interface ConfigurationService : Service<PConfigurationService> {
	NSUserDefaults *prefs;
}

@end
