//
//  iMAS_PasscodeCheck.h
//  PasscodeSet
//
//  Created by Ganley, Gregg on 12/4/12.
//  Copyright (c) 2012 MITRE Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iMAS_PasscodeCheck : NSObject

//** is a configuration profile installed that forces the user to set a more rigorous password
+ (Boolean)isPasscodeSet;

//** iOS 8 adds a keychain API to test if passcode is set
+ (Boolean)isPasscodeSetKeychainAPI;

@end
