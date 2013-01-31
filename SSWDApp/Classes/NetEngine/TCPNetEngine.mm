//
//  TCPNetEngine.m
//  solomon
//
//  Created by Du Jin on 11-12-1.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "TCPNetEngine.h"
#import "SpyProtocol.h"
#import "Crypt.h"
#import "SpyTypeDef.h"
#import "SpyDefine.h"
#import "SSWDData.h"
#import "SpyDBManager.h"
#import "CCTextField.h"
#define OS_32
//#define STATICKEY @"0000000000000000"
#define STATICKEY @"1234567890123456"

//#define NSLog
@interface NSData (Tea)
- (NSData *)TeaEncryptWithPaserString:(NSString *)key;
- (NSData *)TeaDecryptWithPaserString:(NSString *)key;
+ (vector<char>)date2vector:(NSData *)d;
+ (NSData *)dataWithCharVector:(vector<taf::Char>)c;
@end

@implementation NSData (Tea)
+ (NSData *)dataWithCharVector:(vector<taf::Char>)vc{
	taf::Char  *d=new  taf::Char[vc.size()]; 
	copy(vc.begin(),vc.end(),d); 
    if (d) {
        delete d;
    }
    
	return [NSData dataWithBytes:vc.data() length:vc.size()];
}

+ (vector<char>)date2vector:(NSData *)d{
    
	vector<char> vdata;
	vdata.resize([d length]);
	memcpy(&vdata[0], [d bytes], [d length]);
    
    return vdata;
}

// 16 byte key
- (NSData *)TeaEncryptWithPaserString:(NSString *)key
{
	//NSParameterAssert(key!=nil);
	const char * inValue = (const char *)[self bytes];
	const char * keyValue = [key UTF8String];
	int inValueLen = [self length];
	
	CCrypt crypt;
	crypt.SetArith(CRYPT_2, CRYPT_2);
	crypt.SetKey((unsigned char*)keyValue, [key lengthOfBytesUsingEncoding:NSASCIIStringEncoding]);
	
	int encryptBufferLen = crypt.FindEncryptSize(inValueLen);
	unsigned char * encryptBuffer = new unsigned char[encryptBufferLen+1];
	memset(encryptBuffer,0x0,encryptBufferLen);
	crypt.Encrypt((unsigned char *)inValue, inValueLen, encryptBuffer, encryptBufferLen);
	
	NSData * encryptData = [NSData dataWithBytes:encryptBuffer length:encryptBufferLen];
    
	
	if (encryptBuffer) {
		delete encryptBuffer;
	}
	return encryptData ;
}

