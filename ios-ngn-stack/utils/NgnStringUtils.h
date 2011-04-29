#import <Foundation/Foundation.h>

@interface NgnStringUtils : NSObject {

}

+(const NSString*)emptyValue;
+(const NSString*)nullValue;
+(BOOL)isNullOrEmpty:(NSString*)string;
+(BOOL)contains:(NSString*) string subString:(NSString*)subStr;
+(NSString*) toNSString: (const char*)cstring;
+(const char*) toCString: (NSString*)nsstring;

@end
