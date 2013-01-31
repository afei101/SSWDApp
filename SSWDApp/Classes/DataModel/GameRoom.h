//
//  GameRoom.h
//  SSWDApp
//
//  Created by gaofei on 13-1-29.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPNetEngine.h"
@interface GameRoom : NSObject{
    ROOM_GAME_STATE mGameState;//表示游戏目前所处于的状态
    NSMutableDictionary *mGameUsers;//这个结构是GameUser的数组，表示所有进入这个房间的玩家
    
    int mRoundNum;//这个是进行的局数
    long long mCurrent;//目前正在进行录音的好友
    long long mPrevious;//上一个录音的好友
    NSString *mKeyWord;
    NSString *mRoomName;
    long long mRoomID;
}

@property(nonatomic,retain)NSMutableDictionary *mGameUsers;
@property(nonatomic,retain)NSString *mKeyWord;

@property(nonatomic)int mRoundNum;
@property(nonatomic)long long mPrevious;
@property(nonatomic)long long mCurrent;
@property(nonatomic)ROOM_GAME_STATE mGameState;
@property(nonatomic,retain)NSString *mRoomName;
@property(nonatomic)long long mRoomID;
@end
