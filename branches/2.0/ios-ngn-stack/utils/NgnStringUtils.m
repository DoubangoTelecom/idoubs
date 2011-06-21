/* Copyright (C) 2010-2011, Mamadou Diop.
 * Copyright (c) 2011, Doubango Telecom. All rights reserved.
 *
 * Contact: Mamadou Diop <diopmamadou(at)doubango(dot)org>
 *       
 * This file is part of iDoubs Project ( http://code.google.com/p/idoubs )
 *
 * idoubs is free software: you can redistribute it and/or modify it under the terms of 
 * the GNU General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 *       
 * idoubs is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 * See the GNU General Public License for more details.
 *       
 * You should have received a copy of the GNU General Public License along 
 * with this program; if not, write to the Free Software Foundation, Inc., 
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 */
#import "NgnStringUtils.h"

#undef kStringEmpty
#define kStringEmpty	@""

@implementation NgnStringUtils

+(const NSString*)emptyValue{
	return kStringEmpty;
}

+(const NSString*)nullValue{
	return @"(null)";
}

+(BOOL)isNullOrEmpty:(NSString*)string{
	return string == nil || string==(id)[NSNull null] || [string isEqualToString: kStringEmpty];
}

+(BOOL)contains:(NSString*) string subString:(NSString*)subStr{
	return [string rangeOfString:subStr].location != NSNotFound;
}

+(NSString*) toNSString: (const char*)cstring{
	return cstring ? [NSString stringWithCString:cstring encoding: NSUTF8StringEncoding] : nil;
}

+(const char*) toCString: (NSString*)nsstring{
	return [nsstring UTF8String];
}

#if TARGET_OS_IPHONE
+(UIColor*) colorFromRGBValue: (int)rgbvalue{
	return [UIColor colorWithRed: ((float)((rgbvalue & 0xFF0000) >> 16))/255.0
					green: ((float)((rgbvalue & 0xFF00) >> 8))/255.0
					blue: ((float)(rgbvalue & 0xFF))/255.0 alpha:1.0];
}
#endif
@end
