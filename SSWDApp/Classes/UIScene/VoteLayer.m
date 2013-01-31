//
//  VoteLayer.m
//  SSWDApp
//
//  Created by BladeWang on 13-1-22.
//  Copyright 2013年 share. All rights reserved.
//

#import "VoteLayer.h"
#import "GameUser.h"
#import "Utility.h"


@implementation VoteLayer
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	VoteLayer *layer = [VoteLayer node];
	
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
        [self initData];
        
        //设置背景
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCSprite *background;
		
		if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
			background = [CCSprite spriteWithFile:@"bg_vote.png"];
		} else {
			background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
		}
		background.position = ccp(size.width/2, size.height/2);
        
		// add the label as a child to this Layer
		[self addChild: background];
        
        //房间号
        CCSprite *spriteRoom = [CCSprite spriteWithFile:@"text_room_num.png"];

        spriteRoom.position = ccp(spriteRoom.contentSize.width/2 + 50, size.height- (spriteRoom.contentSize.height/2) - 10);
        
        [self addChild:spriteRoom z:0 tag:0];
        
        int roomNum = 00246;
        
        CCLabelTTF *labelRoomNum = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i",roomNum] fontName:@"DFPHaiBaoW12-GB" fontSize:20];
        
        labelRoomNum.color = ccRED;//??
        
        labelRoomNum.position = ccp(spriteRoom.contentSize.width+ 70 + labelRoomNum.contentSize.width/2, spriteRoom.position.y);
        
        [self addChild:labelRoomNum z:0 tag:1];
        
        //请投票提示
        CCSprite *votePlz = [CCSprite spriteWithFile:@"text_voteplz.png"];

        votePlz.position = ccp(votePlz.contentSize.width/2 + 50, votePlz.contentSize.height/2 + 10);
        
        [self addChild:votePlz z:0 tag:2];
        
        timeNum = 10;
        
        
        //倒计时提示
        
        labelTime = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i",timeNum] fontName:@"DFPHaiBaoW12-GB" fontSize:24];
        
        labelTime.color = ccBLACK;//??加描边
        
        labelTime.position = ccp(size.width - labelTime.contentSize.width - 50, labelTime.contentSize.height/2 +10);
        
        [self addChild:labelTime z:0 tag:3];
        
        
        
        CCSprite *time = [CCSprite spriteWithFile:@"text_time2.png"];
        
        time.position = ccp(labelTime.position.x - labelTime.contentSize.width/2 - 20 - time.contentSize.width/2, time.contentSize.height/2 + 10);
        
        [self addChild:time z:0 tag:4];
        
        
        CCSprite *bgSprite = [CCSprite spriteWithFile:@"bg_voting.png"];
        
        bgSprite.position = ccp(size.width/2, size.height/2);
        
        [self addChild:bgSprite z:0 tag:5];
        
        //头像
        CGPoint oldPointUp = CGPointMake(bgSprite.contentSize.width/5, bgSprite.contentSize.height/3*2);
        CGPoint oldPointDown = CGPointMake(bgSprite.contentSize.width/4, bgSprite.contentSize.height/3);
        
        NSMutableArray *upItems = [NSMutableArray array];
        int i = 0;
        for (GameUser *user in mUsers) {
            
            //例子程序，首先获取头像的图片
            UIImage *iconImage = [UIImage imageNamed:user.mIcon];
            
            //对头像处里，获取圆形icon
            UIImage *iconImageA = [Utility generateCircleIcon:iconImage width:140 height:140 iconType:ICON_STATE_BIG];
            
            CCLabelTTF *name = [CCLabelTTF labelWithString:user.mNickName fontName:@"DFPHaiBaoW12-GB" fontSize:16];
            CCLabelTTF *name2 = [CCLabelTTF labelWithString:user.mNickName fontName:@"DFPHaiBaoW12-GB" fontSize:16];
            
            
            CCSprite *head = [CCSprite spriteWithCGImage:iconImageA.CGImage key:nil];
            name.position = ccp(head.contentSize.width/2, 0);
            [head addChild:name];
            
            CCSprite *head2 = [CCSprite spriteWithCGImage:iconImageA.CGImage key:nil];
            name2.position = ccp(head.contentSize.width/2, 0);
            [head2 addChild:name2];
            
            CCMenuItemSprite *itemSprite = [CCMenuItemSprite itemWithNormalSprite:head selectedSprite:head2 target:self selector:@selector(headSelected:)];
            
            
            itemSprite.tag = i;
            [upItems addObject:itemSprite];
            i++;
            
        }
        
        CCMenu *upMenu = [CCMenu menuWithItems:[upItems objectAtIndex:0], [upItems objectAtIndex:1],[upItems objectAtIndex:2],[upItems objectAtIndex:3],nil];
        [upMenu alignItemsHorizontallyWithPadding:10];
        upMenu.position = ccp(bgSprite.contentSize.width/2, oldPointUp.y + 10);
        upmenuY = upMenu.position.y;
        upMenu.tag = 200;
        [bgSprite addChild:upMenu];
        
        CCMenu *downMenu = [CCMenu menuWithItems:[upItems objectAtIndex:4], [upItems objectAtIndex:5],[upItems objectAtIndex:6],nil];
        [downMenu alignItemsHorizontallyWithPadding:20];
        downMenu.position = ccp(bgSprite.contentSize.width/2, oldPointDown.y);
        downMenu.tag = 201;
        downmenuY = downMenu.position.y;
        [bgSprite addChild:downMenu];
        
        
        
         timer = [CCTimerTargetSelector timerWithTarget:self selector:@selector(timer) interval:1];
        [self schedule:@selector(timer) interval:1];
        
        
	}
	return self;
}

