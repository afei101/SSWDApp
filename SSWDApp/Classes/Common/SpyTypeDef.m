//
//  iShareTypeDef.m
//  NoxEngine
//
//  Created by 飞 高 on 12-2-22.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#import "SpyTypeDef.h"

@implementation Tag
@synthesize strId;
@synthesize value;

-(void)dealloc{
    [strId release];
    [value release] ;
    [super dealloc];
}
@end

// [公用包头]
@implementation Header
@synthesize shVer;
@synthesize lCurrTime;
@synthesize stResult;
@synthesize uAccIp;
@synthesize stBaseUserInfo;

-(void)dealloc{
    [stResult release];
    [stBaseUserInfo release] ;
    [super dealloc];
}
@end

@implementation CSLogin
@synthesize uuid;
@synthesize strIosToken;

-(void)dealloc{
    [strIosToken release];
    [super dealloc];
}
@end

@implementation SCLoginRsp
@synthesize iErrCode;

-(void)dealloc{
    [super dealloc];
}
@end


@implementation CmdResult
@synthesize iCmdId;
@synthesize iErrCode;
@synthesize strErrDesc;
@synthesize iSubErrCode;

-(void)dealloc{
    [strErrDesc release];
    [super dealloc];
}
@end

@implementation UserBaseInfo
@synthesize uuid;
@synthesize eType;
@synthesize strID;
@synthesize strCover;
@synthesize strNick;

-(void)dealloc{
    [strID release];
    [strCover release];
    [strNick release];
    [super dealloc];
}
@end

@implementation UserInfo
@synthesize iTotalTimes;
@synthesize iWinTimes;
@synthesize iLostTimes;
@synthesize iLevel;
@synthesize cGender;
@synthesize strEmail;
@synthesize strDesc;
@synthesize stBaseInfo;

-(void)dealloc{
    [strEmail release];
    [strDesc release];
    [stBaseInfo release];
    [super dealloc];
}
@end

@implementation CSRegister
@synthesize stUserInfo;

-(void)dealloc{
    [stUserInfo release];
    [super dealloc];
}
@end

@implementation SCRegisterRsp
@synthesize iErrCode;
@synthesize IsNewUser;
@synthesize stUserSvrInfo;

-(void)dealloc{
    [stUserSvrInfo release];
    [super dealloc];
}
@end

@implementation UserSvrInfo
@synthesize stUserInfo;
@synthesize vKey;

-(void)dealloc{
    [stUserInfo release];
    [vKey release];
    [super dealloc];
}
@end

@implementation RoomBaseInfo
@synthesize lRoomId;
@synthesize strRoomName;
@synthesize eUseState;
@synthesize nMaxMembers;
@synthesize nCurMembers;
@synthesize lCreateUser;

-(void)dealloc{
    [strRoomName release];
    [super dealloc];
}
@end

@implementation HallBaseInfo
@synthesize nRoomNum;
@synthesize nUserNum;
@synthesize mapRoomInfo;


-(void)dealloc{
    [mapRoomInfo release];
    [super dealloc];
}
@end

@implementation UserGameInfo
@synthesize stUserInfo;
@synthesize eGameState;
@synthesize lRoomId;

-(void)dealloc{
    [stUserInfo release];
    [super dealloc];
}
@end

@implementation RoomDetailInfo
@synthesize stBaseInfo;
@synthesize eGameState;
@synthesize mapUserInfo;
@synthesize iStateUserCnt;

-(void)dealloc{
    [stBaseInfo release];
    [mapUserInfo release];
    [super dealloc];
}
@end


@implementation CSLogout
@synthesize uuid;
@synthesize strIosToken;

-(void)dealloc{
    [strIosToken release];
    [super dealloc];
}
@end

@implementation SCLogoutRsp
@synthesize iErrCode;

-(void)dealloc{
    [super dealloc];
}
@end

//获取大厅信息
@implementation CSGetHallInfo
@synthesize uuid;

-(void)dealloc{
    [super dealloc];
}
@end

@implementation SCGetHallInfoRsp
@synthesize iErrCode;
@synthesize stHallInfo;

-(void)dealloc{
    [stHallInfo release];
    [super dealloc];
}
@end

