#import "NgnContactService.h"

@implementation NgnContactService(Notifications)


@end

@implementation NgnContactService

-(NgnContactService*)init{
	if((self = [super init])){
		mAddressBook = NULL;
		mPeople = [[NSMutableArray alloc] init];
	}
	return self;
}

//
// INgnBaseService
//

-(BOOL) start{
	if(mAddressBook){
		CFRelease(mAddressBook), mAddressBook = NULL;
	}
	
	if((mAddressBook = ABAddressBookCreate())){
	}
	
	return YES;
}

-(BOOL) stop{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	if(mAddressBook){
		CFRelease(mAddressBook), mAddressBook = NULL;
	}
	return YES;
}

-(void)dealloc{
	[self stop];
	
	[mPeople release];
	
	[super dealloc];
}

@end
