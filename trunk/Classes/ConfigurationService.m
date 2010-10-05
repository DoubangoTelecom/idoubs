/*
 * Copyright (C) 2010 Mamadou Diop.
 *
 * Contact: Mamadou Diop <diopmamadou(at)doubango.org>
 *       
 * This file is part of idoubs Project (http://code.google.com/p/idoubs)
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

#import "ConfigurationService.h"

#import "DWSipStack.h"

@interface ConfigurationService(Codecs)
-(int) getCodecs;
@end

@implementation ConfigurationService(Codecs)
-(int) getCodecs{
	tdav_codec_id_t codecs = tdav_codec_id_none;
	
	if([self->prefs boolForKey:@"codecs_amr_nb_oa"]){
		codecs |= tdav_codec_id_amr_nb_oa;
	}
	if([self->prefs boolForKey:@"codecs_amr_nb_be"]){
		codecs |= tdav_codec_id_amr_nb_be;
	}
	if([self->prefs boolForKey:@"codecs_gsm"]){
		codecs |= tdav_codec_id_gsm;
	}
	if([self->prefs boolForKey:@"codecs_pcma"]){
		codecs |= tdav_codec_id_pcma;
	}
	if([self->prefs boolForKey:@"codecs_pcmu"]){
		codecs |= tdav_codec_id_pcmu;
	}
	if([self->prefs boolForKey:@"codecs_speex_nb"]){
		codecs |= tdav_codec_id_speex_nb;
	}
	if([self->prefs boolForKey:@"codecs_h263"]){
		codecs |= tdav_codec_id_h263;
	}
	if([self->prefs boolForKey:@"codecs_h263p"]){
		codecs |= tdav_codec_id_h263p;
	}
	if([self->prefs boolForKey:@"codecs_h264_bp10"]){
		codecs |= tdav_codec_id_h264_bp10;
	}
	if([self->prefs boolForKey:@"codecs_h264_bp20"]){
		codecs |= tdav_codec_id_h264_bp20;
	}
	if([self->prefs boolForKey:@"codecs_h264_bp30"]){
		codecs |= tdav_codec_id_h264_bp30;
	}
	if([self->prefs boolForKey:@"codecs_theora"]){
		codecs |= tdav_codec_id_theora;
	}
	
	return (int)codecs;
}

@end

@implementation ConfigurationService

//FIXME: use FD
//
// Internal functions
//
-(NSString*) entryKey: (CONFIGURATION_SECTION_T) section entry:(CONFIGURATION_ENTRY_T) e{	
	switch (section) {
			/* === IDENTITY === */
		case CONFIGURATION_SECTION_IDENTITY:
			switch (e) {
				case CONFIGURATION_ENTRY_DISPLAY_NAME: return @"identity_displayname";
				case CONFIGURATION_ENTRY_IMPI: return @"identity_impi";
				case CONFIGURATION_ENTRY_IMPU: return @"identity_impu";
				case CONFIGURATION_ENTRY_PASSWORD: return @"identity_password";
			}
			break;
			
			/* === GENERAL === */
		case CONFIGURATION_SECTION_GENERAL:
			break;
			
			/* === LTE === */
		case CONFIGURATION_SECTION_LTE:
			break;
			
			/* === NETWORK === */
		case CONFIGURATION_SECTION_NETWORK:
			switch (e) {
				case CONFIGURATION_ENTRY_EARLY_IMS: return @"identity_earlyims";
				case CONFIGURATION_ENTRY_IP_VERSION: return @"network_ipversion";
				case CONFIGURATION_ENTRY_PCSCF_DISCOVERY: return nil;
				case CONFIGURATION_ENTRY_PCSCF_HOST: return @"network_pcscf_host";
				case CONFIGURATION_ENTRY_PCSCF_PORT: return @"network_pcscf_port";
				case CONFIGURATION_ENTRY_REALM: return @"identity_realm";
				case CONFIGURATION_ENTRY_SIGCOMP: return @"network_sigcomp";
				case CONFIGURATION_ENTRY_THREE_3G: return @"network_3g";
				case CONFIGURATION_ENTRY_TRANSPORT: return @"network_transport";
				case CONFIGURATION_ENTRY_WIFI: return @"network_wifi";
			}
			break;
			
			/* === QOS === */
		case CONFIGURATION_SECTION_QOS:
			break;
			
			/* === RCS === */
		case CONFIGURATION_SECTION_RCS:
			break;
			
			/* === SECURITY === */
		case CONFIGURATION_SECTION_SECURITY:
			break;
			
			/* === SESSIONS === */
		case CONFIGURATION_SECTION_SESSIONS:
			break;
			
			/* === MEDIA === */
		case CONFIGURATION_SECTION_MEDIA:
			break;
			
			/* === NATT === */
		case CONFIGURATION_SECTION_NATT:
			switch (e) {					
				case CONFIGURATION_ENTRY_USE_STUN: return @"natt_stun_enabled";
				case CONFIGURATION_ENTRY_STUN_DISCO: return @"natt_stun_disco";
				case CONFIGURATION_ENTRY_STUN_SERVER: return @"natt_stun_server";
				case CONFIGURATION_ENTRY_STUN_PORT: return @"natt_stun_port";
			}
			break;
			
			/* === XCAP === */
		case CONFIGURATION_SECTION_XCAP:
			break;
	}
	
	return @"unknown";
}

