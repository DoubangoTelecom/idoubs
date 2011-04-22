#import <Foundation/Foundation.h>


#ifndef NGNCONFIGURATIONENTRY_H
#define NGNCONFIGURATIONENTRY_H

static const NSString* PCSCF_DISCOVERY_DNS_SRV = "DNS_NAPTR_SRV";

// General
static const NSString* GENERAL_AUTOSTART = "GENERAL_AUTOSTART";
static const NSString* GENERAL_SHOW_WELCOME_SCREEN = "GENERAL_SHOW_WELCOME_SCREEN";
static const NSString* GENERAL_FULL_SCREEN_VIDEO = "GENERAL_FULL_SCREEN_VIDEO";
static const NSString* GENERAL_USE_FFC = "GENERAL_USE_FFC";
static const NSString* GENERAL_INTERCEPT_OUTGOING_CALLS = "GENERAL_INTERCEPT_OUTGOING_CALLS";
static const NSString* GENERAL_VIDEO_FLIP = "GENERAL_VIDEO_FLIP";
static const NSString* GENERAL_AUDIO_PLAY_LEVEL = "GENERAL_AUDIO_PLAY_LEVEL";
static const NSString* GENERAL_ENUM_DOMAIN = "GENERAL_ENUM_DOMAIN";

// Identity
static const NSString* IDENTITY_DISPLAY_NAME = "IDENTITY_DISPLAY_NAME";
static const NSString* IDENTITY_IMPU = "IDENTITY_IMPU";
static const NSString* IDENTITY_IMPI = "IDENTITY_IMPI";
static const NSString* IDENTITY_PASSWORD = "IDENTITY_PASSWORD";

// Network
static const NSString* NETWORK_REGISTRATION_TIMEOUT = "NETWORK_REGISTRATION_TIMEOUT";
static const NSString* NETWORK_REALM = "NETWORK_REALM";
static const NSString* NETWORK_USE_WIFI = "NETWORK_USE_WIFI";
static const NSString* NETWORK_USE_3G = "NETWORK_USE_3G";
static const NSString* NETWORK_USE_EARLY_IMS = "NETWORK_USE_EARLY_IMS";
static const NSString* NETWORK_IP_VERSION = "NETWORK_IP_VERSION";
static const NSString* NETWORK_PCSCF_DISCOVERY = "NETWORK_PCSCF_DISCOVERY";
static const NSString* NETWORK_PCSCF_HOST = "NETWORK_PCSCF_HOST";
static const NSString* NETWORK_PCSCF_PORT = "NETWORK_PCSCF_PORT";
static const NSString* NETWORK_USE_SIGCOMP = "NETWORK_USE_SIGCOMP";
static const NSString* NETWORK_TRANSPORT = "NETWORK_TRANSPORT";

// NAT Traversal
static const NSString* NATT_HACK_AOR = "NATT_HACK_AOR";
static const NSString* NATT_HACK_AOR_TIMEOUT = "NATT_HACK_AOR_TIMEOUT";
static const NSString* NATT_USE_STUN = "NATT_USE_STUN";
static const NSString* NATT_USE_ICE = "NATT_USE_ICE";
static const NSString* NATT_STUN_DISCO = "NATT_STUN_DISCO";
static const NSString* NATT_STUN_SERVER = "NATT_STUN_SERVER";
static const NSString* NATT_STUN_PORT = "NATT_STUN_PORT";

// QoS
static const NSString* QOS_PRECOND_BANDWIDTH = "QOS_PRECOND_BANDWIDTH";
static const NSString* QOS_PRECOND_STRENGTH = "QOS_PRECOND_STRENGTH";
static const NSString* QOS_PRECOND_TYPE = "QOS_PRECOND_TYPE";
static const NSString* QOS_REFRESHER = "QOS_REFRESHER";
static const NSString* QOS_SIP_CALLS_TIMEOUT = "QOS_SIP_CALLS_TIMEOUT";
static const NSString* QOS_SIP_SESSIONS_TIMEOUT = "QOS_SIP_SESSIONS_TIMEOUT";
static const NSString* QOS_USE_SESSION_TIMERS = "QOS_USE_SESSION_TIMERS";


