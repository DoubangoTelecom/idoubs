#if TARGET_OS_IPHONE

#import "NgnContactService.h"
#import "model/NgnContact.h"

#undef TAG
#undef kNameSpace
#define kNameSpace "org.doubango.ios.services.contacts"
#define kTAG @"NgnContactService///: "
#define TAG kTAG

#undef NgnCFRelease
#define NgnCFRelease(x) if(x)CFRelease(x), x=NULL;

@interface NgnContactService(Private)

@property(readonly, getter=isStarted) BOOL started;

-(BOOL) isStarted;
-(void) syncLoad;
@end


static void NgnAddressBookCallbackForElements(const void *value, void *context)
{
	NgnContactService* _self = (NgnContactService*)context;
	if(!_self.started){
		return;
	}
	const ABRecordRef* record = (const ABRecordRef*)value;
	NgnContact* contact = [[NgnContact alloc] initWithABRecordRef: record];
	[[_self contacts] addObject: contact];
	[contact release];
}

static CFComparisonResult NgnAddressBookCompareByCompositeName(ABRecordRef person1, ABRecordRef person2, ABPersonSortOrdering ordering)
{
	CFStringRef displayName1 = ABRecordCopyCompositeName(person1);
	CFStringRef displayName2 = ABRecordCopyCompositeName(person2);
	CFComparisonResult result = kCFCompareEqualTo;
	
	switch([(NSString*)displayName1 compare: (NSString*)displayName2]){
		case NSOrderedAscending:
			result = kCFCompareLessThan;
			break;
		case NSOrderedSame:
			result = kCFCompareEqualTo;
			break;
		case NSOrderedDescending:
			result = kCFCompareGreaterThan;
			break;
	}
	
	NgnCFRelease(displayName1);
	NgnCFRelease(displayName2);
	
	return result;
}

@implementation NgnContactService(Private)

-(BOOL) isStarted{
	return mStarted;
}

-(void)syncLoad{
	mLoading = TRUE;
	[mContacts removeAllObjects];
	ABAddressBookRef addressBook;
	if((addressBook = ABAddressBookCreate())){
		CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
		CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(
										   kCFAllocatorDefault,
										   CFArrayGetCount(people),
										   people
										   );
		CFArraySortValues(
						  peopleMutable,
						  CFRangeMake(0, CFArrayGetCount(peopleMutable)),
						  (CFComparatorFunction) NgnAddressBookCompareByCompositeName,
						  (void*) ABPersonGetSortOrdering()
						  );
		
		// Create NGN contacts
		CFArrayApplyFunction(peopleMutable, CFRangeMake(0, CFArrayGetCount(peopleMutable)), NgnAddressBookCallbackForElements, self);
		
		NgnCFRelease(peopleMutable);
		NgnCFRelease(addressBook);
		NgnCFRelease(people);		
	}
	mLoading = FALSE;
}

@end

@implementation NgnContactService

-(NgnContactService*)init{
	if((self = [super init])){
		mLoaderQueue = dispatch_queue_create(kNameSpace, NULL);
		mContacts = [[NgnContactMutableArray alloc] init];
	}
	return self;
}

//
// INgnBaseService
//

-(BOOL) start{
	NgnNSLog(TAG, @"Start()");
	mStarted = TRUE;
	
	[self load: FALSE];
	
	return YES;
}

-(BOOL) stop{
	NgnNSLog(TAG, @"Stop()");
	mStarted = FALSE;
	
	return YES;
}

-(void)dealloc{
	[self stop];
	if(mLoaderQueue){
		dispatch_release(mLoaderQueue), mLoaderQueue = NULL;
	}
	[mContacts release];
	[super dealloc];
}



//
// INgnContactService
//

-(void) load: (BOOL) asyn{
	if(asyn){
		dispatch_async(mLoaderQueue, ^{
			[self syncLoad];
		});
	}
	else {
		[self syncLoad];
	}

}				   

-(BOOL) isLoading{
	return mLoading;
}

-(NSMutableArray*) contacts{
	return mContacts;
}

-(NSArray*) contactsWithPredicate: (NSPredicate*)predicate{
	return [mContacts filteredArrayUsingPredicate: predicate];
}

@end

#endif /* TARGET_OS_IPHONE */