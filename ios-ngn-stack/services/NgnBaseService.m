#import "NgnBaseService.h"


@implementation NgnBaseService

-(BOOL) start{
	[NSException raise:NSInternalInconsistencyException 
				format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
	return NO;
}

-(BOOL) stop{
	[NSException raise:NSInternalInconsistencyException 
				format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
	return NO;
}

@end
