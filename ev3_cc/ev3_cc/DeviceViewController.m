//
//  DeviceViewController.m
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 13/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import "DeviceViewController.h"
#import "EV3Device.h"
#import "XMPPRoom.h"
#import "RealTimePlot.h"
#import <CorePlot/CorePlot.h>

@interface DeviceViewController () <XMPPRoomDelegate>

@property (weak, nonatomic) IBOutlet NSTextField * jidLabel;
@property (weak, nonatomic) IBOutlet NSTextField * valueLabel;

@property (unsafe_unretained) IBOutlet NSTextView *consoleTextView;

@property (weak, nonatomic) IBOutlet NSView * plotView;
@property (strong, nonatomic) RealTimePlot * plot;

@end

@implementation DeviceViewController

#pragma mark - Public API

+ (NSWindowController *)instantiateInWindowControllerWithDevice:(EV3Device *)device
{
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    NSWindowController *windowController = [storyboard instantiateControllerWithIdentifier:@"Device"];
    DeviceViewController *viewController = (DeviceViewController *)windowController.contentViewController;
    viewController.device = device;
    return windowController;
}

- (void)setDevice:(EV3Device *)device
{
    NSAssert(self.device == nil, @"A device has been already associated with this instance");
    
    _device = device;
    
    [self.device.room addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    self.jidLabel.stringValue = device.roomJID.full;
}

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.plot = [[RealTimePlot alloc] init];
    [self.plot renderInView:self.plotView withTheme:nil animated:YES];
}

#pragma mark - UI Methods

- (IBAction)pressedEnterInTextField:(NSTextField *)textField
{
    NSString *message = textField.stringValue;
    textField.stringValue = @"";
    
    [self.device.room sendMessageWithBody:message];
}

#pragma mark - XMPPRoomDelegate

- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID
{
    NSMutableString *consoleText = self.consoleTextView.textStorage.mutableString;
    if (consoleText.length > 0) {
        [consoleText appendString:@"\n"];
    }
    [consoleText appendString:[NSString stringWithFormat:@"<%@> %@", occupantJID.resource, message.body]];
    [self.consoleTextView scrollRangeToVisible:NSMakeRange(consoleText.length, 0)];
}

@end
