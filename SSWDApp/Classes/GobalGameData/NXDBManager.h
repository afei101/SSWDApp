//
//  NXDBManager.h
//  vshare
//
//  Created by cloudwu cloudwu on 12-1-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXDBDAO.h"
#import "CommentModel.h"
#import "GroupModel.h"
#import "GroupInfoModel.h"
#import "PictureInfoModel.h"
#import "PartakerModel.h"
#import "ShareInfoModel.h"
#import "UserModel.h"
#import "UserInfoModel.h"
#import "ShareData.h"
#import "UserData.h"

#define TABLE_COMMENT       @"CommentModel"
#define TABLE_GROUP         @"GroupModel"
#define TABLE_GROUPINFO     @"GroupInfoModel"
#define TABLE_PICTUREINFO   @"PictureInfoModel"
#define TABLE_PARTAKER      @"PartakerModel"
#define TABLE_SHAREINFO     @"ShareInfoModel"
#define TABLE_USER          @"UserModel"
#define TABLE_USERINFO      @"UserInfoModel"

#define USER_UUIDLIST       @"uuidList"
#define USER_FRIENDUUIDLIST @"frienduuidlist"
#define USER_NO             @"userNo"
#define USER_QQNUM          @"userqqnum"
#define USER_USERID          @"useruserid"
#define USER_NAME           @"username"
#define USER_FRIENDQQNUM    @"userfriendqqnum"
#define USER_QQSID          @"userqqsid"

#define USER_NAME_RENREN    @"usernamerenren"
#define USER_NAME_SINA      @"usernamesina"
#define USER_NAME_QWEIBO    @"usernameweibo"

#define USER_PWD            @"userPwd"
#define USER_NICKNAME       @"nickname"
#define USER_SESSIONID      @"sessionid"
#define PUSH_TOKEN          @"pushToken"
#define USER_PUSHTOKEN      @"pushToken"
#define USER_UNREADNUM      @"unreadNum"
#define USER_INVITENUM      @"inviteNum"
#define USER_UNREADSTR      @"unreadStr"
#define USER_INVITESTR      @"inviteStr"
#define USER_RECPUSHSTR     @"recPushStr"
#define USER_UNREADUUID     @"unreadUuid"
#define USER_INVITEUUID     @"inviteUuid"
#define USER_INVITENAME     @"inviteName"
#define USER_UNREADTYPE     @"unreadType"
#define USER_INVITETYPE     @"inviteType"
#define USER_PUSHENABLE     @"pushEnable"
#define USER_WEBPQUALIT     @"webpQuality"
#define USER_FEEDLIST       @"feedList"
#define USER_COMMENTNUM     @"commentNum"
#define USER_RECPUSHNUM     @"recPushNum"
#define USER_COMMENTUUID    @"commentUuid"
#define USER_COMMENTNAME    @"commentName"
#define USER_COMMENTSTR     @"commentStr"
#define USER_LASTPUSHTYPE   @"lastPushType"
#define IS_APP_PUSH         @"isAPPPush"
#define IS_FORMAL_SERVER    @"isFormalServer"
#define USER_NEEDVERIFY     @"needVerity"
#define USER_LOCALVERSION   @"localVersion"
#define SINA_ACCESS_TOKEN   @"sinaaccesstoken"
#define SINA_EXPIRE_DATE    @"sinaexpiredate"
#define SINA_USER_ID        @"sinauserid"


#define ACCESS_TOKEN_QWEIBO @"access_Token_qweibo"
#define EXPIRATION_DATE_QWEIBO @"expiration_Date_qweibo"
#define USER_ID_QWEIBO       @"user_id_qweibo"
#define OPEN_ID_QWEIBO         @"open_id_qweibo"

#define IS_FIRST_LOGIN    @"isFirstLogin"
#define IS_HAS_ACTIVITY    @"isHasActivity"
#define KEYCHAIN_CRYPTKEY   @"keychainCryptKey"
#define KEYCHAIN_SID        @"keychainSid"

