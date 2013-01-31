//
//  LoginLayer.m
//  SSWDApp
//
//  Created by gaofei on 13-1-22.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import "LoginLayer.h"
#import "SSWDData.h"
#import "StartGameLayer.h"
#import "TCPNetEngine.h"
#import "CCNotify.h"
#import "SpyDBManager.h"
@implementation LoginLayer

-(void)initNetEngine{
    
    if([SSWDData getInstance].mSockPtr == nil) {
        
        if([SSWDData getInstance].mRecvDelegate == nil) {
            [SSWDData getInstance].mRecvDelegate = [[NXRecvDelegate alloc] init] ;
        }
        
        [SSWDData getInstance].mSockPtr = [[AsyncSocket alloc] initWithDelegate:[SSWDData getInstance].mRecvDelegate] ;
    }
    
    NSError * emsg = nil ;
    if(![[SSWDData getInstance].mSockPtr connectToHost:@"120.204.202.196" onPort:8080 error:&emsg]) {
        NSLog(@"NetMainThread, connect failed, error=%@", emsg) ;
    }
}

-(void)accountRegister{
    TCPNetEngine *engine = [TCPNetEngine getInstance];
    CSRegister *csregister = [[CSRegister alloc] init];
    UserInfo *lUserInfo = [[UserInfo alloc] init];
    lUserInfo.iLevel = 0;
    lUserInfo.iWinTimes = 0;
    lUserInfo.iLostTimes = 0;
    lUserInfo.iTotalTimes = 0;
    lUserInfo.cGender = 0;
    lUserInfo.strDesc = @"";
    lUserInfo.strEmail = @"";
    
    UserBaseInfo *userBaseInfo = [[UserBaseInfo alloc] init];
    userBaseInfo.strCover = @"";
    userBaseInfo.strNick = @"afei101";
    userBaseInfo.strID = @"afei101.com";
    userBaseInfo.uuid = 100;
    userBaseInfo.eType = ID_TYPE_SINAWEIBO;
    lUserInfo.stBaseInfo = userBaseInfo;
    [userBaseInfo release];
    
    csregister.stUserInfo = lUserInfo;
    [lUserInfo release];
    
    [engine initHeader];
    NSData *sendPackage = [engine getReqRegisterData:csregister];
    [csregister release];
    [[SSWDData getInstance].mSockPtr writeData:sendPackage withTimeout:1000 tag:0] ;
}

-(void)accountLogin{
    TCPNetEngine *engine = [TCPNetEngine getInstance];
    CSLogin *cslogin = [[CSLogin alloc] init];
    cslogin.uuid = [SpyDBManager getUuid];
    cslogin.strIosToken = @"";
    
    [engine initHeader];
    NSData *sendPackage = [engine getReqLoginData:cslogin];
    [cslogin release];
    [[SSWDData getInstance].mSockPtr writeData:sendPackage withTimeout:1000 tag:0] ;
}



// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	LoginLayer *layer = [LoginLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
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
		CCMenuItemImage *itemLoginGame = [CCMenuItemImage itemWithNormalImage:@"LoginGameBtn.png" selectedImage:@"LoginGameBtnClicked.png"];
        [itemLoginGame setBlock:^(id sender) {
            NSLog(@"登陆游戏");

//            [self weiboLogin];
            [self accountLogin];
            
        }];
        CCMenu *LgoinMenu = [CCMenu menuWithItems:itemLoginGame, nil];
        [LgoinMenu setPosition:ccp( size.width/2+100, size.height/2 - 50)];
        [self addChild:LgoinMenu z:1];
        
        //设置设置功能按钮
        CCMenuItemImage *itemSetting = [CCMenuItemImage itemWithNormalImage:@"SettingBtn.png" selectedImage:@"SettingBtnClicked.png"];
        [itemSetting setBlock:^(id sender) {
            NSLog(@"设置");
        }];
        
        CCMenuItemImage *itemHelp = [CCMenuItemImage itemWithNormalImage:@"HelpBtn.png" selectedImage:@"HelpBtnClicked.png"];
        [itemHelp setBlock:^(id sender) {
            NSLog(@"帮助");
            [self accountRegister];
        }];
        
        CCMenu *optionMenu = [CCMenu menuWithItems:itemSetting,itemHelp,nil];
        [optionMenu alignItemsHorizontallyWithPadding:10];
        [optionMenu setPosition:ccp( size.width/2+100, size.height/2 - 100)];
        [self addChild:optionMenu z:1];
        
        [self initNetEngine];
	}
	return self;
}

