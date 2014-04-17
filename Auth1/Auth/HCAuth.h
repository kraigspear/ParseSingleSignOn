//
// Created by Kraig Spear on 12/28/13.
// Copyright (c) 2013 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HCUser.h"


typedef void (^HCBoolBlock)(BOOL);
typedef void (^HCAuthSuccessBlock)(HCUser *);
typedef void (^HCAuthErrorBlock)(NSError*);

extern NSString * const HCAuthDomain;

static NSString *const ErrorKey = @"error";

@interface HCAuth : NSObject


//Create a new account on the Auth server, and the local App account as well
- (void)signUpWithUserName:(NSString *)userName andPassword:(NSString *)password success:(HCAuthSuccessBlock)success failure:(HCAuthErrorBlock)failure;

//Log in to an existing account on the Auth server, If the login was successful we are logged on to the client App as well.
- (void)logOnWithUserName:(NSString *)userName andPassword:(NSString *)password success:(HCAuthSuccessBlock) success
                  failure:(HCAuthErrorBlock) failure;

@end