#import <Foundation/Foundation.h>

#import "INgnBaseService.h"

#if TARGET_OS_IPHONE
#	import "model/NgnContact.h"
#endif

@protocol INgnContactService <INgnBaseService>
-(void) load: (BOOL) asyn;
-(BOOL) isLoading;
-(NSMutableArray*) contacts;
-(NSArray*) contactsWithPredicate: (NSPredicate*)predicate;
@end

