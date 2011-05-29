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
#import "ContactDetailsController.h"
#import "PhoneEntryCell.h"
#import <QuartzCore/QuartzCore.h>
#import "CallViewController.h"

#import "idoubs2AppDelegate.h"

#define kTagActionSheetTextMessage				1
#define kTagActionSheetVideoCall				2
#define kTagActionSheetAddToFavorites			3
#define kTagActionSheetChooseFavoriteMediaType	4

@implementation ContactDetailsController

@synthesize reuseIdentifier;
@synthesize labelDisplayName;
@synthesize imageViewAvatar;
@synthesize tableViewPhones;
@synthesize tableViewEmails;

@synthesize buttonVideoCall;
@synthesize buttonTextMessage;
@synthesize buttonAddToFavorites;

@synthesize contact;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableViewPhones.layer.cornerRadius = 10;
	self.tableViewPhones.layer.cornerRadius = 10;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear: animated];
	self.navigationItem.title = @"Info";
	
	if(self.contact){
		self.labelDisplayName.text = self.contact.displayName;
		[self.tableViewEmails reloadData];
		[self.tableViewPhones reloadData];
		
		CGRect rect = self.tableViewPhones.frame;
		rect.size.height = self.tableViewPhones.contentSize.height;
		self.tableViewPhones.frame = rect;
		
		rect = self.tableViewEmails.frame;
		rect.size.height = self.tableViewEmails.contentSize.height;
		rect.origin.y = self.tableViewPhones.frame.origin.y + self.tableViewPhones.frame.size.height + 12.f;
		self.tableViewEmails.frame = rect;
	}
}

- (IBAction) onButtonClicked: (id)sender{
	UIActionSheet *sheet = nil;
	
	if(sender == self.buttonTextMessage){
		if(self.contact){
			int count = [self.contact.phoneNumbers count];
			if(count > 1){
				sheet = [[UIActionSheet alloc] initWithTitle:@"Send a text message" 
														   delegate:self 
												  cancelButtonTitle:nil
											 destructiveButtonTitle:nil
												  otherButtonTitles:nil];
				sheet.tag = kTagActionSheetTextMessage;
			}
			else if(count == 1){
				idoubs2AppDelegate* appDelegate = ((idoubs2AppDelegate*) [[UIApplication sharedApplication] delegate]);
				appDelegate.chatViewController.remoteParty = ((NgnPhoneNumber*)[self.contact.phoneNumbers objectAtIndex:0]).number;
				[self.navigationController pushViewController:appDelegate.chatViewController  animated:YES];
			}
		}
	}
	else if(sender == self.buttonVideoCall){
		if(self.contact){
			int count = [self.contact.phoneNumbers count];
			if(count > 1){
				sheet = [[UIActionSheet alloc] initWithTitle:@"Make Video call" 
													delegate:self 
										   cancelButtonTitle:nil
									  destructiveButtonTitle:nil
										   otherButtonTitles:nil];
				sheet.tag = kTagActionSheetVideoCall;
			}
			else if(count == 1){
				[CallViewController makeAudioVideoCallWithRemoteParty: ((NgnPhoneNumber*)[self.contact.phoneNumbers objectAtIndex:0]).number 
														  andSipStack:[[NgnEngine getInstance].sipService getSipStack]];
			}
		}
	}
	else if(sender == self.buttonAddToFavorites){
		if(self.contact){
			int count = [self.contact.phoneNumbers count];
			if(count > 1){
				sheet = [[UIActionSheet alloc] initWithTitle:@"Add to Favorites." 
													delegate:self 
										   cancelButtonTitle:nil
									  destructiveButtonTitle:nil
										   otherButtonTitles:nil];
				sheet.tag = kTagActionSheetAddToFavorites;
			}
			else if(count == 1){
				sheet = [[UIActionSheet alloc] initWithTitle:[@"Add " stringByAppendingFormat:@"%@ to Favorites as:",((NgnPhoneNumber*)[self.contact.phoneNumbers objectAtIndex:0]).number]
													delegate:self 
										   cancelButtonTitle:nil
									  destructiveButtonTitle:nil
										   otherButtonTitles:nil];
				addToFavoritesLastIndex = 0;
				sheet.tag = kTagActionSheetChooseFavoriteMediaType;
			}
		}
	}
	
	if(sheet){
		sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		
		switch (sheet.tag) {
			case kTagActionSheetTextMessage:
			case kTagActionSheetVideoCall:
			case kTagActionSheetAddToFavorites:
			{
				for(NgnPhoneNumber* phoneNumber in self.contact.phoneNumbers){
					[sheet addButtonWithTitle: [phoneNumber.description stringByAppendingFormat:@" %@",  phoneNumber.number]];
				}
				break;
			}
			case kTagActionSheetChooseFavoriteMediaType:
			{
				for(int i=0; i< sizeof(kFavoriteMediaEntries)/sizeof(FavoriteMediaEntry_t); i++){
					[sheet addButtonWithTitle:kFavoriteMediaEntries[i].description];
				}
				break;
			}
		}
		
		int cancelIdex = [sheet addButtonWithTitle: @"Cancel"];
		sheet.cancelButtonIndex = cancelIdex;
		
		[sheet showInView:self.parentViewController.tabBarController.view];
		[sheet release];
	}
}


