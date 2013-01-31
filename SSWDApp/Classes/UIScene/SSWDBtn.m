//
//  SSWDBtn.m
//  SSWDApp
//
//  Created by gaofei on 13-1-23.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import "SSWDBtn.h"
#import "amrFileCodec.h"

@implementation SSWDBtn
@synthesize mSelectedBtnImage;
@synthesize mNormalBtnImage;


-(id) init
{
	if ((self=[super init]) ) {
        mNormalBtnImage = [CCSprite spriteWithFile:@"voice_btn.png"];
        
        [self addChild:mNormalBtnImage];
        [self setContentSize:CGSizeMake(mNormalBtnImage.boundingBox.size.width, mNormalBtnImage.boundingBox.size.height)];
	}
    
    return self;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];

    if (touchLocation.x <= self.boundingBox.size.width/2
        && touchLocation.y <= self.boundingBox.size.height/2
        && touchLocation.x >= -self.boundingBox.size.width/2
        && touchLocation.y >= -self.boundingBox.size.height/2) {
        
//        NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc] init];
//        [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
//        [recordSetting setValue:[NSNumber numberWithFloat:44110] forKey:AVSampleRateKey];
//        [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
//        [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVEncoderBitRateKey];
        
        NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  [NSNumber numberWithFloat: 8000],AVSampleRateKey,
                                  [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                  [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                  [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                  [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                  [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,nil];
        
        mRecordedTmpFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent: @"333.wav"]];
        NSLog(@"Using File called: %@",mRecordedTmpFile);
        NSError *error;
        mRecorder = [[AVAudioRecorder alloc] initWithURL:mRecordedTmpFile settings:recordSetting error:&error];
        
        [mRecorder setDelegate:self];
        [mRecorder record]; 
        NSLog(@"在相应区域，相应");
        return YES;
    }
    else{
        NSLog(@"Using File called: %@",[mRecordedTmpFile absoluteURL]);
        NSData *data = [NSData dataWithContentsOfURL:mRecordedTmpFile];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"b6" ofType:@"wav" ];
//        NSData *abc1 = [NSData dataWithContentsOfFile:filePath];

        NSData *abc = EncodeWAVEToAMR(data,1,16);
        
        
        NSData *ddd = DecodeAMRToWAVE(abc);
        
        NSError *error;
        AVAudioPlayer * avPlayer = [[AVAudioPlayer alloc] initWithData:ddd error:&error];
        [avPlayer prepareToPlay];
        [avPlayer setVolume:1.0];
        [avPlayer play];
        
        return NO;
    }
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    NSLog(@"SSWDBtn TowerSelectSprite (BOOL)ccTouchMoved");
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    NSLog(@"SSWDBtn TowerSelectSprite (BOOL)ccTouchEnd");
    [mRecorder stop];
//    mRecorder.
}

-(void)onEnter{
    [super onEnter];
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(void)onExit{
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [super onExit];
}
-(void)dealloc{
    [mSelectedBtnImage release];
    [mNormalBtnImage release];
    [super dealloc];
}
@end