- (void)timer{
    CCLOG(@"aaasssdddd");
    timeNum--;
    if (timeNum>=0) {
        [labelTime setString:[NSString stringWithFormat:@"%i",timeNum]];
    }else{
        [self unschedule:_cmd];
        CCLOG(@"toggle the target player");
    }

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
    timer = nil;
    labelTime = nil;
    [mUsers release];
    [super dealloc];
}

- (void)headSelected:(id)sender{
    CCNode *node = (CCNode *)sender;
    
    
    CCLOG(@"=== %i",node.tag);
    CCLayerColor *layercolor = [CCLayerColor layerWithColor:ccc4(255, 0, 0, 150)];
    CGSize size = [[CCDirector sharedDirector] winSize];
    layercolor.contentSize = size;
    
//    layercolor.
    
    CCLOG(@"layercolor.contentSize = %f ==%f",layercolor.contentSize.width,layercolor.contentSize.height);
    
    CCSprite *headCoverSprite = [CCSprite spriteWithFile:@"headCover.png"];

    CCNode *_node = [self getChildByTag:100];
    if (_node) {
        [self removeChildByTag:100 cleanup:YES];

    }
    CCSprite *coverSprite = [self maskedLayerWithSprite:layercolor maskSprite:headCoverSprite node:node];
    coverSprite.position = ccp(size.width/2, size.height/2);
    [self addChild:coverSprite z:1 tag:100];

}

- (CCSprite *)maskedLayerWithSprite:(CCLayerColor *)textureLayer maskSprite:(CCSprite *)maskSprite node:(CCNode *)node{
    
    CCNode *bgSpriteNode = [self getChildByTag:5];
    
    // 1
    CCRenderTexture * rt = [CCRenderTexture renderTextureWithWidth:textureLayer.contentSize.width height:textureLayer.contentSize.height];
    
    // 2

//    textureLayer.position = ccp(size.width/2, size.height/2);
    CCLOG(@"sss==%f,==%f",bgSpriteNode.position.x,bgSpriteNode.position.y);
    CCLOG(@"==%f,==%f",bgSpriteNode.contentSize.width/2,bgSpriteNode.contentSize.height/2);
    CGFloat offsetY = bgSpriteNode.position.y - bgSpriteNode.contentSize.height/2;
    CCLOG(@"node==%f,==%f",node.position.x,node.position.y);
    CGFloat curX = bgSpriteNode.position.x + node.position.x;
    CGFloat curY = bgSpriteNode.position.y + node.position.y;
    if (node.tag <= 3) {
        curY = offsetY + upmenuY;
    }else{
        curY = offsetY + downmenuY;
    }
    maskSprite.position = ccp(curX, curY);
//    textureLayer.position = ccp(textureLayer.contentSize.width/2, textureLayer.contentSize.height/2);
    
    // 3
    
    [maskSprite setBlendFunc:(ccBlendFunc){GL_CONSTANT_ALPHA, GL_ZERO}];
//    [textureLayer setBlendFunc:(ccBlendFunc){GL_DST_ALPHA, GL_ZERO}];
    
    // 4
    [rt beginWithClear:0 g:0 b:0 a:0.5];
    [maskSprite visit];
//    [textureLayer visit];
    [rt end];
    
    // 5
    CCSprite *retval = [CCSprite spriteWithTexture:rt.sprite.texture];
    retval.flipY = YES;
    
    CCSprite *aimSprite = [CCSprite spriteWithFile:@"icon_aim.png"];
    aimSprite.position = ccp(curX, curY);
    [retval addChild:aimSprite];
    return retval;
    
}

- (CCSprite *)maskedSpriteWithSprite:(CCSprite *)textureSprite maskSprite:(CCSprite *)maskSprite {
    
    // 1
    
    CCRenderTexture * rt = [CCRenderTexture renderTextureWithWidth:maskSprite.contentSize.width height:maskSprite.contentSize.height];
    
    // 2
    maskSprite.position = ccp(maskSprite.contentSize.width/2, maskSprite.contentSize.height/2);
    textureSprite.position = ccp(textureSprite.contentSize.width/2, textureSprite.contentSize.height/2);
    
    // 3
    [maskSprite setBlendFunc:(ccBlendFunc){GL_ONE, GL_ZERO}];
    [textureSprite setBlendFunc:(ccBlendFunc){GL_DST_ALPHA, GL_ZERO}];
    
    // 4
    [rt begin];
    [maskSprite visit];
    [textureSprite visit];
    [rt end];
    
    // 5
    CCSprite *retval = [CCSprite spriteWithTexture:rt.sprite.texture];
    retval.flipY = YES;
    return retval;
    
}


@end
