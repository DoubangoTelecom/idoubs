#if TARGET_OS_IPHONE

#import "NgnContact.h"

@implementation NgnContact

@synthesize id;
@synthesize displayName;
@synthesize firstName;
@synthesize lastName;
@synthesize phoneNumbers;

-(NgnContact*)initWithABRecordRef: (const ABRecordRef) record{
	if((self = [super init]) && record){
		self->phoneNumbers = [[NSMutableArray alloc] init];
		
		self->id = ABRecordGetRecordID(record);
		self->displayName = (NSString *)ABRecordCopyCompositeName(record);
		self->fisrtName = (NSString*)ABRecordCopyValue(record, kABPersonFirstNameProperty);
		self->lastName = (NSString*)ABRecordCopyValue(record, kABPersonLastNameProperty);
		
		CFStringRef phoneNumber, phoneNumberLabel;
		NgnPhoneNumber* ngnPhoneNumber;
		ABMutableMultiValueRef multi = ABRecordCopyValue(record, kABPersonPhoneProperty);
		for (CFIndex i = 0; i < ABMultiValueGetCount(multi); i++) {
			phoneNumberLabel = ABMultiValueCopyLabelAtIndex(multi, i);
			phoneNumber      = ABMultiValueCopyValueAtIndex(multi, i);
			
			ngnPhoneNumber = [[NgnPhoneNumber alloc] initWithNumber: (NSString*)phoneNumber andDescription: (NSString*)phoneNumberLabel];
			[self->phoneNumbers addObject: ngnPhoneNumber];
			
			[ngnPhoneNumber release];
			CFRelease(phoneNumberLabel);
			CFRelease(phoneNumber);
		}
		CFRelease(multi);
	}
	return self;
}

-(NgnPhoneNumber*) getPhoneNumberWithPredicate: (NSPredicate*)predicate{
	@synchronized(self.phoneNumbers){
		for (NgnPhoneNumber*phoneNumber in self.phoneNumbers) {
			if([predicate evaluateWithObject: phoneNumber]){
				return phoneNumber;
			}
		}
	}
	return nil;
}

-(void)dealloc{
	[self->displayName release];
	[self->fisrtName release];
	[self->lastName release];
	
	[self->phoneNumbers release];
	
	[super dealloc];
}

@end

#endif /* TARGET_OS_IPHONE */
