//
//  ReadyGameLayer.m
//  SSWDApp
//
//  Created by gaofei on 13-1-22.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import "ReadyGameLayer.h"
#import "StartGameLayer.h"
#import "Utility.h"
#import "GameLayer.h"
#import "SSWDData.h"
#import "SpyDBManager.h"
#import "CCNotify.h"

@implementation ReadyGameLayer
@synthesize mReadyTimer;
@synthesize mCountdown;
@synthesize mUsers;
@synthesize mCountDownlabel;
@synthesize mUserLayers;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ReadyGameLayer *layer = [ReadyGameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


-(void)playReady{
    TCPNetEngine *engine = [TCPNetEngine getInstance];
    
    CSUserPlayReady *playReadyReq = [[CSUserPlayReady alloc] init];
    playReadyReq.lRoomId = [SSWDData getInstance].mGameRoom.mRoomID;
    
    UserGameInfo *userGameInfo = [[UserGameInfo alloc] init];
    userGameInfo.lRoomId = [SSWDData getInstance].mGameRoom.mRoomID;
    userGameInfo.eGameState = USER_GAME_STATE_Ready;
    
    UserBaseInfo *userBaseInfo = [[UserBaseInfo alloc] init];
    userBaseInfo.strNick = [SpyDBManager getNickName];
    userBaseInfo.strID = [SpyDBManager getStrID];
    userBaseInfo.strCover = [SpyDBManager getIcon];
    userBaseInfo.uuid = [SpyDBManager getUuid];
    userBaseInfo.eType = [SpyDBManager getUserType];
    userGameInfo.stUserInfo = userBaseInfo;
    [userBaseInfo release];
    
    playReadyReq.stUserInfo = userGameInfo;
    [userGameInfo release];
    
    [engine initHeader];
    NSData *sendPackage = [engine getReqCSUserPlayReady:playReadyReq];
    [playReadyReq release];
    
    [[SSWDData getInstance].mSockPtr writeData:sendPackage withTimeout:1000 tag:0] ;
}


-(void) initData{
    SSWDData *instance = [SSWDData getInstance];
    mUsers = instance.mGameRoom.mGameUsers;
    
//    GameUser *gameUser = [[GameUser alloc] init];
//    gameUser.mNickName = @"afei";
//    gameUser.mIcon = @"icon_example.jpg";
//    [mUsers addObject:gameUser];
//    [gameUser release];
//    
//    GameUser *gameUser1 = [[GameUser alloc] init];
//    gameUser1.mNickName = @"afei";
//    gameUser1.mIcon = @"icon_example.jpg";
//    [mUsers addObject:gameUser1];
//    [gameUser1 release];
//    
//    GameUser *gameUser2 = [[GameUser alloc] init];
//    gameUser2.mNickName = @"afei";
//    gameUser2.mIcon = @"icon_example.jpg";
//    [mUsers addObject:gameUser2];
//    [gameUser2 release];

}

-(void)leaveRoom{
    TCPNetEngine *engine = [TCPNetEngine getInstance];
    CSLeaveRoom *leaveRoom = [[CSLeaveRoom alloc] init];
    leaveRoom.uuid = [SpyDBManager getUuid];
    leaveRoom.lRoomId = [SSWDData getInstance].mGameRoom.mRoomID;
    
    [engine initHeader];
    NSData *sendPackage = [engine getReqCSLeaveRoom:leaveRoom];
    [leaveRoom release];
    [[SSWDData getInstance].mSockPtr writeData:sendPackage withTimeout:1000 tag:0] ;
}


//
-(id) init
{
	if( (self=[super init])) {
		// ask director for the window size
        NSLog(@"ReadyGameLayer init");
        CGSize size = [[CCDirector sharedDirector] winSize];
        mCountdown = 10;
        
        [self initData];
        //准备游戏的背景
        CCSprite *backgroundLayer = [CCSprite spriteWithFile:@"PrepareBackground.png"];
        [backgroundLayer setPosition:ccp(size.width/2, size.height/2)];
        [self addChild:backgroundLayer];
        
        //头像背景
        iconBackgroundLayer = [CCSprite spriteWithFile:@"ReadyIconBackground.png"];
        [iconBackgroundLayer setPosition:ccp(size.width/2, size.height/2)];
        [self addChild:iconBackgroundLayer];
        
        //离开按钮
		CCMenuItemImage *itemExitGame = [CCMenuItemImage itemWithNormalImage:@"ExitBtn.png" selectedImage:@"ExitBtn.png"];
        [itemExitGame setBlock:^(id sender) {
            NSLog(@"离开游戏");
            [self leaveRoom];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[StartGameLayer scene] ]];
        }];
        CCMenu *exitMenu = [CCMenu menuWithItems:itemExitGame, nil];
        [exitMenu setPosition:ccp( size.width/2+200, size.height/2 + 130)];
        [self addChild:exitMenu z:3];
        
        //房间号的图片
        CCSprite *roomWord = [CCSprite spriteWithFile:@"RoomNum.png"];
        [roomWord setPosition:ccp(roomWord.boundingBox.size.width/2 + 10, size.height - roomWord.boundingBox.size.height/2 - 10)];
        [self addChild:roomWord z:1];
        
        //准备好请按开始的提示
        CCSprite *hintWord = [CCSprite spriteWithFile:@"hint_ready_game.png"];
        [hintWord setPosition:ccp(hintWord.boundingBox.size.width/2 + 5, hintWord.boundingBox.size.height/2 + 10)];
        [self addChild:hintWord z:1];
        
        //时间数字
        NSString *sCountDown = [NSString stringWithFormat:@"%d",mCountdown];
        mCountDownlabel = [CCLabelTTF labelWithString:sCountDown fontName:@"DFPHaiBaoW12-GB" fontSize:25];
        [mCountDownlabel setPosition:ccp(size.width - mCountDownlabel.boundingBox.size.width/2 - 80, hintWord.boundingBox.size.height/2 + 15)];
        [self addChild:mCountDownlabel z:2];
        
        //开始按钮
		CCMenuItemImage *itemStartGame = [CCMenuItemImage itemWithNormalImage:@"start.png" selectedImage:@"start.png"];
        [itemStartGame setBlock:^(id sender) {
            NSLog(@"开始游戏");
            [self playReady];
//            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameLayer scene] ]];
        }];
        CCMenu *startMenu = [CCMenu menuWithItems:itemStartGame, nil];
        [startMenu setPosition:ccp( size.width/2+200, size.height/2 - 130)];
        [self addChild:startMenu z:1];
        

        //首先创建8个layer，用于存放用户的展示信息
        CCLabelTTF *labelTime = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%lld",[SSWDData getInstance].mGameRoom.mRoomID] fontName:@"DFPHaiBaoW12-GB" fontSize:24];
        labelTime.position = ccp(100, size.height - labelTime.boundingBox.size.height);
        [self addChild:labelTime z:0 tag:3];
        
        //设置用户头像相关
        [self setUser];
        
        
	}
	return self;
}

