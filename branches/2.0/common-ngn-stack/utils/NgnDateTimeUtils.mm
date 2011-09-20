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
#import "NgnDateTimeUtils.h"


@implementation NgnDateTimeUtils


+(NSDateFormatter*) historyEventDuration{
	static NSDateFormatter* sHistoryEventDuration = nil;
	if(!sHistoryEventDuration){
		sHistoryEventDuration = [[NSDateFormatter alloc] init];
        [sHistoryEventDuration setDateFormat:@"mm:ss"];
	}
	return sHistoryEventDuration;
}

+(NSDateFormatter*) historyEventDate{
	static NSDateFormatter* sHistoryEventDate = nil;
	if(!sHistoryEventDate){
		sHistoryEventDate = [[NSDateFormatter alloc] init];
        [sHistoryEventDate setTimeStyle:NSDateFormatterNoStyle];
        [sHistoryEventDate setDateStyle:NSDateFormatterMediumStyle];
	}
	return sHistoryEventDate;
}

+(NSDateFormatter*) chatDate{
	static NSDateFormatter* sChatDate = nil;
	if(!sChatDate){
		sChatDate = [[NSDateFormatter alloc] init];
        [sChatDate setDateFormat:@"MMMM dd, yyyy HH:mm"];
	}
	return sChatDate;
}

+(NSDateFormatter*) historyEventTime
{
	static NSDateFormatter* sTime = nil;
	if(!sTime){
		sTime = [[NSDateFormatter alloc] init];
        [sTime setDateFormat:@"HH:mm"];
	}
	return sTime;
}

@end
