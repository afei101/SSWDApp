//
//  IShareDefine.h
//  NoxEngine
//
//  Created by 飞 高 on 12-2-22.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

// [C->S]
#define STATE_CMD_CSRegister                        1//注册
#define STATE_CMD_CSLogin                           2//登陆回包
#define STATE_Cmd_CSGetHallInfo                     3//获取大厅信息
#define STATE_Cmd_CSCreateRoom                      4//创建房间
#define STATE_Cmd_CSEnterRoom                       5//进入房间
#define STATE_Cmd_CSLeaveRoom                       6//离开房间
#define STATE_Cmd_CSGetRoomInfo                     7//获取房间信息
#define STATE_Cmd_CSPlayReady                       8///玩家准备
#define STATE_Cmd_CSRoundVoice                      9//玩家上传录音
#define STATE_Cmd_CSRoundVote                       10//玩家投票
#define STATE_Cmd_CSHello                           11//心跳包，一分钟一次，无需回包      		
#define STATE_Cmd_CSLogout                          99//用户登出
        		

// [S->C]
#define STATE_CMD_SCRegisterRsp                     1001//用户注册返回包
#define STATE_CMD_SCLoginRsp                        1002//用户登录返回包
#define STATE_Cmd_SCGetHallInfoRsp                  1003//获取大厅信息返回包
#define STATE_Cmd_SCCreateRoomRsp                   1004//创建房间返回包
#define STATE_Cmd_SCEnterRoomRsp                    1005//进入房间返回包
#define STATE_Cmd_SCLeaveRoomRsp                    1006//离开房间返回包
#define STATE_Cmd_SCGetRoomInfoRsp                  1007//获取房间信息返回包
#define STATE_Cmd_SCPlayReadyRsp                    1008//玩家准备返回包
#define STATE_Cmd_SCRoundVoiceRsp                   1009//玩家上传录音返回包
#define STATE_Cmd_SCRoundVoteRsp                    1010//玩家投票返回包
#define STATE_Cmd_SCLogoutRsp                       1099//用户登出


#define STATE_Cmd_SCUserStateChage                  100//玩家状态通知
#define STATE_Cmd_SCRoomStateChage                  101//房间状态通知
#define STATE_Cmd_SCHallStateChage                  102//大厅状态通知
	

