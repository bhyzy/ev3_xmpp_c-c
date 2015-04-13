//
//  DeviceViewController.h
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 13/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class EV3Device;

@interface DeviceViewController : NSViewController

@property (strong, nonatomic) EV3Device * device;

+ (NSWindowController *)instantiateInWindowControllerWithDevice:(EV3Device *)device;

@end
