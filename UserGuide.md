

# Introduction #

This document is a user guide for **iDoubs** and is intended for End users or testers <br /> If you are a developer and would like more technical information, please take a look on the Developer guide: <br />
This document assume that you already installed the client on you mobile. If you don't have it installed yet please do it. There are three ways to install the client:
  1. For developers: Build the client by yourself using xcode. The process is explained here: [Building\_iDoubs\_v2\_x](Building_iDoubs_v2_x.md)
  1. For beta testers: Please send us your device id and we will send you back the installer (**.ipa).
  1. For end-users: Please download the application from the App Store (not available yet :()**

# Configuration #
This section explain how to configure your credentials in order to connect to your SIP network. <br />

## SIP Account ##
If you are a newbie and don't have a SIP account I recommend using **sip2sip.info**.<br />
To create an account: [https://mdns.sipthor.net/register\_sip\_account.phtml](https://mdns.sipthor.net/register_sip_account.phtml).<br />
In the next section I will consider that the user is using our private IMS network: **doubango.org**.

## All In One ##
Below you have a screenshot showing an overview of the configuration process.<br />
![http://idoubs.googlecode.com/svn/branches/2.0/screenshots/settings_allinone.png](http://idoubs.googlecode.com/svn/branches/2.0/screenshots/settings_allinone.png)

## Configuring your credentials ##
  * From the springboard select **Settings**, scroll down and select **idoubs** from the list as shown below. <br />
![http://idoubs.googlecode.com/svn/branches/2.0/screenshots/goto_settings.png](http://idoubs.googlecode.com/svn/branches/2.0/screenshots/goto_settings.png)

  * From the list of settings, select **Identity** and fill the fields like this (off course you must adjust them to fit your credentials):<br />
![http://idoubs.googlecode.com/svn/branches/2.0/screenshots/settings_identity.png](http://idoubs.googlecode.com/svn/branches/2.0/screenshots/settings_identity.png)

  1. **Public Id** (a.k.a IMS Public Identity or IMPU): As its name says, it’s your public visible identifier where you are willing to receive calls or any demands. An IMPU could be either a SIP or tel URI (e.g. tel:+33100000 or sip:bob@doubango.org). For those using **iDoubs** as a basic SIP client, the IMPU should coincide with their SIP URI (a.k.a SIP address).
  1. **Private Id** (a.k.a IMS Private Identity or IMPI): The IMPI is a unique identifier assigned to a user (or UE) by the home network. It could be either a SIP URI (e.g. sip:bob@doubango.org), a tel URI (e.g. tel:+33100000) or any alphanumeric string (e.g. bob@doubango.org or bob). For those using **iDoubs** as a basic SIP client, the IMPI should coincide with their authentication name. If you don't know what is your IMPI, then fill the field with your SIP address as above.
  1. **Password**: Your password.
  1. **Realm**: The realm is the name of the domain to authenticate to. It should be a valid SIP URI or domain name (e.g. sip:doubango.org or doubango.org).
  1. **3GPP Early IMS**: If you are not using an IMS server you should use this option to disable some heavy IMS authentication procedures.

## Configuring network connection ##
Go back to the settings the select **Network** and fill the fields like this (off course you must adjust them for your own network): <br /><br />
![http://idoubs.googlecode.com/svn/branches/2.0/screenshots/settings_network.png](http://idoubs.googlecode.com/svn/branches/2.0/screenshots/settings_network.png)

  1. **wiFi**: To enable/disable WiFi.
  1. **3G/2.5G**: To enable/disable 3G, 4G (VoLTE) and 2.5G.
  1. **Proxy Host**: This is the IPv4/IPv6 address or FQDN (Fully-Qualified Domain Name) of your SIP server or outbound proxy (e.g. 192.168.0.1 or doubango.org or 2a01:e35:8b32:7050:212:f0ff:fe99:c9fc).
  1. **Proxy Port**: The port associated to the proxy host. Should be **5060**.
  1. **Transport**: The transport type (TCP or UDP) to use. You should use TCP in order to be able to receive incoming calls when the application is running in the background unless you enable the **"Keep-Awake"** option for UDP.
  1. **Enable SigComp**: Whether to enable SIP Signaling Compression. You MUST not enable this option unless your Server supports this feature.

# Running the client #
Now that the client is correctly configured you are ready to start it. Go to the Springboard and select **iDoubs** in order to run the client. <br />
![http://idoubs.googlecode.com/svn/branches/2.0/screenshots/goto_idoubs.png](http://idoubs.googlecode.com/svn/branches/2.0/screenshots/goto_idoubs.png).
<br />
If you have correctly set your credentials then the color of status bar should be green otherwise it'll be grey. <br />

## Configuring NAT Traversal ##

## Managing your favorites ##
### Adding favorites ###
### Deleting favorites ###

## Making Voice calls ##

## Making Video calls ##

## Sending/Receiving files ##

## Sending/Receiving Instant Messages ##