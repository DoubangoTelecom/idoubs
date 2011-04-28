#import <Foundation/Foundation.h>

#import "INgnBaseService.h"

@protocol INgnConfigurationService <INgnBaseService>
-(NSString*)getStringForKey: (NSString*)key;
-(int)getIntForKey: (NSString*)key;
-(float)getFloatForKey: (NSString*)key;
-(BOOL)getBoolForKey: (NSString*)key;
@end
