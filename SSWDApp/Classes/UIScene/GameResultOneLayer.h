//
//  GameLayer.h
//  SSWDApp
//
//  Created by gaofei on 13-1-21.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "HelloWorldLayer.h"

@interface GameResultOneLayer : CCLayer
{
    NSMutableArray *mUsers;
}
+(CCScene *) scene;
@end
