//
//  EV3Device.h
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 12/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMPPJID;
@class XMPPStream;
@class XMPPRoom;
@class XMPPMessage;

@interface EV3Device : NSObject

- (instancetype)initWithRoomJID:(XMPPJID *)roomJID stream:(XMPPStream *)stream;

@property (readonly, nonatomic) XMPPJID * roomJID;
@property (readonly, strong, nonatomic) XMPPRoom * room;
@property (readonly, nonatomic) XMPPStream * stream;

@property (readonly, copy, nonatomic) NSString * name;
@property (readonly, strong, nonatomic) NSNumber * rawValue;
@property (readonly, assign, nonatomic) NSUInteger decimals;
@property (readwrite, copy, nonatomic) NSString * mode;
@property (readonly, strong, nonatomic) NSArray * modes;
@property (readonly, copy, nonatomic) NSString * unit;

@property (readonly, nonatomic) NSString * valueString;
@property (readonly, nonatomic) NSNumber * formattedValue;

- (XMPPMessage *)sendMessageWithBody:(NSString *)body;

@end
