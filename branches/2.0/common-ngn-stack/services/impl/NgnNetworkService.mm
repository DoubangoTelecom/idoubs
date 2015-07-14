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
#import "NgnNetworkService.h"
#import "NgnStringUtils.h"
#import "NgnNetworkEventArgs.h"
#import "NgnNotificationCenter.h"

#import <netinet/in.h> /* sockaddr_in */

#define kReachabilityHostName nil

#undef TAG
#define kTAG @"NgnNetworkService///: "
#define TAG kTAG


@interface NgnNetworkService(Private)
-(BOOL) startListening;
-(BOOL) stopListening;
-(void) setNetworkReachability:(NgnNetworkReachability_t)reachability_;
-(void) setNetworkType:(NgnNetworkType_t)networkType_;
@end


static NgnNetworkReachability_t NgnConvertFlagsToReachability(SCNetworkConnectionFlags flags)
{
	NgnNetworkReachability_t reachability = NetworkReachability_None;
	
	if(flags & kSCNetworkFlagsTransientConnection) reachability = (NgnNetworkReachability_t)(reachability | NetworkReachability_TransientConnection);
	if(flags & kSCNetworkFlagsReachable) reachability = (NgnNetworkReachability_t)(reachability | NetworkReachability_Reachable);
	if(flags & kSCNetworkFlagsConnectionRequired) reachability = (NgnNetworkReachability_t)(reachability | NetworkReachability_ConnectionRequired);
	if(flags & kSCNetworkFlagsConnectionAutomatic) reachability = (NgnNetworkReachability_t)(reachability | NetworkReachability_ConnectionAutomatic);
	if(flags & kSCNetworkFlagsInterventionRequired) reachability = (NgnNetworkReachability_t)(reachability | NetworkReachability_InterventionRequired);
	if(flags & kSCNetworkFlagsIsLocalAddress) reachability = (NgnNetworkReachability_t)(reachability | NetworkReachability_IsLocalAddress);
	if(flags & kSCNetworkFlagsIsDirect) reachability = (NgnNetworkReachability_t)(reachability | NetworkReachability_IsDirect);
	
	return reachability;
}

static NgnNetworkType_t NgnConvertFlagsToNetworkType(SCNetworkConnectionFlags flags){
	
	NgnNetworkType_t networkType = NetworkType_None;
#if TARGET_OS_IPHONE
	if(flags & kSCNetworkReachabilityFlagsIsWWAN)
	{
		networkType = (NgnNetworkType_t) (networkType | NetworkType_3G); // Ok, this is not true but iOS don't provide suchinformation
	}
	else
#endif /* TARGET_OS_IPHONE */
	{
		networkType = (NgnNetworkType_t) (networkType | NetworkType_WLAN);
	}
	
	return networkType;
}

static void NgnNetworkReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkConnectionFlags flags, void *info)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NgnNetworkService *self_ = (NgnNetworkService*)info;
	
	[self_ setNetworkReachability:NgnConvertFlagsToReachability(flags)];
	[self_ setNetworkType:NgnConvertFlagsToNetworkType(flags)];
	
	/* raise event */
	NgnNetworkEventArgs *eargs = [[[NgnNetworkEventArgs alloc] initWithType:NETWORK_EVENT_STATE_CHANGED] autorelease];
	[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnNetworkEventArgs_Name object:eargs];
	
	[pool release];
}

//
// private implementation
//

@implementation NgnNetworkService(Private)

