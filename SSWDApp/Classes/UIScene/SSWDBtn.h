//
//  SSWDBtn.h
//  SSWDApp
//
//  Created by gaofei on 13-1-23.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface SSWDBtn : CCLayer<CCTargetedTouchDelegate,AVAudioRecorderDelegate>{
    CCSprite *mNormalBtnImage;
    CCSprite *mSelectedBtnImage;
    AVAudioRecorder *mRecorder;
    NSURL *mRecordedTmpFile;
}

@property(nonatomic,retain) CCSprite *mNormalBtnImage;
@property(nonatomic,retain) CCSprite *mSelectedBtnImage;
@end

