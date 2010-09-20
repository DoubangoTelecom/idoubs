//
//  ConfigurationService.m
//  iDoubs
//
//  Created by Mamadou DIOP on 8/29/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import "ConfigurationService.h"


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
								  
								  
							
								  nil];
		
		[self->prefs registerDefaults:defaults];
	}
	return self;
}

//
// PService
//
-(BOOL) start{
	return NO;
}

-(BOOL) stop{
	return NO;
}

//
// PConfigurationService
//

-(NSString*) getString: (CONFIGURATION_SECTION_T) section entry:(CONFIGURATION_ENTRY_T) e{
	NSString* value = [self->prefs stringForKey:[self entryKey: section entry:e]];
	return value;
}

-(int) getInt: (CONFIGURATION_SECTION_T) section  entry:(CONFIGURATION_ENTRY_T) e{
	return [self->prefs integerForKey:[self entryKey: section entry:e]];
}

-(float) getFloat: (CONFIGURATION_SECTION_T) section entry:(CONFIGURATION_ENTRY_T) e{
	return [self->prefs floatForKey:[self entryKey: section entry:e]];
}

-(BOOL) getBoolean: (CONFIGURATION_SECTION_T) section entry:(CONFIGURATION_ENTRY_T) e{
	return [self->prefs boolForKey:[self entryKey: section entry:e]];
}


@end
