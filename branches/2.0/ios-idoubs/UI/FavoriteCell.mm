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
#import "FavoriteCell.h"
#import "ContactDetailsController.h";

@interface FavoriteCell(Private)
+(UIImage*) imageForMediaType: (NgnMediaType_t)mediaType;
@end


@implementation FavoriteCell(Private)

+(UIImage*) imageForMediaType: (NgnMediaType_t)mediaType{
	static UIImage* imageSMS = nil;
	static UIImage* imageAudio = nil;
	static UIImage* imageVideo = nil;
	
	switch (mediaType) {
		case MediaType_SMS:
			if(imageSMS == nil){
				imageSMS = [[UIImage imageNamed:@"type_sms"] retain];
			}
			return imageSMS;
			
		case MediaType_Audio:
			if(imageAudio == nil){
				imageAudio = [[UIImage imageNamed:@"type_audio"] retain];
			}
			return imageAudio;
			
		case MediaType_AudioVideo:
		case MediaType_Video:
			if(imageVideo == nil){
				imageVideo = [[UIImage imageNamed:@"type_video"] retain];
			}
			return imageVideo;
			
		default:
			return nil;
	}
}
@end



@implementation FavoriteCell

@synthesize labelDisplayName;
@synthesize labelPhoneType;
@synthesize imageViewPhoneType;
@synthesize buttonDetails;
@synthesize navigationController;

-(NSString *)reuseIdentifier{
	return kFavoriteCellIdentifier;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setFavorite:(NgnFavorite* )favorite_{
	[self->favorite release];
	self.labelPhoneType.text = @"";
	self.labelDisplayName.text = @"";
	
	if((self->favorite = [favorite_ retain])){
		if(self.favorite.contact){
			for (NgnPhoneNumber* phoneNumber in self.favorite.contact.phoneNumbers) {
				if([phoneNumber.number isEqualToString: self.favorite.number]){
					self.labelPhoneType.text = phoneNumber.description;
					break;
				}
			}
		}
		self.labelDisplayName.text = self.favorite.displayName;
		self.buttonDetails.hidden = (self.favorite.contact == nil);
		self.imageViewPhoneType.image =[FavoriteCell imageForMediaType:self.favorite.mediaType];
	}
}

-(NgnFavorite *)favorite{
	return self->favorite;
}

- (IBAction) onButtonDetailsClick: (id)sender{
	if(self.favorite.contact && self.navigationController){
		ContactDetailsController *details = [[ContactDetailsController alloc] initWithNibName:@"ContactDetails" bundle:nil];
		details.contact = self.favorite.contact;
		[self.navigationController pushViewController:details animated:YES];
		[details release];
	}
}

- (void)dealloc {
	[favorite release];
	[labelDisplayName release];
	[labelPhoneType release];
	[imageViewPhoneType release];
	[navigationController release];
	[buttonDetails release];
	
    [super dealloc];
}


@end