-(ConfigurationService*) init{
	if((self = [super init])){
		self->prefs = [NSUserDefaults standardUserDefaults];
		
		// FIXME: First time for Simulator
		NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
								  
								  /* === IDENTITY === */
								  @"John Doe", @"identity_displayname",
								  @"johndoe@open-ims.test", @"identity_impi",
								  @"sip:johndoe@open-ims.test", @"identity_impu",
								  @"", @"identity_password",
																	
								  
								  
								  /* === NETWORK === */
								  [NSNumber numberWithBool:NO], @"identity_earlyims",
								  @"IPv4", @"network_ipversion",
								  @"127.0.0.1", @"network_pcscf_host",
								  [NSNumber numberWithInt:5060], @"network_pcscf_port",
								  @"sip:open-ims.test", @"identity_realm",
								  [NSNumber numberWithBool:NO], @"network_sigcomp",
								  [NSNumber numberWithBool:NO], @"network_3g",
								  [NSNumber numberWithBool:YES], @"network_wifi",
								  @"UDP", @"network_transport",
								  
								  
								  /* === MEDIA === */
								  [NSNumber numberWithBool:NO], @"codecs_amr_nb_oa",
								  [NSNumber numberWithBool:NO], @"codecs_amr_nb_be",
								  [NSNumber numberWithBool:YES], @"codecs_gsm",
								  [NSNumber numberWithBool:YES], @"codecs_pcma",
								  [NSNumber numberWithBool:YES], @"codecs_pcmu",
								  [NSNumber numberWithBool:NO], @"codecs_speex_nb",
								  [NSNumber numberWithBool:NO], @"codecs_h263",
								  [NSNumber numberWithBool:YES], @"codecs_h263p",
								  [NSNumber numberWithBool:YES], @"codecs_h264_bp10",
								  [NSNumber numberWithBool:NO], @"codecs_h264_bp20",
								  [NSNumber numberWithBool:NO], @"codecs_h264_bp30",
								  [NSNumber numberWithBool:YES], @"codecs_theora",
								  
								  
								  /* === NATT === */
								  [NSNumber numberWithBool:NO], @"natt_stun_enabled",
								  [NSNumber numberWithBool:NO], @"natt_stun_disco",
								  @"numb.viagenie.ca", @"natt_stun_server",
								  [NSNumber numberWithInt:3478], @"natt_stun_port",
								  
							
								  nil];
		
		[self->prefs registerDefaults:defaults];
	}
	return self;
}

//
// PService
//
-(BOOL) start{
	[[NSNotificationCenter defaultCenter] addObserver: self 
				selector: @selector(userDefaultsDidChangeNotification:) name: NSUserDefaultsDidChangeNotification object: nil];
	return YES;
}

-(BOOL) stop{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	return YES;
}


-(void)userDefaultsDidChangeNotification:(NSNotification *)note {
	[DWSipStack setCodecs:[self getCodecs]];
}

//
// PConfigurationService
//

-(NSString*) getString: (CONFIGURATION_SECTION_T) section entry:(CONFIGURATION_ENTRY_T) e{
	NSString* value = [self->prefs stringForKey:[self entryKey: section entry:e]];
	return value;
}

-(int) getInt: (CONFIGURATION_SECTION_T) section  entry:(CONFIGURATION_ENTRY_T) e{
	if(section == CONFIGURATION_SECTION_MEDIA && e == CONFIGURATION_ENTRY_CODECS){// HACK: special case
		return [self getCodecs];
	}
	return [self->prefs integerForKey:[self entryKey: section entry:e]];
}

-(float) getFloat: (CONFIGURATION_SECTION_T) section entry:(CONFIGURATION_ENTRY_T) e{
	return [self->prefs floatForKey:[self entryKey: section entry:e]];
}

-(BOOL) getBoolean: (CONFIGURATION_SECTION_T) section entry:(CONFIGURATION_ENTRY_T) e{
	return [self->prefs boolForKey:[self entryKey: section entry:e]];
}



@end
