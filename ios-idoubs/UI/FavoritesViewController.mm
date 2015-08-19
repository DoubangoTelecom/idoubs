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
#import "FavoritesViewController.h"
#import "FavoriteCell.h"
#import "idoubs2AppDelegate.h"
#import "CallViewController.h"

#import <QuartzCore/QuartzCore.h>

//
//	Private
//

@interface FavoritesViewController(Private)
-(void) refreshData;
-(void) reloadData;
-(void) refreshDataAndReload;
-(void) refreshView;
-(void) onFavoritesEvent:(NSNotification*)notification;
@end

@implementation FavoritesViewController(Private)

-(void) refreshData{
	@synchronized(self->favorites){
		NSArray* favorites_ = [[[[NgnEngine sharedInstance].storageService favorites] allValues] sortedArrayUsingSelector:@selector(compareFavoriteByDisplayName:)];
		[self->favorites removeAllObjects];
		[self->favorites addObjectsFromArray: favorites_];
		
		[self refreshView];
	}
}

-(void) reloadData{
	[self.tableView reloadData];
}

-(void) refreshDataAndReload{
	[self refreshData];
	[self reloadData];
}

-(void) refreshView{
	if([self->favorites count] > 0){
		self.view = self.tableView;
		self.navigationItem.leftBarButtonItem = self.tableView.editing ? self->navigationItemDone : self->navigationItemEdit;
	}
	else {
		self.tableView.editing = NO;
		self.view = self.viewNoFavorites;
		self.navigationItem.leftBarButtonItem = nil;
	}
}

-(void) onFavoritesEvent:(NSNotification*)notification{
	NgnFavoriteEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case FAVORITE_ITEM_ADDED:
		{
			NgnFavorite* favorite = [[[NgnEngine sharedInstance].storageService favorites] objectForKey: [NSNumber numberWithLongLong: eargs.favoriteId]];
			if(favorite){
				[self->favorites addObject: favorite];
				[self reloadData];
			}
			break;
		}
			
		case HISTORY_EVENT_ITEM_MOVED:
		case HISTORY_EVENT_ITEM_UPDATED:
		{
			[self reloadData];
			break;
		}
			
		case HISTORY_EVENT_ITEM_REMOVED:
		{
			for (NgnFavorite* favorite in self->favorites) {
				if(favorite.id == eargs.favoriteId){
					[self->favorites removeObject: favorite];
					[self reloadData];
					break;
				}
			}
			break;
		}
			
		case HISTORY_EVENT_RESET:
		default:
		{
			[self refreshDataAndReload];
			break;
		}
	}
	
	[self refreshView];
}

@end

@implementation FavoritesViewController

@synthesize tableView;
@synthesize pickedNumber;
@synthesize viewNoFavorites;
@synthesize buttonAddFavorite;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if(!self->favorites){
		self->favorites = [[NSMutableArray alloc] init];
	}
	
	[[NSNotificationCenter defaultCenter]
			addObserver:self selector:@selector(onFavoritesEvent:) name:kNgnFavoriteEventArgs_Name object:nil];
	
	self->navigationItemEdit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																					target:self
																					action:@selector(onButtonNavivationItemClick:)];
	self->navigationItemDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(onButtonNavivationItemClick:)];
	self->navigationItemAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																				   target:self
																				   action:@selector(onButtonNavivationItemClick:)];
	self.navigationItem.leftBarButtonItem = self->navigationItemEdit;
	self.navigationItem.rightBarButtonItem = self->navigationItemAdd;
	
	self.buttonAddFavorite.layer.borderWidth = 2.f;
	self.buttonAddFavorite.layer.borderColor = [[UIColor grayColor] CGColor];
	self.buttonAddFavorite.layer.cornerRadius = 10.f;
	
	[self refreshData];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	
    [self->favorites removeAllObjects];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
	[self->favorites removeAllObjects];
	[self reloadData];
}

- (IBAction) onButtonAddFavoriteClick: (id)sender{
	PeoplePicker *picker = [[PeoplePicker alloc] init];
	[picker pickNumber:self];
	[picker release];
}