#define LASTCURACLID        @"lastCurACLid"
#define A8TOKEN             @"n8token"

#define LOGIN_TYPE          @"login_type"
#define SINA_BIND           @"sina_bind"
#define QQ_BIND             @"qq_bind"
#define QQWEIBO_BIND        @"qqweibo_bind"
#define RENREN_BIND         @"renren_bind"

#define SINA_BIND_NAME           @"sina_bind_name"
#define QQ_BIND_NAME             @"qq_bind_name"
#define QQWEIBO_BIND_NAME        @"qqweibo_bind_name"
#define RENREN_BIND_NAME         @"renren_bind_name"

// sharedata modle

#define KcommentNum @"commentNum"
#define KcreateTime @"createTime"
#define Kcreator    @"creator"
#define KlbsLat     @"lbsLat"
#define KlbsLon     @"lbsLon"
#define KlId        @"lId"
#define KpicNum     @"picNum"
#define Kstatus     @"status"
#define KtextContent @"textContent"
#define Ktype       @"type"
#define Kuuid       @"uuid"
#define KfileKey    @"fileKey"
#define Kindex      @"index"
#define Ksegment    @"segment"
#define KsegmentSent @"segmentSent"
#define KparentId   @"parentId"
#define Kcontent    @"content"
#define KcommentedUser    @"commentTo"


@interface NXDBManager : NSObject
{
    NXDBDAO *mDBDAO;
    NSMutableDictionary *contextPool;
    NSMutableDictionary *threadPool;
    NSLock *dbLock;
}

@property (nonatomic, strong, readonly) NSMutableDictionary *contextPool;
@property (nonatomic, strong, readonly) NSMutableDictionary *threadPool;
@property (nonatomic, strong, readonly) NSLock *dbLock;

+ (NXDBManager *)shareInstance;
+ (void)setSqliteForManager:(long long)uuid;
+ (void)removeAllContext;

/*
//UserModel access methods
- (void)insertOrUpdateUserModel:(NSDictionary *)userDic userInfo:(NSArray *)userInfoArr;
- (UserModel *)loadUserModel:(long long)uuid;
- (NSArray *)loadAllUserModel;
- (void)deleteUserModel:(long long)uuid;

//UserInfoModel access methods
- (void)insertOrUpdateUserInfoModel:(NSDictionary *)userInfoDic;
- (NSArray *)loadUserInfoModel:(long long)uuid;
- (UserInfoModel *)loadUserInfoModel:(long long)uuid type:(int)type;
- (void)deleteUserInfoModel:(long long)uuid type:(int)type;
*/
//new UserData access methods
//- (void)insertOrUpdateUserData:(UserData *)userData;
- (void)insertOrUpdateUserData:(NSMutableArray *)userDataArray;
- (UserData *)loadUserData:(long long)uuid;
- (NSArray *)loadAllUserData;
- (void)deleteUser:(long long)uuid;

//GroupModel access methods
- (void)insertOrUpdateGroupModel:(NSDictionary *)groupDic groupInfo:(NSArray *)groupInfoArr;
- (GroupModel *)loadGroupModel:(int)groupId;
- (NSArray *)loadAllGroupModel;
- (void)deleteGroupModel:(int)groupId;

//CircleInfo access methods
- (NSArray *)loadAllGroupWithFriends ;

//GroupInfoModel access methods
- (void)insertOrUpdateGroupInfoModel:(NSArray *)groupInfoArr;
- (NSArray *)loadGroupInfoModel:(int)groupId;
- (NSArray *)loadGroupInfoModel:(int)groupId type:(int)type;
- (NSArray *)loadGroupInfoModelForUuid:(long long)uuid;
- (void)deleteGroupInfoModel:(int)groupId withUuid:(long long)uuid;
- (void)deleteGroupInfoModelWithUuid:(long long)uuid;

