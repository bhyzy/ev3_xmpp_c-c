//
//  DeviceCommandViewController.h
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 19/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class EV3Device;

@interface DeviceCommandViewController : NSViewController

@property (strong, nonatomic) EV3Device *controlledDevice;

@end
