iMAS - PasscodeCheck Security Control
=====================================


Short Description
=================

iOS does not offer a simple API check for developers to assess the security level of an iOS device.  iMAS - PasscodeCheck security control offers open source code, which can be easily added to any iOS application bundle and release process.

Background
==========

iOS does not offer a simple API or library that a developer can programmatically call to confirm whether or not the system passcode is set. If it is set, is it complex, specifically more complex than a simple 4 digit passcode? Without this assurance, an iOS application could be vulnerable to data theft stemming from inadequate application security. This is based on the scenario where an attacker gains physical access to an iOS device, either from an owner losing their device, temporary loss due to the device being serviced, or actual theft of the device. Once an iOS device is in the hands of an attacker, without a passcode or a simple 4-digit passcode on the device, the attacker will be able to bruteforce the passcode with ease. Once the passcode is known, the device can be unlocked, jailbroken, and application data easily stolen. This vulnerability can be reduced considerably with the use of a complex passcode, that is, one that is at least 6 digits in length and alphanumeric. Given this scenario, an iOS application developer does not have any mechanism to assess if an app is running in a marginally secure or a verified secure environment.

iMAS has researched and implemented a system passcode check library and process that can be easily added to any iOS application bundle and release process. 
 

Vulnerabilities Addressed
=========================

1. No system passcode set on iOS device
2. 4-digit system passcode set on iOS device
3. Finger smudge on screen attack
4. Jailbreak and passcode bruteforce attack

Design
======

The PasscodeCheck security check is implemented using the Certificate, Key, and Trust services provided in the Security.framework. Essentially, a configuration profile is created which contains the specific password policies for the device.  One can make the restrictions simple or very extensive.  For our tests, we created a config profile which forces a 6 digit passcode.  The configuration profile would then be installed on a device.  During install, iOS reads the profile and then enforces the new passcode requirements - requiring the user to enter a 6 digit passcode.  At this point, the device is more secure, so why do anymore?  Well, from an application it is impossible to tell if a particular configuraiton profile is installed and doubly impossible to programatically figure out the details of the config profile.  Hence the need for the certificate bundling and validation.  So, the next steps require a self-signed root certificate and a leaf certificate be created.  The root cert is bundled with the configuration profile at creation time.  The leaf certificate is bundled with the iOS application.  Finally, the application can use iMAS PasscodeCheck to confirm the leaf cert is present, and then confirm its signatures match with the root cert.  If all checks validate, then PasscodeCheck isPasscodeSet returns a boolean true otherwise false.    


