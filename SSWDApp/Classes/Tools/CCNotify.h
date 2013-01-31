//
//  CCNotify.h
//  SSWDApp
//
//  Created by gaofei on 13-1-28.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import <Foundation/Foundation.h>
#define  NOTIFY_LOGIN_SUCCESS           @"NOTIFY_LOGIN_SUCCESS" //登陆成功的通知
#define  NOTIFY_CREATE_ROOM_SUCCESS     @"NOTIFY_CREATE_ROOM_SUCCESS" //创建房间成功
#define  NOTIFY_ENTER_ROOM_SUCCESS      @"NOTIFY_ENTER_ROOM_SUCCESS" //进入房间成功
#define  NOTIFY_USER_STATE_CHANGE       @"NOTIFY_USER_STATE_CHANGE"//游戏房间中的玩家状态发生变化
#define  NOTIFY_GAME_STATE_CHANGE       @"NOTIFY_GAME_STATE_CHANGE"//游戏状态发生变化，用于在游戏中的情况


@interface CCNotify : NSObject

+ (id)getObj:(NSDictionary*)obj byNum:(NSInteger)i;
+ (void)sentNotify:(NSString*)type obj:(id)content,... NS_REQUIRES_NIL_TERMINATION;
@end