-(void)setUser{
    
     CGSize size = [[CCDirector sharedDirector] winSize];
    
    //设置用户头像
    int index = 0;
    //首先设置哪些已经进入的房间的头像
    NSArray *keys = [mUsers allKeys];
    for (NSNumber *uuidNumber in keys) {
        GameUser *user = [mUsers objectForKey:uuidNumber];
        CCLayer *userIcon = [[CCLayer alloc] init];
        //设置头像大小
        [userIcon setContentSize:CGSizeMake(140, 140)];
        //例子程序，首先获取头像的图片
        UIImage *iconImage = [UIImage imageNamed:user.mIcon];
        
        //对头像处里，获取圆形icon
        UIImage *iconImageA = [Utility generateCircleIcon:iconImage width:140 height:140 iconType:ICON_STATE_BIG];
        
        CCSprite *icon = [CCSprite spriteWithCGImage:iconImageA.CGImage key:nil];
        [userIcon addChild:icon];
        //获取头像的位置，是第几行第几列的
        int rowIndex = index%4;
        int colIndex = 1;
        if (index >= 4) {
            colIndex = -1;
        }
        else{
            colIndex = 1;
        }
        
        //计算头像的位置
        [userIcon setPosition:ccp(size.width/2 - (3 -2*rowIndex)*(icon.boundingBox.size.width+20)/2 - 40
                                  ,size.height/2 + colIndex*(icon.boundingBox.size.height - 20) - 40)];
        
        [iconBackgroundLayer addChild:userIcon z:2 tag:100];
        index++;
    }
    
    for (int i = index; i < 8; i++) {
        CCLayer *userIcon1 = [[CCLayer alloc] init];
        [userIcon1 setContentSize:CGSizeMake(140, 140)];
        UIImage *tempIconBackground1 = [UIImage imageNamed:@"icon_background_4.png"];
        CCSprite *icon = [CCSprite spriteWithCGImage:tempIconBackground1.CGImage key:@"icon_background_4"];
        
        CCSprite *iconHintWord= [CCSprite spriteWithFile:@"prepareWord.png"];
        
        int rowIndex = i%4;
        int colIndex = 1;
        if (i >= 4) {
            colIndex = -1;
        }
        else{
            colIndex = 1;
        }
        
        [userIcon1 setPosition:ccp(size.width/2 - (3 -2*rowIndex)*(icon.boundingBox.size.width+20)/2 - 40
                                   ,size.height/2 + colIndex*(icon.boundingBox.size.height - 20) - 40)];
        
        [iconHintWord setPosition:ccp(size.width/2 - (3 -2*rowIndex)*(icon.boundingBox.size.width+20)/2 - 40
                                      ,size.height/2 + colIndex*(icon.boundingBox.size.height - 20) - 40)];
        
        [iconBackgroundLayer addChild:userIcon1 z:2 tag:100];
        [iconBackgroundLayer addChild:iconHintWord z:2 tag:100];
        
    }

}

