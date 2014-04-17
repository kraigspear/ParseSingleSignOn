//
// Created by Kraig Spear on 12/28/13.
// Copyright (c) 2013 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HCUser : NSObject

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userId;

- (id) initWithName:(NSString*) userName userId:(NSString*) userId;

@end