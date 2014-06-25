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

    
    Boolean is_set = [iMAS_PasscodeCheck isPasscodeSet];
    
    if (is_set == TRUE)
        self.output.text = @"Device passcode meets app requirements";
    else
        self.output.text = @"Device passcode may not be set or does not meet app requirements!";
    
    NSLog(@"is passcode set? %d", [iMAS_PasscodeCheck isPasscodeSet]);

    
    
}

// when app goes into background
-(void) clearOutput {
    self.output.text = @"";
    
    self.view.backgroundColor = [UIColor clearColor];
    self.output.backgroundColor = [UIColor clearColor];
    UIToolbar* bgToolbar = [[UIToolbar alloc] initWithFrame:self.view.frame];
    bgToolbar.barStyle = UIBarStyleDefault;
    [self.view.superview insertSubview:bgToolbar belowSubview:self.view];
}

-(void) viewWillAppear:(BOOL)animated {
    self.output.text = @"";
}

- (void)viewDidLoad {
    self.output.text = @"";
}

- (void)viewDidUnload {
    [self setOutput:nil];
    [super viewDidUnload];
    
    
}
@end