- (NSData *)TeaDecryptWithPaserString:(NSString *)key
{

	//NSParameterAssert(key!=nil);
	const char * inValue = (const char *)[self bytes];
	const char * keyValue = [key UTF8String];
	int inValueLen = [self length];
	
	CCrypt crypt;
	crypt.SetArith(CRYPT_2, CRYPT_2);
	crypt.SetKey((unsigned char*)keyValue, [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
	
	unsigned char * decryptBuffer = new unsigned char [inValueLen+1];
	memset(decryptBuffer,0x0,inValueLen);
	int decryptBufferLen = inValueLen;
	crypt.Decrypt((unsigned char *)inValue, inValueLen, decryptBuffer, decryptBufferLen);
	
	NSData * descryptData = [NSData dataWithBytes:decryptBuffer length:decryptBufferLen];
	if (decryptBuffer) {
		delete decryptBuffer;
	}
	return descryptData;
}

@end

template <typename JceStructBase>
void serializeJceObj(JceStructBase& jceObj,vector<char>& outBuf)
{
    outBuf.clear();
	taf::JceOutputStream<> jos;
	jceObj.writeTo(jos);
    outBuf = jos.getByteBuffer();
}

template <typename JceStructBase>
void serializeJceObjWithEncrypt(JceStructBase& jceObj,vector<char>& outBuf,NSString *key)
{

    @autoreleasepool {
        taf::JceOutputStream<> jos;
        jceObj.writeTo(jos);
        
        NSData *preData = [NSData dataWithBytes:jos.getBuffer() length:jos.getLength()];
        NSData *enData = [preData TeaEncryptWithPaserString:key];
        NSUInteger length = [enData length];
        outBuf.clear();
        outBuf.resize(length);
        memcpy(&outBuf[0], [enData bytes], length);
    }
}


template <typename JceStructBase>
void serializeJceObjWithEncodeType(JceStructBase& jceObj,vector<char>& outBuf,int encodeType)
{
	switch (encodeType) {
        case 0:
            serializeJceObj(jceObj,outBuf);
            return ;
        case 1:
            serializeJceObjWithEncrypt(jceObj, outBuf,STATICKEY);
            return;
        case 2:
            serializeJceObjWithEncrypt(jceObj, outBuf, [[TCPNetEngine getInstance] cryptKey]);
        return;
    }
    
}

template <typename JceStructBase>
void deserializeJceObj(JceStructBase& jceObj, vector<char>& buf)
{
	taf::JceInputStream<> jis;
	jis.setBuffer(buf);
	jceObj.readFrom(jis);
}

template <typename JceStructBase>
void deserializeJceObjWithDecrypt(JceStructBase& jceObj, vector<char>& buf,NSString *key)
{
    @autoreleasepool {
        NSData *preData = [NSData dataWithBytes:buf.data() length:buf.size()];
        NSData *deData = [preData TeaDecryptWithPaserString:key];
        
        taf::JceInputStream<> jis;
        jis.setBuffer((const char*)[deData bytes], [deData length]);
        jceObj.readFrom(jis);
    }

    
}

template <typename JceStructBase>
void deserializeJceObjWithEncodeType(JceStructBase& jceObj, vector<char>& buf ,int encodyType)
{
    switch (encodyType) {
        case 0:
            deserializeJceObj(jceObj, buf);
            return;
        case 1:
            deserializeJceObjWithDecrypt(jceObj, buf,STATICKEY);
            return;
        case 2:
        {
            deserializeJceObjWithDecrypt(jceObj, buf,  [[TCPNetEngine getInstance] cryptKey]);
        }
        return;
    }
    
}


template <class   Type>
void  clearVector(vector<Type>&  vt)
{ 
    vector<Type> vtTemp; 
    vtTemp.swap(vt); 
} 

@interface TCPNetEngine (DataHelper)

-(NSData *) preRequestData:(SpyGame::CMD)cmd head:(vector<char> &)head body:(vector<char> &)body encodytype:(Byte)encodytype;

-(int) parsePacketData:(NSData *)data package:(SpyGame::Package &)package;

@end

@implementation TCPNetEngine (DataHelper)
-(NSData *)genPacketData:(vector<char>&)preBuf
{
    unsigned char* buf = new unsigned char[preBuf.size() + 6];
    memset(buf, 0xff, 1);
    memset(buf+1, 0xee, 1);
	int len = htonl(preBuf.size() + 6);
	memcpy(buf+2, &len, 4);
	memcpy(buf+6, (unsigned char*)preBuf.data(), preBuf.size());
    NSData *data = [NSData dataWithBytes:(char*)buf length:preBuf.size()+6];
    delete[] buf;
    return data;
}

-(NSData *) preRequestData:(SpyGame::CMD)cmd head:(vector<char> &)head body:(vector<char> &)body encodytype:(Byte)encodytype
{
    SpyGame::Package prePacked;

    prePacked.uuid =  100;
    prePacked.iSeqNo = m_seqNo;
    prePacked.eCmd = cmd;
    prePacked.cEncodeType = encodytype;
    prePacked.head = head;
    prePacked.body = body;
    vector<char> outbuf; 
    serializeJceObj(prePacked,outbuf);
    return [self genPacketData:outbuf];
}

-(NSData *) preRequestData:(SpyGame::CMD)cmd head:(vector<char> &)head body:(vector<char> &)body encodytype:(Byte)encodytype uuid:(long long)uuid
{
    SpyGame::Package prePacked;
    
    prePacked.uuid =  uuid;
    prePacked.iSeqNo = m_seqNo;
    prePacked.eCmd = cmd;
    prePacked.cEncodeType = encodytype;
    prePacked.head = head;
    prePacked.body = body;
    vector<char> outbuf; 
    serializeJceObj(prePacked,outbuf);
    return [self genPacketData:outbuf];
}

-(void )preResponseData:(NSData *)data outbuf:(vector<char> &)outbuf
{
    outbuf.clear();
    //NSLog(@"data length : %d" , [data length]);
    outbuf.resize([data length]);
    memcpy(&outbuf[0], (const char *)[data bytes], [data length]);  
}
-(int) parsePacketData:(NSData *)data package:(SpyGame::Package &)package

{
    vector<char> vbuff;
    [self preResponseData:data outbuf:vbuff];
    
    deserializeJceObj(package,vbuff);
    clearVector(vbuff);
    return package.cEncodeType;
}

@end



@implementation TCPNetEngine (TCPRequest)
#pragma mark TCPRequest oc2jce
- (SpyGame::CmdResult)formatIShareCmdResult:(CmdResult *)_cmdResult {
    SpyGame::CmdResult cmdR;
    cmdR.iCmdId = _cmdResult.iCmdId;
    cmdR.iErrCode = _cmdResult.iErrCode;
    cmdR.strErrDesc = [_cmdResult.strErrDesc UTF8String];
    cmdR.iSubErrCode = _cmdResult.iSubErrCode;
    
    return cmdR;
}

- (SpyGame::UserBaseInfo)formatishareUserBaseInfo:(UserBaseInfo *)_userBaseInfo {
    SpyGame::UserBaseInfo userBaseInfo;
    userBaseInfo.uuid = _userBaseInfo.uuid;
    userBaseInfo.eType = (SpyGame::ID_TYPE)_userBaseInfo.eType;
    userBaseInfo.strID = [_userBaseInfo.strID UTF8String];
    userBaseInfo.strCover = [_userBaseInfo.strCover UTF8String];
    userBaseInfo.strNick = [_userBaseInfo.strNick UTF8String];
    return userBaseInfo;
}

- (SpyGame::UserInfo)formatUserInfo:(UserInfo *)_userInfo {
    SpyGame::UserInfo userInfo;
    userInfo.iTotalTimes = _userInfo.iTotalTimes;
    userInfo.iWinTimes = _userInfo.iWinTimes;
    userInfo.iLostTimes = _userInfo.iLostTimes;
    userInfo.iLevel = _userInfo.iLevel;
    userInfo.cGender = _userInfo.cGender;
    userInfo.strDesc = [_userInfo.strDesc UTF8String];
    userInfo.strEmail = [_userInfo.strEmail UTF8String];
    
    userInfo.stBaseInfo = [self formatishareUserBaseInfo:_userInfo.stBaseInfo];
    return userInfo;
}

- (SpyGame::UserGameInfo)formatUserGameInfo:(UserGameInfo *)_userGameInfo {
    SpyGame::UserGameInfo userGameInfo;
    userGameInfo.lRoomId = _userGameInfo.lRoomId;
    userGameInfo.eGameState = (SpyGame::USER_GAME_STATE)_userGameInfo.eGameState;

    userGameInfo.stUserInfo = [self formatishareUserBaseInfo:_userGameInfo.stUserInfo];
    return userGameInfo;
}

#pragma mark TCPRequest convertHeaderData
-(void)convertHeaderData:(vector<char> &)head encodeType:(int)encodeType{
    SpyGame::Header header;
    //设置版本号
    if ([_reqheader objectForKey:@"shVer"]!=nil)
        header.shVer = [[_reqheader objectForKey:@"shVer"] shortValue];
    
    //设置时间（首先获取默认时间，然后获取实际时间）
    header.lCurrTime = [TCPNetEngine getCurrentTime];
    if ([_reqheader objectForKey:@"lCurrTime"]!=nil)
        header.lCurrTime = [[_reqheader objectForKey:@"lCurrTime"] intValue];
    
    header.stUserInfo = [self formatishareUserBaseInfo:[_reqheader objectForKey:@"stUserBaseInfo"]];
    
    //设置stResult
    if ([_reqheader objectForKey:@"stResult"]) {
        header.stResult = [self formatIShareCmdResult:[_reqheader objectForKey:@"stResult"]];
    }
    
    //设置Svr Id
    if ([_reqheader objectForKey:@"uAccIp"]) {
        header.uAccIp = [[_reqheader objectForKey:@"uAccIp"] intValue];
    }
    
    serializeJceObjWithEncodeType(header,head,encodeType);
}

//通过传入的协议数据获取最终的二进制数据
-(NSData *)getReqLoginData:(CSLogin *)login {
    //设置包头
    vector<char> head ;
    [self convertHeaderData:head encodeType:1];
    
    //设置包体
    SpyGame::CSLogin _login;
    _login.uuid = login.uuid;
    _login.strIosToken = [login.strIosToken UTF8String];
    
    vector<char>body;
    serializeJceObjWithEncodeType(_login, body, 1);
    
    NSData *data =  [self preRequestData:(SpyGame::Cmd_CSLogin) head:head body:body  encodytype:1];
    return data;
}

-(NSData *)getReqLogoutData:(CSLogout *)logout{
    //设置包头
    vector<char> head ;
    [self convertHeaderData:head encodeType:2];
    
    //设置包体
    SpyGame::CSLogout _logout;
    _logout.uuid = logout.uuid;
    _logout.strIosToken = [logout.strIosToken UTF8String];
    
    vector<char>body;
    serializeJceObjWithEncodeType(_logout, body, 2);
    
    NSData *data =  [self preRequestData:(SpyGame::Cmd_CSLogout) head:head body:body  encodytype:2];
    return data;
}

-(NSData *)getReqGetHallInfo:(CSGetHallInfo *)getHallInfo{
    //设置包头
    vector<char> head ;
    [self convertHeaderData:head encodeType:0];
    
    //设置包体
    SpyGame::CSLogout _getHallInfo;
    _getHallInfo.uuid = getHallInfo.uuid;
    
    vector<char>body;
    serializeJceObjWithEncodeType(_getHallInfo, body, 0);
    
    NSData *data =  [self preRequestData:(SpyGame::Cmd_CSGetHallInfo) head:head body:body  encodytype:0];
    return data;
}

-(NSData*)getReqRegisterData:(CSRegister*)csregister{
    //设置包头
    vector<char> head ;
    [self convertHeaderData:head encodeType:1];
    
    //设置包体
    SpyGame::CSRegister _csregister;
    _csregister.stUserInfo = [self formatUserInfo:csregister.stUserInfo];
    
    vector<char>body;
    serializeJceObjWithEncodeType(_csregister, body, 1);
    
    NSData *data =  [self preRequestData:(SpyGame::Cmd_CSRegister) head:head body:body  encodytype:1];
    return data;
}

-(NSData *)getReqCreateRoom:(CSCreateRoom *)createRoom{
    //设置包头
    vector<char> head ;
    [self convertHeaderData:head encodeType:1];
    
    //设置包体
    SpyGame::CSCreateRoom _createRoom;
    _createRoom.lCreateUser = createRoom.lCreateUser;
    _createRoom.strRoomName = [createRoom.strRoomName UTF8String];
    
    vector<char>body;
    serializeJceObjWithEncodeType(_createRoom, body, 1);
    
    NSData *data =  [self preRequestData:(SpyGame::Cmd_CSCreateRoom) head:head body:body  encodytype:1];
    return data;
}

-(NSData *)getReqCSEnterRoom:(CSEnterRoom *)enterRoom{
    //设置包头
    vector<char> head ;
    [self convertHeaderData:head encodeType:1];
    
    //设置包体
    SpyGame::CSEnterRoom _enterRoom;
    _enterRoom.lRoomId = enterRoom.lRoomId;
    _enterRoom.uuid = enterRoom.uuid;
    
    vector<char>body;
    serializeJceObjWithEncodeType(_enterRoom, body, 1);
    
    NSData *data =  [self preRequestData:(SpyGame::Cmd_CSEnterRoom) head:head body:body  encodytype:1];
    return data;
}

-(NSData *)getReqCSLeaveRoom:(CSLeaveRoom *)leaveRoom{
    //设置包头
    vector<char> head ;
    [self convertHeaderData:head encodeType:1];
    
    //设置包体
    SpyGame::CSLeaveRoom _leaveRoom;
    _leaveRoom.lRoomId = leaveRoom.lRoomId;
    _leaveRoom.uuid = leaveRoom.uuid;
    
    vector<char>body;
    serializeJceObjWithEncodeType(_leaveRoom, body, 1);
    
    NSData *data =  [self preRequestData:(SpyGame::Cmd_CSLeaveRoom) head:head body:body  encodytype:1];
    return data;
}

-(NSData *)getReqCSGetRoomInfo:(CSGetRoomInfo *)getRoomInfo{
    //设置包头
    vector<char> head ;
    [self convertHeaderData:head encodeType:0];
    
    //设置包体
    SpyGame::CSGetRoomInfo _getRoomInfo;
    _getRoomInfo.lRoomId = getRoomInfo.lRoomId;
    
    vector<char>body;
    serializeJceObjWithEncodeType(_getRoomInfo, body, 0);
    
    NSData *data =  [self preRequestData:(SpyGame::Cmd_CSGetRoomInfo) head:head body:body  encodytype:0];
    return data;
}

-(NSData *)getReqCSUserPlayReady:(CSUserPlayReady *)userPlayReady{
    //设置包头
    vector<char> head ;
    [self convertHeaderData:head encodeType:1];
    
    //设置包体
    SpyGame::CSUserPlayReady _userPlayReady;
    _userPlayReady.lRoomId = userPlayReady.lRoomId;
    _userPlayReady.stUserInfo = [self formatUserGameInfo:userPlayReady.stUserInfo];
    
    vector<char>body;
    serializeJceObjWithEncodeType(_userPlayReady, body, 1);
    
    NSData *data =  [self preRequestData:(SpyGame::Cmd_CSPlayReady) head:head body:body  encodytype:1];
    return data;
}

-(NSData *)getReqCSRoundVoice:(CSRoundVoice *)roundVocie{
    //设置包头
    vector<char> head ;
    [self convertHeaderData:head encodeType:0];
    
    //设置包体
    SpyGame::CSRoundVoice _roundVocie;
    _roundVocie.lRoomId = roundVocie.lRoomId;
    _roundVocie.uuid = roundVocie.uuid;    
    _roundVocie.vVoiceData = [NSData date2vector:roundVocie.vVoiceData];
    
    vector<char>body;
    serializeJceObjWithEncodeType(_roundVocie, body, 0);
    
    NSData *data =  [self preRequestData:(SpyGame::Cmd_CSRoundVoice) head:head body:body  encodytype:0];
    return data;
}

-(NSData *)getReqCSRoundVote:(CSRoundVote *)roundVote{
    //设置包头
    vector<char> head ;
    [self convertHeaderData:head encodeType:0];
    
    //设置包体
    SpyGame::CSRoundVote _roundVote;
    _roundVote.uuid = roundVote.uuid;
    _roundVote.lVotedUser = roundVote.lVotedUser;

    vector<char>body;
    serializeJceObjWithEncodeType(_roundVote, body, 0);
    
    NSData *data =  [self preRequestData:(SpyGame::Cmd_CSRoundVote) head:head body:body  encodytype:0];
    return data;
}
@end

@interface NSString (TCPPrivate)
+ (NSString *)stringWithStdString:(string)str;
@end
@implementation NSString (TCPPrivate)
+ (NSString *)stringWithStdString:(string)str{
	return [NSString stringWithCString:str.c_str()  encoding:NSUTF8StringEncoding];
}
@end

@implementation TCPNetEngine
@synthesize cryptKey;
@synthesize serverCurrTime;
@synthesize serverSwitch;
@synthesize timeoffset;
@synthesize isLoginSucceed;
@synthesize m_seqNo;
@synthesize mStuff;
@synthesize mTokenA8;
@synthesize sQQ;
@synthesize iconMD5;
@synthesize iconSegmentCount;
@synthesize iconSegmentSend;
@synthesize sessionID;
@synthesize userArray;
@synthesize qqFriendsArray;
@synthesize numberOfQQFriends;
@synthesize isAddFriend;
@synthesize timeInterval;
@synthesize bLoginViewController;
@synthesize bQQAuthorizeViewController;
@synthesize helloTimer;
//有用代码

//初始化部分代码
+ (TCPNetEngine *)getInstance {
	static TCPNetEngine *instance;
	@synchronized(self) {
		if (!instance) {
			instance = [[TCPNetEngine alloc] init];
		}
	}
	return instance;
}

- (id)init
{
	if (self = [super init]) {
		
		_selectorDict = [[NSMutableDictionary alloc] init];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
		NSString *_cryptKey = [defaults objectForKey:@"ISHARECRYPTKEY"];
        if (cryptKey==nil) {
            cryptKey = _cryptKey;
        }

        [defaults synchronize];
        recvingMsg = [[NSMutableDictionary alloc] init];
        sendingMsg = [[NSMutableDictionary alloc] init];
        
        mStuff = nil;
        
        userArray = [[NSMutableArray alloc] init];
        qqFriendsArray = [[NSMutableArray alloc] init];
        
        helloTimer = [NSTimer scheduledTimerWithTimeInterval: 30
                                         target: self
                                       selector: @selector(sendHello)
                                       userInfo: nil
                                        repeats: YES];
	}
	return self;
}

//目前来看，是对外的总接口
-(NSData*)getReqData:(NSDictionary *)dictionary{
    int cmd = [[dictionary objectForKey:@"cmd"] intValue] ;
    id arg = [dictionary objectForKey:@"arg"];
    
	switch (cmd) {
        case STATE_CMD_CSLogin:
        {
            return [self getReqLoginData:arg];
        }
    }
    return nil;
}

-(void)setCryptKey:(NSString *)_cryptKey{
    cryptKey = [_cryptKey copy];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:_cryptKey forKey:@"ISHARECRYPTKEY"];
	[defaults synchronize];
}

-(void)setPasswordMD5:(NSData*)pwdMD5{
    NSLog(@"passwordMD5");
//    [NXDBManager setCurrentPwd:pwdMD5];
}

-(NSData*)getHello{
    vector<char> empty;
    vector<char> head ;
    [self convertHeaderData:head encodeType:0];
    
    NSData *data =  [self preRequestData:(SpyGame::Cmd_CSHello) head:head body:empty  encodytype:0];
    return data;
}

-(void)sendHello{
    NSLog(@"send hello");
    [self initHeader];
    NSData *sendPackage = [self getHello];
    if ([SSWDData getInstance].mSockPtr) {
        [[SSWDData getInstance].mSockPtr writeData:sendPackage withTimeout:1000 tag:0] ;
    }
}

- (void)initHeader{
	
	if (_reqheader==nil) {
		_reqheader = [[NSMutableDictionary alloc] init];
	}
    
	//设置版本号
	[_reqheader setObject:[NSNumber numberWithShort:0] forKey:@"shVer"];
    
    //设置时间
    [_reqheader setObject:[NSNumber numberWithLongLong:timeoffset] forKey:@"lCurrTime"];
    
    //设置uAppIp
    [_reqheader setObject:[NSNumber numberWithInt:0] forKey:@"uAccIp"];
    
    //设置cmdResult
    CmdResult *rst = [[CmdResult alloc] init];
    rst.iCmdId = 0;
    rst.iErrCode = 0;
    rst.strErrDesc = @"";
    rst.iSubErrCode = 0;
    [_reqheader setObject:rst forKey:@"stResult"];

    UserBaseInfo *userBaseInfo = [[UserBaseInfo alloc] init];
    userBaseInfo.uuid = [SpyDBManager getUuid];
    userBaseInfo.eType = ID_TYPE_SINAWEIBO;
    userBaseInfo.strID = [SpyDBManager getStrID];
    if (nil == userBaseInfo.strID) {
        userBaseInfo.strID = @"";
    }
    userBaseInfo.strNick = [SpyDBManager getNickName];
    if (nil == userBaseInfo.strNick) {
        userBaseInfo.strNick = @"";
    }
    userBaseInfo.strCover = [SpyDBManager getIcon];
    if (NULL == userBaseInfo.strCover) {
        userBaseInfo.strCover  = @"";
    }
    [_reqheader setObject:userBaseInfo forKey:@"stUserBaseInfo"];
}

+ (long long)getCurrentTime{
    TCPNetEngine *engine = [TCPNetEngine getInstance];
    return ([[NSDate date] timeIntervalSince1970] + engine.timeInterval);
}


-(void)dealloc
{
    if (_selectorDict) {
        _selectorDict = nil;
    }
    
    if (_reqheader) {
        _reqheader = nil;
    }
    
    if (recvingMsg) {
        recvingMsg = nil;
    }
    
    if (sendingMsg) {
        sendingMsg = nil;
    }
    qqFriendsArray = nil;
    userArray = nil;
    [super dealloc];;
}

@end

@implementation TCPNetEngine (TCPResponse)
#pragma mark QXResponse  Function
//获取回包的命令
-(int)getCmd:(NSData*)rspData{
    SpyGame::Package package;
    [self parsePacketData:rspData package:package];
    return package.eCmd;
}

-(RoomBaseInfo*)formatRoomBaseInfoRsp:(SpyGame::RoomBaseInfo)roomBaseInfo{
    __autoreleasing RoomBaseInfo *_roomBaseInfo = [[RoomBaseInfo alloc] init];
    _roomBaseInfo.lRoomId = roomBaseInfo.lRoomId;
    _roomBaseInfo.nMaxMembers = roomBaseInfo.nMaxMembers;
    _roomBaseInfo.nCurMembers = roomBaseInfo.nCurMembers;
    _roomBaseInfo.lCreateUser = roomBaseInfo.lCreateUser;
    _roomBaseInfo.eUseState = (ROOM_USE_STATE)roomBaseInfo.eUseState;
    _roomBaseInfo.strRoomName = [NSString stringWithFormat:@"%s" , roomBaseInfo.strRoomName.c_str()];
    
    return _roomBaseInfo;
}

-(HallBaseInfo*)formatHallBaseInfoRsp:(SpyGame::HallBaseInfo)hallBaseInfo{
    __autoreleasing HallBaseInfo *_hallBaseInfo = [[HallBaseInfo alloc] init];
    _hallBaseInfo.nRoomNum = hallBaseInfo.nRoomNum;
    _hallBaseInfo.nUserNum = hallBaseInfo.nUserNum;
    
    
    _hallBaseInfo.mapRoomInfo = [[NSMutableDictionary alloc] init];
    map<taf::Int64 , SpyGame::RoomBaseInfo>::iterator iter;
    for(iter = hallBaseInfo.mapRoomInfo.begin(); iter != hallBaseInfo.mapRoomInfo.end(); iter++){
        long long roomid = iter->first;
        RoomBaseInfo *roomBaseInfo = [self formatRoomBaseInfoRsp:iter->second];
        [_hallBaseInfo.mapRoomInfo setObject:roomBaseInfo forKey:[NSNumber numberWithLongLong:roomid]];
    }

    return _hallBaseInfo;
}

-(UserBaseInfo*)formatUserBaseInfoRsp:(SpyGame::UserBaseInfo)userBaseInfo{
    __autoreleasing UserBaseInfo *_userBaseInfo = [[UserBaseInfo alloc] init];
    _userBaseInfo.uuid = userBaseInfo.uuid;
    _userBaseInfo.eType = (ID_TYPE)userBaseInfo.eType;
    _userBaseInfo.strCover = [NSString stringWithFormat:@"%s" , userBaseInfo.strCover.c_str()];
    _userBaseInfo.strID = [NSString stringWithFormat:@"%s" , userBaseInfo.strID.c_str()];
    _userBaseInfo.strNick = [NSString stringWithFormat:@"%s" , userBaseInfo.strNick.c_str()];
    return _userBaseInfo;
}

-(UserInfo*)formatUserInfoRsp:(SpyGame::UserInfo)userInfo{
    __autoreleasing UserInfo *_userInfo = [[UserInfo alloc] init];
    _userInfo.iTotalTimes = userInfo.iTotalTimes;
    _userInfo.iWinTimes = userInfo.iWinTimes;
    _userInfo.iLevel = userInfo.iLevel;
    _userInfo.iLostTimes = userInfo.iLostTimes;
    _userInfo.strDesc = [NSString stringWithFormat:@"%s" , userInfo.strDesc.c_str()];
    _userInfo.strEmail = [NSString stringWithFormat:@"%s" , userInfo.strEmail.c_str()];
    _userInfo.cGender = userInfo.cGender;
    
    _userInfo.stBaseInfo = [self formatUserBaseInfoRsp:userInfo.stBaseInfo];
    return _userInfo;
}

-(UserGameInfo*)formatUserGameInfoRsp:(SpyGame::UserGameInfo)userGameInfo{
    __autoreleasing UserGameInfo *_userGameInfo = [[UserGameInfo alloc] init];
    _userGameInfo.lRoomId = userGameInfo.lRoomId;
    _userGameInfo.eGameState = (USER_GAME_STATE)userGameInfo.eGameState;
    _userGameInfo.stUserInfo = [self formatUserBaseInfoRsp:userGameInfo.stUserInfo];
    
    return _userGameInfo;
}

-(RoomDetailInfo*)formatRoomDetailInfoRsp:(SpyGame::RoomDetailInfo)roomDetailInfo{
    __autoreleasing RoomDetailInfo *_roomDetailInfo = [[RoomDetailInfo alloc] init];
    _roomDetailInfo.eGameState = (ROOM_GAME_STATE)roomDetailInfo.eGameState;
    _roomDetailInfo.stBaseInfo = [self formatRoomBaseInfoRsp:roomDetailInfo.stBaseInfo];
    _roomDetailInfo.iStateUserCnt = roomDetailInfo.iStateUserCnt;
    _roomDetailInfo.mapUserInfo = [[NSMutableDictionary alloc] init];
    map<taf::Int64 , SpyGame::UserGameInfo>::iterator iter;
    for(iter = roomDetailInfo.mapUserInfo.begin(); iter != roomDetailInfo.mapUserInfo.end(); iter++){
        long long uuid = iter->first;
        UserGameInfo *userGameInfo = [self formatUserGameInfoRsp:iter->second];
        [_roomDetailInfo.mapUserInfo setObject:userGameInfo forKey:[NSNumber numberWithLongLong:uuid]];
    }
    
    return _roomDetailInfo;
}

-(RoundWordInfo*)formatRoundWordInfoRsp:(SpyGame::RoundWordInfo)roundWordInfo{
    __autoreleasing RoundWordInfo *_roundWordInfo = [[RoundWordInfo alloc] init];
    _roundWordInfo.lCurrentUser = roundWordInfo.lCurrentUser;
    _roundWordInfo.nRoundNum = roundWordInfo.nRoundNum;
    _roundWordInfo.strGameWords = [NSString stringWithFormat:@"%s" , roundWordInfo.strGameWords.c_str()];
    return _roundWordInfo;
}


-(RoundVoiceInfo*)formatRoundVoiceInfoRsp:(SpyGame::RoundVoiceInfo)roundVoiceInfo{
    __autoreleasing RoundVoiceInfo *_roundVoiceInfo = [[RoundVoiceInfo alloc] init];
    _roundVoiceInfo.nRoundNum = roundVoiceInfo.nRoundNum;
    _roundVoiceInfo.lCurrentUser = roundVoiceInfo.lCurrentUser;
    _roundVoiceInfo.lPreviousUser = roundVoiceInfo.lPreviousUser;
    _roundVoiceInfo.vPreviousUserVoice = [NSData dataWithCharVector:roundVoiceInfo.vPreviousUserVoice ];
    return _roundVoiceInfo;
}

-(GameResultInfo*)formatGameResultInfoRsp:(SpyGame::GameResultInfo)gameResultInfo{
    __autoreleasing GameResultInfo *_gameResultInfo = [[GameResultInfo alloc] init];
    _gameResultInfo.iResult = gameResultInfo.iResult;
    _gameResultInfo.iSpyUser = gameResultInfo.iSpyUser;
    _gameResultInfo.strOtherWords = [NSString stringWithFormat:@"%s" , gameResultInfo.strOtherWords.c_str()];
    _gameResultInfo.strSpyWords = [NSString stringWithFormat:@"%s" , gameResultInfo.strSpyWords.c_str()];
    return _gameResultInfo;
}

-(RoundVoteInfo*)formatRoundVoteInfoRsp:(SpyGame::RoundVoteInfo)roundVoteInfo{
    __autoreleasing RoundVoteInfo *_roundVoteInfo = [[RoundVoteInfo alloc] init];
    _roundVoteInfo.iRestart = roundVoteInfo.iRestart;
    _roundVoteInfo.iVoteUser = roundVoteInfo.iVoteUser;
    _roundVoteInfo.stGameResult = [self formatGameResultInfoRsp:roundVoteInfo.stGameResult];
    
    return _roundVoteInfo;
}

-(SCRegisterRsp*)rspGetRegisterRsp:(vector<taf::Char>)body encode:(int)encode{
    SpyGame::SCRegisterRsp rsp;
    deserializeJceObjWithEncodeType(rsp, body, encode);
    
    __autoreleasing SCRegisterRsp *scGRCR = [[SCRegisterRsp alloc] init];
    scGRCR.iErrCode = rsp.iErrCode;
    scGRCR.IsNewUser = rsp.IsNewUser;
    
    UserSvrInfo *userSvrInfo = [[UserSvrInfo alloc] init];
    userSvrInfo.stUserInfo = [self formatUserInfoRsp:rsp.stUserSvrInfo.stUserInfo];
    userSvrInfo.vKey = [NSData dataWithCharVector:rsp.stUserSvrInfo.vKey];
    scGRCR.stUserSvrInfo = userSvrInfo;
    [userSvrInfo release];
    
    return scGRCR;
}


-(SCRegisterRsp*)getRegisterRspData:(NSData*)rspData{
    SpyGame::Package package;
    int encode = [self parsePacketData:rspData package:package];
    
    SpyGame::Header head;
    deserializeJceObjWithEncodeType(head,package.head,encode);
    
    [self initHeader];
    vector<taf::Char>  body =  package.body;
    
    if (head.stResult.iErrCode == 0) {
        return [self rspGetRegisterRsp:body encode:encode];
    }
    return nil;
}

-(SCLoginRsp*)rspGetLoginQQRsp:(vector<taf::Char>)body{
    SpyGame::SCLoginRsp rsp;
    deserializeJceObjWithEncodeType(rsp, body, 1);
    
    __autoreleasing SCLoginRsp *scGRCR = [[SCLoginRsp alloc] init];
    scGRCR.iErrCode = rsp.iErrCode;
    return scGRCR;
}

-(SCLoginRsp*)getLoginRspData:(NSData*)rspData{
    SpyGame::Package package;
    int encode = [self parsePacketData:rspData package:package];
    
    SpyGame::Header head;
    deserializeJceObjWithEncodeType(head,package.head,encode);
    
    [self initHeader];
    vector<taf::Char>  body =  package.body;
    
    if (head.stResult.iErrCode == 0) {
        return [self rspGetLoginQQRsp:body];
    }
    
    return nil;
}

-(SCLogoutRsp*)rspGetLogoutRsp:(vector<taf::Char>)body{
    SpyGame::SCLogoutRsp rsp;
    deserializeJceObjWithEncodeType(rsp, body, 1);
    
    __autoreleasing SCLogoutRsp *scGRCR = [[SCLogoutRsp alloc] init];
    scGRCR.iErrCode = rsp.iErrCode;
    return scGRCR;
}

-(SCLogoutRsp*)getLogoutRspData:(NSData*)rspData{
    SpyGame::Package package;
    int encode = [self parsePacketData:rspData package:package];
    
    SpyGame::Header head;
    deserializeJceObjWithEncodeType(head,package.head,encode);
    
    [self initHeader];
    vector<taf::Char>  body =  package.body;
    
    if (head.stResult.iErrCode == 0) {
        return [self rspGetLogoutRsp:body];
    }
    
    return nil;
}


-(SCGetHallInfoRsp*)rspGetHallInfoRsp:(vector<taf::Char>)body{
    SpyGame::SCGetHallInfoRsp rsp;
    deserializeJceObjWithEncodeType(rsp, body, 0);
    
    __autoreleasing SCGetHallInfoRsp *scGRCR = [[SCGetHallInfoRsp alloc] init];
    scGRCR.iErrCode = rsp.iErrCode;
    scGRCR.stHallInfo = [self formatHallBaseInfoRsp:rsp.stHallInfo];
    return scGRCR;
}

-(SCGetHallInfoRsp*)getHallInfoRspData:(NSData*)rspData{
    SpyGame::Package package;
    int encode = [self parsePacketData:rspData package:package];
    
    SpyGame::Header head;
    deserializeJceObjWithEncodeType(head,package.head,encode);
    
    [self initHeader];
    vector<taf::Char>  body =  package.body;
    
    if (head.stResult.iErrCode == 0) {
        return [self rspGetHallInfoRsp:body];
    }
    
    return nil;
}

-(SCCreateRoomRsp*)rspCreateRoomRsp:(vector<taf::Char>)body{
    SpyGame::SCCreateRoomRsp rsp;
    deserializeJceObjWithEncodeType(rsp, body, 1);
    
    __autoreleasing SCCreateRoomRsp *scGRCR = [[SCCreateRoomRsp alloc] init];
    scGRCR.iErrCode = rsp.iErrCode;
    scGRCR.stRoomInfo = [self formatRoomDetailInfoRsp:rsp.stRoomInfo];
    return scGRCR;
}

-(SCCreateRoomRsp*)getCreateRoomRspData:(NSData*)rspData{
    SpyGame::Package package;
    int encode = [self parsePacketData:rspData package:package];
    
    SpyGame::Header head;
    deserializeJceObjWithEncodeType(head,package.head,encode);
    
    [self initHeader];
    vector<taf::Char>  body =  package.body;
    
    if (head.stResult.iErrCode == 0) {
        return [self rspCreateRoomRsp:body];
    }
    
    return nil;
}

-(SCEnterRoomRsp*)rspEnterRoomRsp:(vector<taf::Char>)body{
    SpyGame::SCEnterRoomRsp rsp;
    deserializeJceObjWithEncodeType(rsp, body, 1);
    
    __autoreleasing SCEnterRoomRsp *scGRCR = [[SCEnterRoomRsp alloc] init];
    scGRCR.iErrCode = rsp.iErrCode;
    scGRCR.stRoomInfo = [self formatRoomDetailInfoRsp:rsp.stRoomInfo];
    return scGRCR;
}

-(SCEnterRoomRsp*)getEnterRoomRspData:(NSData*)rspData{
    SpyGame::Package package;
    int encode = [self parsePacketData:rspData package:package];
    
    SpyGame::Header head;
    deserializeJceObjWithEncodeType(head,package.head,encode);
    
    [self initHeader];
    vector<taf::Char>  body =  package.body;
    
    if (head.stResult.iErrCode == 0) {
        return [self rspEnterRoomRsp:body];
    }
    
    return nil;
}

//SCLeaveRoom
-(SCLeaveRoomRsp*)rspLeaveRoomRsp:(vector<taf::Char>)body{
    SpyGame::SCLeaveRoomRsp rsp;
    deserializeJceObjWithEncodeType(rsp, body, 1);
    
    __autoreleasing SCLeaveRoomRsp *scGRCR = [[SCLeaveRoomRsp alloc] init];
    scGRCR.iErrCode = rsp.iErrCode;
    return scGRCR;
}

-(SCLeaveRoomRsp*)getLeaveRoomRspData:(NSData*)rspData{
    SpyGame::Package package;
    int encode = [self parsePacketData:rspData package:package];
    
    SpyGame::Header head;
    deserializeJceObjWithEncodeType(head,package.head,encode);
    
    [self initHeader];
    vector<taf::Char>  body =  package.body;
    
    if (head.stResult.iErrCode == 0) {
        return [self rspLeaveRoomRsp:body];
    }
    
    return nil;
}

//SCGetRoomInfoRsp
-(SCGetRoomInfoRsp*)rspGetRoomInfoRsp:(vector<taf::Char>)body{
    SpyGame::SCGetRoomInfoRsp rsp;
    deserializeJceObjWithEncodeType(rsp, body, 1);
    
    __autoreleasing SCGetRoomInfoRsp *scGRCR = [[SCGetRoomInfoRsp alloc] init];
    scGRCR.iErrCode = rsp.iErrCode;
    scGRCR.stRoomInfo = [self formatRoomDetailInfoRsp:rsp.stRoomInfo];
    return scGRCR;
}

-(SCGetRoomInfoRsp*)getGetRoomInfoRspData:(NSData*)rspData{
    SpyGame::Package package;
    int encode = [self parsePacketData:rspData package:package];
    
    SpyGame::Header head;
    deserializeJceObjWithEncodeType(head,package.head,encode);
    
    [self initHeader];
    vector<taf::Char>  body =  package.body;
    
    if (head.stResult.iErrCode == 0) {
        return [self rspGetRoomInfoRsp:body];
    }
    
    return nil;
}

//SCUserPlayReadyRsp
-(SCUserPlayReadyRsp*)rspUserPlayReadyRsp:(vector<taf::Char>)body{
    SpyGame::SCUserPlayReadyRsp rsp;
    deserializeJceObjWithEncodeType(rsp, body, 1);
    
    __autoreleasing SCUserPlayReadyRsp *scGRCR = [[SCUserPlayReadyRsp alloc] init];
    scGRCR.iErrCode = rsp.iErrCode;
    return scGRCR;
}

-(SCUserPlayReadyRsp*)getUserPlayReadyRspData:(NSData*)rspData{
    SpyGame::Package package;
    int encode = [self parsePacketData:rspData package:package];
    
    SpyGame::Header head;
    deserializeJceObjWithEncodeType(head,package.head,encode);
    
    [self initHeader];
    vector<taf::Char>  body =  package.body;
    
    if (head.stResult.iErrCode == 0) {
        return [self rspUserPlayReadyRsp:body];
    }
    return nil;
}

//SCRoundVoiceRsp
-(SCRoundVoiceRsp*)rspRoundVoiceRsp:(vector<taf::Char>)body{
    SpyGame::SCRoundVoiceRsp rsp;
    deserializeJceObjWithEncodeType(rsp, body, 1);
    
    __autoreleasing SCRoundVoiceRsp *scGRCR = [[SCRoundVoiceRsp alloc] init];
    scGRCR.iErrCode = rsp.iErrCode;
    return scGRCR;
}

-(SCRoundVoiceRsp*)getRoundVoiceRspData:(NSData*)rspData{
    SpyGame::Package package;
    int encode = [self parsePacketData:rspData package:package];
    
    SpyGame::Header head;
    deserializeJceObjWithEncodeType(head,package.head,encode);
    
    [self initHeader];
    vector<taf::Char>  body =  package.body;
    
    if (head.stResult.iErrCode == 0) {
        return [self rspRoundVoiceRsp:body];
    }
    return nil;
}

//SCRoundVoiceRsp
-(SCRoundVoteRsp*)rspRoundVoteRsp:(vector<taf::Char>)body{
    SpyGame::SCRoundVoteRsp rsp;
    deserializeJceObjWithEncodeType(rsp, body, 1);
    
    __autoreleasing SCRoundVoteRsp *scGRCR = [[SCRoundVoteRsp alloc] init];
    scGRCR.iErrCode = rsp.iErrCode;
    return scGRCR;
}

-(SCRoundVoteRsp*)getRoundVoteRspData:(NSData*)rspData{
    SpyGame::Package package;
    int encode = [self parsePacketData:rspData package:package];
    
    SpyGame::Header head;
    deserializeJceObjWithEncodeType(head,package.head,encode);
    
    [self initHeader];
    vector<taf::Char>  body =  package.body;
    
    if (head.stResult.iErrCode == 0) {
        return [self rspRoundVoteRsp:body];
    }
    return nil;
}

//SCUserStateChange
-(SCUserStateChange*)rspUserStateChangeRsp:(vector<taf::Char>)body{
    SpyGame::SCUserStateChange rsp;
    deserializeJceObjWithEncodeType(rsp, body, 0);
    
    __autoreleasing SCUserStateChange *scGRCR = [[SCUserStateChange alloc] init];
//    scGRCR.lRoomId = rsp.lRoomId;
    scGRCR.stUserInfo = [self formatUserGameInfoRsp:rsp.stUserInfo];
    return scGRCR;
}

-(SCUserStateChange*)getUserStateChangeRspData:(NSData*)rspData{
    SpyGame::Package package;
    int encode = [self parsePacketData:rspData package:package];
    
    SpyGame::Header head;
    deserializeJceObjWithEncodeType(head,package.head,encode);
    
    [self initHeader];
    vector<taf::Char>  body =  package.body;
    
    if (head.stResult.iErrCode == 0) {
        return [self rspUserStateChangeRsp:body];
    }
    return nil;
}


//SCUserStateChange
-(SCRoomStateChange*)rspRoomStateChangeRsp:(vector<taf::Char>)body{
    SpyGame::SCRoomStateChange rsp;
    deserializeJceObjWithEncodeType(rsp, body, 1);
    
    __autoreleasing SCRoomStateChange *scGRCR = [[SCRoomStateChange alloc] init];
    scGRCR.eGameState = (ROOM_GAME_STATE)rsp.eGameState;
    scGRCR.stBaseInfo = [self formatRoomBaseInfoRsp:rsp.stBaseInfo];
    
    scGRCR.stWordInfo = [self formatRoundWordInfoRsp:rsp.stWordInfo];
    scGRCR.stVoiceInfo = [self formatRoundVoiceInfoRsp:rsp.stVoiceInfo];
    scGRCR.stVoteInfo = [self formatRoundVoteInfoRsp:rsp.stVoteInfo];
    
    return scGRCR;
}

-(SCRoomStateChange*)getRoomStateChangeRspData:(NSData*)rspData{
    SpyGame::Package package;
    int encode = [self parsePacketData:rspData package:package];
    
    SpyGame::Header head;
    deserializeJceObjWithEncodeType(head,package.head,encode);
    
    [self initHeader];
    vector<taf::Char>  body =  package.body;
    
    if (head.stResult.iErrCode == 0) {
        return [self rspRoomStateChangeRsp:body];
    }
    return nil;
}

//SCHallStateChange
-(SCHallStateChange*)rspHallStateChangeRsp:(vector<taf::Char>)body{
    SpyGame::SCHallStateChange rsp;
    deserializeJceObjWithEncodeType(rsp, body, 1);
    
    __autoreleasing SCHallStateChange *scGRCR = [[SCHallStateChange alloc] init];
    scGRCR.stHallInfo = [self formatHallBaseInfoRsp:rsp.stHallInfo];
    return scGRCR;
}

-(SCHallStateChange*)getHallStateChangeRspData:(NSData*)rspData{
    SpyGame::Package package;
    int encode = [self parsePacketData:rspData package:package];
    
    SpyGame::Header head;
    deserializeJceObjWithEncodeType(head,package.head,encode);
    
    [self initHeader];
    vector<taf::Char>  body =  package.body;
    
    if (head.stResult.iErrCode == 0) {
        return [self rspHallStateChangeRsp:body];
    }
    return nil;
}
@end

