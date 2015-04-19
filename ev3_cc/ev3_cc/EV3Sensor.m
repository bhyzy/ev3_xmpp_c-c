//
//  EV3Sensor.m
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 19/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import "EV3Sensor.h"
#import "DDLog.h"
#import "EV3Device+Subclass.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface EV3Sensor ()

@property (readwrite, strong, nonatomic) NSNumber * rawValue;
@property (readwrite, assign, nonatomic) NSUInteger decimals;
@property (readwrite, strong, nonatomic) NSArray * modes;
@property (readwrite, copy, nonatomic) NSString * unit;

@end

@implementation EV3Sensor

#pragma mark - Public API

+ (BOOL)isSensorDeviceName:(NSString *)deviceName
{
    return [@[@"lego-ev3-uart-30", @"lego-ev3-uart-32", @"lego-ev3-uart-29", @"lego-ev3-touch", @"lego-ev3-uart-33"] containsObject:deviceName];
}

- (instancetype)initWithRoomJID:(XMPPJID *)roomJID stream:(XMPPStream *)stream
{
    self = [super initWithRoomJID:roomJID stream:stream];
    if (self != nil) {
        // let's get some sensor data right off the bat
        [self sendMessageWithBody:@"get modes"];
        [self sendMessageWithBody:@"get mode"];
        [self sendMessageWithBody:@"get unit"];
        [self sendMessageWithBody:@"get decimals"];
        [self sendMessageWithBody:@"get value"];
    }
    return self;
}

- (NSNumber *)formattedValue
{
    return @(self.rawValue.doubleValue / pow(10, self.decimals));
}

+ (NSSet *)keyPathsForValuesAffectingFormattedValue
{
    return [NSSet setWithObjects:@"rawValue", @"decimals", nil];
}

- (NSString *)valueString
{
    return [NSString stringWithFormat:@"%.1f %@", self.formattedValue.doubleValue, self.unit];
}

+ (NSSet *)keyPathsForValuesAffectingValueString
{
    return [NSSet setWithObjects:@"formattedValue", @"unit", nil];
}

- (void)setMode:(NSString *)mode
{
    if (![mode isEqualToString:self.mode]) {
        _mode = [mode copy];
        [self sendMessageWithBody:[@"set mode " stringByAppendingString:mode]];
        self.valueRange = [EV3Sensor valueRangeForDeviceNamed:self.name inMode:_mode];
    }
}

#pragma mark - Private Methods

- (void)handleDeviceMessageBody:(NSString *)body
{
    NSArray *components = [body componentsSeparatedByString:@" "];
    NSString *messageType = components.count > 0 ? components[0] : nil;
    NSString *argument = components.count > 1 ? components[1] : nil;
    
    if (messageType == nil) {
        DDLogError(@"%@, %@ # missing message type", THIS_FILE, THIS_METHOD);
        return;
    }
    
    if (argument == nil) {
        DDLogError(@"%@, %@ # missing argument for message type '%@'", THIS_FILE, THIS_METHOD, messageType);
        return;
    }
    
    if ([messageType isEqualToString:@"value"]) {
        // at the moment we're only supporting single-value modes
        self.rawValue = [self.numberFormatter numberFromString:argument];
        DDLogVerbose(@"%@, %@ # did update value of %@: %@", THIS_FILE, THIS_METHOD, self.roomJID, self.rawValue);
    } else if ([messageType isEqualToString:@"mode"]) {
        // don't use the setter in order to avoid side effects
        [self willChangeValueForKey:@"mode"];
        _mode = argument;
        self.valueRange = [EV3Sensor valueRangeForDeviceNamed:self.name inMode:_mode];
        [self didChangeValueForKey:@"mode"];
    } else if ([messageType isEqualToString:@"unit"]) {
        self.unit = argument;
    } else if ([messageType isEqualToString:@"decimals"]) {
        self.decimals = (NSUInteger)[argument integerValue];
    } else if ([messageType isEqualToString:@"modes"]) {
        self.modes = [argument componentsSeparatedByString:@","];
    } else {
        DDLogError(@"%@, %@ # failed to parse message body (unrecognized message type '%@'): %@", THIS_FILE, THIS_METHOD, messageType, body);
    }
}

// Let's hard code possible value ranges for some devices.
// Not the most elegant solution out there, but hey, it's enough for this proof of concept.
+ (EV3ValueRange)valueRangeForDeviceNamed:(NSString *)deviceName inMode:(NSString *)mode
{
    EV3ValueRange range = EV3MakeValueRange(0, 300);
    
    if ([deviceName isEqualToString:@"lego-ev3-uart-30"]) {
        // EV3 ultrasonic distance sensor
        if ([mode isEqualToString:@"US-DIST-CM"]) {
            range = EV3MakeValueRange(0, 255);
        } else if ([mode isEqualToString:@"US-DIST-IN"]) {
            range = EV3MakeValueRange(0, 100.3);
        }
    } else if ([deviceName isEqualToString:@"lego-ev3-touch"]) {
        // EV3 touch sensor (button)
        if ([mode isEqualToString:@"TOUCH"]) {
            range = EV3MakeValueRange(0, 1);
        }
    }
    
    return range;
}

@end
