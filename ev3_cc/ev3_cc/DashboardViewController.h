//
//  DashboardViewController.h
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 12/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DashboardViewController;

@protocol DashboardViewControllerDelegate <NSObject>

- (void)dashboardViewControllerDidRequestSignOut:(DashboardViewController *)controller;

@end

@interface DashboardViewController : NSViewController

@property (weak, nonatomic) id <DashboardViewControllerDelegate> delegate;

@end
