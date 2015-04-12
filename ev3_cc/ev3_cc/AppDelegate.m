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

@interface AppDelegate () <SignInViewControllerDelegate, DashboardViewControllerDelegate>

@property (strong, nonatomic) NSWindowController * signInWindowController;
@property (strong, nonatomic) NSWindowController * dashboardWindowController;

@property (strong, nonatomic) NSWindowController * currentWindowController;


@end

@implementation AppDelegate

#pragma mark - Application Life Cycle

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
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

- (NSWindowController *)instantiateDashboardWindowController
{
    NSWindowController *windowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Dashboard"];
    ((DashboardViewController *)windowController.contentViewController).delegate = self;
    return windowController;
}

#pragma mark - SignInViewControllerDelegate

- (void)signInViewController:(SignInViewController *)controller didAuthenticateWithJID:(NSString *)jid
{
    self.currentWindowController = [self instantiateDashboardWindowController];
}

#pragma mark - DashboardViewControllerDelegate

- (void)dashboardViewControllerDidRequestSignOut:(DashboardViewController *)controller
{
    self.currentWindowController = [self instantiateSignInWindowController];
}

@end
