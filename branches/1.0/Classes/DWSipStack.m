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

#import "DWSipStack.h"

#import "DWSipEvent.h"

#import "DWVideoProducer.h"
#import "DWVideoConsumer.h"

@interface DWSipStack(Private)

-(BOOL) addSigCompCompartment: (NSString*) compId;
-(BOOL) removeSigCompCompartment: (NSString*) compId;

@end

@implementation DWSipStack

static unsigned __count = 0;
static int __stack_callback(const tsip_event_t *sipevent);

@synthesize state;
@synthesize handle;

-(DWSipStack *) initWithDelegate: (NSObject<DWSipStackDelegate>*) _delegate realmUri: (NSString *)realm impiUri: (NSString *)impi impuUri: (NSString *)impu{
	self = [super init];
	
	if(self){
		self->delegate = [_delegate retain];
		
		/* initialize network layer */
		if(__count == 0){
			tdav_init();
			
			// Register iOS4 Video Consumer and Producer
			tmedia_consumer_plugin_register(dw_videoConsumer_plugin_def_t);
			tmedia_producer_plugin_register(dw_videoProducer_plugin_def_t);
			
			tnet_startup();
		}
		/* Create stack handle */
		self->handle = tsip_stack_create(__stack_callback, [realm UTF8String], [impi UTF8String], [impu UTF8String],
							TSIP_STACK_SET_LOCAL_IP(TNET_SOCKET_HOST_ANY),
							TSIP_STACK_SET_USERDATA(self), /* used as context (useful for server-initiated requests) */
							TSIP_STACK_SET_NULL());
		__count++;
		
		
		// Sip Headers
	}
	
	return self;
}


-(BOOL) start{
	return (tsip_stack_start(self->handle) == 0);
}

-(BOOL) setRealm: (NSString *)realmUri{
	return (tsip_stack_set(self->handle,
				TSIP_STACK_SET_REALM([realmUri UTF8String]),
				TSIP_STACK_SET_NULL()) == 0);
}

-(BOOL) setIMPI: (NSString *) impiUri{
	return (tsip_stack_set(self->handle,
				TSIP_STACK_SET_IMPI([impiUri UTF8String]),
				TSIP_STACK_SET_NULL()) == 0);
}

-(BOOL) setIMPU: (NSString *) impuUri{
	return (tsip_stack_set(self->handle,
				TSIP_STACK_SET_IMPU([impuUri UTF8String]),
				TSIP_STACK_SET_NULL()) == 0);
}

-(BOOL) setPassword: (NSString*) password{
	return (tsip_stack_set(self->handle,
				TSIP_STACK_SET_PASSWORD([password UTF8String]),
				TSIP_STACK_SET_NULL()) == 0);
}

-(BOOL) setAMF: (NSString*) amf{
	uint16_t _amf = (uint16_t)tsk_atox([amf UTF8String]);
	return (tsip_stack_set(self->handle,
				TSIP_STACK_SET_IMS_AKA_AMF(_amf),
				TSIP_STACK_SET_NULL()) == 0);
}

-(BOOL) setOperatorId: (NSString*) opid{
	return (tsip_stack_set(self->handle,
				TSIP_STACK_SET_IMS_AKA_OPERATOR_ID([opid UTF8String]),
				TSIP_STACK_SET_NULL()) == 0); 
}

-(BOOL) setProxyCSCFWithFQDN: (NSString*) fqdn andPort: (unsigned short) port andTransport: (NSString*) transport andIPVersion: (NSString *) ipversion{
	unsigned _port = port; //promote
	return (tsip_stack_set(self->handle,
				TSIP_STACK_SET_PROXY_CSCF([fqdn UTF8String], _port, [transport UTF8String], [ipversion UTF8String]),
				TSIP_STACK_SET_NULL()) == 0);
}

-(BOOL) setLocalIP: (NSString*) ip{
	return (tsip_stack_set(self->handle,
				TSIP_STACK_SET_LOCAL_IP([ip UTF8String]),
				TSIP_STACK_SET_NULL()) == 0);
}

-(BOOL) setLocalPort: (unsigned short) port{
	unsigned _port = port;//promote
	return (tsip_stack_set(self->handle,
				TSIP_STACK_SET_LOCAL_PORT(_port),
				TSIP_STACK_SET_NULL()) == 0);
}

-(BOOL) setEarlyIMS: (BOOL) enabled{
	return (tsip_stack_set(self->handle,
				TSIP_STACK_SET_EARLY_IMS(enabled? tsk_true : tsk_false),
				TSIP_STACK_SET_NULL()) == 0);
}