- (void) onEnter{
    //添加消息
    [super onEnter];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:NOTIFY_LOGIN_SUCCESS object:nil];
}

-(void) onExit{
    //注销消息
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super onExit];
}

//登陆成功处理
- (void)loginSuccess:(NSNotification *)notification{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[StartGameLayer scene]]];
}

- (void) dealloc
{
    [[SSWDData getInstance].mSinaweibo release];
     [SSWDData getInstance].mSinaweibo = nil;
    [userInfo release], userInfo = nil;
	[super dealloc];
}

#pragma mark - Weibo Private Methods
- (void)weiboLogin{
    [SSWDData getInstance].mSinaweibo = [[SinaWeibo alloc] initWithAppKey:kAppKey appSecret:kAppSecret appRedirectURI:kAppRedirectURI andDelegate:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *sinaweiboInfo = [defaults objectForKey:@"SinaWeiboAuthData"];
    if ([sinaweiboInfo objectForKey:@"AccessTokenKey"] && [sinaweiboInfo objectForKey:@"ExpirationDateKey"] && [sinaweiboInfo objectForKey:@"UserIDKey"])
    {
        [SSWDData getInstance].mSinaweibo.accessToken = [sinaweiboInfo objectForKey:@"AccessTokenKey"];
        [SSWDData getInstance].mSinaweibo.expirationDate = [sinaweiboInfo objectForKey:@"ExpirationDateKey"];
        [SSWDData getInstance].mSinaweibo.userID = [sinaweiboInfo objectForKey:@"UserIDKey"];
    }
    

    [[SSWDData getInstance].mSinaweibo logIn];

}
//得到sina用户信息
- (void)getSinaUserInfo
{
    SinaWeibo *sinaweibo = [SSWDData getInstance].mSinaweibo;
    [sinaweibo requestWithURL:@"users/show.json"
                       params:[NSMutableDictionary dictionaryWithObject:sinaweibo.userID forKey:@"uid"]
                   httpMethod:@"GET"
                     delegate:self];
}


- (void)removeAuthData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
}

- (void)storeAuthData
{
    
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              [SSWDData getInstance].mSinaweibo.accessToken, @"AccessTokenKey",
                              [SSWDData getInstance].mSinaweibo.expirationDate, @"ExpirationDateKey",
                              [SSWDData getInstance].mSinaweibo.userID, @"UserIDKey",
                              [SSWDData getInstance].mSinaweibo.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - SinaWeibo Delegate

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogIn userID = %@ accesstoken = %@ expirationDate = %@ refresh_token = %@", sinaweibo.userID, sinaweibo.accessToken, sinaweibo.expirationDate,sinaweibo.refreshToken);
    
    //    [self resetButtons];
    [self storeAuthData];
    
//    [self createMainMenu:NO];
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogOut");
    [self removeAuthData];
    //    [self resetButtons];
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboLogInDidCancel");
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"sinaweibo logInDidFailWithError %@", error);
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    NSLog(@"sinaweiboAccessTokenInvalidOrExpired %@", error);
    [self removeAuthData];
    //    [self resetButtons];
}

#pragma mark - SinaWeiboRequest Delegate

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    if ([request.url hasSuffix:@"users/show.json"])
    {
        if (userInfo) {
            [userInfo release], userInfo = nil;
        }
        
    }
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    //得到sina用户信息回调，[SSWDData getInstance].mSinaweibo.userID
    if ([request.url hasSuffix:@"users/show.json"])
    {
        [userInfo release];
        userInfo = [result retain];
    }
}


@end
