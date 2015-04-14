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
#import "DDLog.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface EV3Device () <XMPPStreamDelegate>

@property (readwrite, strong, nonatomic) XMPPRoom * room;
@property (readwrite, copy, nonatomic) NSString * name;
@property (readwrite, strong, nonatomic) NSObject * value;

@end

@implementation EV3Device

#pragma mark - Public API

- (instancetype)initWithRoomJID:(XMPPJID *)roomJID stream:(XMPPStream *)stream
{
    self = [super init];
    if (self != nil) {
        _roomJID = roomJID;
        _stream = stream;
        _name = nil; // TODO [bhy] implement
        
        self.room = [[XMPPRoom alloc] initWithRoomStorage:[[XMPPRoomMemoryStorage alloc] init] jid:roomJID];
        
        [self.room addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [self.room activate:stream];
        [self.room joinRoomUsingNickname:@"client" history:nil];
    }
    return self;
}

#pragma mark - Private Methods

- (void)handleDeviceMessageBody:(NSString *)body
{
    NSArray *components = [body componentsSeparatedByString:@" "];
    if (components.count == 0) {
        DDLogError(@"%@, %@ # failed to parse message body (no components): %@", THIS_FILE, THIS_METHOD, body);
        return;
    }
    
    NSString *messageType = components[0];
    if ([messageType isEqualToString:@"value"]) {
        NSString *valueString;
        if (components.count > 1) {
            valueString = components[1];
            self.value = [self parseValue:valueString];
            DDLogVerbose(@"%@, %@ # did update value of %@: %@", THIS_FILE, THIS_METHOD, self.roomJID, self.value);
        } else {
            DDLogError(@"%@, %@ # failed to parse message body (missing value): %@", THIS_FILE, THIS_METHOD, body);
        }
    } else {
        DDLogError(@"%@, %@ # failed to parse message body (unrecognized message type '%@'): %@", THIS_FILE, THIS_METHOD, messageType, body);
    }
}

- (NSObject *)parseValue:(NSString *)stringValue
{
    // TODO [bhy] implement real parsing and return appropriate value based on device type
    return stringValue;
}

#pragma mark - XMPP Stream Delegate

- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID
{
    //DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
//    <message xmlns="jabber:client" from="sensor3@muc.localhost/sensor3" to="test3@localhost/Bartlomiej’s MacBook Pro" type="groupchat" lang="en">
//        <body>value 793</body>
//    </message>
    
    // TODO [bhy] handle only messages originating from the device itself?
    if (/*[message.from isEqual:self.roomJID] &&*/ [message isGroupChatMessageWithBody]) {
        [self handleDeviceMessageBody:message.body];
    }
}

@end
