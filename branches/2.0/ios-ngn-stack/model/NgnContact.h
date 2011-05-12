#if TARGET_OS_IPHONE

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

#import "utils/NgnPredicate.h"
#import "model/NgnPhoneNumber.h"

#undef NgnContactMutableArray
#undef NgnContactArray
#define NgnContactMutableArray	NSMutableArray
#define NgnContactArray	NSArray

@class NgnPhoneNumber;

@interface NgnContact : NSObject {
	int32_t id;
	NSString* displayName;
	NSString* fisrtName;
	NSString* lastName;
	NSMutableArray* phoneNumbers;
	NSData* picture;
}

-(NgnContact*)initWithABRecordRef: (const ABRecordRef) record;
-(NgnPhoneNumber*) getPhoneNumberWithPredicate: (NSPredicate*)predicate;

@property(readonly) int32_t id;
@property(readonly) NSString* displayName;
@property(readonly) NSString* firstName;
@property(readonly) NSString* lastName;
@property(readonly) NSMutableArray* phoneNumbers;
@property(readonly) NSData* picture;

@end

#endif /* TARGET_OS_IPHONE */