@implementation CSCreateRoom
@synthesize lCreateUser;
@synthesize strRoomName;

-(void)dealloc{
    [strRoomName release];
    [super dealloc];
}
@end

@implementation SCCreateRoomRsp
@synthesize iErrCode;
@synthesize stRoomInfo;

-(void)dealloc{
    [stRoomInfo release];
    [super dealloc];
}
@end

@implementation CSEnterRoom
@synthesize uuid;
@synthesize lRoomId;

-(void)dealloc{
    [super dealloc];
}
@end

@implementation SCEnterRoomRsp
@synthesize iErrCode;
@synthesize stRoomInfo;

-(void)dealloc{
    [stRoomInfo release];
    [super dealloc];
}
@end

@implementation CSLeaveRoom
@synthesize lRoomId;
@synthesize uuid;

-(void)dealloc{
    [super dealloc];
}
@end

@implementation SCLeaveRoomRsp
@synthesize iErrCode;

-(void)dealloc{
    [super dealloc];
}
@end

@implementation CSGetRoomInfo
@synthesize lRoomId;

-(void)dealloc{
    [super dealloc];
}
@end

@implementation SCGetRoomInfoRsp
@synthesize iErrCode;
@synthesize stRoomInfo;

-(void)dealloc{
    [stRoomInfo release];
    [super dealloc];
}
@end

@implementation CSUserPlayReady
@synthesize lRoomId;
@synthesize stUserInfo;

-(void)dealloc{
    [stUserInfo release];
    [super dealloc];
}
@end

@implementation SCUserPlayReadyRsp
@synthesize iErrCode;

-(void)dealloc{
    [super dealloc];
}
@end


@implementation CSRoundVoice
@synthesize uuid;
@synthesize lRoomId;
@synthesize vVoiceData;

-(void)dealloc{
    [vVoiceData release];
    [super dealloc];
}
@end

@implementation SCRoundVoiceRsp
@synthesize iErrCode;

-(void)dealloc{
    [super dealloc];
}
@end

@implementation CSRoundVote
@synthesize uuid;
@synthesize lVotedUser;
@synthesize lRoomId;

-(void)dealloc{
    [super dealloc];
}
@end

@implementation SCRoundVoteRsp
@synthesize iErrCode;

-(void)dealloc{
    [super dealloc];
}
@end

@implementation SCUserStateChange
@synthesize lRoomId;
@synthesize stUserInfo;

-(void)dealloc{
    [stUserInfo release];
    [super dealloc];
}
@end

@implementation RoundWordInfo
@synthesize nRoundNum;
@synthesize lCurrentUser;
@synthesize strGameWords;
@synthesize lFirstUser;

-(void)dealloc{
    [strGameWords release];
    [super dealloc];
}
@end

@implementation RoundVoiceInfo
@synthesize nRoundNum;
@synthesize lCurrentUser;
@synthesize lPreviousUser;
@synthesize vPreviousUserVoice;

-(void)dealloc{
    [vPreviousUserVoice release];
    [super dealloc];
}
@end

@implementation GameResultInfo
@synthesize iResult;
@synthesize iSpyUser;
@synthesize strSpyWords;
@synthesize strOtherWords;

-(void)dealloc{
    [strOtherWords release];
    [strSpyWords release];
    [super dealloc];
}
@end

@implementation RoundVoteInfo
@synthesize iRestart;
@synthesize iVoteUser;
@synthesize stGameResult;
@synthesize mVoteInfo;
@synthesize mVoteResult;
@synthesize lFirstUser;

-(void)dealloc{
    [stGameResult release];
    [mVoteResult release];
    [mVoteInfo release];
    [super dealloc];
}
@end

@implementation SCRoomStateChange
@synthesize stBaseInfo;
@synthesize eGameState;
@synthesize stWordInfo;
@synthesize stVoiceInfo;
@synthesize stVoteInfo;
@synthesize stResultInfo;


-(void)dealloc{
    [stBaseInfo release];
    [stWordInfo release];
    [stVoiceInfo release];
    [stVoteInfo release];
    [stResultInfo release];
    [super dealloc];
}
@end

@implementation SCHallStateChange
@synthesize stHallInfo;

-(void)dealloc{
    [stHallInfo release];
    [super dealloc];
}
@end

