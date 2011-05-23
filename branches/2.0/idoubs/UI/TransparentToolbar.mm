#import "TransparentToolbar.h"


@implementation TransparentToolbar

//- (void)drawRect:(CGRect)rect {
//    UIImage *image = [[UIImage imageNamed:@"sample.png"] retain];
//    [image drawInRect:rect];
//    [image release];    
//}

// Override draw rect to avoid
// background coloring
//- (void)drawRect:(CGRect)rect {
    // do nothing in here
//}

// Set properties to make background
// translucent.
- (void) applyTranslucentBackground{
	self.backgroundColor = [UIColor clearColor];
	self.opaque = NO;
	self.translucent = YES;
}

- (id)initWithCoder:(NSCoder *)decoder { 
	self = [super initWithCoder:decoder]; 
	if (self) { 
		[self applyTranslucentBackground]; 
	} 
	return self; 
}

// Override init.
- (id) init{
	self = [super init];
	[self applyTranslucentBackground];
	return self;
}

// Override initWithFrame.
- (id) initWithFrame:(CGRect) frame{
	self = [super initWithFrame:frame];
	[self applyTranslucentBackground];
	return self;
}

@end
