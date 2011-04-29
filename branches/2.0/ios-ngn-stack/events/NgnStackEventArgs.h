#import <Foundation/Foundation.h>
#import "NgnEventArgs.h"

#define kNgnStackEventArgs_Name @"NgnStackEventArgs_Name"

typedef enum NgnStackEventTypes_e {
	STACK_EVENT_NONE,
	
	STACK_START_OK,
    STACK_START_NOK,
    STACK_STOP_OK,
    STACK_STOP_NOK
}
NgnStackEventTypes_t;

@interface NgnStackEventArgs : NgnEventArgs {
	NgnStackEventTypes_t eventType;
	NSString* phrase;
}

@property(readonly) NgnStackEventTypes_t eventType;
@property(readonly,retain) NSString* phrase;


-(NgnStackEventArgs*)initWithEventType: (NgnStackEventTypes_t)_eventType andPhrase: (NSString*)_phrase;

@end
