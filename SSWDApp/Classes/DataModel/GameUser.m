//
//  GameUser.m
//  SSWDApp
//
//  Created by gaofei on 13-1-22.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import "GameUser.h"

@implementation GameUser
@synthesize mNickName;
@synthesize mIcon;
@synthesize mUserState;
@synthesize uuid;
@synthesize voiceData;

-(void)dealloc{
    [mNickName release];
    [mIcon release];
    [voiceData release];
    [super dealloc];
}
@end
