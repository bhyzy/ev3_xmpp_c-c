//
//  DashboardViewController.m
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 12/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import "DashboardViewController.h"

@interface DashboardViewController ()

@end

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)signOutButtonPressed:(id)sender
{
    [self.delegate dashboardViewControllerDidRequestSignOut:self];
}

@end
