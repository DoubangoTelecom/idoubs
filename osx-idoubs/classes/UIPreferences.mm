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
#import "UIPreferences.h"
#import "idoubs2AppDelegate.h"

#import "OSXNgnStack.h"

#import "tinydav.h"

#define kIndexUDP 0
#define kIndexTCP 1
#define kIndexTLS 2

#define kIndexSRtpNone 0
#define kIndexSRtpOptional 1
#define kIndexSRtpMandatory 2

#define kIndexMediaProfile_Default 0
#define kIndexMediaProfile_RTCWeb 1

#define  kIndexMediaVsize_sqcif 0
#define  kIndexMediaVsize_qcif 1
#define  kIndexMediaVsize_qvga 2
#define  kIndexMediaVsize_cif 3
#define  kIndexMediaVsize_hvga 4
#define  kIndexMediaVsize_vga 5
#define  kIndexMediaVsize_4cif 6
#define  kIndexMediaVsize_svga 7
#define  kIndexMediaVsize_480p 8
#define  kIndexMediaVsize_720p 9
#define  kIndexMediaVsize_16cif 10
#define  kIndexMediaVsize_1080p 11

typedef struct codec_s {
	tdav_codec_id_t _id;
	NSString *bundle_key;
	NSString *name;
	NSString *description;
}
codec_t;

static const codec_t __audioCodecs[] = 
{
	{ tdav_codec_id_g722, MEDIA_CODEC_USE_G722, @"G.722", @"G.722 (16 KHz)" },
	{ tdav_codec_id_pcma, MEDIA_CODEC_USE_PCMA, @"PCMA", @"PCMA (8 KHz)"  },
	{ tdav_codec_id_pcmu, MEDIA_CODEC_USE_PCMU, @"PCMU", @"PCMU (8 KHz)" },
	{ tdav_codec_id_g729ab, MEDIA_CODEC_USE_G729AB, @"G.729a", @"G.729a (8 KHz)" },
	{ tdav_codec_id_amr_nb_oa, MEDIA_CODEC_USE_AMR_NB_OA @"AMR-NB-OA", @"AMR Narrowband Octet Aligned (8 KHz)" },
	{ tdav_codec_id_amr_nb_be, MEDIA_CODEC_USE_AMR_NB_BE, @"AMR-NB-BE", @"AMR Narrowband Bandwidth Efficient Aligned (8 KHz)" },
	{ tdav_codec_id_gsm, MEDIA_CODEC_USE_GSM, @"GSM", @"GSM (8 KHz)" },
	{ tdav_codec_id_speex_nb, MEDIA_CODEC_USE_SPEEX_NB, @"Speex-NB", @"Speex Narrowband (8 KHz)" },
	{ tdav_codec_id_speex_wb, MEDIA_CODEC_USE_SPEEX_WB, @"Speex-WB", @"Speex Wideband (16 KHz)" },
	{ tdav_codec_id_speex_uwb, MEDIA_CODEC_USE_SPEEX_UWB, @"Speex-UWB", @"Speex Ultra-Wideband (32 KHz)" },
};
static const codec_t __videoCodecs[] = 
{	
	{ tdav_codec_id_vp8, MEDIA_CODEC_USE_VP8, @"VP8", @"Google's VP8" },
	{ tdav_codec_id_h264_bp, MEDIA_CODEC_USE_H264BP, @"H.264-BP", @"H.264 Base Profile" },
	{ tdav_codec_id_h264_mp, MEDIA_CODEC_USE_H264MP, @"H.264-MP", @"H.264 Main Profile" },
	{ tdav_codec_id_h263, MEDIA_CODEC_USE_H263, @"H.263", @"H.263-1996" },
	{ tdav_codec_id_h263p, MEDIA_CODEC_USE_H263P, @"H.263+", @"H.263-1998" },
	{ tdav_codec_id_theora, MEDIA_CODEC_USE_THEORA, @"Theora", @"Theora" },
	{ tdav_codec_id_mp4ves_es, MEDIA_CODEC_USE_MP4VES, @"MP4V-ES", @"MPEG-4 Part 2" },
};

