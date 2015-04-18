//
//  EV3Device.m
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 12/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import "EV3Device.h"
#import "XMPP.h"
#import "XMPPRoom.h"
#import "XMPPRoomMemoryStorage.h"
#import "XMPPMessage+XEP0045.h"
#import "XMPPStream.h"
#import "DDLog.h"

static const int ddLogLevel = LOG_LEVEL_INFO;

@interface EV3Device () <XMPPStreamDelegate>

@property (readwrite, strong, nonatomic) XMPPRoom * room;
@property (strong, nonatomic) XMPPJID * roomOwnerJID;

@property (readwrite, copy, nonatomic) NSString * name;
@property (readwrite, strong, nonatomic) NSNumber * rawValue;
@property (readwrite, assign, nonatomic) NSUInteger decimals;
@property (readwrite, strong, nonatomic) NSArray * modes;
@property (readwrite, copy, nonatomic) NSString * unit;
@property (readwrite, assign, nonatomic) EV3ValueRange valueRange;

@property (strong, nonatomic) NSNumberFormatter * numberFormatter;

@end

@implementation EV3Device

#pragma mark - Public API

- (instancetype)initWithRoomJID:(XMPPJID *)roomJID stream:(XMPPStream *)stream
{
    self = [super init];
    if (self != nil) {
        _roomJID = roomJID;
        _stream = stream;
        _name = roomJID.user;
        _valueRange = [EV3Device valueRangeForDeviceNamed:_name inMode:nil];
        
        self.room = [[XMPPRoom alloc] initWithRoomStorage:[[XMPPRoomMemoryStorage alloc] init] jid:roomJID];
        // TODO [bhy] for now let's assume the room owner (actual device) will use the nickname 'device'
        self.roomOwnerJID = [roomJID jidWithNewResource:@"device"];
        
        [self.room addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [self.room activate:stream];
        [self.room joinRoomUsingNickname:@"client" history:nil];
        
        [self.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        // let's get some device data right off the bat
        [self sendMessageWithBody:@"get modes"];
        [self sendMessageWithBody:@"get mode"];
        [self sendMessageWithBody:@"get unit"];
        [self sendMessageWithBody:@"get decimals"];
        [self sendMessageWithBody:@"get value"];
        
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    }
    return self;
}

- (XMPPMessage *)sendMessageWithBody:(NSString *)body
{
    NSXMLElement *bodyElement = [NSXMLElement elementWithName:@"body" stringValue:body];
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.roomOwnerJID elementID:nil child:bodyElement];
    [self.room.xmppStream sendElement:message];
    return message;
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
        self.valueRange = [EV3Device valueRangeForDeviceNamed:self.name inMode:_mode];
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
        self.valueRange = [EV3Device valueRangeForDeviceNamed:self.name inMode:_mode];
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

#pragma mark - XMPP Stream Delegate

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    if (message.isGroupChatMessage) {
        // group chat messages are handled separately
        return;
    }
    
    // we're only interested in messages from the device itself
    if ([message.from isEqualToJID:self.roomOwnerJID]) {
        [self handleDeviceMessageBody:message.body];
    }
}

#pragma mark - XMPP Room Delegate

- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID
{
    // we're only interested in messages from the device itself
    if ([occupantJID isEqualToJID:self.roomOwnerJID]) {
        [self handleDeviceMessageBody:message.body];
    }
}

@end
