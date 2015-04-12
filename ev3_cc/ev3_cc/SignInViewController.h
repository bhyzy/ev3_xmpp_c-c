//
//  SignInViewController.h
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 12/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SignInViewController;

@protocol SignInViewControllerDelegate <NSObject>

- (void)signInViewController:(SignInViewController *)controller didAuthenticateWithJID:(NSString *)jid;

@end

@interface SignInViewController : NSViewController

@property (weak, nonatomic) id <SignInViewControllerDelegate> delegate;

@end