//
// private
//

@interface UIPreferences(Private)
-(void)onWindowClosed:(NSNotification*)notification;
-(void)loadConfig;
-(void)saveConfig;
-(void)pushConfig;
@end

@implementation UIPreferences(Private)

-(void)onWindowClosed:(NSNotification*)notification
{
	[self autorelease];
}

-(void)loadConfig
{
	// Identity
	[self.textFieldDisplayName setStringValue:[[NgnEngine sharedInstance].configurationService getStringWithKey:IDENTITY_DISPLAY_NAME]];
	[self.textFieldPrivateId setStringValue:[[NgnEngine sharedInstance].configurationService getStringWithKey:IDENTITY_IMPI]];
	[self.textFieldPublicId setStringValue:[[NgnEngine sharedInstance].configurationService getStringWithKey:IDENTITY_IMPU]];
	[self.textFieldPassword setStringValue:[[NgnEngine sharedInstance].configurationService getStringWithKey:IDENTITY_PASSWORD]];
	[self.textFieldRealm setStringValue:[[NgnEngine sharedInstance].configurationService getStringWithKey:NETWORK_REALM]];
	[self.checkBoxEarlyIMS setState:[[NgnEngine sharedInstance].configurationService getBoolWithKey:NETWORK_USE_EARLY_IMS] ? NSOnState : NSOffState];
	
	// Network
	[self.textFieldProxyHost setStringValue:[[NgnEngine sharedInstance].configurationService getStringWithKey:NETWORK_PCSCF_HOST]];
	[self.textFieldProxyPort setIntValue:[[NgnEngine sharedInstance].configurationService getIntWithKey:NETWORK_PCSCF_PORT]];
	[self.buttonCellIPv6 setState:[[[NgnEngine sharedInstance].configurationService getStringWithKey:NETWORK_IP_VERSION] isEqualToString:@"ipv6"] ? NSOnState : NSOffState];
	[self.buttonCellIPv4 setState:[self.buttonCellIPv6 state] == NSOnState ? NSOffState : NSOnState];
	NSString* transport = [[NgnEngine sharedInstance].configurationService getStringWithKey:NETWORK_TRANSPORT];
	if([transport isEqualToString:@"tcp"]){
		[self.comboBoxTransport selectItemAtIndex:kIndexTCP];
	}
	else if([transport isEqualToString:@"tls"]){
		[self.comboBoxTransport selectItemAtIndex:kIndexTLS];
	}
	else{
		[self.comboBoxTransport selectItemAtIndex:kIndexUDP];
	}
	[self.checkBoxDiscoDNS setState:[[NgnEngine sharedInstance].configurationService getBoolWithKey:NETWORK_PCSCF_DISCOVERY_USE_DNS] ? NSOnState : NSOffState];
	[self.checkBoxDiscoDHCP setState:[[NgnEngine sharedInstance].configurationService getBoolWithKey:NETWORK_PCSCF_DISCOVERY_USE_DHCP] ? NSOnState : NSOffState];
	[self.checkBoxSigComp setState:[[NgnEngine sharedInstance].configurationService getBoolWithKey:NETWORK_USE_SIGCOMP] ? NSOnState : NSOffState];
	[self.textFieldAMF setStringValue:[[NgnEngine sharedInstance].configurationService getStringWithKey:SECURITY_IMSAKA_AMF]];
	[self.textFieldOpId setStringValue:[[NgnEngine sharedInstance].configurationService getStringWithKey:SECURITY_IMSAKA_OPID]];
	switch ([[NgnEngine sharedInstance].configurationService getIntWithKey:SECURITY_SRTP_MODE]) {
		case kDefaultSecuritySRtpMode_None: default: [self.comboBoxSRTPMode selectItemAtIndex:kIndexSRtpNone]; break;
		case kDefaultSecuritySRtpMode_Optional: [self.comboBoxSRTPMode selectItemAtIndex:kIndexSRtpOptional]; break;
		case kDefaultSecuritySRtpMode_Mandatory: [self.comboBoxSRTPMode selectItemAtIndex:kIndexSRtpMandatory]; break;
	}
	switch([[NgnEngine sharedInstance].configurationService getIntWithKey:MEDIA_PROFILE]){
		case kDefaultMediaProfile_Default: default: [self.comboBoxProfile selectItemAtIndex:kIndexMediaProfile_Default]; break;
		case kDefaultMediaProfile_RTCWeb: [self.comboBoxProfile selectItemAtIndex:kIndexMediaProfile_RTCWeb]; break;
	}
	switch([[NgnEngine sharedInstance].configurationService getIntWithKey:MEDIA_PREFERRED_VIDEO_SIZE]){
		case kDefaultMediaVsize_sqcif: [self.comboBoxPrefVsize selectItemAtIndex:kIndexMediaVsize_sqcif]; break;
		case kDefaultMediaVsize_qcif: [self.comboBoxPrefVsize selectItemAtIndex:kIndexMediaVsize_qcif]; break;
		case kDefaultMediaVsize_qvga: [self.comboBoxPrefVsize selectItemAtIndex:kIndexMediaVsize_qvga]; break;
		case kDefaultMediaVsize_cif: [self.comboBoxPrefVsize selectItemAtIndex:kIndexMediaVsize_cif]; break;
		case kDefaultMediaVsize_hvga: [self.comboBoxPrefVsize selectItemAtIndex:kIndexMediaVsize_hvga]; break;
		case kDefaultMediaVsize_vga: default:[self.comboBoxPrefVsize selectItemAtIndex:kIndexMediaVsize_vga]; break;
		case kDefaultMediaVsize_4cif: [self.comboBoxPrefVsize selectItemAtIndex:kIndexMediaVsize_4cif]; break;
		case kDefaultMediaVsize_svga: [self.comboBoxPrefVsize selectItemAtIndex:kIndexMediaVsize_svga]; break;
		case kDefaultMediaVsize_480p: [self.comboBoxPrefVsize selectItemAtIndex:kIndexMediaVsize_480p]; break;
		case kDefaultMediaVsize_720p: [self.comboBoxPrefVsize selectItemAtIndex:kIndexMediaVsize_720p]; break;
		case kDefaultMediaVsize_16cif: [self.comboBoxPrefVsize selectItemAtIndex:kIndexMediaVsize_16cif]; break;
		case kDefaultMediaVsize_1080p: [self.comboBoxPrefVsize selectItemAtIndex:kIndexMediaVsize_1080p]; break;
	}
	
	
	// NAT Traversal
	[self.checkBoxICEEnable setState:[[NgnEngine sharedInstance].configurationService getBoolWithKey:NATT_USE_ICE] ? NSOnState : NSOffState];
	[self.checkBoxSTUNEnable setState:[[NgnEngine sharedInstance].configurationService getBoolWithKey:NATT_USE_STUN] ? NSOnState : NSOffState];
	[self.buttonCellSTUNDiscover setState:[[NgnEngine sharedInstance].configurationService getBoolWithKey:NATT_USE_STUN_DISCO] ? NSOnState : NSOffState];
	[self.buttonCellSTUNUseThisServer setState:[self.buttonCellSTUNDiscover state] == NSOnState ? NSOffState : NSOnState];
	[self.textFieldSTUNServerHost setStringValue:[[NgnEngine sharedInstance].configurationService getStringWithKey:NATT_STUN_SERVER]];
	[self.textFieldSTUNServerPort setIntValue:[[NgnEngine sharedInstance].configurationService getIntWithKey:NATT_STUN_PORT]];
	
	// Codecs
	if([self.audioCodecs count] == 0){
		for(int i = 0; i < sizeof(__audioCodecs)/sizeof(codec_t); i++){
			if(tdav_codec_is_supported(__audioCodecs[i]._id)){
				[self.audioCodecs addObject:[NSDictionary dictionaryWithObjectsAndKeys:
											 [NSNumber numberWithInt:(int)__audioCodecs[i]._id], @"id",
											 __audioCodecs[i].bundle_key, @"bundle_key",
											 __audioCodecs[i].name, @"name",
											 __audioCodecs[i].description, @"description",
											 nil]];
			}
		}
	}
	[self.arrayControllerAudioCodecs setContent:self.audioCodecs];
	if([self.videoCodecs count] == 0){
		for(int i = 0; i < sizeof(__videoCodecs)/sizeof(codec_t); i++){
			if(tdav_codec_is_supported(__videoCodecs[i]._id)){
				[self.videoCodecs addObject:[NSDictionary dictionaryWithObjectsAndKeys:
											 [NSNumber numberWithInt:(int)__videoCodecs[i]._id], @"id",
											 __videoCodecs[i].bundle_key, @"bundle_key",
											 __videoCodecs[i].name, @"name",
											 __videoCodecs[i].description, @"description",
											 nil]];
			}
		}
	}
	[self.arrayControllerVideoCodecs setContent:self.videoCodecs];
}

