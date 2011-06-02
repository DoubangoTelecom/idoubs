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
#import "BaloonCell.h"
#import <QuartzCore/QuartzCore.h> /* cornerRadius... */

#import "idoubs2Constants.h"

#undef kCornerRadius
#undef kBorderWidth
#define kCornerRadius 8
#define kBorderWidth 0.8f

@interface BaloonCell(Colors)
+(CGColorRef)colorOutgoingBorder;
+(NSArray*)colorsOutgoing;
+(CGColorRef)colorIncomingBorder;
+(NSArray*)colorsIncoming;
@end

@implementation BaloonCell(Colors)

+(NSArray*) colorsOutgoing{
	static NSArray* sColorsOutgoing = nil;
	if(sColorsOutgoing == nil){
		sColorsOutgoing = [[NSArray arrayWithObjects:
						   (id)[[NgnStringUtils colorFromRGBValue: kColorBaloonOutTop] CGColor], 
						   (id)[[NgnStringUtils colorFromRGBValue: kColorBaloonOutMiddle] CGColor], 
						   (id)[[NgnStringUtils colorFromRGBValue: kColorBaloonOutBottom] CGColor],
						   nil] retain];
	}
	return sColorsOutgoing;
}

+(CGColorRef)colorOutgoingBorder{
	static CGColorRef sColorOutgoingBorder = nil;
	if(sColorOutgoingBorder == nil){
		sColorOutgoingBorder = CGColorRetain([[NgnStringUtils colorFromRGBValue: kColorBaloonOutBorder] CGColor]);
	}
	return sColorOutgoingBorder;
}

+(NSArray*)colorsIncoming{
	static NSArray* sColorsIncoming = nil;
	if(sColorsIncoming == nil){
		sColorsIncoming = [[NSArray arrayWithObjects:
							(id)[[NgnStringUtils colorFromRGBValue: kColorBaloonInTop] CGColor], 
							(id)[[NgnStringUtils colorFromRGBValue: kColorBaloonInMiddle] CGColor], 
							(id)[[NgnStringUtils colorFromRGBValue: kColorBaloonInBottom] CGColor],
							nil] retain];
	}
	return sColorsIncoming;
}

+(CGColorRef)colorIncomingBorder{
	static CGColorRef sColorIncomingBorder = nil;
	if(sColorIncomingBorder == nil){
		sColorIncomingBorder = CGColorRetain([[NgnStringUtils colorFromRGBValue: kColorBaloonInBorder] CGColor]);
	}
	return sColorIncomingBorder;
}

@end

@implementation BaloonCell

@synthesize labelContent;
@synthesize labelDate;

-(NSString *)reuseIdentifier{
	return kBaloonCellIdentifier;
}

- (id)initWithCoder:(NSCoder *)decoder{
	self = [super initWithCoder:decoder];
    if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.clipsToBounds = YES;
		self.labelContent.lineBreakMode = UILineBreakModeWordWrap;
		self.labelContent.numberOfLines = 0;
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.clipsToBounds = YES;
		self.labelContent.lineBreakMode = UILineBreakModeWordWrap;
		self.labelContent.numberOfLines = 0;
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

- (void)layoutSubviews{
    [super layoutSubviews];
    float indentPoints = self.indentationLevel * self.indentationWidth;
    self.contentView.frame = CGRectMake(indentPoints,
										self.contentView.frame.origin.y,
										self.contentView.frame.size.width - indentPoints, 
										self.contentView.frame.size.height);
}

#define kCellTopHeight		20.f
#define kCellBottomHeight	20.f
#define kCellDateHeight		20.f
#define kCellContentFontSize 17.f

+(CGFloat)getHeight:(NgnHistorySMSEvent*)event constrainedWidth:(CGFloat)width{
	if(event){
		NSString* content = event.contentAsString ? event.contentAsString : @"";
		CGSize constraintSize;
		constraintSize.width = width;
		constraintSize.height = MAXFLOAT;
		CGSize contentSize = [content sizeWithFont:[UIFont fontWithName:@"Arial" size:kCellContentFontSize] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
		return kCellTopHeight + kCellBottomHeight + kCellDateHeight + contentSize.height;
	}
	return 0.0;
}

#define kBaloonMargin 20.f
#define kContentMarginLeft 10.f
#define kContentMarginRight 10.f
#define kCellEditMargin		 20.f

-(void)setEvent:(NgnHistorySMSEvent*)event forTableView:(UITableView*)tableView{
	if(event){
		self.labelContent.text = event.contentAsString ? event.contentAsString : @"";
		
		CGSize constraintSize;
		constraintSize.width = tableView.frame.size.width - kBaloonMargin /* right */ - (kBaloonMargin * 4) /* left */;
		constraintSize.height = MAXFLOAT;
		CGSize contentSize = [self.labelContent.text sizeWithFont:self.labelContent.font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
		contentSize.width += kContentMarginLeft + kContentMarginRight;
		
		self.labelDate.text = [[NgnDateTimeUtils chatDate] stringFromDate:
						  [NSDate dateWithTimeIntervalSince1970: event.start]];
		
		CAGradientLayer *gradient = [CAGradientLayer layer];
		gradient.cornerRadius = kCornerRadius;
		gradient.borderWidth = kBorderWidth;

		switch (event.status) {
			case HistoryEventStatus_Outgoing:
			case HistoryEventStatus_Failed:
			case HistoryEventStatus_Missed:
			{
				gradient.colors = [BaloonCell colorsOutgoing];
				gradient.borderColor = [BaloonCell colorOutgoingBorder];
				self.labelContent.frame = CGRectMake(tableView.frame.size.width - kBaloonMargin - contentSize.width - (tableView.editing ? + kCellEditMargin : 0.f), 
													 self.labelContent.frame.origin.y, 
													 contentSize.width, 
													 contentSize.height);
				break;
			}
			
			case HistoryEventStatus_Incoming:
			default:
			{
				gradient.colors = [BaloonCell colorsIncoming];
				gradient.borderColor = [BaloonCell colorIncomingBorder];
				self.labelContent.frame = CGRectMake(kBaloonMargin + (tableView.editing ? + kCellEditMargin : 0.f), 
													 self.labelContent.frame.origin.y, 
													 contentSize.width, 
													 contentSize.height);
				break;
			}
		}// end switch()
		
		gradient.frame = self.labelContent.frame;
		for(CALayer *ly in self.layer.sublayers){
			if([ly isKindOfClass: [CAGradientLayer class]]){
				[ly removeFromSuperlayer];
				break;
			}
		}
		[self.layer insertSublayer:gradient atIndex:0];
	}
}

- (void)dealloc {
    [super dealloc];
}


@end
