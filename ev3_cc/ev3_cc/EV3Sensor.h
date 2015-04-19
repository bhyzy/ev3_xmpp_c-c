//
//  EV3Sensor.h
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 19/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import "EV3Device.h"

@interface EV3Sensor : EV3Device

@property (readonly, strong, nonatomic) NSNumber * rawValue;
@property (readonly, assign, nonatomic) NSUInteger decimals;
@property (readwrite, copy, nonatomic) NSString * mode;
@property (readonly, strong, nonatomic) NSArray * modes;
@property (readonly, copy, nonatomic) NSString * unit;

+ (BOOL)isSensorDeviceName:(NSString *)deviceName;

@end
