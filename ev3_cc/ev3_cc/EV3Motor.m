//
//  EV3Motor.m
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 19/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import "EV3Motor.h"
#import "DDLog.h"
#import "EV3Device+Subclass.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface EV3Motor ()

@end

@implementation EV3Motor

#pragma mark - Public API

+ (BOOL)isMotorDeviceName:(NSString *)deviceName
{
    return [@[@"lego-ev3-l-motor", @"lego-ev3-m-motor"] containsObject:deviceName];
}

- (instancetype)initWithRoomJID:(XMPPJID *)roomJID stream:(XMPPStream *)stream
{
    self = [super initWithRoomJID:roomJID stream:stream];
    if (self != nil) {
        self.valueRange = EV3MakeValueRange(-100, 100);
        // let's get some motor data right off the bat
        [self sendMessageWithBody:@"get duty_cycle_sp"];
    }
    return self;
}

- (NSNumber *)formattedValue
{
    return @(self.dutyCycle);
}

+ (NSSet *)keyPathsForValuesAffectingFormattedValue
{
    return [NSSet setWithObjects:@"dutyCycle", nil];
}

- (NSString *)valueString
{
    return [NSString stringWithFormat:@"%.0f %%", self.dutyCycle];
}

+ (NSSet *)keyPathsForValuesAffectingValueString
{
    return [NSSet setWithObjects:@"dutyCycle", nil];
}

- (void)setDutyCycle:(double)dutyCycle
{
    _dutyCycle = MAX(self.valueRange.minValue, MIN(self.valueRange.maxValue, floor(dutyCycle)));
    [self sendMessageWithBody:[NSString stringWithFormat:@"set duty_cycle_sp %d", (int)dutyCycle]];
    [self sendMessageWithBody:@"set run-forever"];
}

- (void)reset
{
    self.dutyCycle = 0;
    [self sendMessageWithBody:@"set command reset"];
}

- (void)stop
{
    self.dutyCycle = 0;
    [self sendMessageWithBody:@"set command stop"];
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
    
    if ([messageType isEqualToString:@"duty_cycle_sp"]) {
        [self willChangeValueForKey:@"dutyCycle"];
        _dutyCycle = [self.numberFormatter numberFromString:argument].doubleValue;
        [self didChangeValueForKey:@"dutyCycle"];
        DDLogVerbose(@"%@, %@ # did update motor duty cycle of %@: %@", THIS_FILE, THIS_METHOD, self.roomJID, @(self.dutyCycle));
    } else {
        DDLogError(@"%@, %@ # failed to parse message body (unrecognized message type '%@'): %@", THIS_FILE, THIS_METHOD, messageType, body);
    }
}

@end