-(void)saveConfig
{
	// Identity
	[[NgnEngine sharedInstance].configurationService setStringWithKey:IDENTITY_DISPLAY_NAME andValue:[self.textFieldDisplayName stringValue]];
	[[NgnEngine sharedInstance].configurationService setStringWithKey:IDENTITY_IMPI andValue:[self.textFieldPrivateId stringValue]];
	[[NgnEngine sharedInstance].configurationService setStringWithKey:IDENTITY_IMPU andValue:[self.textFieldPublicId stringValue]];
	[[NgnEngine sharedInstance].configurationService setStringWithKey:IDENTITY_PASSWORD andValue:[self.textFieldPassword stringValue]];
	[[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_REALM andValue:[self.textFieldRealm stringValue]];
	[[NgnEngine sharedInstance].configurationService setBoolWithKey:NETWORK_USE_EARLY_IMS andValue:[self.checkBoxEarlyIMS state]==NSOnState];
	
	// Network
	[[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_PCSCF_HOST andValue:[self.textFieldProxyHost stringValue]];
	[[NgnEngine sharedInstance].configurationService setIntWithKey:NETWORK_PCSCF_PORT andValue:[self.textFieldProxyPort intValue]];
	[[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_IP_VERSION andValue:[self.buttonCellIPv6 state]==NSOnState ? @"ipv6" : @"ipv4"];
	switch ([self.comboBoxTransport indexOfSelectedItem]) {
		case kIndexTCP:
			[[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_TRANSPORT andValue:@"tcp"];
			break;
		case kIndexTLS:
			[[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_TRANSPORT andValue:@"tls"];
			break;
		default:
		case kIndexUDP:
			[[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_TRANSPORT andValue:@"udp"];
			break;
	}
	[[NgnEngine sharedInstance].configurationService setBoolWithKey:NETWORK_PCSCF_DISCOVERY_USE_DNS andValue:[self.checkBoxDiscoDNS state]==NSOnState];
	[[NgnEngine sharedInstance].configurationService setBoolWithKey:NETWORK_PCSCF_DISCOVERY_USE_DHCP andValue:[self.checkBoxDiscoDHCP state]==NSOnState];
	[[NgnEngine sharedInstance].configurationService setBoolWithKey:NETWORK_USE_SIGCOMP andValue:[self.checkBoxSigComp state]==NSOnState];
	[[NgnEngine sharedInstance].configurationService setStringWithKey:SECURITY_IMSAKA_AMF andValue:[self.textFieldAMF stringValue]];
	[[NgnEngine sharedInstance].configurationService setStringWithKey:SECURITY_IMSAKA_OPID andValue:[self.textFieldOpId stringValue]];
	switch ([self.comboBoxSRTPMode indexOfSelectedItem]) {
		case kIndexSRtpNone: default: [[NgnEngine sharedInstance].configurationService setIntWithKey:SECURITY_SRTP_MODE andValue:kDefaultSecuritySRtpMode_None]; break;
		case kIndexSRtpOptional: [[NgnEngine sharedInstance].configurationService setIntWithKey:SECURITY_SRTP_MODE andValue:kDefaultSecuritySRtpMode_Optional]; break;
		case kIndexSRtpMandatory: [[NgnEngine sharedInstance].configurationService setIntWithKey:SECURITY_SRTP_MODE andValue:kDefaultSecuritySRtpMode_Mandatory]; break;
	}
	switch ([self.comboBoxProfile indexOfSelectedItem]) {
		case kIndexMediaProfile_Default: default: [[NgnEngine sharedInstance].configurationService setIntWithKey:MEDIA_PROFILE andValue: kDefaultMediaProfile_Default]; break;
		case kIndexMediaProfile_RTCWeb: [[NgnEngine sharedInstance].configurationService setIntWithKey:MEDIA_PROFILE andValue: kDefaultMediaProfile_RTCWeb]; break;
	}
	switch ([self.comboBoxPrefVsize indexOfSelectedItem]) {
		case kIndexMediaVsize_sqcif: [[NgnEngine sharedInstance].configurationService setIntWithKey:MEDIA_PREFERRED_VIDEO_SIZE andValue: kDefaultMediaVsize_sqcif]; break;
		case kIndexMediaVsize_qcif: [[NgnEngine sharedInstance].configurationService setIntWithKey:MEDIA_PREFERRED_VIDEO_SIZE andValue: kDefaultMediaVsize_qcif]; break;
		case kIndexMediaVsize_qvga: [[NgnEngine sharedInstance].configurationService setIntWithKey:MEDIA_PREFERRED_VIDEO_SIZE andValue: kDefaultMediaVsize_qvga]; break;	
		case kIndexMediaVsize_cif: [[NgnEngine sharedInstance].configurationService setIntWithKey:MEDIA_PREFERRED_VIDEO_SIZE andValue: kDefaultMediaVsize_cif]; break;
		case kIndexMediaVsize_hvga: [[NgnEngine sharedInstance].configurationService setIntWithKey:MEDIA_PREFERRED_VIDEO_SIZE andValue: kDefaultMediaVsize_hvga]; break;
		case kIndexMediaVsize_vga: default: [[NgnEngine sharedInstance].configurationService setIntWithKey:MEDIA_PREFERRED_VIDEO_SIZE andValue: kDefaultMediaVsize_vga]; break;
		case kIndexMediaVsize_4cif: [[NgnEngine sharedInstance].configurationService setIntWithKey:MEDIA_PREFERRED_VIDEO_SIZE andValue: kDefaultMediaVsize_4cif]; break;
		case kIndexMediaVsize_svga: [[NgnEngine sharedInstance].configurationService setIntWithKey:MEDIA_PREFERRED_VIDEO_SIZE andValue: kDefaultMediaVsize_svga]; break;
		case kIndexMediaVsize_480p: [[NgnEngine sharedInstance].configurationService setIntWithKey:MEDIA_PREFERRED_VIDEO_SIZE andValue: kDefaultMediaVsize_480p]; break;
		case kIndexMediaVsize_720p: [[NgnEngine sharedInstance].configurationService setIntWithKey:MEDIA_PREFERRED_VIDEO_SIZE andValue: kDefaultMediaVsize_720p]; break;
		case kIndexMediaVsize_16cif: [[NgnEngine sharedInstance].configurationService setIntWithKey:MEDIA_PREFERRED_VIDEO_SIZE andValue: kDefaultMediaVsize_16cif]; break;
		case kIndexMediaVsize_1080p: [[NgnEngine sharedInstance].configurationService setIntWithKey:MEDIA_PREFERRED_VIDEO_SIZE andValue: kDefaultMediaVsize_1080p]; break;
	}
	
	
	// NAT Traversal
	[[NgnEngine sharedInstance].configurationService setBoolWithKey:NATT_USE_ICE andValue:[self.checkBoxICEEnable state]==NSOnState];
	[[NgnEngine sharedInstance].configurationService setBoolWithKey:NATT_USE_STUN andValue:[self.checkBoxSTUNEnable state]==NSOnState];
	[[NgnEngine sharedInstance].configurationService setBoolWithKey:NATT_USE_STUN_DISCO andValue:[self.buttonCellSTUNDiscover state]==NSOnState];
	[[NgnEngine sharedInstance].configurationService setStringWithKey:NATT_STUN_SERVER andValue:[self.textFieldSTUNServerHost stringValue]];
	[[NgnEngine sharedInstance].configurationService setIntWithKey:NATT_STUN_PORT andValue:[self.textFieldSTUNServerPort intValue]];
	
	[[NgnEngine sharedInstance].configurationService synchronize];
}

-(void)pushConfig
{
	// Identity
	// Other configs will be pushed when the user try to register again
	
	// Network
	// Other configs will be pushed when the user try to register again
	
	// NAT Traversal
	
	
}

@end


//
// default
//

@implementation UIPreferences

@synthesize buttonSave;
@synthesize buttonCancel;

// Identity
@synthesize textFieldDisplayName;
@synthesize textFieldPublicId;
@synthesize textFieldPrivateId;
@synthesize textFieldPassword;
@synthesize textFieldRealm;
@synthesize checkBoxEarlyIMS;

// Network
@synthesize textFieldProxyHost;
@synthesize textFieldProxyPort;
@synthesize buttonCellIPv4;
@synthesize buttonCellIPv6;
@synthesize comboBoxTransport;
@synthesize checkBoxDiscoDHCP;
@synthesize checkBoxDiscoDNS;
@synthesize checkBoxSigComp;
@synthesize textFieldOpId;
@synthesize textFieldAMF;
@synthesize comboBoxSRTPMode;

// NAT Traversal
@synthesize checkBoxICEEnable;
@synthesize checkBoxSTUNEnable;
@synthesize buttonCellSTUNDiscover;
@synthesize buttonCellSTUNUseThisServer;
@synthesize textFieldSTUNServerHost;
@synthesize textFieldSTUNServerPort;

// Media
@synthesize comboBoxProfile;
@synthesize comboBoxPrefVsize;

// Codecs
@synthesize collectionViewAudioCodecs;
@synthesize arrayControllerAudioCodecs;
@synthesize audioCodecs;
@synthesize videoCodecs;
@synthesize collectionViewVideoCodecs;
@synthesize arrayControllerVideoCodecs;

-(void)awakeFromNib
{
	[super awakeFromNib];
	
	
	[self.collectionViewAudioCodecs setMaxItemSize:NSMakeSize(4000.f, 34.f)];
	[self.collectionViewAudioCodecs setMinItemSize:NSMakeSize(300.f, 34.f)];
	[self.collectionViewAudioCodecs setAutoresizingMask:NSViewWidthSizable];
	[self.collectionViewAudioCodecs setMaxNumberOfColumns:1];
	[self.collectionViewVideoCodecs setMaxItemSize:NSMakeSize(4000.f, 34.f)];
	[self.collectionViewVideoCodecs setMinItemSize:NSMakeSize(300.f, 34.f)];
	[self.collectionViewVideoCodecs setAutoresizingMask:NSViewWidthSizable];
	[self.collectionViewVideoCodecs setMaxNumberOfColumns:1];
	
	if(!self.audioCodecs){
		self->audioCodecs = [[NSMutableArray alloc] init];
	}
	if(!self.videoCodecs){
		self->videoCodecs = [[NSMutableArray alloc] init];
	}
}

-(void)loadWindow
{
	[super loadWindow];
	
	//[[self window] setBackgroundColor:[NSColor whiteColor]];
	
	[self loadConfig];
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self selector:@selector(onWindowClosed:) name:NSWindowWillCloseNotification object:[self window]];
}

- (IBAction)onButtonClick:(id)sender
{
	if(sender == self.buttonSave){
		[self saveConfig];
		[self pushConfig];
	}
	else if(sender == self.buttonCancel){
		[self loadConfig];
	}
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[self.audioCodecs release];
	[self.videoCodecs release];
	
	[super dealloc];
}

@end
