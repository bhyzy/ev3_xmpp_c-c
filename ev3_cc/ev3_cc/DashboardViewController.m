//
//  DashboardViewController.m
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 12/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import "DashboardViewController.h"
#import "XMPP.h"
#import "XMPPMUC.h"
#import "DDLog.h"
#import "EV3Device.h"
#import "DeviceViewController.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface DashboardViewController () <XMPPStreamDelegate>

@property (strong, nonatomic) XMPPMUC * xmppMUC;

@property (strong, nonatomic) XMPPJID * conferenceJID;
@property (strong, nonatomic) NSString * roomsDiscoID;

@property (strong, nonatomic) NSArray * devices;
@property (strong, nonatomic) NSMutableDictionary * deviceWindowControllers;

@property (weak, nonatomic) IBOutlet NSTextField * serverAddressLabel;
@property (weak, nonatomic) IBOutlet NSTextField * jidLabel;

@end

@implementation DashboardViewController

#pragma mark - View Controller Life Cycle

- (void)viewWillAppear
{
    [super viewWillAppear];
    
    if (self.xmppMUC == nil) {
        NSAssert(self.xmppStream != nil, @"An XMPP stream should be ready at this point");
        [self setupStream];
        [self setupUI];
        [self discoverDevices];
    }
}

- (void)dealloc
{
    [self.xmppStream removeDelegate:self];
}

#pragma mark - XMPP Stream and MUC

- (void)setupStream
{
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    self.xmppMUC = [[XMPPMUC alloc] init];
    [self.xmppMUC activate:self.xmppStream];
    
    self.conferenceJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"muc.%@", self.xmppStream.myJID.domain]];
}

- (void)setupUI
{
    NSString *hostname = self.xmppStream.hostName ?: self.xmppStream.myJID.domain;
    NSString *serverAddress = [NSString stringWithFormat:@"%@:%@", hostname, @(self.xmppStream.hostPort)];
    
    self.serverAddressLabel.stringValue = serverAddress;
    self.jidLabel.stringValue = self.xmppStream.myJID.full;
    
    self.deviceWindowControllers = [NSMutableDictionary new];
}

- (void)discoverDevices
{
    self.devices = [NSArray array];
    
    self.roomsDiscoID = [self.xmppStream generateUUID];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:self.conferenceJID elementID:self.roomsDiscoID child:query];
    [self.xmppStream sendElement:iq];
}

- (void)handleRoomDiscoResult:(XMPPIQ *)iq
{
    NSMutableArray *mutableDevices = [self mutableArrayValueForKey:@"devices"];
    
    // Parse conference disco result and connect to all available devices (MUC rooms)
    NSXMLElement *queryElement = [iq elementForName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    NSArray *items = [queryElement elementsForName:@"item"];
    for (NSXMLElement *item in items) {
        XMPPJID *roomJID = [XMPPJID jidWithString:[item attributeStringValueForName:@"jid"]];
        EV3Device *device = [[EV3Device alloc] initWithRoomJID:roomJID stream:self.xmppStream];
        [mutableDevices addObject:device];
    }
}

#pragma mark - UI Methods

- (IBAction)signOutButtonPressed:(id)sender
{
    [self.xmppStream disconnect];
    [self.delegate dashboardViewControllerDidDisconnect:self];
}

- (void)showDetailsWindowForDevice:(EV3Device *)device
{
    NSWindowController *windowController = self.deviceWindowControllers[device.roomJID];
    if (windowController == nil) {
        windowController = [DeviceViewController instantiateInWindowControllerWithDevice:device];
        self.deviceWindowControllers[device.roomJID] = windowController;
    }
    [windowController showWindow:self];
}

- (void)dismissDetailsWindowForDevice:(EV3Device *)device
{
    NSWindowController *windowController = self.deviceWindowControllers[device.roomJID];
    [self.deviceWindowControllers removeObjectForKey:device.roomJID];
    [windowController close];
}

#pragma mark - XMPPStream Delegate

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [self.delegate dashboardViewControllerDidDisconnect:self];
}

//- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq
//{
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//}
//
//- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
//{
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if ([iq.elementID isEqualToString:self.roomsDiscoID]) {
        [self handleRoomDiscoResult:iq];
        return YES;
    }
    
    return NO;
}

//- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
//{
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//}

@end
