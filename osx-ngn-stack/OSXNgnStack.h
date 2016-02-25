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
#ifndef OSX_NGN_STACK_API_H
#define OSX_NGN_STACK_API_H

#import "OSXNgnConfig.h"

#import "NgnEngine.h"

#import "utils/NgnConfigurationEntry.h"
#import "utils/NgnStringUtils.h"
#import "utils/NgnUriUtils.h"
#import "utils/NgnPredicate.h"
#import "utils/NgnDateTimeUtils.h"
#import "utils/NgnNotificationCenter.h"
#import "utils/NSDate+Utilities.h"

#import "events/NgnRegistrationEventArgs.h"
#import "events/NgnStackEventArgs.h"
#import "events/NgnInviteEventArgs.h"
#import "events/NgnMessagingEventArgs.h"
#import "events/NgnSubscriptionEventArgs.h"
#import "events/NgnPublicationEventArgs.h"
#import "events/NgnHistoryEventArgs.h"
#import "events/NgnFavoriteEventArgs.h"
#import "events/NgnContactEventArgs.h"
#import "events/NgnNetworkEventArgs.h"

#import "sip/NgnRegistrationSession.h"
#import "sip/NgnAVSession.h"
#import "sip/NgnMessagingSession.h"
#import "sip/NgnSubscriptionSession.h"
#import "sip/NgnPublicationSession.h"
#import "sip/NgnPresenceStatus.h"

#import "model/NgnContact.h"
#import "model/NgnPhoneNumber.h"
#import "model/NgnHistoryEvent.h"
#import "model/NgnHistorySMSEvent.h"
#import "model/NgnHistoryAVCallEvent.h"
#import "model/NgnFavorite.h"

#import "media/NgnMediaType.h"
#import "media/NgnContentType.h"
#import "media/NgnEventPackageType.h"
#import "media/NgnCamera.h"
#import "media/NgnVideoView.h"

#endif /* OSX_NGN_STACK_API_H */

