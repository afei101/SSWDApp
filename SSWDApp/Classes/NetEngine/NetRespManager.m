//
//  NetRespManager.m
//  SSWDApp
//
//  Created by gaofei on 13-1-28.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import "NetRespManager.h"
#import "SpyDefine.h"
#import "SpyDBManager.h"
#import "CCNotify.h"
#import "SSWDData.h"
#import "GameRoom.h"
@implementation NetRespManager

//初始化部分代码
+ (NetRespManager *)getInstance {
	static NetRespManager *instance;
	@synchronized(self) {
		if (!instance) {
			instance = [[NetRespManager alloc] init];
		}
	}
	return instance;
}

- (id)init
{
	if (self = [super init]) {
		//初始化相关变量
	}
	return self;
}

-(void)handleRsp:(NSData*)rspData{
    int cmd = [[TCPNetEngine getInstance] getCmd:rspData];
    NSLog(@"response comd : %d" , cmd);
    switch (cmd) {
        case STATE_CMD_SCRegisterRsp:{
            SCRegisterRsp*rsp = [[TCPNetEngine getInstance] getRegisterRspData:rspData];
            if (0 == rsp.iErrCode) {
                //登陆成功，首先保存有用的用户信息，然后发出消息，进行页面跳转
                [SpyDBManager setUuid:rsp.stUserSvrInfo.stUserInfo.stBaseInfo.uuid];
                [SpyDBManager setNickName:rsp.stUserSvrInfo.stUserInfo.stBaseInfo.strNick];
                [SpyDBManager setStrID:rsp.stUserSvrInfo.stUserInfo.stBaseInfo.strID];
                [SpyDBManager setIcon:rsp.stUserSvrInfo.stUserInfo.stBaseInfo.strCover];
                [SpyDBManager setLevel:rsp.stUserSvrInfo.stUserInfo.iLevel];
                [SpyDBManager setTotalTimes:rsp.stUserSvrInfo.stUserInfo.iTotalTimes];
                [SpyDBManager setWinTimes:rsp.stUserSvrInfo.stUserInfo.iWinTimes];
                [SpyDBManager setLostTimes:rsp.stUserSvrInfo.stUserInfo.iLostTimes];
                [SpyDBManager setCrypt:rsp.stUserSvrInfo.vKey];
                [SpyDBManager setUserType:rsp.stUserSvrInfo.stUserInfo.stBaseInfo.eType];
                
                //发送消息，通知界面进行页面跳转
                [CCNotify sentNotify:NOTIFY_LOGIN_SUCCESS obj:nil];
                
            }
            else{
                NSLog(@"登陆失败");
            }
        }
        break;
        case STATE_CMD_SCLoginRsp:{
            SCLoginRsp *rsp = [[TCPNetEngine getInstance] getLoginRspData:rspData];
            if (0 == rsp.iErrCode) {
                NSLog(@"登陆成功");
                //登陆成功 发送消息，通知界面进行页面跳转
                [CCNotify sentNotify:NOTIFY_LOGIN_SUCCESS obj:nil];
            }
            else{
                NSLog(@"登录失败");
            }
        }
            break;
        case STATE_Cmd_SCCreateRoomRsp:{
            SCCreateRoomRsp *rsp = [[TCPNetEngine getInstance] getCreateRoomRspData:rspData];
            if (0 == rsp.iErrCode) {
                NSLog(@"创建房间成功");
                //发送创建游戏房间成功的消息
                [CCNotify sentNotify:NOTIFY_CREATE_ROOM_SUCCESS obj:nil];
            }
            else{
                NSLog(@"创建房间失败");
            }
        }
        break;
        case STATE_Cmd_SCGetHallInfoRsp:{
            SCGetHallInfoRsp *rsp = [[TCPNetEngine getInstance] getHallInfoRspData:rspData];
            
            if (0 == rsp.iErrCode) {
                NSLog(@"获取大厅信息成功");
                NSArray *keys = [rsp.stHallInfo.mapRoomInfo allKeys]; // values in  foreach loop
                for (NSString *key in keys) {
                    RoomBaseInfo *roomBaseInfo = [rsp.stHallInfo.mapRoomInfo objectForKey:key];
                    [[SSWDData getInstance].mRoomInfo addObject:roomBaseInfo];
                    NSLog(@"roomid   : %lld" , roomBaseInfo.lRoomId);
                    NSLog(@"roomname : %@" , roomBaseInfo.strRoomName);
                }
            }
            else{
                NSLog(@"获取大厅信息失败");
            }
        }
        break;
        case STATE_Cmd_SCEnterRoomRsp:{
            SCEnterRoomRsp *rsp = [[TCPNetEngine getInstance] getEnterRoomRspData:rspData];
            
            if (0 == rsp.iErrCode) {
                NSLog(@"进入游戏室成功");
                RoomDetailInfo *detailInfo = rsp.stRoomInfo;
                [SSWDData getInstance].mGameRoom.mRoomID = detailInfo.stBaseInfo.lRoomId;
                [SSWDData getInstance].mGameRoom.mRoomName = detailInfo.stBaseInfo.strRoomName;
                [SSWDData getInstance].mGameRoom.mGameState = ROOM_GAME_STATE_GameWait;
                
                NSArray *keys = [detailInfo.mapUserInfo allKeys];
                [SSWDData getInstance].mGameRoom.mGameUsers = [[NSMutableDictionary alloc] init];
                for (NSNumber *suuid in keys) {
                    UserGameInfo *userGameInfo = [detailInfo.mapUserInfo objectForKey:suuid];
                    GameUser *gameUser = [[GameUser alloc] init];
                    gameUser.mIcon =  userGameInfo.stUserInfo.strCover;
                    gameUser.mNickName = userGameInfo.stUserInfo.strNick;
                    gameUser.mUserState = userGameInfo.eGameState;
                    gameUser.uuid = userGameInfo.stUserInfo.uuid;
                    [[SSWDData getInstance].mGameRoom.mGameUsers setObject:gameUser forKey:suuid];
                    [gameUser release]; 
                }
                
                //发送进入游戏房间成功的消息
                [CCNotify sentNotify:NOTIFY_ENTER_ROOM_SUCCESS obj:nil];
                
            }
            else{
                NSLog(@"进入游戏室失败");
            }
        }
            break;
        case STATE_Cmd_SCLeaveRoomRsp:{
            SCLeaveRoomRsp *rsp = [[TCPNetEngine getInstance] getLeaveRoomRspData:rspData];
            
            if (0 == rsp.iErrCode) {
                NSLog(@"离开游戏室成功");
            }
            else{
                NSLog(@"进入游戏室失败");
            }
        }
            break;
        case STATE_Cmd_SCRoomStateChage:{
            //主要是游戏进行中的状态变换
            SCRoomStateChange *rsp = [[TCPNetEngine getInstance] getRoomStateChangeRspData:rspData];
            if (NULL == rsp) {
                [SSWDData getInstance].mGameRoom.mGameState = rsp.eGameState;
                
                switch (rsp.eGameState) {
                    case ROOM_GAME_STATE_GameWait:
                    case ROOM_GAME_STATE_GameReady:{
                        NSLog(@"游戏目前处于准备状态，应该不会推送这种状态过来");
                    }
                        break;
                    case ROOM_GAME_STATE_GameStart:
                        NSLog(@"游戏正式开始");
                        [SSWDData getInstance].mGameRoom.mGameState = ROOM_GAME_STATE_GameStart;
                        [SSWDData getInstance].mGameRoom.mKeyWord = rsp.stWordInfo.strGameWords;
                        [SSWDData getInstance].mGameRoom.mRoundNum = rsp.stWordInfo.nRoundNum;
                        [SSWDData getInstance].mGameRoom.mCurrent = rsp.stWordInfo.lFirstUser;
                        [SSWDData getInstance].mGameRoom.mPrevious = 0;
                        
                        //此处发出消息，开始游戏，界面进行跳转
                        break;
                    case ROOM_GAME_STATE_RoundVoice:
                        NSLog(@"下一轮标失");
                        [SSWDData getInstance].mGameRoom.mCurrent = rsp.stVoiceInfo.lCurrentUser;
                        [SSWDData getInstance].mGameRoom.mRoundNum = rsp.stVoiceInfo.nRoundNum;
                        [SSWDData getInstance].mGameRoom.mPrevious = rsp.stVoiceInfo.lPreviousUser;
                        
                        GameUser *user = [[SSWDData getInstance].mGameRoom.mGameUsers objectForKey:[NSNumber numberWithLongLong:rsp.stVoiceInfo.lPreviousUser]];
                        if (user) {
                            user.voiceData = rsp.stVoiceInfo.vPreviousUserVoice;
                        }
                        
                        //发送消息，播送上一个说话的人的内容，然后等待下一个说话
                        //如果用户是下一个要说话的人，则用户开始录音
                        break;
                    default:
                        break;
                }
            }
        }
            break;
        case STATE_Cmd_SCPlayReadyRsp:{
            SCUserPlayReadyRsp *rsp = [[TCPNetEngine getInstance] getUserPlayReadyRspData:rspData];
            if (rsp.iErrCode == 0) {
                NSLog(@"准备游戏成功");
            }
            else{
                NSLog(@"准备游戏失败");
            }
        }
            break;
        //这里是大厅的所有状态变化
        case STATE_Cmd_SCUserStateChage:{
            SCUserStateChange *rsp = [[TCPNetEngine getInstance] getUserStateChangeRspData:rspData];
            if (NULL != rsp) {
                switch (rsp.stUserInfo.eGameState) {
                    case USER_GAME_STATE_Wait:{
                        //如果数组时空，则重新创建数组
                        if (NULL == [SSWDData getInstance].mGameRoom.mGameUsers)
                            [SSWDData getInstance].mGameRoom.mGameUsers = [[NSMutableDictionary alloc] init];
                        
                        //因为是一个新的用户进入房间，所以要创建一个新的好友，然后把好友加入好友列表的数据结构里面
                        GameUser *gameUser = [[GameUser alloc] init];
                        gameUser.mUserState = USER_GAME_STATE_Wait;
                        gameUser.mNickName = rsp.stUserInfo.stUserInfo.strNick;
                        gameUser.mIcon = rsp.stUserInfo.stUserInfo.strCover;
                        gameUser.uuid = rsp.stUserInfo.stUserInfo.uuid;
                        [[SSWDData getInstance].mGameRoom.mGameUsers setObject:gameUser forKey:[NSNumber numberWithLongLong:gameUser.uuid]];
                        [gameUser release];
                    }
                        break;
                    case USER_GAME_STATE_Ready:{
                        //用户有这个状态的时候，肯定这个用户已经加入到这个房间里面了
                        //所以只在用户列表里面找到这个用户，然后变换他的状态就可以了
                        GameUser *gameUser = [[SSWDData getInstance].mGameRoom.mGameUsers objectForKey:[NSNumber numberWithLongLong:rsp.stUserInfo.stUserInfo.uuid]];
                        //如果这个用户存在，则修改用户状态为准备好的状态
                        if (gameUser) {
                            gameUser.mUserState = USER_GAME_STATE_Ready;
                        }
                    }
                        break;
                    case USER_GAME_STATE_Out:{
                        //用户离开这个房间，说明用户已经是这个房间的，因为用户要离开这个房间，所以把这个用户从用户里表中删除即可
                        [[SSWDData getInstance].mGameRoom.mGameUsers removeObjectForKey:[NSNumber numberWithLongLong:rsp.stUserInfo.stUserInfo.uuid]];
                    }
                    case USER_GAME_STATE_Play:{
                        //目前不知道这个状态在什么情况下会push过来，所以暂时不做任何处理
                    }
                        break;
                    case USER_GAME_STATE_Kickoffed:{
                        //用户被踢出房间，目前虽然没有这个情况，不过如果发现这种状态，则和用户离开房间一样处理即可
                        //将用户从列表中删除
                        [[SSWDData getInstance].mGameRoom.mGameUsers removeObjectForKey:[NSNumber numberWithLongLong:rsp.stUserInfo.stUserInfo.uuid]];
                    }
                    default:
                        break;
                }
                //发送进入游戏房间成功的消息，这些消息都是在游戏房间这个界面接受的消息
                [CCNotify sentNotify:NOTIFY_USER_STATE_CHANGE obj:nil];
            }
        }
            break;
        default:
            break;
    }



}
@end
