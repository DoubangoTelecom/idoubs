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

@end
