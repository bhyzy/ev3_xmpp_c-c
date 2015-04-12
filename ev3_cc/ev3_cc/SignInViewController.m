//
//  SignInViewController.m
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 12/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import "SignInViewController.h"

NSString * const kTempJID = @"test@localhost";
NSString * const kTempPassword = @"test";

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet NSTextField * jidTextField;
@property (weak, nonatomic) IBOutlet NSTextField * passwordTextField;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)signInButtonPressed:(id)sender
{
    NSString *jid = self.jidTextField.stringValue;
    NSString *password = self.passwordTextField.stringValue;
    
    self.jidTextField.stringValue = @"";
    self.passwordTextField.stringValue = @"";
    
    if ([jid isEqualToString:kTempJID] && [password isEqualToString:kTempPassword]) {
        [self.delegate signInViewController:self didAuthenticateWithJID:jid];
    }
}

@end