// Media
static const NSString* MEDIA_CODECS = "MEDIA_CODECS";
static const NSString* MEDIA_AUDIO_RESAMPLER_QUALITY = "MEDIA_AUDIO_RESAMPLER_QUALITY";
static const NSString* MEDIA_AUDIO_CONSUMER_GAIN = "MEDIA_AUDIO_CONSUMER_GAIN";
static const NSString* MEDIA_AUDIO_PRODUCER_GAIN = "MEDIA_AUDIO_PRODUCER_GAIN";
static const NSString* MEDIA_AUDIO_CONSUMER_ATTENUATION = "MEDIA_AUDIO_CONSUMER_ATTENUATION";
static const NSString* MEDIA_AUDIO_PRODUCER_ATTENUATION = "MEDIA_AUDIO_PRODUCER_ATTENUATION";

// Security
static const NSString* SECURITY_IMSAKA_AMF = "SECURITY_IMSAKA_AMF";
static const NSString* SECURITY_IMSAKA_OPID = "SECURITY_IMSAKA_OPID";

// XCAP
static const NSString* XCAP_PASSWORD = "XCAP_PASSWORD";
static const NSString* XCAP_USERNAME = "XCAP_USERNAME";
static const NSString* XCAP_ENABLED = "XCAP_ENABLED";
static const NSString* XCAP_XCAP_ROOT = "XCAP_XCAP_ROOT";

// RCS (Rich Communication Suite)
static const NSString* RCS_AVATAR_PATH = "RCS_AVATAR_PATH";
static const NSString* RCS_USE_BINARY_SMS = "RCS_USE_BINARY_SMS";
static const NSString* RCS_CONF_FACT = "RCS_CONF_FACT";
static const NSString* RCS_FREE_TEXT = "RCS_FREE_TEXT";
static const NSString* RCS_HACK_SMS = "RCS_HACK_SMS";
static const NSString* RCS_USE_MSRP_FAILURE = "RCS_USE_MSRP_FAILURE";
static const NSString* RCS_USE_MSRP_SUCCESS = "RCS_USE_MSRP_SUCCESS";
static const NSString* RCS_USE_MWI = "RCS_USE_MWI"
static const NSString* RCS_USE_OMAFDR = "RCS_USE_OMAFDR";
static const NSString* RCS_USE_PARTIAL_PUB = "RCS_USE_PARTIAL_PUB";
static const NSString* RCS_USE_PRESENCE = "RCS_USE_PRESENCE";
static const NSString* RCS_USE_RLS = "RCS_USE_RLS";
static const NSString* RCS_SMSC = "RCS_SMSC";
static const NSString* RCS_STATUS  = "RCS_STATUS";


//
//      Default values
//

// General
static const BOOL DEFAULT_GENERAL_SHOW_WELCOME_SCREEN = true;
static const BOOL DEFAULT_GENERAL_FULL_SCREEN_VIDEO = true;
static const BOOL DEFAULT_GENERAL_INTERCEPT_OUTGOING_CALLS = true;
static const BOOL DEFAULT_GENERAL_USE_FFC = true;
static const BOOL DEFAULT_GENERAL_FLIP_VIDEO = false;
static const BOOL DEFAULT_GENERAL_AUTOSTART = true;
static const float DEFAULT_GENERAL_AUDIO_PLAY_LEVEL = 0.25f;
static const NSString* DEFAULT_GENERAL_ENUM_DOMAIN = "e164.org";

//      Identity
static const NSString* DEFAULT_IDENTITY_DISPLAY_NAME = "John Doe";
static const NSString* DEFAULT_IDENTITY_IMPU = "sip:johndoe@doubango.org";
static const NSString* DEFAULT_IDENTITY_IMPI = "johndoe";
static const NSString* DEFAULT_IDENTITY_PASSWORD = null;

// Network
static int DEFAULT_NETWORK_REGISTRATION_TIMEOUT = 1700;
static const NSString* DEFAULT_NETWORK_REALM = "doubango.org";
static BOOL DEFAULT_NETWORK_USE_WIFI = true;
static BOOL DEFAULT_NETWORK_USE_3G = false;
static const NSString* DEFAULT_NETWORK_PCSCF_DISCOVERY = "None";
static const NSString* DEFAULT_NETWORK_PCSCF_HOST = "127.0.0.1";
static int DEFAULT_NETWORK_PCSCF_PORT = 5060;
static BOOL DEFAULT_NETWORK_USE_SIGCOMP = false;
static const NSString* DEFAULT_NETWORK_TRANSPORT = "udp";
static const NSString* DEFAULT_NETWORK_IP_VERSION = "ipv4";
static BOOL DEFAULT_NETWORK_USE_EARLY_IMS = false;


