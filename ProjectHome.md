This application uses [Doubango Framework](http://www.doubango.org/).
<br />

<font color='green' size='2'>
<strong>iDoubs v2.x-preview (beta) is now available for developers</strong><br />
The source code is under <strong>branches/2.0</strong> and depends on <strong>doubango v2.x</strong><br />
To build the source code: <a href='http://code.google.com/p/idoubs/wiki/Building_iDoubs_v2_x'>http://code.google.com/p/idoubs/wiki/Building_iDoubs_v2_x</a>
<br />
New features: <br />
- The SIP/IMS Stack is 7 times faster<br />
- NGN (Next Generation Network) stack for developers (<strong>ios-ngn-stack</strong> and <strong>osx-ngn-stack</strong>)<br />
- Add support for MAC OS X<br />
- Both TCP and UDP (Keep Awake) multitasking for iOS4+<br />
- Full HD (1080p) video<br />
- NAT Traversal using ICE<br />
- Adds support for TLS, SRTP and RTCP<br />
- Crystal clear audio  quality (adaptive jitter buffer, echo cancellation, noise suppression, automatic resampling, gain control, ...)<br />
- Better video quality (low latency, low cpu usage, ...)<br />
- Audio codecs:  Opus, G.722, G.729AB, AMR-NB, iLBC, GSM, PCMA, PCMU, Speex-NB, Speex-WB, Speex-UWB<br />
- Video codecs: . VP8, H264, MP4V-ES, Theora, H.263, H.263-1998<br />
- Chat (SMS-like)<br />
- Favorites<br />
- Fix many issues (video rotation, compilation, user interface, ...)<br />
- and much more features<br />
</font>



## Introduction ##

[3GPP IMS](http://en.wikipedia.org/wiki/IP_Multimedia_Subsystem) (IP Multimedia Subsystem) is the next generation network for delivering IP multimedia services. IMS is standardized by the 3rd Generation Partnership Project (3GPP).
IMS services could be used over any type of network, such as [3GPP LTE](http://en.wikipedia.org/wiki/3GPP_Long_Term_Evolution), GPRS, Wireless LAN, CDMA2000 or fixed line. <br />

[iDoubs v2.x](http://code.google.com/p/idoubs/) is the first fully featured open source 3GPP IMS Client for iOS devices (iPhone, iPod Touch and iPad). The main purpose of the project is to exhibit [doubango](http://doubango.org)'s features and to offer an IMS client to the open source community. [doubango](http://doubango.org) is an experimental, open source, 3GPP IMS/LTE framework for both embedded (Android, Windows Mobile, Symbian, iPhone, iPad, ...) and desktop systems (Windows XP/Vista/7, MAC OS X, Linux, ...) and is written in ANSI-C to ease portability. The framework has been carefully designed to efficiently work on embedded systems with limited memory and low computing power. <br />
As the SIP implementation follows [RFC 3261](http://www.ietf.org/rfc/rfc3261.txt) and [3GPP TS 24.229 Rel-9](http://www.3gpp.org/ftp/Specs/html-info/24229.htm) specifications, this will allow you to connect to any compliant SIP registrar. <br />

The current version of [iDoubs](http://code.google.com/p/idoubs/) partially implements [GSMA Rich Communication Suite release 3](http://www.gsmworld.com/our-work/mobile_lifestyle/rcs/index.htm) and [The One Voice profile V1.0.0](http://news.vzw.com/OneVoiceProfile.pdf) (LTE/4G, also known as [GSMA VoLTE](http://www.gsmworld.com/our-work/mobile_broadband/VoLTE.htm)) specifications. Missing features will be implemented in the next releases. **Stay tuned**.<br /><br />

## Getting Started ##
  * To build the source code of iDoubs v2.x: [http://code.google.com/p/idoubs/wiki/Building\_iDoubs\_v2\_x](http://code.google.com/p/idoubs/wiki/Building_iDoubs_v2_x)
  * Developer's Guide (work in progress): [http://code.google.com/p/idoubs/wiki/DevelopersGuide](http://code.google.com/p/idoubs/wiki/DevelopersGuide)
  * To configure the client: [http://code.google.com/p/idoubs/wiki/UserGuide](http://code.google.com/p/idoubs/wiki/UserGuide)

## Screenshots ##
### iOS ###
<table cellpadding='3'>
<tr>
<td align='center'><img src='http://idoubs.googlecode.com/svn/branches/2.0/screenshots/background_invite.png' /></td>
<td align='center'><img src='http://idoubs.googlecode.com/svn/branches/2.0/screenshots/videocall_incoming.png' /></td>
<td align='center'><img src='http://idoubs.googlecode.com/svn/branches/2.0/screenshots/videocall_incall.png' /></td>
<td align='center'><img src='http://idoubs.googlecode.com/svn/branches/2.0/screenshots/videocall_outgoing.png' /></td>
</tr>
<tr>
<td align='center'><b>Receiving call(on background)</b></td>
<td align='center'><b>Incoming call</b></td>
<td align='center'><b>In call</b></td>
<td align='center'><b>Outgoing call</b></td>
</tr>
<tr>
<td align='center'><img src='http://idoubs.googlecode.com/svn/branches/2.0/screenshots/numpad.png' /></td>
<td align='center'><img src='http://idoubs.googlecode.com/svn/branches/2.0/screenshots/audiocall.png' /></td>
<td align='center'><img src='http://idoubs.googlecode.com/svn/branches/2.0/screenshots/messages.png' /></td>
<td align='center'><img src='http://idoubs.googlecode.com/svn/branches/2.0/screenshots/chat.png' /></td>
</tr>
<tr>
<td align='center'><b>Dialer</b></td>
<td align='center'><b>Audio Call</b></td>
<td align='center'><b>Synthesized view of the messages</b></td>
<td align='center'><b>Chat screen</b></td>
</tr>
<tr>
<td align='center'><img src='http://idoubs.googlecode.com/svn/branches/2.0/screenshots/contacts.png' /></td>
<td align='center'><img src='http://idoubs.googlecode.com/svn/branches/2.0/screenshots/favorites.png' /></td>
<td align='center'><img src='http://idoubs.googlecode.com/svn/branches/2.0/screenshots/recents.png' /></td>
</tr>
<tr>
<td align='center'><b>Address Book with presence info</b></td>
<td align='center'><b>Favorites</b></td>
<td align='center'><b>Recents</b></td>
</tr>
</table>
<br />
### MAC OSX ###
<table cellpadding='3'>
<tr>
<td align='center'><img src='http://idoubs.googlecode.com/svn/branches/2.0/screenshots/osx-videocall.png' /></td>
<td align='center'><img src='http://idoubs.googlecode.com/svn/branches/2.0/screenshots/osx-history.png' /></td>><br>
</tr>
<tr>
<td align='center'><b>Video Call screen (MAC OS X)</b></td>
<td align='center'><b>History Screen (MAC OS X)</b></td>
</tr>
</table>
<br />

## GSMA RCS ##
[doubango](http://doubango.org) partially support [GSMA RCS](http://www.gsmworld.com/our-work/mobile_lifestyle/rcs/gsma_rcs_project.htm) as defined in release 3. The core features will be fully implemented in the next major release.

## One Voice Profile (GSMA VoLTE) ##
Some features of the [One Voice Profile](http://news.vzw.com/OneVoiceProfile.pdf) are implemented in this version (v1.0.0) and the other will be added in the coming releases.<br /><br />
![http://imsdroid.googlecode.com/svn/banches/2.0/screenshots/LTE_Architecture.png](http://imsdroid.googlecode.com/svn/banches/2.0/screenshots/LTE_Architecture.png)
<br /><br />
Already implemented: <br />
  * 5.2.1 SIP Registration Procedures
  * 5.2.2 Authentication
  * 5.2.3 Addressing
  * 5.2.4 Call establishment and termination
  * 5.2.6 Tracing of Signalling
  * 5.2.7 The use of Signalling Compression
  * 5.3 Supplementary services (Communication Hold 3GPP TS 24.610, Message Waiting Indication 3GPP TS 24.606, Communication Barring 3GPP TS 24.611)
  * 5.4.1 SIP Precondition Considerations
  * 5.4.4 Multimedia Considerations
  * 5.5 SMS over IP
  * 6.2.1 Codecs
  * 6.2.5 AMR Payload Format Considerations


<br />
<br />
**© 2010-2012 Doubango Telecom** <br />
_Inspiring the future_