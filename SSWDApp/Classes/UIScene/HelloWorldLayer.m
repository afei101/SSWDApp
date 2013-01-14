//
//  HelloWorldLayer.m
//  SSWDApp
//
//  Created by gaofei on 13-1-10.
//  Copyright share 2013年. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "SSWDData.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
    // always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		
        
        [self initNetEngine];
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"谁是卧底?" fontName:@"Marker Felt" fontSize:64];
        
		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
		// position the label on the center of the screen
		label.position =  ccp( size.width /2 , size.height/2 + size.height/5);
		
		// add the label as a child to this Layer
		[self addChild: label];
		
		// Default font size will be 28 points.
		[CCMenuItemFont setFontSize:28];
		
		// Achievement Menu Item using blocks
		CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"开始游戏"];
        
		// Leaderboard Menu Item using blocks
		CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"创建房间"];
		
		CCMenu *menu = [CCMenu menuWithItems:itemAchievement, itemLeaderboard, nil];
		
		[menu alignItemsHorizontallyWithPadding:20];
		[menu setPosition:ccp( size.width/2, size.height/2 - 50)];
		
		// Add the menu to the layer
		[self addChild:menu];
        
	}
	return self;
}


-(void)initNetEngine{
    
    if([SSWDData getInstance].mSockPtr == nil) {
        
        if([SSWDData getInstance].mRecvDelegate == nil) {
            [SSWDData getInstance].mRecvDelegate = [[NXRecvDelegate alloc] init] ;
        }
        
        [SSWDData getInstance].mSockPtr = [[AsyncSocket alloc] initWithDelegate:[SSWDData getInstance].mRecvDelegate] ;
    }
    
    NSError * emsg = nil ; 
    if(![[SSWDData getInstance].mSockPtr connectToHost:@"113.108.82.81" onPort:8080 error:&emsg]) {
        NSLog(@"NetMainThread, connect failed, error=%@", emsg) ;
    }
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
