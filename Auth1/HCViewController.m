//
//  HCViewController.m
//  Auth1
//
//  Created by Kraig Spear on 12/28/13.
//  Copyright (c) 2013 Kraig Spear. All rights reserved.
//

#import "HCViewController.h"
#import "HCAuth.h"
#import "MBProgressHUD.h"

@interface HCViewController ()

@end

@implementation HCViewController
{
    HCAuth *_auth;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.emailTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logOnAction:(id)sender
{
    if (_auth != nil) return;

    _auth = [[HCAuth alloc] init];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Logging In";

    [_auth logOnWithUserName:self.emailTextField.text andPassword:self.passwordTextField.text
                     success:^(HCUser *user)
                     {
                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                         _auth = nil;

                         if (user)
                             [self showMessage:@"Welcome Back!!!"];
                         else
                             [self showMessage:@"Invalid username and or password"];
                     }
                     failure:^(NSError *error)
                     {
                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                         _auth = nil;
                         [self showMessage:error.localizedDescription];
                     }];

}

- (IBAction)signUpAction:(id)sender
{
    if (_auth != nil) return;

    _auth = [[HCAuth alloc] init];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Creating Account";

    [_auth signUpWithUserName:self.emailTextField.text
                  andPassword:self.passwordTextField.text
                      success:^(HCUser *user)
                      {
                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                          if(user)
                          {
                              [self showMessage:@"Account created, welcome aboard"];
                          }
                          else
                          {
                              [self showMessage:@"Sorry, wasn't able to create a new account"];
                          }
                      }
                      failure:^(NSError *error)
                      {
                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                          _auth = nil;
                          [self showMessage:error.localizedDescription];
                      }];

}


- (void)showMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"LogOn" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}

@end