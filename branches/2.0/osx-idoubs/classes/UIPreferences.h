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
#import <Cocoa/Cocoa.h>

@interface UIPreferences : NSWindowController<NSCollectionViewDelegate> {
	
	NSButton *buttonSave;
	NSButton *buttonCancel;
	
	// Identity
	NSTextField *textFieldDisplayName;
	NSTextField *textFieldPublicId;
	NSTextField *textFieldPrivateId;
	NSSecureTextField *textFieldPassword;
	NSTextField *textFieldRealm;
	NSButton *checkBoxEarlyIMS;
	NSTextField *textFieldOpId;
	NSTextField *textFieldAMF;
	
	// Network
	NSButtonCell *buttonCellIPv4;
	NSButtonCell *buttonCellIPv6;
	NSTextField *textFieldProxyHost;
	NSTextField *textFieldProxyPort;
	NSComboBox *comboBoxTransport;
	NSButton *checkBoxDiscoDHCP;
	NSButton *checkBoxDiscoDNS;
	NSButton *checkBoxSigComp;
	
	// NAT Traversal
	NSButton *checkBoxSTUNEnable;
	NSButtonCell *buttonCellSTUNDiscover;
	NSButtonCell *buttonCellSTUNUseThisServer;
	NSTextField *textFieldSTUNServerHost;
	NSTextField *textFieldSTUNServerPort;
	
	// Codecs
	NSCollectionView *collectionViewAudioCodecs;
	NSArrayController *arrayControllerAudioCodecs;
	NSMutableArray* audioCodecs;
	NSCollectionView *collectionViewVideoCodecs;
	NSArrayController *arrayControllerVideoCodecs;
	NSMutableArray* videoCodecs;
}

@property (assign) IBOutlet NSButton *buttonSave;
@property (assign) IBOutlet NSButton *buttonCancel;

// Identity
@property (assign) IBOutlet NSTextField *textFieldDisplayName;
@property (assign) IBOutlet NSTextField *textFieldPublicId;
@property (assign) IBOutlet NSTextField *textFieldPrivateId;
@property (assign) IBOutlet NSSecureTextField *textFieldPassword;
@property (assign) IBOutlet NSTextField *textFieldRealm;
@property (assign) IBOutlet NSButton *checkBoxEarlyIMS;
@property (assign) IBOutlet NSTextField *textFieldOpId;
@property (assign) IBOutlet NSTextField *textFieldAMF;

// Network
@property (assign) IBOutlet NSTextField *textFieldProxyHost;
@property (assign) IBOutlet NSTextField *textFieldProxyPort;
@property (assign) IBOutlet NSButtonCell *buttonCellIPv4;
@property (assign) IBOutlet NSButtonCell *buttonCellIPv6;
@property (assign) IBOutlet NSComboBox *comboBoxTransport;
@property (assign) IBOutlet NSButton *checkBoxDiscoDHCP;
@property (assign) IBOutlet NSButton *checkBoxDiscoDNS;
@property (assign) IBOutlet NSButton *checkBoxSigComp;

// NAT Traversal
@property (assign) IBOutlet NSButton *checkBoxSTUNEnable;
@property (assign) IBOutlet NSButtonCell *buttonCellSTUNDiscover;
@property (assign) IBOutlet NSButtonCell *buttonCellSTUNUseThisServer;
@property (assign) IBOutlet NSTextField *textFieldSTUNServerHost;
@property (assign) IBOutlet NSTextField *textFieldSTUNServerPort;

// Codecs
@property (assign) IBOutlet NSCollectionView *collectionViewAudioCodecs;
@property (assign) IBOutlet NSArrayController *arrayControllerAudioCodecs;
@property (readonly) NSMutableArray* audioCodecs;
@property (readonly) NSMutableArray* videoCodecs;
@property (assign) IBOutlet NSCollectionView *collectionViewVideoCodecs;
@property (assign) IBOutlet NSArrayController *arrayControllerVideoCodecs;


- (IBAction)onButtonClick:(id)sender;

@end
