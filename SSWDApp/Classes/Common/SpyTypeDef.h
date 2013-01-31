//
//  iShareTypeDef.h
//  NoxEngine
//
//  Created by 飞 高 on 12-2-22.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

// [房间游戏状态]
typedef enum ROOM_GAME_STATE
{
    ROOM_GAME_STATE_GameWait = 1,		//游戏等待中，无数据
    ROOM_GAME_STATE_GameReady = 2,		//游戏准备中，无数据
    ROOM_GAME_STATE_GameStart = 3, 		//[仅事件通知]游戏开始，无数据
    ROOM_GAME_STATE_RoundVoice = 4, 	//通知某个玩家开始依次上传音频，使用RoundVoiceInfo
    ROOM_GAME_STATE_RoundVote = 5, 		//[仅事件通知]通知所有玩家开始投票，无数据
    ROOM_GAME_STATE_NA
}ROOM_GAME_STATE;

// [玩家游戏状态]
typedef enum USER_GAME_STATE
{
    USER_GAME_STATE_Wait = 1,		//进入房间，开始等待
    USER_GAME_STATE_Ready = 2, 		//准备
    USER_GAME_STATE_Play = 3, 		//正在爽
    USER_GAME_STATE_Kickoffed = 4, 	//已出局，正围观
    USER_GAME_STATE_Out = 5,		//离开房间
    USER_GAME_STATE_NA
}USER_GAME_STATE;

// [ID类型]
typedef enum ID_TYPE {
    ID_TYPE_SINAWEIBO = 1, //腾讯微博
    ID_TYPE_QQWEIBO = 2, //新浪微博
    ID_TYPE_RENREN = 3, //人人
    ID_TYPE_NA
}ID_TYPE;

// [房间使用状态]
typedef enum  ROOM_USE_STATE
{
    ROOM_STATE_Play = 1, 	//正在玩
    ROOM_STATE_Ready = 2, 	//正在准备
    ROOM_STATE_Used = 3, 	//有人使用
    ROOM_STATE_Empty = 4, 	//空
    ROOM_STATE_NA
}ROOM_USE_STATE;

// [TLV协议结构]
@interface Tag:NSObject
{
	NSString* strId;
	NSData* value;
}
@property (nonatomic,strong) NSString* strId;
@property (nonatomic,strong) NSData* value;
@end

/*---------------    公用结构体   -------------------*/
@interface CmdResult:NSObject
{
	int iCmdId;           	// 命令ID, 无命令id可填0
	int iErrCode;       		// 处理结果，为0表示成功，非0失败
	NSString* strErrDesc;     	// 失败原因，在errorCode非0时有意义, UTF-8编码
	int iSubErrCode;   		// 二级错误码, 通常用来透传第三方服务的错误码(比如验证码)
}
@property (nonatomic) int iCmdId;
@property (nonatomic) int iErrCode;
@property (nonatomic,strong) NSString* strErrDesc;
@property (nonatomic) int iSubErrCode;
@end

//[玩家基本信息]
@interface UserBaseInfo : NSObject{
    long long uuid;
    ID_TYPE eType;
    NSString *strID;
    NSString *strCover;
    NSString *strNick;
}

@property (nonatomic) long long uuid;
@property (nonatomic) ID_TYPE eType;
@property (nonatomic,retain) NSString *strID;
@property (nonatomic,retain) NSString *strCover;
@property (nonatomic,retain) NSString *strNick;
@end


// [玩家详细信息]
@interface UserInfo:NSObject
{
    UserBaseInfo *stBaseInfo;
    unsigned int iTotalTimes;
    unsigned int iWinTimes;
    unsigned int iLostTimes;
    unsigned int iLevel;
    Byte cGender;
    NSString *strEmail;
    NSString *strDesc;
}

@property(nonatomic)unsigned int iTotalTimes;
@property(nonatomic)unsigned int iWinTimes;
@property(nonatomic)unsigned int iLostTimes;
@property(nonatomic)unsigned int iLevel;
@property(nonatomic)Byte cGender;
@property(nonatomic,retain)NSString *strEmail;
@property(nonatomic,retain)NSString *strDesc;
@property(nonatomic,retain)UserBaseInfo *stBaseInfo;

