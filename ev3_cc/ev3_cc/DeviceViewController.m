//
//  DeviceViewController.m
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 13/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import "DeviceViewController.h"

@interface DeviceViewController ()

@end

@implementation DeviceViewController

+ (NSWindowController *)instantiateInWindowControllerWithDevice:(EV3Device *)device
{
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    NSWindowController *windowController = [storyboard instantiateControllerWithIdentifier:@"Device"];
    DeviceViewController *viewController = (DeviceViewController *)windowController.contentViewController;
    viewController.device = device;
    return windowController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
}

@end
