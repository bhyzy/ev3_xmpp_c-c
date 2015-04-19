//
//  MotorCommandViewController.m
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 19/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import "MotorCommandViewController.h"
#import "EV3Motor.h"

@interface MotorCommandViewController ()
@end

@implementation MotorCommandViewController

- (IBAction)resetMotor:(id)sender
{
    EV3Motor *motor = (EV3Motor *)self.representedObject;
    [motor reset];
}

- (IBAction)stopMotor:(id)sender
{
    EV3Motor *motor = (EV3Motor *)self.representedObject;
    [motor stop];
}

@end
