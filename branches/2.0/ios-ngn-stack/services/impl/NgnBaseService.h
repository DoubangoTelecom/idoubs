#import <Foundation/Foundation.h>

#import "INgnBaseService.h"

@interface NgnBaseService : NSObject<INgnBaseService> {
	
}

-(BOOL) start;
-(BOOL) stop;

@end