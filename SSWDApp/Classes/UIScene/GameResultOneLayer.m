//
//  GameLayer.m
//  SSWDApp
//
//  Created by gaofei on 13-1-21.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import "GameResultOneLayer.h"
#import "ReadyGameLayer.h"
#import "Utility.h"

@implementation GameResultOneLayer
// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameResultOneLayer *layer = [GameResultOneLayer node];
	
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
        [self initData];
        
        
        CGSize size = [[CCDirector sharedDirector] winSize];

        //设置背景
        CCSprite *background;		
		if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
			background = [CCSprite spriteWithFile:@"bg_gameover.png"];
		} else {
			background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
		}
		background.position = ccp(size.width/2, size.height/2);
		[self addChild: background];
        
        //设置结束提示语
        CCSprite *label = [CCSprite spriteWithFile:@"text_ending1.png"];
        label.position = ccp(size.width/2, size.height- label.contentSize.height/2 - 20);
        [self addChild:label z:0 tag:0];
        
        //设置“本轮胜者”
        CCSprite *label1 = [CCSprite spriteWithFile:@"text_victor.png"];
        label1.position = ccp(label.contentSize.width/2 - 20, label.position.y - label.contentSize.height/2 - 60);
        [self addChild:label1 z:0 tag:1];
        
        //画头像
        CGPoint oldPoint = CGPointMake(label1.position.x + label1.contentSize.width/2 + 30, label1.position.y);
        for (GameUser *user in mUsers) {
            
            //例子程序，首先获取头像的图片
            UIImage *iconImage = [UIImage imageNamed:user.mIcon];
            
            //对头像处里，获取圆形icon
            UIImage *iconImageA = [Utility generateCircleIcon:iconImage width:70 height:70 iconType:ICON_STATE_SMALL];
            
            CCSprite *head = [CCSprite spriteWithCGImage:iconImageA.CGImage key:nil];
            head.position = oldPoint;
            [self addChild:head z:0];
            oldPoint = ccp(head.position.x + head.contentSize.width/2 + 25, head.position.y);
            
            CCSprite *_label = [CCSprite spriteWithFile:@"icon_background_3.png"];
            _label.position = ccp(head.contentSize.width/2, head.contentSize.height/2);
            [head addChild:_label z:0 ];

        }
        
        [CCMenuItemFont setFontSize:28];
    
        //重新开始按钮
        CCMenuItemImage *itemPlayAgain = [CCMenuItemImage itemWithNormalImage:@"btn_playagain.png" selectedImage:@"btn_playagain.png"];
        [itemPlayAgain setBlock:^(id sender) {
            NSLog(@"重新开始");
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[ReadyGameLayer scene] ]];
        }];
       
        CCMenu *menu = [CCMenu menuWithItems:itemPlayAgain, nil];
		
		[menu setPosition:ccp( size.width/2, size.height/2 - 100)];
		
		[self addChild:menu];


	}
	return self;
}

-(void) initData{
    mUsers = [[NSMutableArray alloc] init];
    GameUser *gameUser = [[GameUser alloc] init];
    gameUser.mNickName = @"afei";
    gameUser.mIcon = @"icon_example.jpg";
    [mUsers addObject:gameUser];
    [gameUser release];
    
    GameUser *gameUser1 = [[GameUser alloc] init];
    gameUser1.mNickName = @"afei";
    gameUser1.mIcon = @"icon_example.jpg";
    [mUsers addObject:gameUser1];
    [gameUser1 release];
    
    GameUser *gameUser2 = [[GameUser alloc] init];
    gameUser2.mNickName = @"afei";
    gameUser2.mIcon = @"icon_example.jpg";
    [mUsers addObject:gameUser2];
    [gameUser2 release];
    
    GameUser *gameUser3 = [[GameUser alloc] init];
    gameUser3.mNickName = @"afei";
    gameUser3.mIcon = @"icon_example.jpg";
    [mUsers addObject:gameUser3];
    [gameUser3 release];
    
    GameUser *gameUser4 = [[GameUser alloc] init];
    gameUser4.mNickName = @"afei";
    gameUser4.mIcon = @"icon_example.jpg";
    [mUsers addObject:gameUser4];
    [gameUser4 release];
    
    GameUser *gameUser5 = [[GameUser alloc] init];
    gameUser5.mNickName = @"afei";
    gameUser5.mIcon = @"icon_example.jpg";
    [mUsers addObject:gameUser5];
    [gameUser5 release];
    
    GameUser *gameUser6 = [[GameUser alloc] init];
    gameUser6.mNickName = @"afei";
    gameUser6.mIcon = @"icon_example.jpg";
    [mUsers addObject:gameUser6];
    [gameUser6 release];
}



- (void)dealloc{
    [mUsers release];
    [super dealloc];
}

@end
