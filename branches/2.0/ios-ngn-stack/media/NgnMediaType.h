#ifndef NGN_MEDIATYPE_H
#define NGN_MEDIATYPE_H

typedef enum NgnMediaType_e {
	MediaType_None = 0,
	MediaType_Audio = (0x01<<0),
	MediaType_Video = (0x01<<1),
	MediaType_AudioVideo = MediaType_Audio | MediaType_Video,
	MediaType_SMS = (0x01<<2),
	MediaType_Chat = (0x01<<3),
	MediaType_FileTransfer = (0x01<<4),
	MediaType_Msrp = MediaType_Chat | MediaType_FileTransfer,
}
NgnMediaType_t;

static bool isAudioVideoType(NgnMediaType_t type){
	return (type & MediaType_AudioVideo);
}
static bool isVideoType(NgnMediaType_t type){
	return (type & MediaType_Video);
}
static bool isFileTransfer(NgnMediaType_t type){
	return type == MediaType_FileTransfer;
}
static bool isChat(NgnMediaType_t type){
	return type == MediaType_Chat;
}
static bool isMsrpType(NgnMediaType_t type){
	return (type & MediaType_Msrp);
}


#endif /* NGN_MEDIATYPE_H */
