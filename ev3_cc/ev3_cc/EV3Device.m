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
#import "EV3Sensor.h"
#import "EV3Motor.h"

static const int ddLogLevel = LOG_LEVEL_INFO;

@interface EV3Device () <XMPPStreamDelegate>

@property (readwrite, strong, nonatomic) XMPPRoom * room;
@property (strong, nonatomic) XMPPJID * roomOwnerJID;

@property (readwrite, copy, nonatomic) NSString * name;
@property (readwrite, assign, nonatomic) EV3ValueRange valueRange;

@property (strong, nonatomic) NSNumberFormatter * numberFormatter;

@end

@implementation EV3Device

#pragma mark - Public API

+ (EV3Device *)deviceWithRoomJID:(XMPPJID *)roomJID stream:(XMPPStream *)stream
{
    NSString *deviceName = roomJID.user;
    if ([EV3Sensor isSensorDeviceName:deviceName]) {
        return [[EV3Sensor alloc] initWithRoomJID:roomJID stream:stream];
    } else if ([EV3Motor isMotorDeviceName:deviceName]) {
        return [[EV3Motor alloc] initWithRoomJID:roomJID stream:stream];
    } else {
        return [[EV3Device alloc] initWithRoomJID:roomJID stream:stream];
    }
}

- (instancetype)initWithRoomJID:(XMPPJID *)roomJID stream:(XMPPStream *)stream
{
    self = [super init];
    if (self != nil) {
        _roomJID = roomJID;
        _stream = stream;
        _name = roomJID.user;
        
        self.room = [[XMPPRoom alloc] initWithRoomStorage:[[XMPPRoomMemoryStorage alloc] init] jid:roomJID];
        // TODO [bhy] for now let's assume the room owner (actual device) will use the nickname 'device'
        self.roomOwnerJID = [roomJID jidWithNewResource:@"device"];
        
        [self.room addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [self.room activate:stream];
        [self.room joinRoomUsingNickname:@"client" history:nil];
        
        [self.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
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

#pragma mark - Private Methods

- (void)handleDeviceMessageBody:(NSString *)body
{
    // Override in subclasses
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
