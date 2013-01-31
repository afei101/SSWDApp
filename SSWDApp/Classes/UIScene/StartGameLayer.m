//
//  StartGameLayer.m
//  SSWDApp
//
//  Created by gaofei on 13-1-22.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import "StartGameLayer.h"
#import "ReadyGameLayer.h"
#import "GameResultOneLayer.h"
#import "GameResultTwoLayer.h"
#import "GameResultThreeLayer.h"
#import "GameResultFourLayer.h"
#import "VoteLayer.h"
#import "TCPNetEngine.h"
#import "SpyDBManager.h"
#import "SSWDData.h"
#import "CCNotify.h"
#import "CCTextField.h"
@implementation StartGameLayer
// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	StartGameLayer *layer = [StartGameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void)getHallInfo{
    TCPNetEngine *engine = [TCPNetEngine getInstance];
    
    CSGetHallInfo *getHallInfoReq = [[CSGetHallInfo alloc] init];
    getHallInfoReq.uuid = [SpyDBManager getUuid];
    
    [engine initHeader];
    NSData *sendPackage = [engine getReqGetHallInfo:getHallInfoReq];
    [getHallInfoReq release];
    
    [[SSWDData getInstance].mSockPtr writeData:sendPackage withTimeout:1000 tag:0] ;
}

-(void)createRoom{
    TCPNetEngine *engine = [TCPNetEngine getInstance];
    
    CSCreateRoom *createRoomReq = [[CSCreateRoom alloc] init];
    createRoomReq.lCreateUser = [SpyDBManager getUuid];
    createRoomReq.strRoomName = @"afei room";
    
    [engine initHeader];
    NSData *sendPackage = [engine getReqCreateRoom:createRoomReq];
    [createRoomReq release];
    
    [[SSWDData getInstance].mSockPtr writeData:sendPackage withTimeout:1000 tag:0] ;
}

-(void)enterRoom{
    TCPNetEngine *engine = [TCPNetEngine getInstance];
    
    CSEnterRoom *enterRoomReq = [[CSEnterRoom alloc] init];
    enterRoomReq.uuid = [SpyDBManager getUuid];
    NSLog(@"enter room : %lld" , enterRoomReq.uuid);
    RoomBaseInfo *roomInfo = [[SSWDData getInstance].mRoomInfo objectAtIndex:0];
    enterRoomReq.lRoomId = 4;
    
    [engine initHeader];
    NSData *sendPackage = [engine getReqCSEnterRoom:enterRoomReq];
    [enterRoomReq release];
    
    [[SSWDData getInstance].mSockPtr writeData:sendPackage withTimeout:1000 tag:0] ;
}

//
-(id) init
{
	if( (self=[super init])) {
		// ask director for the window size
        NSLog(@"LoginLayer init");
        //获取屏幕的宽高
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        //设置登陆页面的背景
        CCSprite *backgroundLayer = [CCSprite spriteWithFile:@"LoginBackground.png"];
        [backgroundLayer setPosition:ccp(size.width/2, size.height/2)];
        [self addChild:backgroundLayer];
        
        //设置登陆页面的登陆按钮
		CCMenuItemImage *itemStartGame = [CCMenuItemImage itemWithNormalImage:@"startGame.png" selectedImage:@"startGameClicked.png"];
        [itemStartGame setBlock:^(id sender) {
            NSLog(@"登陆游戏");
            [self enterRoom];
//            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[ReadyGameLayer scene] ]];
        }];
        
        
        CCTextField *field = [CCTextField textFieldWithFieldSize:CGSizeMake(200, 30)];
        [field setTextColor:ccc3(255, 255, 255)];
        [field setText:@"1"];
        [field setPosition:ccp(200, 200)];
        [self addChild:field z:5];
        
        CCMenu *startMenu = [CCMenu menuWithItems:itemStartGame, nil];
        [startMenu setPosition:ccp( size.width/2+100, size.height/2 - 40)];
        [self addChild:startMenu z:1];
        
        //设置创建房间页面的登陆按钮
		CCMenuItemImage *itemCreateGame = [CCMenuItemImage itemWithNormalImage:@"CreateGameBtn.png" selectedImage:@"CreateGameBtnClicked.png"];
        [itemCreateGame setBlock:^(id sender) {
            NSLog(@"创建房间");
            [self createRoom];
        }];
        CCMenu *createGameMenu = [CCMenu menuWithItems:itemCreateGame, nil];
        [createGameMenu setPosition:ccp( size.width/2+100, size.height/2 - 85)];
        [self addChild:createGameMenu z:1];
        
        
        //设置设置功能按钮
        CCMenuItemImage *itemSetting = [CCMenuItemImage itemWithNormalImage:@"SettingBtn.png" selectedImage:@"SettingBtnClicked.png"];
        [itemSetting setBlock:^(id sender) {
            NSLog(@"设置 startGame");
            //测试代码，用于获取大厅的基本信息
            [self getHallInfo];
        }];
        
        CCMenuItemImage *itemHelp = [CCMenuItemImage itemWithNormalImage:@"HelpBtn.png" selectedImage:@"HelpBtnClicked.png"];
        [itemHelp setBlock:^(id sender) {
            NSLog(@"帮助 startGame");
            
            //bladewang
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[VoteLayer scene] ]];
        }];
        
        CCMenu *optionMenu = [CCMenu menuWithItems:itemSetting,itemHelp,nil];
        [optionMenu alignItemsHorizontallyWithPadding:10];
        [optionMenu setPosition:ccp( size.width/2+100, size.height/2 - 125)];
        [self addChild:optionMenu z:1];
        
	}
	return self;
}


//登陆成功处理
- (void)enterRoomSuccess:(NSNotification *)notification{
    //进入游戏房间界面
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[ReadyGameLayer scene]]];
}

//登陆成功处理
- (void)createRoomSuccess:(NSNotification *)notification{
    //进入游戏房间界面,这个时候这个游戏房间只有创建游戏玩家的一个人
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[ReadyGameLayer scene]]];
}

-(void)onEnter{
    [super onEnter];
    //注册进入游戏成功的消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterRoomSuccess:) name:NOTIFY_ENTER_ROOM_SUCCESS object:nil];
    
    //注册创建房间成功的消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createRoomSuccess:) name:NOTIFY_CREATE_ROOM_SUCCESS object:nil];
}

-(void)onExit{
    //注销相关消息
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super onExit];
}


@end
