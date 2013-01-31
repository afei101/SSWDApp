//
//  GameRoom.m
//  SSWDApp
//
//  Created by gaofei on 13-1-29.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import "GameRoom.h"

@implementation GameRoom
@synthesize mGameState;
@synthesize mGameUsers;
@synthesize mCurrent;
@synthesize mKeyWord;
@synthesize mRoundNum;
@synthesize mRoomID;
@synthesize mRoomName;
@synthesize mPrevious;

-(void)dealloc{
    [mGameUsers release];
    [mKeyWord release];
    [mRoomName release];
    [super dealloc];
}

@end