//玩家进入房间后会倒计时，如果倒计时完成的时候玩家还没有选择准备ok，则推出该界面
- (void)countDownTimer: (NSTimer *) timer
{
//    mCountdown --;
//    if (mCountdown > 0) {
//        NSString *sCountDown = [NSString stringWithFormat:@"%d",mCountdown];
//        [mCountDownlabel setString:sCountDown];
//    }
//    else{
//        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[StartGameLayer scene] ]];
//    }

}

//这个是游戏房间中的用户状态改变的回调消息
- (void)userStateChange:(NSNotification *)notification{
    //这个函数的主要思路目前是如果一个好友的状态发生改变，则把界面上所有的好友的相关的展示都重新渲染一边
    //这种方法虽然不是效率最高的方法，但目前看来是最简单，和最不容易出错的方法
    //具体步骤如下所示
    //首先重新设置数据源
    [iconBackgroundLayer removeAllChildrenWithCleanup:YES];
//    [self removeAllChildrenWithCleanup:YES];
    [self setUser];
}



//这里注意，要调用父类的onEnter方法
-(void)onEnter{
    [super onEnter];
//    [mUsers removeAllObjects];
//    NSArray *keys = [[SSWDData getInstance].mGameRoom.mGameUsers allKeys];
//    for (NSNumber *uuidNumber in keys) {
//        GameUser *gGameUser = [[SSWDData getInstance].mGameRoom.mGameUsers objectForKey:uuidNumber];
//        GameUser *lGameUser = [[GameUser alloc] init];
//        lGameUser.uuid = gGameUser.uuid;
//        lGameUser.mIcon = gGameUser.mIcon;
//        lGameUser.mNickName = gGameUser.mNickName;
//        lGameUser.mUserState = gGameUser.mUserState;
//        
//        [mUsers addObject:lGameUser];
//    }
    //添加玩家状态改变的消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userStateChange:) name:NOTIFY_USER_STATE_CHANGE object:nil];
}

-(void)onExit{
    //注销相关消息
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [mReadyTimer invalidate];
    
    [super onExit];
}


-(void)onEnterTransitionDidFinish{
    NSLog(@"ReadyGameLayer onEnterTransitionDidFinish");
    [super onEnterTransitionDidFinish];
    mReadyTimer =  [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                   target: self
                                                 selector: @selector(countDownTimer:)
                                                 userInfo: nil
                                                  repeats: YES];
}

@end