//
//	UIActionSheetDelegate
//

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex != actionSheet.cancelButtonIndex){
		switch (actionSheet.tag) {
			case kTagActionSheetVideoCall:
			{
				[CallViewController makeAudioVideoCallWithRemoteParty: ((NgnPhoneNumber*)[self.contact.phoneNumbers objectAtIndex:buttonIndex]).number 
									andSipStack:[[NgnEngine getInstance].sipService getSipStack]];
				break;
			}
			case kTagActionSheetTextMessage:
			{
				idoubs2AppDelegate* appDelegate = ((idoubs2AppDelegate*) [[UIApplication sharedApplication] delegate]);
				appDelegate.chatViewController.remoteParty = ((NgnPhoneNumber*)[self.contact.phoneNumbers objectAtIndex:buttonIndex]).number;
				[self.navigationController pushViewController:appDelegate.chatViewController  animated:YES];
				break;
			}
				
			case kTagActionSheetAddToFavorites:
			{
				addToFavoritesLastIndex =  buttonIndex;
				UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:[@"Add " stringByAppendingFormat:@"%@ to Favorites as:",((NgnPhoneNumber*)[self.contact.phoneNumbers objectAtIndex:buttonIndex]).number]
													delegate:self 
										   cancelButtonTitle:nil
									  destructiveButtonTitle:nil
										   otherButtonTitles:nil];
				sheet.tag = kTagActionSheetChooseFavoriteMediaType;
				sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
				for(int i=0; i< sizeof(kFavoriteMediaEntries)/sizeof(FavoriteMediaEntry_t); i++){
					[sheet addButtonWithTitle:kFavoriteMediaEntries[i].description];
				}
				int cancelIdex = [sheet addButtonWithTitle: @"Cancel"];
				sheet.cancelButtonIndex = cancelIdex;
				
				[sheet showInView:self.parentViewController.tabBarController.view];
				[sheet release];
				break;
			}
				
			case kTagActionSheetChooseFavoriteMediaType:
			{
				if(self.contact && [self.contact.phoneNumbers count] > addToFavoritesLastIndex){
					NgnMediaType_t mediaType = kFavoriteMediaEntries[buttonIndex].mediaType;
					NgnPhoneNumber* phoneNumber = ((NgnPhoneNumber*)[self.contact.phoneNumbers objectAtIndex:addToFavoritesLastIndex]);
					
					NgnFavorite* favorite = [[NgnFavorite alloc] initWithNumber:phoneNumber.number andMediaType:mediaType];
					[[NgnEngine getInstance].storageService addFavorite: favorite];
					[favorite release];
				}
				
				break;
			}
				
			default:
				break;
		}
	}
}

//
//	UITableViewDelegate
//

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(tableView == self.tableViewPhones){
		return self.contact ? [self.contact.phoneNumbers count] : 0;
	}
	else if(tableView == self.tableViewPhones){
		return 0;
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(tableView == self.tableViewPhones){
		PhoneEntryCell* cell = (PhoneEntryCell*)[tableView dequeueReusableCellWithIdentifier: kPhoneEntryCellIdentifier];
		if (cell == nil) {		
			cell = [[[NSBundle mainBundle] loadNibNamed:@"PhoneEntryCell" owner:self options:nil] lastObject];
		}
		cell.number = [self.contact.phoneNumbers objectAtIndex: indexPath.row];
		return cell;
	}
	else if(tableView == self.tableViewEmails){
		return nil;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(tableView == self.tableViewPhones){
		[CallViewController makeAudioCallWithRemoteParty: ((NgnPhoneNumber*)[self.contact.phoneNumbers objectAtIndex:indexPath.row]).number 
												  andSipStack:[[NgnEngine getInstance].sipService getSipStack]];
	}
	else if(tableView == self.tableViewEmails){
		
	}
}

- (void)dealloc {
	[contact release];
	
	[labelDisplayName release];
	[imageViewAvatar release];
	[tableViewPhones release];
	[tableViewEmails release];
	
	[buttonVideoCall release];
	[buttonTextMessage release];
	[buttonAddToFavorites release];
	
    [super dealloc];
}

@end
