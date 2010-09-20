//
//  Service.h
//  iDoubs
//
//  Created by Mamadou DIOP on 8/29/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PService.h"

@interface Service : NSObject<PService> {


}

-(BOOL) start;
-(BOOL) stop;

@end
