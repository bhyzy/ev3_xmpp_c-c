//
//  DashboardViewController.h
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 12/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class XMPPStream;

@class DashboardViewController;

@protocol DashboardViewControllerDelegate <NSObject>

- (void)dashboardViewControllerDidSignOut:(DashboardViewController *)controller;

@end

@interface DashboardViewController : NSViewController

@property (strong, nonatomic) XMPPStream * xmppStream;
@property (weak, nonatomic) id <DashboardViewControllerDelegate> delegate;

@end