@end

// [公用包头]
@interface Header:NSObject
{
    short shVer; 	// 协议版本
	long long lCurrTime;  	// 当前时间，由发起方填写。
	CmdResult* stResult;  // 应答包中的结果
    unsigned int uAccIp;
    UserBaseInfo *stBaseUserInfo;
}
@property (nonatomic) short shVer;
@property (nonatomic) long long lCurrTime;
@property (nonatomic,retain) UserBaseInfo* stBaseUserInfo;
@property (nonatomic,retain) CmdResult* stResult;
@property (nonatomic)unsigned int uAccIp;
@end

// [用户密钥信息]
@interface UserSvrInfo:NSObject
{
    UserInfo *stUserInfo;
    NSData *vKey;
}

@property (nonatomic,retain) UserInfo *stUserInfo;
@property (nonatomic,retain) NSData *vKey;
@end

// [房间基本信息]用于大厅显示
@interface RoomBaseInfo:NSObject
{
    long long lRoomId;		//房价ID
    NSString *strRoomName;	//房间名称
    ROOM_USE_STATE eUseState;	//房间使用状态
    int nMaxMembers;		//房间最大限制人数
    int nCurMembers;		//房价当前人数
    long long lCreateUser;		//房间创建者
}

@property (nonatomic) long long lRoomId;
@property (nonatomic) long long lCreateUser;
@property (nonatomic) int nMaxMembers;
@property (nonatomic) int nCurMembers;
@property (nonatomic) ROOM_USE_STATE eUseState;
@property (nonatomic,retain) NSString *strRoomName;
@end

// [大厅基本信息]
@interface HallBaseInfo:NSObject
{
    int nRoomNum;			//当前房间数
    int nUserNum;		//大厅当前人数
    NSMutableDictionary *mapRoomInfo;//房间信息
}

@property (nonatomic) int nRoomNum;
@property (nonatomic) int nUserNum;
@property (nonatomic,retain) NSMutableDictionary *mapRoomInfo;
@end

// [玩家游戏信息]
@interface UserGameInfo:NSObject
{
    UserBaseInfo *stUserInfo;
    USER_GAME_STATE eGameState;
    long long lRoomId;			//所在房间ID
}

@property (nonatomic) long long lRoomId;
@property (nonatomic) USER_GAME_STATE eGameState;
@property (nonatomic,retain) UserBaseInfo *stUserInfo;
@end

// [房间详细信息]用于参与玩家显示
@interface RoomDetailInfo:NSObject
{
    RoomBaseInfo *stBaseInfo;			//基本信息
    ROOM_GAME_STATE eGameState;		//房间游戏状态
    int iStateUserCnt;
    NSMutableDictionary *mapUserInfo;
}

@property (nonatomic) ROOM_GAME_STATE eGameState;
@property (nonatomic,retain) RoomBaseInfo *stBaseInfo;
@property (nonatomic,retain) NSMutableDictionary *mapUserInfo;
@property (nonatomic)int iStateUserCnt;
@end

@interface CSRegister:NSObject
{
    UserInfo *stUserInfo;
}

@property (nonatomic,retain) UserInfo *stUserInfo;
@end

@interface SCRegisterRsp:NSObject
{
    int iErrCode;			//0成功，1失败
    int IsNewUser;		//是否新用户 1：新用户，0是旧用户
    UserSvrInfo *stUserSvrInfo;	//新用户时，会返回加密Key，旧用户时，只返回基本信息
}

@property (nonatomic) int iErrCode;
@property (nonatomic) int IsNewUser;
@property (nonatomic,retain) UserSvrInfo *stUserSvrInfo;
@end


//登入、登出请求
@interface CSLogin:NSObject
{
    long long uuid;
    NSString *strIosToken;	//IOS的token，用于push
}

@property (nonatomic) long long uuid;
@property (nonatomic,retain) NSString *strIosToken;	//IOS的token，用于push
@end

@interface SCLoginRsp:NSObject
{
    int iErrCode;			//0登录成功，1登录失败
}

