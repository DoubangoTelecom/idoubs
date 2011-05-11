#import <Foundation/Foundation.h>


@interface NgnPhoneNumber : NSObject {
	NSString* number;
	NSString* description;
}

@property(readonly) NSString* number;
@property(readonly) NSString* description;

-(NgnPhoneNumber*) initWithNumber: (NSString*) _number andDescription: (NSString*) _desciption;
@end
