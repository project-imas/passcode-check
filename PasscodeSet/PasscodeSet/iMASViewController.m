//
//  iMASViewController.m
//  PasscodeSet
//
//  Created by Ganley, Gregg on 11/27/12.
//  Copyright (c) 2012 MITRE Corp. All rights reserved.
//

#import "iMASViewController.h"
#import "iMAS_PasscodeCheck.h"

@implementation iMASViewController
@synthesize output = _output;


- (IBAction)runTest:(UIButton *)sender {
    NSString *buttonName = [sender currentTitle];
    
    NSLog(@"Button Pressed = %@", buttonName);

    //**self.output.text = @"iMAS";
    
    
    NSLog(@"is passcode set? %d", [iMAS_PasscodeCheck isPasscodeSet]);

    
    
}

- (void)viewDidUnload {
    [self setOutput:nil];
    [super viewDidUnload];
}
@end
