//
//  AppDelegate.m
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 08/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import "AppDelegate.h"
#import "SignInViewController.h"
#import "DashboardViewController.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

@interface AppDelegate () <SignInViewControllerDelegate, DashboardViewControllerDelegate>

@property (strong, nonatomic) NSWindowController * signInWindowController;
@property (strong, nonatomic) NSWindowController * dashboardWindowController;

@property (strong, nonatomic) NSWindowController * currentWindowController;


@end

@implementation AppDelegate

#pragma mark - Application Life Cycle

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    self.currentWindowController = [self instantiateSignInWindowController];
}

#pragma mark - Window Controllers

- (void)setCurrentWindowController:(NSWindowController *)currentWindowController
{
    [_currentWindowController close];
    _currentWindowController = currentWindowController;
    [currentWindowController showWindow:self];
}

- (NSWindowController *)instantiateSignInWindowController
{
    NSWindowController *windowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"SignIn"];
    ((SignInViewController *)windowController.contentViewController).delegate = self;
    return windowController;
}

- (NSWindowController *)instantiateDashboardWindowControllerWithXMPPStream:(XMPPStream *)stream
{
    NSWindowController *windowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Dashboard"];
    
    DashboardViewController *dashboardViewController = (DashboardViewController *)windowController.contentViewController;
    dashboardViewController.xmppStream = stream;
    dashboardViewController.delegate = self;
    
    return windowController;
}

#pragma mark - SignInViewControllerDelegate

- (void)signInViewController:(SignInViewController *)controller didOpenXMPPStream:(XMPPStream *)xmppStream
{
    self.currentWindowController = [self instantiateDashboardWindowControllerWithXMPPStream:xmppStream];
}

#pragma mark - DashboardViewControllerDelegate

- (void)dashboardViewControllerDidSignOut:(DashboardViewController *)controller
{
    self.currentWindowController = [self instantiateSignInWindowController];
}

@end