-(BOOL) startListening{
	if([self stopListening]){
		Boolean ok;
		int err = 0;
        
         NgnNSLog(TAG, @"startListening(%@)", self.reachabilityHostName);
        
        /* SCNetworkReachabilityCreateWithName won't returns the rigth flags imediately. We need to wait for the callback. */
        if ([NgnStringUtils isNullOrEmpty:self.reachabilityHostName]) {
            struct sockaddr_in fakeAddress;
            bzero(&fakeAddress, sizeof(fakeAddress));
            fakeAddress.sin_len = sizeof(fakeAddress);
            fakeAddress.sin_family = AF_INET;
            
            mReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *) &fakeAddress);
        }
        else {
            mReachability = SCNetworkReachabilityCreateWithName(NULL, [NgnStringUtils toCString:self.reachabilityHostName]);
        }
        
		if (mReachability == NULL) {
			err = SCError();
		}
		
		// Set our callback and install on the runloop.
		if (err == 0) {
			ok = SCNetworkReachabilitySetCallback(mReachability, NgnNetworkReachabilityCallback, &mReachabilityContext);
			if (! ok) {
				err = SCError();
			}
		}
		if (err == 0) {
			ok = SCNetworkReachabilityScheduleWithRunLoop(mReachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
			if (! ok) {
				err = SCError();
			}
		}
		
		if (err == 0) {
			SCNetworkConnectionFlags flags = 0;
			ok = SCNetworkReachabilityGetFlags(mReachability, &flags);
			
			if (ok) {
				[self setNetworkReachability:NgnConvertFlagsToReachability(flags)];
				[self setNetworkType:NgnConvertFlagsToNetworkType(flags)];
			} else {
				[self setNetworkReachability:NetworkReachability_None];
				[self setNetworkType:NetworkType_None];
				err = SCError();
			}
		}
        else  {
            NgnNSLog(TAG, @"startListening() filed: %d", err);
        }
		return (err == 0);
	}
	return NO;
}

-(BOOL) stopListening{
	if(mReachability){
		(void) SCNetworkReachabilityUnscheduleFromRunLoop(
													  mReachability,
													  CFRunLoopGetCurrent(),
													  kCFRunLoopDefaultMode
													  );
		CFRelease(mReachability), mReachability = NULL;
	}
	return YES;
}

-(void) setNetworkReachability:(NgnNetworkReachability_t)reachability_{
	mNetworkReachability = reachability_;
}

-(void) setNetworkType:(NgnNetworkType_t)networkType_{
	mNetworkType = networkType_;
}

@end



//
// default implementation
//

@implementation NgnNetworkService

-(NgnNetworkService*)init{
	if((self = [super init])){
		mNetworkType = NetworkType_None;
		mNetworkReachability = NetworkReachability_None;
		NSString* hostName = kReachabilityHostName;
		mReachabilityHostName = [hostName retain];
		
		mReachabilityContext.version         = 0;
		mReachabilityContext.info            = self;
		mReachabilityContext.retain          = NULL;
		mReachabilityContext.release         = NULL;
		mReachabilityContext.copyDescription = NULL;
		
	}
	return self;
}

//
// IBaseService
//

-(BOOL) start{
	NgnNSLog(TAG, @"Start()");
	
	// reset current values
	mNetworkType = NetworkType_None;
	mNetworkReachability = NetworkReachability_None;
	
	mStarted = [self startListening];
	
	return mStarted;
}

-(BOOL) stop{
	NgnNSLog(TAG, @"Stop()");
	return YES;
}

//
// INgnNetworkService
//

-(NSString*)getReachabilityHostName{
	return mReachabilityHostName;
}

-(void)setReachabilityHostName:(NSString*)hostName{
	[mReachabilityHostName release];
	mReachabilityHostName = [hostName retain];
	
	if(mStarted && mReachabilityHostName){
		[self startListening];
	}
}

-(NgnNetworkType_t) getNetworkType{
	return mNetworkType;
}

-(NgnNetworkReachability_t) getReachability{
	return mNetworkReachability;
}
-(BOOL) isReachable{
	return (mNetworkReachability & NetworkReachability_Reachable)
#if TARGET_OS_MAC || TARGET_IPHONE_SIMULATOR
	&& !(mNetworkReachability & NetworkReachability_ConnectionRequired)
#endif
	;
}
-(BOOL) isReachable:(NSString*)hostName {
    BOOL reachable = NO;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName cStringUsingEncoding:NSASCIIStringEncoding]);
    if (reachability) {
        SCNetworkReachabilityFlags flags;
        reachable = (SCNetworkReachabilityGetFlags(reachability, &flags) == true) && (flags & kSCNetworkFlagsReachable)
#if TARGET_OS_MAC || TARGET_IPHONE_SIMULATOR
        && !(flags & kSCNetworkFlagsConnectionRequired)
#endif
        ;
        CFRelease(reachability);
    }
    return reachable;
}
-(void)dealloc{
	[self stopListening];
	
	[mReachabilityHostName release];
	
	[super dealloc];
}

@end