//ShareInfoModel access methods
- (void)insertShareInfoModel:(NSDictionary *)shareInfoDic pictureInfo:(NSArray *)picInfoArr partaker:(NSArray *)partakerArr;
- (void)insertOrUpdateShareInfoModel:(NSDictionary *)shareInfoDic pictureInfo:(NSArray *)picInfoArr partaker:(NSArray *)partakerArr;
- (ShareInfoModel *)loadShareInfoModelById:(long long)lId;
- (NSArray *)loadShareInfoModelForUuid:(long long)uuid lastNumber:(int)number statusDone:(BOOL)isDone;
- (NSArray *)loadShareInfoModelForUuid:(long long)uuid lastNumber:(int)number statusDone:(BOOL)isDone belongUuid:(long long)belongUuid;
- (NSArray *)loadShareInfoModelForUuid:(long long)uuid lastNumber:(int)number statusDone:(BOOL)isDone timeStamp:(long long)time belongUuid:(long long)belongUuid;
//Add by wy 
- (NSArray *)loadShareInfoModelForUuidNoStatus:(long long)uuid lastNumber:(int)number  belongUuid:(long long)belongUuid;
- (NSArray *)loadShareInfoModelForUuidNoStatus:(long long)uuid lastNumber:(int)number ;
- (NSArray *)loadShareInfoModelForUuidNoStatus:(long long)uuid lastNumber:(int)number  timeStamp:(long long)time belongUuid:(long long)belongUuid;
- (void)updateShareInfo:(NSDictionary *)shareInfoDic ;

//End
- (void)deleteShareInfoModel:(long long)lId;
- (void)deleteShareInfoModelWithUuid:(long long)uuid;

//new ShareData access methods
- (void)insertOrUpdateShareData:(ShareData *)shareData belongUuid:(long long)Uuid;
- (ShareData *)loadShareDataById:(long long)lId;
- (NSArray *)loadShareDataForUuid:(long long)uuid lastNumber:(int)number statusDone:(BOOL)isDone timeStamp:(long long)time belongUuid:(long long)belongUuid;

//PictureInfoModel access methods
- (void)insertPictureInfoModel:(NSDictionary *)picInfoDic;
- (NSArray *)loadPictureInfoModelById:(long long)lId;
- (PictureInfoModel *)loadPictureInfoModelByFileKey:(NSString *)fileKey;
- (void)updatePictureInfoModel:(NSDictionary *)picInfoDic;
- (void)deletePictureInfoModel:(NSString *)fileKey;

//PartakerModel access methods
- (void)insertPartakerModel:(NSDictionary *)partakerDic;
- (NSArray *)loadPartakerModel:(long long)lId;
- (NSArray *)loadPartakerModel:(long long)lId ReadOn:(BOOL)read ;
- (void)updatePartakerModel:(NSDictionary *)partakerDic;
- (void)deletePartakerModel:(long long)lId;
- (NSArray *)loadPartakerModel:(long long)lId ReadStatus:(int)status;

//CommentModel access methods
- (void)insertCommentModel:(NSDictionary *)commentDic;
- (NSArray *)loadCommentModelByParentId:(long long)parentId firstLimited:(BOOL)isLimited;
- (CommentModel *)loadCommentModelByCommentId:(long long)lId;
- (void)updateCommentModel:(NSDictionary *)commentDic;
- (void)deleteCommentModel:(long long)lId;

//UserDefaults access methods
+ (void)setCurrentUuid:(long long)uuid;
+ (long long)getCurrentUuid;
+ (NSArray *)getUuidList;


+ (NSString*)getCurrentSessionId;
+ (void)setCurrentSessionId:(NSString*)sessionId;

+ (void)deleteUuid:(long long)uuid;
+ (void)setPushToken:(NSString *)token;
+ (NSString *)getPushToken;
+(void)delUserDefaults:(NSString *)type;
+ (void)setUserDefaults:(NSString *)type withValue:(id)value forUuid:(long long)uuid;
//+ (void)setUserDefaults:(NSString *)type withValue:(id)value;
+ (id)getUserDefaults:(NSString *)type byUuid:(long long)uuid;
+(id)getUserDefaults:(NSString *)type;

