//
//  TCPNetEngine.h
//  solomon
//
//  Created by Du Jin on 11-12-1.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpyTypeDef.h"



#define SHOW_VERIFYCODE_NOTIFICATION  @"__SHOW_VERIFYCODE_NOTIFICATION__"
#define SHOW_VERIFYCODE_NOTIFICATION_ERROR  @"SHOW_VERIFYCODE_NOTIFICATION_ERROR"
#define SHOW_VERIFYCODE_PASSWORD_ERROR  @"SHOW_VERIFYCODE_PASSWORD_ERROR"
#define LOGIN_RESULT_NOTIFICATION  @"__LOGIN_RESULT_NOTIFICATION__"
#define LOGIN_REGISTER_NOTIFICATION @"__LOGIN_REGISTER_NOTIFICATION__"

@class DataTransferHelper;

@interface TCPNetEngine : NSObject{
    int m_seqNo;
    NSMutableDictionary * _selectorDict;
    NSMutableDictionary *_reqheader;
    
    NSString* cryptKey;
    NSTimeInterval timeoffset;
    long long   serverCurrTime; // 从服务器拿到的时间
    long long   serverSwitch; //控制客户端的功能开关
    
//    UserIdInfo *_idInfo;
    
    int isLoginSucceed;     //是否登录成功 1成功 0不成功
    
    NSMutableDictionary * recvingMsg;
    NSMutableDictionary * sendingMsg;
    
    NSData *mStuff;
    NSData *mTokenA8;
    
    NSString *sessionID;
    NSString *sQQ;
    NSString *iconMD5;
    int iconSegmentCount;
    int iconSegmentSend;
    
    NSMutableArray *userArray;
    NSMutableArray *qqFriendsArray;
    
    int numberOfQQFriends;
    BOOL isAddFriend;
    
    long long timeInterval;
    BOOL bLoginViewController;
    BOOL bQQAuthorizeViewController;
    
    NSTimer    *helloTimer;
}
@property(nonatomic,strong)NSString* cryptKey;
@property(nonatomic,readonly)long long   serverCurrTime;
@property(nonatomic,readonly)long long   serverSwitch;
@property(nonatomic,readonly)  NSTimeInterval timeoffset;
@property(nonatomic,retain)NSTimer    *helloTimer;
@property(nonatomic) int isLoginSucceed;
@property(nonatomic) int m_seqNo;
@property(nonatomic, strong) NSData * mStuff;
@property(nonatomic,strong) NSData *mTokenA8;
@property(nonatomic,strong) NSString *sQQ;
@property(nonatomic,strong) NSString *iconMD5;
@property(nonatomic) int iconSegmentCount;
@property(nonatomic) int iconSegmentSend;
@property(nonatomic ,strong) NSString *sessionID; 
@property(nonatomic,strong)NSMutableArray *userArray;
@property(nonatomic,strong)NSMutableArray *qqFriendsArray;
@property(nonatomic) int numberOfQQFriends;
@property(nonatomic) BOOL isAddFriend;
@property(nonatomic) long long timeInterval;
@property(nonatomic) BOOL bLoginViewController;
@property(nonatomic) BOOL bQQAuthorizeViewController;

+ (TCPNetEngine *)getInstance;
- (void)initHeader;
+ (long long)getCurrentTime;
- (void)sendHello;
@end

@interface TCPNetEngine (TCPRequest)
//Add end
-(NSData *)getReqLoginData:(CSLogin *)login ;
-(NSData *)getReqRegisterData:(CSRegister*)csregister;
-(NSData *)getReqLogoutData:(CSLogout *)logout;
-(NSData *)getReqGetHallInfo:(CSGetHallInfo *)getHallInfo;
-(NSData *)getReqCreateRoom:(CSCreateRoom *)createRoom;
-(NSData *)getReqCSEnterRoom:(CSEnterRoom *)enterRoom;
-(NSData *)getReqCSLeaveRoom:(CSLeaveRoom *)leaveRoom;
-(NSData *)getReqCSGetRoomInfo:(CSGetRoomInfo *)getRoomInfo;
-(NSData *)getReqCSUserPlayReady:(CSUserPlayReady *)userPlayReady;
-(NSData *)getReqCSRoundVoice:(CSRoundVoice *)roundVocie;
-(NSData *)getReqCSRoundVote:(CSRoundVote *)roundVote;
@end

@interface TCPNetEngine (TCPResponse)
-(int)getCmd:(NSData*)rspData;
-(SCRegisterRsp*)getRegisterRspData:(NSData*)rspData;
-(SCLoginRsp*)getLoginRspData:(NSData*)rspData;
-(SCLogoutRsp*)getLogoutRspData:(NSData*)rspData;
-(SCCreateRoomRsp*)getCreateRoomRspData:(NSData*)rspData;
-(SCGetHallInfoRsp*)getHallInfoRspData:(NSData*)rspData;
-(SCEnterRoomRsp*)getEnterRoomRspData:(NSData*)rspData;
-(SCLeaveRoomRsp*)getLeaveRoomRspData:(NSData*)rspData;
-(SCGetRoomInfoRsp*)getGetRoomInfoRspData:(NSData*)rspData;
-(SCUserPlayReadyRsp*)getUserPlayReadyRspData:(NSData*)rspData;
-(SCRoundVoiceRsp*)getRoundVoiceRspData:(NSData*)rspData;
-(SCRoundVoteRsp*)getRoundVoteRspData:(NSData*)rspData;
-(SCRoomStateChange*)getRoomStateChangeRspData:(NSData*)rspData;
-(SCUserStateChange*)getUserStateChangeRspData:(NSData*)rspData;
@end
