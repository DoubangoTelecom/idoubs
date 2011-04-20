#import <Foundation/Foundation.h>

@interface NgnStringUtils : NSObject {

}

+(const NSString*)emptyValue;
+(const NSString*)nullValue;
+(BOOL)isNullOrEmpty:(NSString*)string;

@end
