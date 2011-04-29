#import "NgnStringUtils.h"

@implementation NgnStringUtils

+(const NSString*)emptyValue{
	return @"";
}

+(const NSString*)nullValue{
	return @"(null)";
}

+(BOOL)isNullOrEmpty:(NSString*)string{
	return string == nil || string == [NgnStringUtils emptyValue];
}

+(BOOL)contains:(NSString*) string subString:(NSString*)subStr{
	return [string rangeOfString:subStr].location != NSNotFound;
}

+(NSString*) toNSString: (const char*)cstring{
	return [NSString stringWithCString:cstring encoding: NSUTF8StringEncoding];
}

+(const char*) toCString: (NSString*)nsstring{
	return [nsstring UTF8String];
}

@end
