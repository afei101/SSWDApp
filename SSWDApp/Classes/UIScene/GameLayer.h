//
//  GameLayer.h
//  SSWDApp
//
//  Created by gaofei on 13-1-21.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface GameLayer : CCLayer<UITableViewDataSource, UITableViewDelegate>{
    NSMutableArray *mGameUsers;
    
    UITableView *mTableView;
    NSMutableArray *mUsers;
}

@property(nonatomic,retain)NSMutableArray *mGameUsers;

+(CCScene *) scene;
@end
