//
//  SpyDBManager.h
//  SSWDApp
//
//  Created by gaofei on 13-1-28.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import <Foundation/Foundation.h>
#define USER_USERID             @"user_userid"
#define USER_NICKNAME           @"user_nickname"
#define USER_STRID              @"user_strid"
#define USER_ICON               @"user_icon"
#define USER_LEVEL              @"user_level"
#define USER_TOTALTIMES         @"user_totaltimes"
#define USER_WINTIMES           @"user_wintimes"
#define USER_LOSTTIMES          @"user_losttimes"
#define USER_USERTYPE           @"user_usertype"
#define USER_CRYPTKEY           @"user_cryptkey"

@interface SpyDBManager : NSObject

//用户uuid相关存储
+ (long long)getUuid;
+ (void)setUuid:(long long)uuid;

//用户昵称相关存储操作
+ (NSString*)getNickName;
+ (void)setNickName:(NSString*)nickName;

//用户ID相关存储操作
+ (NSString*)getStrID;
+ (void)setStrID:(NSString*)strID;

//用户头像相关存储操作
+ (NSString*)getIcon;
+ (void)setIcon:(NSString*)icon;

//用户等级相关存储
+ (unsigned int)getLevel;
+ (void)setLevel:(unsigned int)level;

//用户总局数相关存储
+ (unsigned int)getTotalTimes;
+ (void)setTotalTimes:(unsigned int)totalTimes;

//用户赢的局数相关存储
+ (unsigned int)getWinTimes;
+ (void)setWinTimes:(unsigned int)winTimes;

//用户输的局数相关存储
+ (void)setLostTimes:(unsigned int)lostTimes;
+ (unsigned int)getLostTimes;

//用户类型相关存储
+ (void)setUserType:(int)userType;
+ (int)getUserType;

//加解密key相关存储
+ (void)setCrypt:(NSData*)crypt;
+ (NSData*)getCrypt;
@end
