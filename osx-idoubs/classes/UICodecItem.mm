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
 */
#import "UICodecItem.h"

#import "OSXNgnStack.h"
#import "tinydav.h"

@implementation UICodecItem


@synthesize checkBoxName;
@synthesize textFiledDescription;

- (void) awakeFromNib 
{
	[super awakeFromNib];
}

-(id)copyWithZone:(NSZone *)zone
{
	id result = [super copyWithZone:zone];
	
	[NSBundle loadNibNamed:@"UICodecItem" owner:result];
	
	return result;
}

- (void)setRepresentedObject:(id)object 
{
	[super setRepresentedObject:object];
	
	if (object == nil){
		return;
	}
	
	NSDictionary* codec = (NSDictionary*) [self representedObject];
	//tdav_codec_id_t _id = (tdav_codec_id_t) [((NSNumber*)[codec objectForKey:@"id"]) intValue];
	NSString* bundleKey = [codec objectForKey:@"bundle_key"];
	
	[self.checkBoxName setTitle:[codec objectForKey:@"name"]];
	[self.checkBoxName setState:[[NgnEngine sharedInstance].configurationService getBoolWithKey:bundleKey] ? NSOnState : NSOffState];
	[self.textFiledDescription setStringValue:[codec objectForKey:@"description"]];
	
}

- (IBAction)onCheckBoxClick:(id)sender
{
	[[NgnEngine sharedInstance].configurationService setBoolWithKey:[((NSDictionary*) [self representedObject]) objectForKey:@"bundle_key"] 
														   andValue:[self.checkBoxName state] == NSOnState];
	
}

- (void)dealloc
{
	[super dealloc];
}

@end
