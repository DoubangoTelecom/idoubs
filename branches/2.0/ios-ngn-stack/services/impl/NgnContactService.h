#if TARGET_OS_IPHONE

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

#import "iOSNgnConfig.h"
#import "NgnBaseService.h"
#import "INgnContactService.h"

@class NgnContact;

@interface NgnContactService : NgnBaseService <INgnContactService>{	
	dispatch_queue_t mLoaderQueue;
	BOOL mLoading;
	BOOL mStarted;
	NgnContactMutableArray* mContacts;
}

@end


#endif /* TARGET_OS_IPHONE */