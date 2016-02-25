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
#import "UITabViewItem.h"

#import "UIAuthentication.h"
#import "UIContacts.h"
#import "UIHistory.h"

@interface UITabViewItem(Private)
+(NSString*) identifierForType:(UITabViewItemType_t)type;
+(NSString*) labelForType:(UITabViewItemType_t)type;
+(NSViewController*) viewControllerForType:(UITabViewItemType_t)type;
@end

@implementation UITabViewItem(Private)

+(NSString*) identifierForType:(UITabViewItemType_t)type
{
	switch (type) {
		case UITabViewItemType_Authentication:
			return @"tabitem_authentication";
		case UITabViewItemType_Contacts:
			return @"tabitem_contacts";
		case UITabViewItemType_History:
			return @"tabitem_history";
			
		default:
			return @"tabitem_unknown";
	}
}

+(NSString*) labelForType:(UITabViewItemType_t)type
{
	switch (type) {
		case UITabViewItemType_Authentication:
			return @"Authentication";
		case UITabViewItemType_Contacts:
			return @"Contacts";
		case UITabViewItemType_History:
			return @"History";
			
		default:
			return @"Unknown";
	}
}

+(NSViewController*) viewControllerForType:(UITabViewItemType_t)type
{
	switch (type) {
		case UITabViewItemType_Authentication:
			return [[[UIAuthentication alloc] initWithNibName:@"UIAuthentication" bundle:nil] autorelease];
		case UITabViewItemType_Contacts:
			return [[[UIContacts alloc] initWithNibName:@"UIContacts" bundle:nil] autorelease];
		case UITabViewItemType_History:
			return [[[UIHistory alloc] initWithNibName:@"UIHistory" bundle:nil] autorelease];
		default:
			return nil;
	}
}

@end


@implementation UITabViewItem

@synthesize type;
@synthesize viewController;

-(UITabViewItem*) initWithType:(UITabViewItemType_t)type_
{
	if((self = [super initWithIdentifier:[UITabViewItem identifierForType:type_]])){
		self->type = type_;
		self->viewController = [[UITabViewItem viewControllerForType:type_] retain];
		self.view = [self.viewController view];
		self.label = [UITabViewItem labelForType:type_];
	}
	return self;
}

-(void)dealloc
{
	[self.viewController release];
	[super dealloc];
}

@end
