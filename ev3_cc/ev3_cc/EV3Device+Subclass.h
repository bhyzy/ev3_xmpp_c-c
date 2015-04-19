//
//  EV3Device+Subclass.h
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 19/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import "EV3Device.h"

@interface EV3Device (Subclass)

@property (strong, nonatomic) NSNumberFormatter * numberFormatter;
@property (readwrite, assign, nonatomic) EV3ValueRange valueRange;

- (instancetype)initWithRoomJID:(XMPPJID *)roomJID stream:(XMPPStream *)stream;

- (void)handleDeviceMessageBody:(NSString *)body;

@end
