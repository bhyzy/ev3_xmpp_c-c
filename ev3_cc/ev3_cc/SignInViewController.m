//
//  SignInViewController.m
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 12/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import "SignInViewController.h"
#import "XMPP.h"
#import "DDLog.h"
#import <SystemConfiguration/SystemConfiguration.h>

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

NSString * const kTempJID = @"test@localhost";
NSString * const kTempPassword = @"test";

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet NSTextField * jidTextField;
@property (weak, nonatomic) IBOutlet NSTextField * passwordTextField;
@property (weak, nonatomic) IBOutlet NSButton * signInButton;
@property (weak, nonatomic) IBOutlet NSTextField * errorLabel;

@property (strong, nonatomic) XMPPStream * xmppStream;
@property (assign, nonatomic, getter=isConnectionOpen) BOOL connectionOpen;
@property (assign, nonatomic, getter=isAuthenticating) BOOL authenticating;

@end

@implementation SignInViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.xmppStream = [[XMPPStream alloc] init];
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)dealloc
{
    [self.xmppStream removeDelegate:self];
}

#pragma mark - UI Methods

- (IBAction)signInButtonPressed:(id)sender
{
    [self.view.window makeFirstResponder:nil];
    
    [self displayErrorMessage:nil];
    
    NSString *resource = (__bridge_transfer NSString *)SCDynamicStoreCopyComputerName(NULL, NULL);
    self.xmppStream.myJID = [XMPPJID jidWithString:self.jidTextField.stringValue resource:resource];
    
    NSError *error;
    BOOL success;
    
    if (!self.xmppStream.isConnected)
    {
        success = [[self xmppStream] connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    }
    else
    {
        success = [[self xmppStream] authenticateWithPassword:self.passwordTextField.stringValue error:&error];
    }
    
    if (success)
    {
        self.authenticating = YES;
        [self lockSignInUI];
    }
    else
    {
        [self displayErrorMessage:error.localizedDescription];
    }
}

- (void)enableSignInUI:(BOOL)enabled
{
    self.jidTextField.enabled = enabled;
    self.passwordTextField.enabled = enabled;
    self.signInButton.enabled = enabled;
}

- (void)lockSignInUI
{
    [self enableSignInUI:NO];
}

- (void)unlockSignInUI
{
    [self enableSignInUI:YES];
}

- (void)displayErrorMessage:(NSString *)message
{
    self.errorLabel.stringValue = message ?: @"";
    self.errorLabel.hidden = (message.length == 0);
}

#pragma mark - XMPPStream Delegate

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // Allow self-signed certificates
    //[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    self.connectionOpen = YES;
    
    NSString *password = self.passwordTextField.stringValue;
    
    NSError *error = nil;
    BOOL operationInProgress = [self.xmppStream authenticateWithPassword:password error:&error];
    
    if (!operationInProgress)
    {
        [self displayErrorMessage:error.localizedDescription];
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    self.authenticating = NO;
    
    XMPPPresence *presence = [XMPPPresence presence];
    [self.xmppStream sendElement:presence];
    
    [self.delegate signInViewController:self didOpenXMPPStream:self.xmppStream];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    self.authenticating = NO;
    
    [self unlockSignInUI];
    [self displayErrorMessage:@"Invalid username/password"];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [self displayErrorMessage:@"Cannot connect to server"];
    
    self.connectionOpen = NO;
    self.authenticating = NO;

    [self unlockSignInUI];
}

@end
