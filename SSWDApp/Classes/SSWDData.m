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
    }
    
    return self;
}

-(void)dealloc
{
    [super dealloc];
}
@end
