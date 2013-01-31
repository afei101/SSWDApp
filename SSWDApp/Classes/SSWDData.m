//
//  SSWDData.m
//  SSWDApp
//
//  Created by gaofei on 13-1-10.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import "SSWDData.h"

@implementation SSWDData
@synthesize mSockPtr;
@synthesize mRecvDelegate;
@synthesize mGameUser;
@synthesize mSinaweibo;
@synthesize mRoomInfo;
@synthesize mGameRoom;

static SSWDData * mEngine;

+ (SSWDData *)getInstance {
	@synchronized(self)
	{
		if  (mEngine  ==  nil)
		{
            mEngine = [[self alloc] init];
        }
    }
	
	return  mEngine;
}

-(id)init{
    if(self = [super init])
    {
        //netMain相关变量
        mSockPtr = nil ;
        mRecvDelegate = nil ;
        mRoomInfo = [[NSMutableArray alloc] init];
        mGameRoom = [[GameRoom alloc] init];
    }
    
    return self;
}

-(void)dealloc
{
    [mRoomInfo release];
    [mGameRoom release];
    [mSinaweibo release];
    [mRecvDelegate release];
    [mSockPtr release];
    [mGameUser release];
    
    [super dealloc];
}
@end
