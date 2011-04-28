#import <Foundation/Foundation.h>

#import <services/INgnBaseService.h>

@interface NgnBaseService : NSObject<INgnBaseService> {
	
}

-(BOOL) start;
-(BOOL) stop;

@end