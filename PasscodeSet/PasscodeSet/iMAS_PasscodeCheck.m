//
//  iMAS_isPasscodeSet.m
//  PasscodeSet
//
//  Created by Ganley, Gregg on 12/4/12.
//  Copyright (c) 2012 MITRE Corp. All rights reserved.
//

#import "iMAS_PasscodeCheck.h"



// TODO Should also look for versions greater
#ifndef __IPHONE_8_0
void* kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly = NULL;
#endif


@implementation iMAS_PasscodeCheck


//** is a configuration profile installed that forces the user to set a more rigorous password

+ (Boolean)isPasscodeSet {

    OSStatus            err;
    NSString *          certPath;
    NSData *            certData;
    SecCertificateRef   cert;
    SecPolicyRef        policy;
    SecTrustRef         trust;
    SecTrustResultType  trustResult;
    Boolean             isPasscodeSetResult = FALSE;
    NSError *errorPtr;

    //**
    //** TEST code
    //** Read cert and display contents to console
    //**
    /* 
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"passcodeCheckCert" ofType:@"der"];
    if (filePath) {
     NSString *myText = [NSString stringWithContentsOfFile:filePath];
     NSLog(@"CERT contents = %@", myText);
    }
    */

    //** get path of cert file
    certPath = [[NSBundle mainBundle] pathForResource:@"passcodeCheckCert" ofType:@"der"];
    if (certPath == nil) {
        //** cert not bundled with application, so fail passcode check
        NSLog(@"passcodeCheckCert.der file not found");
        return false;
    }

    //** read cert file data
    certData = [NSData dataWithContentsOfFile: certPath options: 1  error: &errorPtr];
    if (certData == 0) {
        NSLog(@"read failed with error: %@", errorPtr);
        return false;
    }
    
    //** Creates a certificate object from a DER representation of a certificate.
    cert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef) certData);
    if (cert == NULL) {
        NSLog(@"could not create a cert object from cert file!");
        return false;
    }
    
    //** Returns a policy object for the default X.509 policy
    policy = SecPolicyCreateBasicX509();
    if (policy == NULL) {
        NSLog(@"could not retrieve X.509 policy object!");
        return false;
    }

    //** Creates a trust management object based on certificates and policies
    //** Here we pass in the bundled cert which is evaluated against the given X.509 policy
    err = SecTrustCreateWithCertificates((__bridge CFArrayRef) [NSArray arrayWithObject:(__bridge id)cert], policy, &trust);
    if (err != noErr || trust == NULL) {
        NSLog(@"could not create a trust management object!");
        return false;
    }
    //assert(err == noErr);
    //assert(trust != NULL);


    //**
    /* Evaluates trust for the specified certificate and policies.
       The SecTrustEvaluate function validates a certificate by verifying its signature 
       plus the signatures of the certificates in its certificate chain, up to the anchor certificate, 
       according to the policy or policies included in the trust management object.
    */
    trustResult = -1;
    err = SecTrustEvaluate(trust, &trustResult);
    NSLog(@"err = %d, trustResult = %d", (int) err, (int) trustResult);
    switch (trustResult) {
        case kSecTrustResultProceed: // 1
        case kSecTrustResultConfirm: // 2 - deprecated in iOS 7, but still valid in iOS 6
        case kSecTrustResultUnspecified: // 4
            isPasscodeSetResult = true;
            break;
        case kSecTrustResultRecoverableTrustFailure:  // 5
        case kSecTrustResultDeny: // 3
        case kSecTrustResultFatalTrustFailure: // 6
        case kSecTrustResultOtherError: // 7
        case kSecTrustResultInvalid: // 0
        default:
            isPasscodeSetResult = false;
            break;
    }
    
    CFRelease(trust);
    CFRelease(policy);
    CFRelease(cert);
    
    return isPasscodeSetResult;
}

+ (Boolean)isPasscodeSetKeychainAPI {
    
    BOOL isAPIAvailable = (kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly != NULL);
    
    // Not available prior to iOS 8 - safe to return false rather than throwing exception
    if(isAPIAvailable) {
    
        // From http://pastebin.com/T9YwEjnL
        NSData* secret = [@"Device has passcode set?" dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *attributes = @{
                                     (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                     (__bridge id)kSecAttrService: @"LocalDeviceServices",
                                     (__bridge id)kSecAttrAccount: @"NoAccount",
                                     (__bridge id)kSecValueData: secret,
                                     (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
                                     };
        
        // Original code claimed to check if the item was already on the keychain
        // but in reality you can't add duplicates so this will fail with errSecDuplicateItem
        // if the item is already on the keychain (which could throw off our check if
        // kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly was not set)
        
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)attributes, NULL);
        if (status == errSecSuccess) { // item added okay, passcode has been set
            NSDictionary *query = @{
                                    (__bridge id)kSecClass:  (__bridge id)kSecClassGenericPassword,
                                    (__bridge id)kSecAttrService: @"LocalDeviceServices",
                                    (__bridge id)kSecAttrAccount: @"NoAccount"
                                    };
            
            status = SecItemDelete((__bridge CFDictionaryRef)query);
            
            return true;
        }
        
        // errSecDecode seems to be the error thrown on a device with no passcode set
        if (status == errSecDecode) {
            return false;
        }
    }
    
    return false;
}

@end
