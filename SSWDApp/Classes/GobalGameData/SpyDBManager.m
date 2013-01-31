//
//  SpyDBManager.m
//  SSWDApp
//
//  Created by gaofei on 13-1-28.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import "SpyDBManager.h"

@implementation SpyDBManager

//uuid相关存储操作
+ (void)setUuid:(long long)uuid
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_USERID];
    NSNumber *uuidObj = [NSNumber numberWithLongLong:uuid];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:uuidObj];
        [userDefualts setValue:list forKey:USER_USERID];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:uuidObj])
        {
            [temp removeObject:uuidObj];
        }
        [temp insertObject:uuidObj atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_USERID];
        [userDefualts synchronize];
    }
}

+ (long long)getUuid
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_USERID];
    if(list != nil)
    {
        return [[list objectAtIndex:0] longLongValue];
    }
    return -1;
}

//用户昵称相关存储操作
+ (void)setNickName:(NSString*)nickName
{
    if(nickName == nil) {
        return;
    }
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_NICKNAME];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:nickName];
        [userDefualts setValue:list forKey:USER_NICKNAME];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:nickName])
        {
            [temp removeObject:nickName];
        }
        [temp insertObject:nickName atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_NICKNAME];
        [userDefualts synchronize];
    }
}

+ (NSString*)getNickName
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_NICKNAME];
    if(list != nil)
    {
        if([[list objectAtIndex:0] isEqualToString:@""])
            return @"";
        else
            return [list objectAtIndex:0];
    }
    return @"";
}

//用户ID相关存储操作
+ (void)setStrID:(NSString*)strID
{
    if(strID == nil) {
        return;
    }
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_STRID];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:strID];
        [userDefualts setValue:list forKey:USER_STRID];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:strID])
        {
            [temp removeObject:strID];
        }
        [temp insertObject:strID atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_STRID];
        [userDefualts synchronize];
    }
}

+ (NSString*)getStrID
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_STRID];
    if(list != nil)
    {
        if([[list objectAtIndex:0] isEqualToString:@""])
            return @"";
        else
            return [list objectAtIndex:0];
    }
    return @"";
}

//用户头像相关存储操作
+ (void)setIcon:(NSString*)icon
{
    if(icon == nil) {
        return;
    }
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_ICON];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:icon];
        [userDefualts setValue:list forKey:USER_ICON];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:icon])
        {
            [temp removeObject:icon];
        }
        [temp insertObject:icon atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_ICON];
        [userDefualts synchronize];
    }
}

+ (NSString*)getIcon
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_ICON];
    if(list != nil)
    {
        if([[list objectAtIndex:0] isEqualToString:@""])
            return @"";
        else
            return [list objectAtIndex:0];
    }
    return @"";
}

//用户等级相关存储
+ (void)setLevel:(unsigned int)level
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_LEVEL];
    NSNumber *uuidObj = [NSNumber numberWithUnsignedInt:level];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:uuidObj];
        [userDefualts setValue:list forKey:USER_LEVEL];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:uuidObj])
        {
            [temp removeObject:uuidObj];
        }
        [temp insertObject:uuidObj atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_LEVEL];
        [userDefualts synchronize];
    }
}

+ (unsigned int)getLevel
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_LEVEL];
    if(list != nil)
    {
        return [[list objectAtIndex:0] unsignedIntValue];
    }
    return 0;
}

//用户总局数相关存储
+ (void)setTotalTimes:(unsigned int)totalTimes
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_TOTALTIMES];
    NSNumber *uuidObj = [NSNumber numberWithUnsignedInt:totalTimes];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:uuidObj];
        [userDefualts setValue:list forKey:USER_TOTALTIMES];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:uuidObj])
        {
            [temp removeObject:uuidObj];
        }
        [temp insertObject:uuidObj atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_TOTALTIMES];
        [userDefualts synchronize];
    }
}

+ (unsigned int)getTotalTimes
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_TOTALTIMES];
    if(list != nil)
    {
        return [[list objectAtIndex:0] unsignedIntValue];
    }
    return 0;
}


//用户赢的局数相关存储
+ (void)setWinTimes:(unsigned int)winTimes
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_WINTIMES];
    NSNumber *uuidObj = [NSNumber numberWithUnsignedInt:winTimes];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:uuidObj];
        [userDefualts setValue:list forKey:USER_WINTIMES];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:uuidObj])
        {
            [temp removeObject:uuidObj];
        }
        [temp insertObject:uuidObj atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_WINTIMES];
        [userDefualts synchronize];
    }
}

+ (unsigned int)getWinTimes
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_WINTIMES];
    if(list != nil)
    {
        return [[list objectAtIndex:0] unsignedIntValue];
    }
    return 0;
}

//用户输的局数相关存储
+ (void)setLostTimes:(unsigned int)lostTimes
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_LOSTTIMES];
    NSNumber *uuidObj = [NSNumber numberWithUnsignedInt:lostTimes];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:uuidObj];
        [userDefualts setValue:list forKey:USER_LOSTTIMES];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:uuidObj])
        {
            [temp removeObject:uuidObj];
        }
        [temp insertObject:uuidObj atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_LOSTTIMES];
        [userDefualts synchronize];
    }
}

+ (unsigned int)getLostTimes
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_LOSTTIMES];
    if(list != nil)
    {
        return [[list objectAtIndex:0] unsignedIntValue];
    }
    return 0;
}

//用户类型相关存储
+ (void)setUserType:(int)userType{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_USERTYPE];
    NSNumber *uuidObj = [NSNumber numberWithInt:userType];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:uuidObj];
        [userDefualts setValue:list forKey:USER_USERTYPE];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:uuidObj])
        {
            [temp removeObject:uuidObj];
        }
        [temp insertObject:uuidObj atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_USERTYPE];
        [userDefualts synchronize];
    }
}

+ (int)getUserType{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_USERTYPE];
    if(list != nil)
    {
        return [[list objectAtIndex:0] intValue];
    }
    return 0;
}

//加解密key相关存储
+ (void)setCrypt:(NSData*)crypt
{
    if(crypt == nil) {
        return;
    }
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_CRYPTKEY];
    
    if(list == nil)
    {
        list = [NSArray arrayWithObject:crypt];
        [userDefualts setValue:list forKey:USER_CRYPTKEY];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:crypt])
        {
            [temp removeObject:crypt];
        }
        [temp insertObject:crypt atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_CRYPTKEY];
        [userDefualts synchronize];
    }
}

+ (NSData*)getCrypt
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_CRYPTKEY];
    if(list != nil)
    {
        return [list objectAtIndex:0];
    }
    return nil;
}
@end
