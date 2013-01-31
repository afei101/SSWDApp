//
//  ConstantData.h
//  SSWDApp
//
//  Created by gaofei on 13-1-23.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import <Foundation/Foundation.h>
// [头像类型]
typedef enum ICON_STATE
{
    ICON_STATE_SMALL = 1,		//游戏运行时的小头像类型
    ICON_STATE_MIDDLE = 2,		//游戏结束显示结果时候的头像类型
    ICON_STATE_BIG = 3, 		//创建游戏时的大头像类型
}ICON_STATE;


// [游戏玩家在游戏中的状态]
typedef enum GAME_USER_STATE
{
    TALKING_GAME_USER_STATE = 1,		//表示玩家正在说话，上传数据
    DEAD_GAME_USER_STATE = 2,           //表示玩家已经死亡
    WAIT_GAME_USER_STATE = 3, 		//表示玩家已经上传过数据，等待其他玩家上传数据
    READY_GAME_USER_STATE = 4 //表示玩家还没有上传数据，并且还没有轮到玩家上传数据
}GAME_USER_STATE;