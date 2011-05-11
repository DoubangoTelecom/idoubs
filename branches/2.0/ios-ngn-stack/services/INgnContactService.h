#import <Foundation/Foundation.h>

#import "INgnBaseService.h"

#import "model/NgnContact.h"

@protocol INgnContactService <INgnBaseService>
-(void) load: (BOOL) asyn;
-(BOOL) isLoading;
-(NgnContactMutableArray*) contacts;
-(NgnContactArray*) contactsWithPredicate: (NSPredicate*)predicate;
@end