-(BOOL) addHeaderName: (NSString*) name andValue: (NSString*) value{
	return (tsip_stack_set(self->handle,
				TSIP_STACK_SET_HEADER([name UTF8String], [value UTF8String]),
				TSIP_STACK_SET_NULL()) == 0);
}

-(BOOL) removeHeader: (NSString*) name{
	return (tsip_stack_set(self->handle,
				TSIP_STACK_UNSET_HEADER([name UTF8String]),
				TSIP_STACK_SET_NULL()) == 0);
}

-(BOOL) addDnsServer: (NSString*) ip{
	return (tsip_stack_set(self->handle,
				TSIP_STACK_SET_DNS_SERVER([ip UTF8String]),
				TSIP_STACK_SET_NULL()) == 0);
}

-(BOOL) setDnsDiscovery: (BOOL) enabled{
	tsk_bool_t _enabled = enabled;// 32bit/64bit workaround
	return (tsip_stack_set(self->handle,
				TSIP_STACK_SET_DISCOVERY_NAPTR(_enabled),
				TSIP_STACK_SET_NULL()) == 0);
}

-(BOOL) setAoRWithIP: (NSString*) ip andPort: (unsigned short) port{
	unsigned _port = port;//promote
	return (tsip_stack_set(self->handle,
				TSIP_STACK_SET_AOR([ip UTF8String], _port),
				TSIP_STACK_SET_NULL()) == 0);
}


-(BOOL) setSigCompParamsWithDMS: (unsigned) dms andSMS: (unsigned) sms andCPB: (unsigned) cpb andPresDict: (BOOL) enablePresDict{
	tsk_bool_t _enablePresDict= enablePresDict;// 32bit/64bit workaround
	return (tsip_stack_set(self->handle,
				TSIP_STACK_SET_SIGCOMP(dms, sms, cpb, _enablePresDict),
				TSIP_STACK_SET_NULL()) == 0);
}

-(BOOL) addSigCompCompartment: (NSString*) _compId{
	return (tsip_stack_set(self->handle,
						   TSIP_STACK_SET_SIGCOMP_NEW_COMPARTMENT([_compId UTF8String]),
						   TSIP_STACK_SET_NULL()) == 0);
}

-(BOOL) removeSigCompCompartment: (NSString*) _compId{
	return (tsip_stack_set(self->handle,
						   TSIP_STACK_UNSET_SIGCOMP_COMPARTMENT([_compId UTF8String]),
						   TSIP_STACK_SET_NULL()) == 0);
}

-(void) setSigCompId: (NSString*) _compId{	
	if(self->compId != nil && self->compId != _compId){
		[self removeSigCompCompartment: self->compId];
	}
	
	[self->compId release], self->compId = [_compId retain];
	if(self->compId){
		[self addSigCompCompartment: self->compId];
	}
}

-(NSString*)sigCompId{
	return self->compId;
}

-(BOOL) setSTUNServerIP: (NSString*) ip andPort: (unsigned short) port{
	unsigned _port = port;//promote
	return (tsip_stack_set(self->handle,
				TSIP_STACK_SET_STUN_SERVER([ip UTF8String], _port),
				TSIP_STACK_SET_NULL()) == 0);
}

-(BOOL) setSTUNCredLogin: (NSString*) login andPassword: (NSString*) password{
	return (tsip_stack_set(self->handle,
				TSIP_STACK_SET_STUN_CRED([login UTF8String], [password UTF8String]),
				TSIP_STACK_SET_NULL()) == 0);
}


-(NSString *) dnsENUMWithService: (NSString *) service andE164Num: (NSString *) e164num andDomain: (NSString*) domain{
	tnet_dns_ctx_t* dnsctx = tsip_stack_get_dnsctx(self->handle);
	char* uri = tsk_null;
	
	if(dnsctx){
		if(!(uri = tnet_dns_enum_2(dnsctx, [service UTF8String], [e164num UTF8String], [domain UTF8String]))){
			TSK_DEBUG_ERROR("ENUM(%s) failed", [e164num UTF8String]);
		}
		tsk_object_unref(dnsctx);
		return [NSString stringWithCString: uri encoding: NSUTF8StringEncoding];
	}
	else{
		TSK_DEBUG_ERROR("No DNS Context could be found");
		return nil;
	}
}

-(NSString *) dnsNaptrSrvWithDomain: (NSString *) domain andService: (NSString *) service andPort: (unsigned short*) port{
	return nil;
}

-(NSString *) dnsSrvWithService: (NSString *) service andPort: (unsigned short*) port{
	return nil;
}


-(BOOL) isValid{
	return (self->handle != tsk_null);
}