//设置是否要进行app push变量
+ (void)setIsAppPush:(int)isPush;
+ (int)getIsPush;
+ (NSString*)getAppPushToken;
+ (void)setAppPushToken:(NSString*)pushToken;

+ (void)setCurrentQQ:(NSString*)qq;
+ (NSString*)getCurrentQQ;

+ (void)setCurrentFriendQQ:(NSString*)qq;
+ (NSString*)getCurrentFriendQQ;

+ (void)setFeedList:(NSMutableArray *)feelist;
+ (NSArray *)getFeedList;

+ (NSString*)getCurrentNickname;
+ (void)setCurrentNickName:(NSString*)nickName;

+ (NSData*)getCurrentPwd;
+ (void)setCurrentPwd:(NSData*)pwd;

+ (int)getCurrentServerType;
+ (void)setCurrentServerType:(int)type;

+ (long long)getCurrentNo;
+ (void)setCurrentNo:(long long)lNo;

+ (long long)getCurrentFriendUuid;
+ (void)setCurrentFriendUuid:(long long)lNo;

+ (NSString*)getCurrentSID;
+ (void)setCurrentSID:(NSString*)sid;

+ (int)getCurrentServerType;
+ (void)setCurrentServerType:(int)type;

+ (int)getFirstLogin:(long long)uuid;
+ (void)setFirstLogin:(int)iIsLogin uuid:(long long)uuid;

+ (int)getHasActivity;
+ (void)setHasActivity:(int)iHasActivity;

+ (int)getLoginType;
+ (void)setLoginType:(int)loginType;

//绑定帐号相关信息
+ (int)getSinaBind;
+ (void)setSinaBind:(int)isBind;

+ (int)getQQWeiboBind;
+ (void)setQQWeiboBind:(int)isBind;

+ (int)getRenRenBind;
+ (void)setRenRenBind:(int)isBind;

+ (int)getQQBind;
+ (void)setQQBind:(int)isBind;

+ (void)setLoginUserName:(NSString*)name;
+ (NSString*)getLoginUserName;

//--------------------
+ (NSString*)getSinaBindId;
+ (void)setSinaBindId:(NSString*)bindId;

+ (NSString*)getQQWeiboBindId;
+ (void)setQQWeiboBindId:(NSString*)bindId;

+ (NSString*)getRenRenBindId;
+ (void)setRenRenBindId:(NSString*)bindId;

+ (NSString*)getQQBindId;
+ (void)setQQBindId:(NSString*)bindId;

+ (NSString*)getLoginUserId;
+ (void)setLoginUserId:(NSString*)userId;

+ (NSString *)getLocalVersion;
+ (void)setLocalVersion:(NSString *)version;

+ (NSString *)getSinaAccessToken;
+ (void)setSinaAccessToken:(NSString *)sinaAccessToken;

+ (NSData*)getCurrentA8Token;
+ (void)setCurrentA8Token:(NSData*)A8Token;

+ (NSDate*)getSinaExpireDate;
+ (void)setSinaExpireDate:(NSDate*)expireDate;

+ (NSString *)getSinaUserId;
+ (void)setSinaUserId:(NSString *)sinaUserId;

//SecKeychain access methods
+ (NSString *)getItemByUuid:(NSString *)uuid itemType:(NSString *)type error:(NSError **)error;
+ (BOOL)storeUuid:(NSString *)uuid item:(NSString *)item itemType:(NSString *)type updateExisting:(BOOL)updateExisting error:(NSError **)error;
+ (BOOL)deleteItemByUuid:(NSString *)uuid itemType:(NSString *)type error:(NSError **)error;

+ (void)setQQWeiboLoginName:(NSString*)name;
+ (NSString*)getQQWeiboLoginName;
+ (void)setSinaLoginName:(NSString*)name;
+ (NSString*)getSinaLoginName;
+ (void)setRenRenLoginName:(NSString*)name;
+ (NSString*)getRenRenLoginName;



- (ShareData *)formatShareInfoModelToShareData:(ShareInfoModel *)shareModel;

@end
