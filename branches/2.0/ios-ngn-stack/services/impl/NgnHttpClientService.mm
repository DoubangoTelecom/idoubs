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
#import "INgnHttpClientService.h"
#import "NgnHttpClientService.h"

#undef TAG
#define kTAG @"NgnHttpClientService///: "
#define TAG kTAG

#define kRequestTypeGET @"GET"
#define kRequestTypePOST @"POST"

@implementation NgnHttpClientService

//
// INgnBaseService
//

-(BOOL) start{
	NgnNSLog(TAG, @"Start()");
	return YES;
}

-(BOOL) stop{
	NgnNSLog(TAG, @"Stop()");
	return YES;
}


//
// INgnHttpClientService
//

-(NSData*) getSynchronously:(NSString*)uri{	
	NgnNSLog(TAG, @"getSynchronously(%@)", uri);
	
	NSError *error = nil;
	NSData *data = nil;
	NSURLResponse *response = nil;
	
	// create the HTTP GET the request
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:uri]];
	[request setHTTPMethod: kRequestTypeGET];
	
	// perform the query
	data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NgnNSLog(TAG, @"getSynchronously() returned %i", [((NSHTTPURLResponse *)response) statusCode]);
	
	return data;
}

-(NSData*) postSynchronously:(NSString*) uri withContentData:(NSData*)contentData withContentType:(NSString*)contentType{
	NgnNSLog(TAG, @"postSynchronously(uri=%@,contentType=%@)", uri, contentType);
	
	NSError *error = nil;
	NSData *data = nil;
	NSURLResponse *response = nil;
	
	// create the the POST request
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:uri]];
	[request setHTTPMethod: kRequestTypePOST];
	[request setHTTPBody:contentData];
	if(contentData){
		[request setValue:contentType forHTTPHeaderField:@"Content-Type"];
	}
	
	// perform the query
	data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NgnNSLog(TAG, @"postSynchronously() returned %i", [((NSHTTPURLResponse *)response) statusCode]);
	
	return data;
}

@end
