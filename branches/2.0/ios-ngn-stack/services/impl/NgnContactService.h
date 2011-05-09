#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

#import "NgnBaseService.h"
#import "INgnContactService.h"

@interface NgnContactService : NgnBaseService <INgnContactService>{
	NSMutableArray* mPeople;
	
	ABAddressBookRef mAddressBook;
}

@end
