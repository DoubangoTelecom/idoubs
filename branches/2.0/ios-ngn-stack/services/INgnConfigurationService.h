#import <Foundation/Foundation.h>

#import "INgnBaseService.h"

@protocol INgnConfigurationService <INgnBaseService>
-(NSString*)getStringForKey: (NSString*)key withDefaultValue: (NSString*)defaultValue;
-(int)getIntForKey: (NSString*)key withDefaultValue: (int)defaultValue;
-(float)getFloatForKey: (NSString*)key withDefaultValue: (float)defaultValue;
-(BOOL)getBoolForKey: (NSString*)key withDefaultValue: (BOOL)defaultValue;
@end
