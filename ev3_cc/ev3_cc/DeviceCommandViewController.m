//
//  DeviceCommandViewController.m
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 19/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import "DeviceCommandViewController.h"
#import "EV3Device.h"

@interface DeviceCommandViewController ()

@property (strong, nonatomic) NSViewController *contentViewController;

@end

@implementation DeviceCommandViewController

- (void)setControlledDevice:(EV3Device *)controlledDevice
{
    _controlledDevice = controlledDevice;
    
    NSString *segueIdentifier = [self segueIdentifierForDevice:controlledDevice];
    if (segueIdentifier != nil) {
        [self performSegueWithIdentifier:segueIdentifier sender:self];
    } else {
        self.contentViewController = nil;
    }
}

- (NSString *)segueIdentifierForDevice:(EV3Device *)device
{
    if ([device isKindOfClass:[EV3Device class]]) {
        return @"controlMotor";
    } else {
        return nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.controlledDevice = nil;
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender
{
    self.contentViewController = (NSViewController *)segue.destinationController;
    self.contentViewController.representedObject = self.controlledDevice;
}

- (void)setContentViewController:(NSViewController *)contentViewController
{
    NSViewController *oldContentVC = _contentViewController;
    NSViewController *newContentVC = contentViewController;
    
    _contentViewController = newContentVC;
    
    if (newContentVC == nil) {
        [oldContentVC removeFromParentViewController];
        [oldContentVC.view removeFromSuperview];
        return;
    }
    
    [self addChildViewController:newContentVC];
    
    if (oldContentVC != nil) {
        [self transitionFromViewController:oldContentVC toViewController:newContentVC options:NSViewControllerTransitionNone completionHandler:^{
            [oldContentVC removeFromParentViewController];
        }];
    } else {
        [self.view addSubview:newContentVC.view];
    }
    
    newContentVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = @{@"content": newContentVC.view};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[content]|" options:0 metrics:0 views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[content]|" options:0 metrics:0 views:views]];
}

@end