-(BOOL) stop{
	return (tsip_stack_stop(self->handle) == 0);
}


+(void) setCodecs:(tdav_codec_id_t) codecs{
	tdav_set_codecs(codecs);
}

- (void)dealloc {
	// stop the stack
	[self stop];
	// destroy the handle
	TSK_OBJECT_SAFE_FREE(self->handle);
	
	[compId release];
	[delegate release], delegate= nil;
	
	
	/* DeInitialize the network layer (only if last stack) */
	if(--__count == 0){
		tdav_deinit();
		tnet_cleanup();
		
		// UnRegister iOS4 Video Consumer and Producer
		tmedia_consumer_plugin_unregister(dw_videoConsumer_plugin_def_t);
		tmedia_producer_plugin_unregister(dw_videoProducer_plugin_def_t);
	}
	
    [super dealloc];
}



int __stack_callback(const tsip_event_t *sipevent)
{
	int ret = 0;
	const DWSipStack* sipStack = nil;
	DWSipEvent* event = nil;
	
	if(!sipevent){ /* should never happen ...but who know? */
		TSK_DEBUG_WARN("Null SIP event.");
		return -1;
	}
	else {
		if(sipevent->type == tsip_event_stack && sipevent->userdata){
			/* sessionless event */
			sipStack = [((NSObject*)sipevent->userdata) isMemberOfClass:[DWSipStack class]] ? ((const DWSipStack*)sipevent->userdata) : nil;
		}
		else {
			const void* userdata;
			/* gets the stack from the session */
			const tsip_stack_handle_t* stack_handle = tsip_ssession_get_stack(sipevent->ss);
			if(stack_handle && (userdata = tsip_stack_get_userdata(stack_handle))){
				sipStack = [((NSObject*)userdata) isMemberOfClass:[DWSipStack class]] ? ((const DWSipStack*)userdata) : nil;
			}
		}
	}
	
	if(!sipStack){
		TSK_DEBUG_WARN("Invalid SIP event (Stack is Null).");
		return -2;
	}
	
	// Les choses serieuses vont commencer!!!
	// This is a POSIX thread but thanks to multithreading
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[sipStack lock];
	
	if(!sipStack->delegate){
		goto done;
	}
	
	switch(sipevent->type){
		case tsip_event_register:
		{   /* REGISTER */
			event = [[DWRegistrationEvent alloc] initWithEvent:(tsip_event_t*)sipevent];
			ret = [sipStack->delegate onEvent: event];
			break;
		}
		case tsip_event_invite:
		{     /* INVITE */
			event = [[DWInviteEvent alloc] initWithEvent:(tsip_event_t*)sipevent];
			ret = [sipStack->delegate onEvent: event];
			break;
		}
		case tsip_event_message:
		{       /* MESSAGE */
			//if(Stack->getCallback()){
			//	e = new MessagingEvent(sipevent);
			//	Stack->getCallback()->OnMessagingEvent((const MessagingEvent*)e);
			//}
			break;
		}
		case tsip_event_options:
		{ /* OPTIONS */
			//if(Stack->getCallback()){
			//	e = new OptionsEvent(sipevent);
			//	Stack->getCallback()->OnOptionsEvent((const OptionsEvent*)e);
			//}
			break;
		}
		case tsip_event_publish:
		{ /* PUBLISH */
			//if(Stack->getCallback()){
			//	e = new PublicationEvent(sipevent);
			//	Stack->getCallback()->OnPublicationEvent((const PublicationEvent*)e);
			//}
			break;
		}
		case tsip_event_subscribe:
		{       /* SUBSCRIBE */
			//if(Stack->getCallback()){
			//	e = new SubscriptionEvent(sipevent);
			//	Stack->getCallback()->OnSubscriptionEvent((const SubscriptionEvent*)e);
			//}
			break;
		}
			
		case tsip_event_dialog:
		{   /* Common to all dialogs */
			event = [[DWDialogEvent alloc]initWithEvent:(tsip_event_t*)sipevent];
			ret = [sipStack->delegate onEvent: event];
			break;
		}
			
		case tsip_event_stack:
		{   /* Stack event */
			event = [[DWStackEvent alloc] initWithEvent:(tsip_event_t*)sipevent];
			ret = [sipStack->delegate onEvent: event];
			break;
		}
			
		default:
		{       /* Unsupported */
			TSK_DEBUG_WARN("%d not supported as SIP event.", sipevent->type);
			ret = -3;
			break;
		}
	}
	
done:
	[sipStack unlock];
	
	[pool release];
	
	return ret;
}

@end
