//
//  GameUser.h
//  SSWDApp
//
//  Created by gaofei on 13-1-22.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConstantData.h"
@interface GameUser : NSObject{
    NSString *mNickName;
    NSString *mIcon;
    GAME_USER_STATE mUserState;
    long long uuid;
    NSData *voiceData;
}

@property(nonatomic,retain)NSString *mNickName;
@property(nonatomic,retain)NSString *mIcon;
@property(nonatomic)GAME_USER_STATE mUserState;
@property(nonatomic)long long uuid;
@property(nonatomic,retain)NSData *voiceData;
@end
