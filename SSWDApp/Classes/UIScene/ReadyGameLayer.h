//
//  ReadyGameLayer.h
//  SSWDApp
//
//  Created by gaofei on 13-1-22.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "GameUser.h"

@interface ReadyGameLayer : CCLayer{
    NSTimer *mReadyTimer;
    int mCountdown;
    CCLabelTTF *mCountDownlabel;
    
    NSMutableDictionary *mUsers;
    NSMutableDictionary *mUserLayers;
    CCSprite *iconBackgroundLayer;
}

@property(nonatomic,retain)NSTimer *mReadyTimer;
@property(nonatomic,retain)CCLabelTTF *mCountDownlabel;
@property(nonatomic)int mCountdown;
@property(nonatomic,retain) NSMutableDictionary *mUsers;
@property(nonatomic,retain) NSMutableDictionary *mUserLayers;

+(CCScene *) scene;
@end
