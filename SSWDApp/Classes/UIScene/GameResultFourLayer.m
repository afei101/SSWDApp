//
//  GameResultFourLayer.m
//  SSWDApp
//
//  Created by BladeWang on 13-1-22.
//  Copyright 2013年 share. All rights reserved.
//

#import "GameResultFourLayer.h"
#import "GameResultTwoLayer.h"
#import "GameUser.h"
#import "Utility.h"


@implementation GameResultFourLayer
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameResultFourLayer *layer = [GameResultFourLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		// ask director for the window size
        [self initData];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCSprite *background;
		
		if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
			background = [CCSprite spriteWithFile:@"bg_gameover4.png"];


		} else {
			background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
		}
		background.position = ccp(size.width/2, size.height/2);
        
		// add the label as a child to this Layer
		[self addChild: background];

        
        GameUser *user = [mUsers objectAtIndex:0];
        //例子程序，首先获取头像的图片
        UIImage *iconImage = [UIImage imageNamed:user.mIcon];
        
        //对头像处里，获取圆形icon
        UIImage *iconImageA = [Utility generateCircleIcon:iconImage width:140 height:140 iconType:ICON_STATE_BIG];
        
        CCSprite *spriteHead = [CCSprite spriteWithCGImage:iconImageA.CGImage key:nil];
        spriteHead.position = ccp(size.width/2, size.height/2);
        [self addChild:spriteHead z:0];

        
        
        NSString  *name = @"高2飞";
        int voteNum = 7;
        CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@获得%i票，出局",name,voteNum] fontName:@"DFPHaiBaoW12-GB" fontSize:24];
        
        label.position = ccp(size.width/2, size.height/2 - spriteHead.contentSize.height/2 - 40);
        
        [self addChild:label z:0 tag:0];
        
        
        
        
        
	}
	return self;
}

- (void)onEnterTransitionDidFinish{
    [self scheduleOnce:@selector(toNextLayer) delay:2];
}

- (void)toNextLayer{
    CCLOG(@"bbbb");
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameResultTwoLayer scene] ]];
}

-(void) initData{
    mUsers = [[NSMutableArray alloc] init];
    GameUser *gameUser = [[GameUser alloc] init];
    gameUser.mNickName = @"afei";
    gameUser.mIcon = @"icon_example.jpg";
    [mUsers addObject:gameUser];
    [gameUser release];
    
}

- (void)dealloc{
    [mUsers release];
    [super dealloc];
}
@end