The developer/organization creates a self-signed root certificate and then creates a leaf certificate from the root certificate.  Must be in DER format, openssl default appears to be PEM.  Use iPhone configuration tool, create a configuration profile, Establish a complex passcode requirement, and any other requirement.  Add the ROOT cert file to the configuration profile, ensure DER format.  Connect the iOS device to the computer then from the iphone config tool install the ROOT cert (with a remove anytime or password to remove option).  This installs the root cert in the trusted root store on the device, not the app keychain.  Bundle leaf cert with app by including in the project.  On each app run, read the leaf cert and validate with installed ROOT cert.  If ROOT cert is present, then validate which returns a  5 is kSecTrustResultRecoverableTrustFailure and 4 is kSecTrustResultUnspecified (4 is good, this says ROOT cert is installed, which says config profile is being enforced.


API and use
===========  

iMAS_PasscodeCheck contains one, static method called isPasscodeSet that returns a boolean.  The return value indicates true, if the complex passcode config profile is installed (thus a complex passcode is in use on the device), and indicates false if anywhere in the validation process fails.

To use this security control:
   1.  Copy its files (.h and .m) to your iOS application project
       - Make the call to isPasscodeSet
       - Based on the return value, one can decide whether to continue use of the application, halt the app, or run in a degraded mode.  
   2.  Create a root and leaf cert, or use the provided certs on this site. 
   3.  Use the iPhone Configuration Tool, and create a configuration profile with an appropriate passcode policy, or use the config profile provided on this site
   4.  Bundle the root cert with your config profile
   5.  Bundle the leaf cert with the application
   5.  Install the config profile on the device(s)
   6.  Compile, build, and test app with PasscodeCheck code in place

SEND US FEEDBACK OF USE and/or FIXES !!!

Certificate Details
===================

The developer/organization creates a self-signed root certificate and then creates a leaf certificate from the root certificate.  Must be in DER format, openssl default appears to be PEM.  Use iPhone configuration tool, create a configuration profile, Establish a complex passcode requirement, and any other requirement.  Add the ROOT cert file to the configuration profile, ensure DER format.  Connect the iOS device to the computer then from the iphone config tool install the ROOT cert (with a remove anytime or password to remove option).  This installs the root cert in the trusted root store on the device, not the app keychain.  Bundle leaf cert with app by including in the project.  On each app run, read the leaf cert and validate with installed ROOT cert.  If ROOT cert is present, then validate which returns a  5 is kSecTrustResultRecoverableTrustFailure and 4 is kSecTrustResultUnspecified (4 is good, this says ROOT cert is installed, which says config profile is being enforced.


Big help from this blog posting:
http://blog.didierstevens.com/2008/12/30/howto-make-your-own-cert-with-openssl

First we generate a 4096-bit long RSA key for our root CA and store it in file ca.key:
<pre>
openssl genrsa -out ca.key 4096
</pre>

If you want to password-protect this key, add option -des3. Next, we create our self-signed root CA certificate ca.crt; you’ll need to provide an identity for your root CA. The -x509 option is used for a self-signed certificate. 1826 days gives us a cert valid for 5 years.

<pre>
## ROOT CERT
openssl req -new -x509 -days 1826 -key ca.key -out ca.crt

Country Name (2 letter code) [AU]:US
State or Province Name (full name) [Some-State]:Massachusetts
Locality Name (eg, city) []:Bedford
Organization Name (eg, company) [Internet Widgits Pty Ltd]:MITRE
Organizational Unit Name (eg, section) []:iMAS
Common Name (eg, YOUR name) []:Fred Smith
Email Address []:f@smith.com
[  ~/projs/imas/certs ] $ ll
total 16
-rw-r--r--  1   staff  2317 Nov  8 10:48 ca.crt
-rw-r--r--  1   staff  3243 Nov  8 10:46 ca.key
</pre>

Next step: create our subordinate CA that will be used for the actual signing. First, generate the key:
<pre>
## INTERMEDIATE / LEAF / Derived Cert
openssl genrsa -out ia.key 4096

## Then, request a certificate signing request (CSR) for this subordinate CA:
openssl req -new -key ia.key -out ia.csr

Country Name (2 letter code) [AU]:US
State or Province Name (full name) [Some-State]:Massachusetts
Locality Name (eg, city) []:Bedford
Organization Name (eg, company) [Internet Widgits Pty Ltd]:MITRE
Organizational Unit Name (eg, section) []:iMAS sub cert
Common Name (eg, YOUR name) []:Tom Smith
Email Address []:t@smith.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:mitre1
An optional company name []:      
[  ~/projs/imas/certs ] $ ll
total 32
-rw-r--r--  1   staff  2317 Nov  8 10:48 ca.crt
-rw-r--r--  1   staff  3243 Nov  8 10:46 ca.key
-rw-r--r--  1   staff  1785 Nov  8 10:52 ia.csr
-rw-r--r--  1   staff  3239 Nov  8 10:50 ia.key
</pre>

Next step: process the request for the subordinate CA certificate and get it signed by the root CA
<pre>
openssl x509 -req -days 730 -in ia.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out ia.crt
</pre>

The cert will be valid for 2 years (730 days) and I decided to choose my own serial number 01 for this cert (-set_serial 01). For the root CA, I let OpenSSL generate a random serial number.

<pre>
Signature ok
subject=/C=US/ST=Massachusetts/L=Bedford/O=MITRE/OU=iMAS sub cert/CN=Tom Smith/emailAddress=t@smith.com
Getting CA Private Key
[  ~/projs/imas/certs ] $ lr
total 40
drwxr-xr-x  29 staff   986 Nov  2 15:07 ..
-rw-r--r--   1 staff  3243 Nov  8 10:46 ca.key
-rw-r--r--   1 staff  2317 Nov  8 10:48 ca.crt
-rw-r--r--   1 staff  3239 Nov  8 10:50 ia.key
-rw-r--r--   1 staff  1785 Nov  8 10:52 ia.csr
-rw-r--r--   1 staff  1984 Nov  8 10:54 ia.crt


## Display the contents of a certificate:
openssl x509 -in ca.crt -noout -text

## convert PEM to DER
openssl x509 -in ca.crt -inform PEM -out ca.der -outform DER
openssl x509 -in ca.der -inform DER -noout -text
mv ca.der iMAS_RootCA.der

openssl x509 -in ia.crt -inform PEM -out ia.der -outform DER
openssl x509 -in ia.der -inform DER -noout -text
mv ia.der passcodeCheckCert.der
</pre>


License
=======

Copyright 2012 The MITRE Corporation, All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
