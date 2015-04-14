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

@interface EV3Device : NSObject

- (instancetype)initWithRoomJID:(XMPPJID *)roomJID stream:(XMPPStream *)stream;

@property (readonly, nonatomic) XMPPJID * roomJID;
@property (readonly, strong, nonatomic) XMPPRoom * room;
@property (readonly, nonatomic) XMPPStream * stream;
@property (readonly, copy, nonatomic) NSString * name;
@property (readonly, strong, nonatomic) NSObject * value;

@end
