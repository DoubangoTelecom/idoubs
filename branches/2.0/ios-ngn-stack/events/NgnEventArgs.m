#import "NgnEventArgs.h"

@implementation NgnEventArgs

-(void)putExtraWithKey: (NSString*)key andValue:(NSString*)value{
	if(!mExtras){
		mExtras = [[NSMutableDictionary alloc] init];
	}
	[mExtras setObject:value forKey:key];
}

-(NSString*)getExtraWithKey: (NSString*)key{
	return [mExtras objectForKey:key];
}

-(void)dealloc{
	[mExtras release];
	[super dealloc];
}

@end
