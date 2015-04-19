//
//  EV3Motor.h
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 19/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import "EV3Device.h"

@interface EV3Motor : EV3Device

+ (BOOL)isMotorDeviceName:(NSString *)deviceName;

@end
