//
//  SSWDData.h
//  SSWDApp
//
//  Created by gaofei on 13-1-10.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "GameUser.h"
#import "NXRecvDelegate.h"
#import "SinaWeibo.h"
#import "GameRoom.h"

@interface SSWDData : NSObject{
    AsyncSocket *mSockPtr;
    //    回调实例
    NXRecvDelegate *mRecvDelegate;
    GameUser *mGameUser;
    
    SinaWeibo *mSinaweibo;
    NSMutableArray *mRoomInfo;
    GameRoom *mGameRoom;
}

@property(nonatomic,retain)AsyncSocket *mSockPtr;
@property(nonatomic,retain)NXRecvDelegate *mRecvDelegate;
@property(nonatomic,retain)GameUser *mGameUser;
@property(nonatomic,retain)SinaWeibo *mSinaweibo;
@property(nonatomic,retain)NSMutableArray *mRoomInfo;
@property(nonatomic,retain)GameRoom *mGameRoom;
+ (SSWDData *)getInstance;
@end
