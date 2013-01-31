//
//  GameResultThreeLayer.m
//  SSWDApp
//
//  Created by BladeWang on 13-1-22.
//  Copyright 2013年 share. All rights reserved.
//

#import "GameResultThreeLayer.h"
#import "GameLayer.h"

@implementation GameResultThreeLayer
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameResultThreeLayer *layer = [GameResultThreeLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		// ask director for the window size
        NSLog(@"GameLayer init");
        CGSize size = [[CCDirector sharedDirector] winSize];

        CCSprite *background;
		
		if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
			background = [CCSprite spriteWithFile:@"bg_gameover3.png"];
            //			background.rotation = 90;
		} else {
			background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
		}
		background.position = ccp(size.width/2, size.height/2);
        
		// add the label as a child to this Layer
		[self addChild: background];
        
//        CCSprite *label = [CCSprite spriteWithFile:@"text_ending2.png"];
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"本轮平票，无人出局，游戏继续..." fontName:@"DFPHaiBaoW12-GB" fontSize:24];
        
//        label.scale = scale;
        
        label.position = ccp(size.width/2, size.height/2);
        
        [self addChild:label z:0 tag:0];
        
        
        
        
        
	}
	return self;
}

- (void)onEnterTransitionDidFinish{
    [self scheduleOnce:@selector(toNextLayer) delay:2];
}

- (void)toNextLayer{
    CCLOG(@"bbbb");
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameLayer scene] ]];
}
@end
