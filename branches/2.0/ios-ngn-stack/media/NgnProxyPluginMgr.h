#if TARGET_OS_IPHONE

#import <Foundation/Foundation.h>

#import "NgnProxyPlugin.h"

@interface NgnProxyPluginMgr : NSObject {
	
}

+(void) initialize;
+(NgnProxyPlugin*) getProxyPluginWithId: (uint64_t)id;

@end

#endif /* TARGET_OS_IPHONE */
