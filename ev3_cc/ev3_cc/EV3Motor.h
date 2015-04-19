//
//  EV3Motor.h
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 19/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import "EV3Device.h"

@interface EV3Motor : EV3Device

// Range: [-100.0, 100.0] (percent of max power in either direction)
@property (assign, nonatomic) double dutyCycle;

+ (BOOL)isMotorDeviceName:(NSString *)deviceName;

- (void)reset;
- (void)stop;

@end
