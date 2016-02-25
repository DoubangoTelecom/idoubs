

## Introduction ##
**iDoubs v2.x** is a beta version of our ([Doubango Telecom](http://www.doubango.org/)) VoIP client for iOS (iPhone, iPod Touch and iPad) and MAC OS X and is based on [Doubango v2.x](http://code.google.com/p/doubango/source/browse/#svn%2Fbranches%2F2.0) while **iDoubs v1.x** (alpha version) was based on [Doubango v1.x](http://code.google.com/p/doubango/source/browse/#svn%2Ftrunk). <br />

This new version is now split in two parts: **iDoubs v2.x** and **ios-ngn-stack**. <br />
  1. **iDoubs v2.x** is the VoIP client and mostly contain UI related code. It depends on **ios-ngn-stack** project (see below).
  1. **ios-ngn-stack** is our NGN (Next Generation Network)  Framework and contains Objective-C wrappers (around ANSI-C) for **Doubango**.  This framework contains wrappers for the protocol stacks (SIP, MSRP, HTTP, RTP ...), utility services (Database storage, Call log management, Address Book ...). <br />

## Checking out the source code ##

To build the source code you will need: xcode 3.x or later, iOS SDK 4.x or later and svn tools.<br />

  * open new Terminal (Applications => Utilities => Terminal)

  * from the command line, login as root
```
sudo -i
```

  * Create new directory named mydoubs anywhere in your disk:
```
mkdir mydoubs
cd mydoubs
```

  * checkout doubango source code (both trunk and branches) into **mydoubs**. **Important:** The destination folder MUST be named **doubango**:
```
svn checkout http://doubango.googlecode.com/svn/ doubango
```

  * create new folder named **iPhone** into **mydoubs**:
```
mkdir iPhone
cd iPhone
```

  * checkout ios-ngn-stack source code into **iPhone** folder. **Important:** The destination folder MUST be named **idoubs**:
```
svn checkout http://idoubs.googlecode.com/svn/ idoubs
```

  * change **mydoubs** folder permissions:
```
cd ../..
chmod -R 777 mydoubs/*
```

## Building the source code ##
This section explain how to build **Doubango**, the **NGN Stack** and **iDoubs** from xcode.

### Building the NGN Stack ###
As stated in the **Introduction** section, **iDoubs v2.x** depends on the NGN Stack which means that you **MUST** build this target before building **iDoubs** target. <br />
**Note:** **iDoubs** project already contains a reference to the NGN Stack (**ios-ngn-stack**) which means that you can build it directly from **iDoubs**. This is not advised if you are building **iDoubs** for the first time. <br />

  * open **mydoubs/iPhone/idoubs/branches/2.0/ios-ngn-stack/ios-ngn-stack.xcodeproj**
  1. **Very Important:** make sure that the right base sdk is selected (iOS SDK x.y): Right click on **ios-ngn-stack** => **Get Info** => **Build** tab => From **Architectures** group, adjust **Base SDK** and select "iOS x.y" where "x.y" is your preferred version of the iOS SDK
  1. build **Doubango:** Right click on **Doubango** aggregated target and select **Build Doubango**
  1. build the NGN stack: Right click on **ios-ngn-stack** target and select **Build ios-ngn-stack**

You are now ready to build the test applications if you want:
  1. **testRegistration:** to  test SIP registration
  1. **testAudioCall:** to test audio calls
  1. **testVideoCall:** to test video calls
  1. **testMessaging:** to test Instant Messaging (SIP Pager Mode IM)

### Building iDoubs ###
**iDoubs** is the VoIP client and depends on **ios-ngn-stack** target. <br />

  * open **mydoubs/iPhone/idoubs/branches/2.0/ios-idoubs/idoubs.xcodeproj**
  1. **Very Important:** make sure that the right base sdk is selected (iOS SDK x.y): Right click on **ios-ngn-stack** => **Get Info** => **Build** tab => From **Architectures** group adjust **Base SDK** and select "iOS x.y" where "x.y" is your preferred version of the iOS SDK
  1. build **Doubango:** Right click on **Doubango** aggregated target and select **Build Doubango**
  1. build the NGN stack: Right click on **Ngn** target and select **Build Ngn**
  1. build the iDoubs: Right click on **iDoubs** target and select **Build iDoubs**
<br />
Et voilà. You can now run iDoubs. <br />
**Note:** As you have remarked, it's possible to build both the NGN stack and Doubango projects from **iDoubs**. <br />
Before starting to use iDoubs, please take a look at the user guide in order to understand how to configure the client.

### Building non-GPL version ###
If you are license owner then, you can build a non-GPL version of Doubango and iDoubs like this:
  * open **mydoubs/iPhone/idoubs/branches/2.0/ios-idoubs/idoubs.xcodeproj**
  * Right click on **idoubs** target => **Get Info** => **Build** tab => **Other Linker Flags** then:
    1. remove **-lx264**
    1. remove **-lg729b** if you don't have required licenses
    1. replace **-lswscale**, **-lavcore**, **-lavutil** and **-lavcodec** with **-lswscale-lgpl**, **-lavcore-lgpl**, **-lavutil-lgpl** and **-lavcodec-lgpl** respectively

  * open **mydoubs/iPhone/idoubs/branches/2.0/ios-ngn-stack/ios-ngn-stack.xcodeproj**
  * Right click on **ios-ngn-stack** target => **Get Info** => **Build** tab => **Other C Flags** then:
    1. replace **-DHAVE\_H264=1** with **-DHAVE\_H264=0**
    1. replace **-DHAVE\_G729=1** with **-DHAVE\_G729=0** if you don't have required licenses

### Building commercial version ###
If you are license owner then, you can build a commercial version of Doubango and iDoubs like this:
  * open **mydoubs/iPhone/idoubs/branches/2.0/ios-idoubs/idoubs.xcodeproj**
  * Right click on **idoubs** target => **Get Info** => **Build** tab => **Other Linker Flags** then:
    1. remove **-lx264**
    1. remove **-lg729b** if you don't have required licenses
    1. remove **-lswscale**, **-lavcore**, **-lavutil** and **-lavcodec**

  * open **mydoubs/iPhone/idoubs/branches/2.0/ios-ngn-stack/ios-ngn-stack.xcodeproj**
  * Right click on **ios-ngn-stack** target => **Get Info** => **Build** tab => **Other C Flags** then:
    1. replace **-DHAVE\_H264=1** with **-DHAVE\_H264=0**
    1. replace **-DHAVE\_FFMPEG=1** with **-DHAVE\_FFMPEG=0**
    1. replace **-DHAVE\_SWSCALE=1** with **-DHAVE\_SWSCALE=0**
    1. replace **-DHAVE\_G729=1** with **-DHAVE\_G729=0** if you don't have required licenses

### Linking the ios-ngn-stack in your own app ###
1. Place your application code in the same folder than iDoubs: **mydoubs/
iPhone/idoubs/branches/2.0/**. This is not required but it's easier to avoid changing the paths by yourself.<br />
2. Add **ios-ngn-stack** project as reference to your xcode project as explained at [http://www.weston-fl.com/blog/?p=2429](http://www.weston-fl.com/blog/?p=2429)<br />
3. Copy all "User-Defined" settings from iDoubs project (NOT target)
to your application project<br />
4. Copy "Other Linker Flags" value from iDoubs target (NOT project) to
you application target<br />
5. Same as (4) for "Header Search Paths"<br />
6. Same as (4) for "Library Search Paths"<br />

### Technical help ###
Please check our [issue tracker](http://code.google.com/p/webrtc2sip/issues/list) or [developer group](https://groups.google.com/group/doubango) if you have any problem.