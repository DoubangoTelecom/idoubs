#import "NgnConfigurationService.h"

@implementation NgnConfigurationService(Private)
- (void)userDefaultsDidChangeNotification:(NSNotification *)note{
	
}
@end


@implementation NgnConfigurationService

-(NgnConfigurationService*)init{
	if((self = [super init])){
		
	}
	return self;
}

//
// INgnBaseService
//

-(BOOL) start{
	[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(userDefaultsDidChangeNotification:) name: NSUserDefaultsDidChangeNotification object: nil];
	return YES;
}

-(BOOL) stop{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	return YES;
}


//
//	INgnConfigurationService
//

-(NSString*)getStringForKey: (NSString*)key withDefaultValue: (NSString*)defaultValue{
	return nil;
}

-(int)getIntForKey: (NSString*)key withDefaultValue: (int)defaultValue{
	return 0;
}


-(float)getFloatForKey: (NSString*)key withDefaultValue: (float)defaultValue{
	return .0f;
}


-(BOOL)getBoolForKey: (NSString*)key withDefaultValue: (BOOL)defaultValue{
	return FALSE;
}

@end