// NAT Traversal
static int DEFAULT_NATT_HACK_AOR_TIMEOUT = 2000;
static BOOL DEFAULT_NATT_HACK_AOR = false;
static BOOL DEFAULT_NATT_USE_STUN = false;
static BOOL DEFAULT_NATT_USE_ICE = false;
static BOOL DEFAULT_NATT_STUN_DISCO = false;
static const NSString* DEFAULT_NATT_STUN_SERVER = "numb.viagenie.ca";
static int DEFAULT_NATT_STUN_PORT = 3478;

// QoS
static const NSString* DEFAULT_QOS_PRECOND_BANDWIDTH = "Low";
static const NSString* DEFAULT_QOS_PRECOND_STRENGTH = tmedia_qos_strength_t.tmedia_qos_strength_none.toString();
static const NSString* DEFAULT_QOS_PRECOND_TYPE = tmedia_qos_stype_t.tmedia_qos_stype_none.toString();
static const NSString* DEFAULT_QOS_REFRESHER = "none";
static int DEFAULT_QOS_SIP_SESSIONS_TIMEOUT = 600000;
static int DEFAULT_QOS_SIP_CALLS_TIMEOUT = 3600;
static BOOL DEFAULT_QOS_USE_SESSION_TIMERS = false;

// Media
/*public static const int DEFAULT_MEDIA_CODECS = 
tdav_codec_id_t.tdav_codec_id_pcma.swigValue() |
tdav_codec_id_t.tdav_codec_id_pcmu.swigValue() |

tdav_codec_id_t.tdav_codec_id_mp4ves_es.swigValue() |
tdav_codec_id_t.tdav_codec_id_h263p.swigValue() |
tdav_codec_id_t.tdav_codec_id_h263.swigValue();*/
static int DEFAULT_MEDIA_AUDIO_RESAMPLER_QUALITY = 0;
static int DEFAULT_MEDIA_AUDIO_CONSUMER_GAIN = 0; // disabled
static int DEFAULT_MEDIA_AUDIO_PRODUCER_GAIN = 0; // disabled
static float DEFAULT_MEDIA_AUDIO_CONSUMER_ATTENUATION = 1f; // disabled
static float DEFAULT_MEDIA_AUDIO_PRODUCER_ATTENUATION = 1f; // disabled

// Security
public static const NSString* DEFAULT_SECURITY_IMSAKA_AMF = "0x0000";
public static const NSString* DEFAULT_SECURITY_IMSAKA_OPID = "0x00000000000000000000000000000000";

// XCAP
static const BOOL DEFAULT_XCAP_ENABLED = false;
public static const NSString* DEFAULT_XCAP_ROOT = "http://doubango.org:8080/services";
public static const NSString* DEFAULT_XCAP_USERNAME = "sip:johndoe@doubango.org";
public static const NSString* DEFAULT_XCAP_PASSWORD = nil;

// RCS (Rich Communication Suite)
static const NSString* DEFAULT_RCS_AVATAR_PATH = "";
static BOOL DEFAULT_RCS_USE_BINARY_SM = false; 
static const NSString* DEFAULT_RCS_CONF_FACT = "sip:Conference-Factory@doubango.org";
static const NSString* DEFAULT_RCS_FREE_TEXT = "Hello world";
static BOOL DEFAULT_RCS_HACK_SMS = false;
static BOOL DEFAULT_RCS_USE_MSRP_FAILURE = true;
static BOOL DEFAULT_RCS_USE_MSRP_SUCCESS = false;
static BOOL DEFAULT_RCS_USE_BINARY_SMS = false;
static BOOL DEFAULT_RCS_USE_MWI = false;
static BOOL DEFAULT_RCS_USE_OMAFDR = false;
static BOOL DEFAULT_RCS_USE_PARTIAL_PUB = false;
static BOOL DEFAULT_RCS_USE_PRESENCE = false;
static BOOL DEFAULT_RCS_USE_RLS = false;
static const NSString* DEFAULT_RCS_SMSC = "sip:+331000000000@doubango.org";
// static const NgnPresenceStatus DEFAULT_RCS_STATUS = NgnPresenceStatus.Online;


#endif /* NGNCONFIGURATIONENTRY_H */
