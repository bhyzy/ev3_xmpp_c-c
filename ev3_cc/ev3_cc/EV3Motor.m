//
//  EV3Motor.m
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 19/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import "EV3Motor.h"
#import "DDLog.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface EV3Motor ()

@end

@implementation EV3Motor

#pragma mark - Public API

+ (BOOL)isMotorDeviceName:(NSString *)deviceName
{
    return [@[@"lego-ev3-l-motor", @"lego-ev3-m-motor"] containsObject:deviceName];
}

@end
