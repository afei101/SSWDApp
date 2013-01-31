//
//  VoteLayer.h
//  SSWDApp
//
//  Created by BladeWang on 13-1-22.
//  Copyright 2013年 share. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface VoteLayer : CCLayer {
    int timeNum;
    CCTimerTargetSelector *timer;
    CCLabelTTF *labelTime;
    
    NSMutableArray *mUsers;
    
    CGFloat upmenuY;
    CGFloat downmenuY;
}
+(CCScene *) scene;
@end