- (IBAction) onButtonNavivationItemClick: (id)sender{
	if(sender == self->navigationItemAdd){
		[self onButtonAddFavoriteClick: sender];
	}
	else if(sender == self->navigationItemEdit || sender == self->navigationItemDone) {
		if((self.tableView.editing = !self.tableView.editing)){
			self.navigationItem.leftBarButtonItem = self->navigationItemDone;
		}
		else {
			self.navigationItem.leftBarButtonItem = self->navigationItemEdit;
		}
	}
}

- (void)dealloc {
	[self.tableView release];
	[self.viewNoFavorites release];
	[self.buttonAddFavorite release];
	[self->navigationItemEdit release];
	[self->navigationItemDone release];
	[self->navigationItemAdd release];
	[self.pickedNumber release];
	[self->favorites release];
	
    [super dealloc];
}


//
//	PeoplePickerDelegate
//

-(BOOL) peoplePicker: (PeoplePicker *)picker shouldContinueAfterPickingNumber: (NgnPhoneNumber*)number{
	self.pickedNumber = number;
	[picker dismiss];
	
	if(self.pickedNumber){
		UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:[@"Add " stringByAppendingFormat:@"%@ to Favorites as:",self.pickedNumber.number]
														   delegate:self 
												  cancelButtonTitle:nil
											 destructiveButtonTitle:nil
												  otherButtonTitles:nil];
		sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		for(int i=0; i< sizeof(kFavoriteMediaEntries)/sizeof(FavoriteMediaEntry_t); i++){
			[sheet addButtonWithTitle:kFavoriteMediaEntries[i].description];
		}
		int cancelIdex = [sheet addButtonWithTitle: @"Cancel"];
		sheet.cancelButtonIndex = cancelIdex;
		
		[sheet showInView:self.parentViewController.tabBarController.view];
		[sheet release];
		
	}
	
	return NO;
}

-(BOOL) peoplePicker: (PeoplePicker *)picker shouldContinueAfterPickingContact: (NgnContact*)contact{
	return YES;
}

//
//	UIActionSheetDelegate
//

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex != actionSheet.cancelButtonIndex && self.pickedNumber){
		NgnFavorite* favorite = [[NgnFavorite alloc] initWithNumber:self.pickedNumber.number andMediaType:kFavoriteMediaEntries[buttonIndex].mediaType];
		[[NgnEngine sharedInstance].storageService addFavorite:favorite];
		[favorite release];
	}
}

//
//	UITableViewDelegate
//

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self->favorites count];
}


- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	FavoriteCell *cell = (FavoriteCell*)[_tableView dequeueReusableCellWithIdentifier: kFavoriteCellIdentifier];
	if (cell == nil) {
		cell = [[[NSBundle mainBundle] loadNibNamed:@"FavoriteCell" owner:self options:nil] lastObject];
		cell.navigationController = self.navigationController;
	}
	
	cell.favorite = [self->favorites objectAtIndex: indexPath.row];
	
	return cell;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	if (editingStyle == UITableViewCellEditingStyleDelete){
		NgnFavorite *favorite = [self->favorites objectAtIndex: indexPath.row];
        if (favorite) {
			[[NgnEngine sharedInstance].storageService deleteFavorite:favorite];
		}
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NgnFavorite* favorite = [self->favorites objectAtIndex: indexPath.row];
	if(favorite){
		switch (favorite.mediaType) {
			case MediaType_AudioVideo:
			case MediaType_Video:
			{
				[CallViewController makeAudioVideoCallWithRemoteParty: favorite.number
													 andSipStack:[[NgnEngine sharedInstance].sipService getSipStack]];
				break;
			}
				
			case MediaType_Audio:
			{
				[CallViewController makeAudioCallWithRemoteParty: favorite.number
														  andSipStack:[[NgnEngine sharedInstance].sipService getSipStack]];
				break;
			}
				
			case MediaType_SMS:
			{
				[idoubs2AppDelegate sharedInstance].chatViewController.remoteParty = favorite.number;
				[[idoubs2AppDelegate sharedInstance] selectTabMessages];
				[[idoubs2AppDelegate sharedInstance].messagesViewController.navigationController 
										pushViewController:[idoubs2AppDelegate sharedInstance].chatViewController  animated:YES];
				break;
			}
				
			default:
				break;
		}
	}
}

@end
