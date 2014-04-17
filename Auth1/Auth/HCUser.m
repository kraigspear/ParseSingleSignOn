//
// Created by Kraig Spear on 12/28/13.
// Copyright (c) 2013 ___FULLUSERNAME___. All rights reserved.
//

#import "HCUser.h"


@implementation HCUser
{

}

- (id) initWithName:(NSString*) userName userId:(NSString*) userId
{

    if(!(self = [self init])) return nil;

    self.userName = userName;
    self.userId = userId;

    return self;
}

@end