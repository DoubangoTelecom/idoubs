#import <Foundation/Foundation.h>

#import "INgnBaseService.h"

#if TARGET_OS_IPHONE
#	import "model/NgnContact.h"
#elif TARGET_OS_MAC
#	import "model/MacContact.h"
#endif

@protocol INgnContactService <INgnBaseService>
-(void) load: (BOOL) asyn;
-(BOOL) isLoading;
-(NgnContactMutableArray*) contacts;
-(NgnContactArray*) contactsWithPredicate: (NSPredicate*)predicate;
@end