@property (nonatomic) int iErrCode;
@end

@interface CSLogout:NSObject
{
    long long uuid;
    NSString *strIosToken;		//IOS的token，用于push
}

@property (nonatomic)long long uuid;
@property (nonatomic,retain) NSString *strIosToken;
@end

@interface SCLogoutRsp:NSObject
{
    int iErrCode;			//0登录成功，1登录失败
}
@property (nonatomic) int iErrCode;
@end

//获取大厅信息
@interface CSGetHallInfo:NSObject
{
    long long uuid;
}
@property (nonatomic) long long uuid;
@end

@interface SCGetHallInfoRsp:NSObject
{
    int iErrCode;			//0获取成功，1失败
    HallBaseInfo *stHallInfo;		//大厅信息
}
@property (nonatomic) int iErrCode;
@property (nonatomic,retain) HallBaseInfo *stHallInfo;
@end

//创建房间
@interface CSCreateRoom:NSObject
{
    long long lCreateUser;
    NSString *strRoomName;
}

@property (nonatomic) long long lCreateUser;
@property (nonatomic,retain) NSString *strRoomName;
@end

@interface SCCreateRoomRsp:NSObject
{
    int iErrCode;			//0成功，1失败
    RoomDetailInfo *stRoomInfo;
}
@property(nonatomic) int iErrCode;
@property(nonatomic,retain) RoomDetailInfo *stRoomInfo;
@end


//进入房间信息
@interface CSEnterRoom:NSObject
{
    long long uuid;
    long long lRoomId;
}

@property(nonatomic)long long uuid;
@property(nonatomic)long long lRoomId;
@end


@interface SCEnterRoomRsp:NSObject
{
    int iErrCode;			//0成功，1失败
    RoomDetailInfo *stRoomInfo;
}

@property(nonatomic) int iErrCode;
@property(nonatomic,retain) RoomDetailInfo *stRoomInfo;
@end

//离开房间信息
@interface CSLeaveRoom:NSObject
{
    long long uuid;
    long long lRoomId;
}
@property(nonatomic) long long uuid;
@property(nonatomic) long long lRoomId;
@end

@interface SCLeaveRoomRsp:NSObject
{
    int iErrCode;			//0成功，1失败
}

@property(nonatomic) int iErrCode;
@end

//获取房间信息
@interface CSGetRoomInfo:NSObject
{
    long long lRoomId;
}

@property(nonatomic)long long lRoomId;
@end

@interface SCGetRoomInfoRsp:NSObject
{
    int iErrCode;			//0成功，1失败
    RoomDetailInfo *stRoomInfo;
}

@property(nonatomic)int iErrCode;
@property(nonatomic,retain)RoomDetailInfo *stRoomInfo;
@end

//玩家Ready
@interface CSUserPlayReady:NSObject
{
    long long lRoomId;
    UserGameInfo *stUserInfo;
}
@property(nonatomic)long long lRoomId;
@property(nonatomic,retain)UserGameInfo *stUserInfo;
@end

@interface SCUserPlayReadyRsp:NSObject
{
    int iErrCode;			//0成功，1失败
}

@property(nonatomic)int iErrCode;
@end

//玩家上传录音
@interface CSRoundVoice:NSObject
{
    long long uuid;
    long long lRoomId;
    NSData *vVoiceData;
}
@property(nonatomic) long long uuid;
@property(nonatomic) long long lRoomId;
@property(nonatomic,retain)  NSData *vVoiceData;
@end

@interface SCRoundVoiceRsp:NSObject
{
    int iErrCode;			//0成功，1失败
}

@property(nonatomic)int iErrCode;
@end

//玩家投票
@interface CSRoundVote:NSObject
{
    long long uuid;
    long long lRoomId;
    long long lVotedUser;
}

@property(nonatomic)long long uuid;
@property(nonatomic)long long lVotedUser;
@property(nonatomic)long long lRoomId;
@end

@interface SCRoundVoteRsp:NSObject
{
    int iErrCode;			//0成功，1失败
}

@property(nonatomic)int iErrCode;
@end

