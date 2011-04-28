#import "NgnSipService.h"

#import "tsk_debug.h"
#import "SipCallback.h"
#import "SipEvent.h"

//
//	NgnSipCallback
//

class _NgnSipCallback : public SipCallback
{
public:
	_NgnSipCallback(NgnSipService* sipService) : SipCallback(){
		mSipService = [sipService retain];
	}
	
	~_NgnSipCallback(){
		[mSipService release];
	}
	
	/* == OnDialogEvent == */
	int OnDialogEvent(const DialogEvent* e){
		const char* _phrase = e->getPhrase();
		NSString* phrase = [NSString stringWithCString:_phrase encoding:NSUTF8StringEncoding];
		const short _code = e->getCode();
		const SipSession* _session = e->getBaseSession();
		if(!_session){
			TSK_DEBUG_ERROR("Null Sip session");
			return -1;
		}
		const long sessionId = _session->getId();
		NgnSipSession* ngnSipSession = nil;
		
		TSK_DEBUG_INFO("OnDialogEvent(%s, %ld)", _phrase, sessionId);
		
		return 0; 
	}
	
	/* == OnStackEvent == */
	int OnStackEvent(const StackEvent* e) { 
		return 0; 
	}
	
	/* == OnInviteEvent == */
	int OnInviteEvent(const InviteEvent* e) { 
		return 0; 
	}
	
	/* == OnMessagingEvent == */
	int OnMessagingEvent(const MessagingEvent* e) { 
		return 0;
	}
	
	/* == OnOptionsEvent == */
	int OnOptionsEvent(const OptionsEvent* e) { 
		return 0; 
	}
	
	/* == OnPublicationEvent == */
	int OnPublicationEvent(const PublicationEvent* e) { 
		return 0; 
	}
	
	/* == OnRegistrationEvent == */
	int OnRegistrationEvent(const RegistrationEvent* e) { 
		return 0; 
	}
	
	/* == OnSubscriptionEvent == */
	int OnSubscriptionEvent(const SubscriptionEvent* e) { 
		return 0; 
	}
	
private
	:
	NgnSipService* mSipService;
};

//
//	NgnSipService
//

@implementation NgnSipService

-(NgnSipService*)init{
	if((self = [super init])){
		_mSipCallback = new _NgnSipCallback(self);
	}
	return self;
}

-(void)dealloc{
	if(_mSipCallback){
		delete _mSipCallback;
	}
	if(mRegistrationSession){
		[NgnRegistrationSession releaseSessionWithId: [mRegistrationSession getId]];
		mRegistrationSession = nil;
	}
	[super dealloc];
}

-(NSString*)getDefaultIdentity{
	return nil;
}

-(void)setDefaultIdentity: (NSString*)identity{
	
}

-(NgnSipStack*)getSipStack{
	return nil;
}

-(BOOL)isRegistered{
	return FALSE;
}

-(ConnectionState_t)getRegistrationState{
	return CONN_STATE_NONE;
}

-(int)getCodecs{
	return 0;
}

-(void)setCodecs: (int)codecs{
	
}

-(BOOL)stopStack{
	return FALSE;
}

-(BOOL)register_{
	return FALSE;
}

-(BOOL)unRegister{
	return FALSE;
}

@end




