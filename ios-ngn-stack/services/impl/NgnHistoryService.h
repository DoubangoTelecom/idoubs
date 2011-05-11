#if TARGET_OS_IPHONE

#import <Foundation/Foundation.h>

#import "iOSNgnConfig.h"
#import "services/impl/NgnBaseService.h"
#import "services/INgnHistoryService.h"

@interface NgnHistoryService : NgnBaseService <INgnHistoryService> {
	
}

@end

#endif /* TARGET_OS_IPHONE */