/*---------------------------  下行 业务协议-------------------------------------*/
@interface SCUserStateChange:NSObject
{
    long long lRoomId;
    UserGameInfo *stUserInfo;
}

@property(nonatomic)long long lRoomId;
@property(nonatomic,retain)UserGameInfo *stUserInfo;
@end

// [某轮所用词语]
@interface RoundWordInfo:NSObject
{
    int nRoundNum;              //第几轮游戏
    long long lCurrentUser;		//当前玩家
    long long lFirstUser;       //第一个发言的用户
    NSString *strGameWords;		//获得的词语
}
@property(nonatomic)int nRoundNum;	
@property(nonatomic)long long lCurrentUser;
@property(nonatomic,retain)NSString *strGameWords;
@property(nonatomic)long long lFirstUser;
@end

// [某轮某用户发言]
@interface RoundVoiceInfo:NSObject
{
    int nRoundNum;			//第几轮游戏
    long long lCurrentUser;		//轮询到的当前玩家发言，传递到最后一个时，该值为lCurrentUser=lPreviousUser
    long long lPreviousUser;		//上一个上传音频的玩家，第一个发言则为空
    NSData *vPreviousUserVoice;	//上一个玩家的音频数据，第一个发言则为空
}

@property(nonatomic)int nRoundNum;
@property(nonatomic)long long lCurrentUser;
@property(nonatomic)long long lPreviousUser;
@property(nonatomic,retain)NSData *vPreviousUserVoice;
@end

// [游戏结果]
@interface GameResultInfo:NSObject
{
    int iResult;  	//0表示SpyOut卧底出局，正方胜利，1表示SpyRemain卧底潜伏至2人，反方胜利
    int iSpyUser;		//卧底用户
    NSString *strSpyWords;	//卧底词语
    NSString *strOtherWords;	//其他人词语
}

@property(nonatomic)int iResult;
@property(nonatomic)int iSpyUser;
@property(nonatomic,retain)NSString *strSpyWords;
@property(nonatomic,retain)NSString *strOtherWords;
@end

// [某轮投票结果]
@interface RoundVoteInfo:NSObject
{
    int iRestart;				//是否重新开始，0表示游戏结束，1表示下一轮
    int iVoteUser;			//本轮出局的人，为0时表示有2人以上得票一样，没人出局
    GameResultInfo *stGameResult;	//游戏结束信息
    long long lFirstUser;			//下一轮第一个发言的用户
    
    NSMutableDictionary *mVoteResult;//用户的投票结果<被投用户，票数>>
    NSMutableDictionary *mVoteInfo;//每个用户的投票详细情况<投票用户，被投票用户>
}

@property(nonatomic)int iRestart;
@property(nonatomic)int iVoteUser;
@property(nonatomic)long long lFirstUser;
@property(nonatomic,retain) GameResultInfo *stGameResult;
@property(nonatomic,retain) NSMutableDictionary *mVoteResult;
@property(nonatomic,retain) NSMutableDictionary *mVoteInfo;
@end


@interface SCRoomStateChange:NSObject
{
    RoomBaseInfo *stBaseInfo;			//基本信息
    ROOM_GAME_STATE eGameState;		//房间游戏状态，根据不同的状态，调用不同结构体
    RoundWordInfo *stWordInfo;		//RoundStart
    RoundVoiceInfo *stVoiceInfo;		//RoundVoice
    RoundVoteInfo *stVoteInfo;		//RoundEnd
    GameResultInfo *stResultInfo;		//GameEnd
}

@property(nonatomic)ROOM_GAME_STATE eGameState;	
@property(nonatomic,retain)RoomBaseInfo *stBaseInfo;
@property(nonatomic,retain)RoundWordInfo *stWordInfo;
@property(nonatomic,retain)RoundVoiceInfo *stVoiceInfo;
@property(nonatomic,retain)RoundVoteInfo *stVoteInfo;
@property(nonatomic,retain)GameResultInfo *stResultInfo;
@end


@interface SCHallStateChange:NSObject
{
    HallBaseInfo *stHallInfo;		//大厅信息
}

@property(nonatomic,retain)HallBaseInfo *stHallInfo;		//大厅信息
@end
