//
//  GameLayer.m
//  SSWDApp
//
//  Created by gaofei on 13-1-21.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import "GameLayer.h"
#import "GameUser.h"
#import "Utility.h"
#import "ConstantData.h"
#import "SSWDData.h"
#import "SSWDBtn.h"
#import "MsgTableViewCell.h"

@implementation GameLayer
@synthesize mGameUsers;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void)initData{
    mGameUsers = [[NSMutableArray alloc] init];
    
    for (int i = 0;  i < 8; i++) {
        GameUser *gameUser = [[GameUser alloc] init];
        gameUser.mNickName = @"afei";
        gameUser.mIcon = @"icon_example.jpg";
        
        
//        NSInteger randomNumber = arc4random() % 4;
//        switch (randomNumber) {
//            case 0:
//                gameUser.mGameState = DEAD_GAME_USER_STATE;
//                break;
//            case 1:
//                gameUser.mGameState = WAIT_GAME_USER_STATE;
//                break;
//            case 2:
//                gameUser.mGameState = TALKING_GAME_USER_STATE;
//                break;
//            case 3:
//                gameUser.mGameState = READY_GAME_USER_STATE;
//                break;
//            default:
//                break;
//        }

        [mGameUsers addObject:gameUser];
        [gameUser release];
    }
    
    [SSWDData getInstance].mGameUser = [[GameUser alloc] init];
    [SSWDData getInstance].mGameUser.mIcon = @"icon_example.jpg";
    [SSWDData getInstance].mGameUser.mNickName = @"afei";
//    [SSWDData getInstance].mGameUser.mGameState = TALKING_GAME_USER_STATE;
//    [SSWDData getInstance].mGameUser.mBReady = true;

}

-(id) init
{
	if( (self=[super init])) {
		// ask director for the window size
        NSLog(@"GameLayer init");
        [self initData];
//        [self initTableViewData];
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        //游戏背景图片
        CCSprite *backgroundLayer = [CCSprite spriteWithFile:@"GameBackground.png"];
        [backgroundLayer setPosition:ccp(size.width/2, size.height/2)];
        [self addChild:backgroundLayer];
        
        //发言部分背景图片
        CCSprite *voiceBackgroundLayer = [CCSprite spriteWithFile:@"VoiceBackground.png"];
        [voiceBackgroundLayer setPosition:ccp(size.width - voiceBackgroundLayer.boundingBox.size.width/2-10, size.height/2)];
        [self addChild:voiceBackgroundLayer];
        
        //创建聊天用tableview
        mTableView = [[UITableView alloc] initWithFrame:CGRectMake(voiceBackgroundLayer.position.x - voiceBackgroundLayer.contentSize.width/2+5
                                                                   , voiceBackgroundLayer.position.y - voiceBackgroundLayer.contentSize.height/2 + 5,
                                                                   voiceBackgroundLayer.contentSize.width -10,
                                                                   voiceBackgroundLayer.contentSize.height - 20) style:UITableViewStylePlain];
        mTableView.dataSource = self;
        mTableView.delegate = self;
        mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        mTableView.layer.cornerRadius = 6.0f;
        mTableView.backgroundColor = [UIColor clearColor];

        
        
        
        //头像部分背景图片
        CCSprite *iconBackgroundLayer = [CCSprite spriteWithFile:@"iconBackground.png"];
        [iconBackgroundLayer setPosition:ccp(iconBackgroundLayer.boundingBox.size.width/2, size.height/2)];
        [self addChild:iconBackgroundLayer];
        
        //添加头像背景的元素
        for (int i = 0; i < 8; i++) {
            //添加头像
            GameUser *user = [mGameUsers objectAtIndex:i];
            
            //例子程序，首先获取头像的图片
            UIImage *iconImage = [UIImage imageNamed:user.mIcon];
            
            //获取生成的圆形头像
            UIImage *iconImageA = [Utility generateCircleIcon:iconImage width:70 height:70 iconType:ICON_STATE_SMALL];
            
            CCSprite *icon = [CCSprite spriteWithCGImage:iconImageA.CGImage key:nil];

            int x = icon.boundingBox.size.width / 2 + 10;
            int y = (icon.boundingBox.size.height + 2)* i  + 30;
            [icon setPosition:ccp(x, y)];
            [iconBackgroundLayer addChild:icon];
            
            //添加头像旁边的发生按钮
//            NSString *gameStateName = nil;
//            switch (user.mGameState) {
//                case DEAD_GAME_USER_STATE:
//                    gameStateName = @"dead.png";
//                    break;
//                case WAIT_GAME_USER_STATE:
//                    gameStateName = @"NoVoice.png";
//                    break;
//                case READY_GAME_USER_STATE:
//                    gameStateName = @"Voiced.png";
//                    break;
//                case TALKING_GAME_USER_STATE:
//                    gameStateName = @"Voicing.png";
//                    break;
//                default:
//                    break;
//            }
//            CCSprite *voiceBtn = [CCSprite spriteWithFile:gameStateName];
//            x = icon.boundingBox.size.width * 3 / 2 + 20;
//            y = (icon.boundingBox.size.height + 2)* i + 30;
//            
//            [voiceBtn setPosition:ccp(x, y)];
//            [iconBackgroundLayer addChild:voiceBtn];
            
        }
        
        //添加发言背景的元素
        //首先添加用户自己的头像元素
        //例子程序，首先获取头像的图片
        UIImage *iconImage = [UIImage imageNamed:[SSWDData getInstance].mGameUser.mIcon];
        
        //获取生成的圆形头像
        UIImage *iconImageA = [Utility generateCircleIcon:iconImage width:140 height:140 iconType:ICON_STATE_BIG];
        CCSprite *myIcon = [CCSprite spriteWithCGImage:iconImageA.CGImage key:nil];
        [myIcon setPosition:ccp(myIcon.boundingBox.size.width/2 + 30,voiceBackgroundLayer.boundingBox.size.height - myIcon.boundingBox.size.height/2 - 30 )];
        [voiceBackgroundLayer addChild:myIcon];
        
        //添加“你拿到的词”这个label
        CCSprite *yourWordLabel = [CCSprite spriteWithFile:@"yourWord.png"];
        [yourWordLabel setPosition:ccp(myIcon.boundingBox.size.width + yourWordLabel.boundingBox.size.width/2 + 40 , voiceBackgroundLayer.boundingBox.size.height - yourWordLabel.boundingBox.size.height/2 - 30)];
        
        [voiceBackgroundLayer addChild:yourWordLabel];
        
        //添加你拿到的词
        CCLabelTTF *word = [CCLabelTTF labelWithString:@"灰机" fontName:@"DFPHaiBaoW12-GB" fontSize:30];
        word.color = ccc3(0,0,0);
        [word setPosition:ccp(myIcon.boundingBox.size.width + word.boundingBox.size.width/2 + 40, voiceBackgroundLayer.boundingBox.size.height - yourWordLabel.boundingBox.size.height - word.boundingBox.size.height/2 - 30 )];
        [voiceBackgroundLayer addChild:word];
        
        //添加倒计时功能
        CCSprite *countDownWord = [CCSprite spriteWithFile:@"count_down_word.png"];
        [countDownWord setPosition:ccp(countDownWord.boundingBox.size.width / 2 + 40 , 100)];
        [voiceBackgroundLayer addChild:countDownWord];
        
        //添加请按下录音的提示文字
        CCSprite *pressVoiceBtnWord = [CCSprite spriteWithFile:@"press_voice_btn_word.png"];
        [pressVoiceBtnWord setPosition:ccp(pressVoiceBtnWord.boundingBox.size.width / 2 + 40 , 60)];
        [voiceBackgroundLayer addChild:pressVoiceBtnWord];

        //添加录音按钮
        SSWDBtn *voiceBtn = [[SSWDBtn alloc] init];
        [voiceBtn setPosition:ccp( voiceBackgroundLayer.boundingBox.size.width/2 + 80, voiceBackgroundLayer.boundingBox.size.height/2 - 50)];
        [voiceBackgroundLayer addChild:voiceBtn z:1];

	}
	return self;
}

- (void)onEnterTransitionDidFinish{
//            [[[CCDirector sharedDirector] openGLView] addSubview:mTableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return mUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = [indexPath row];
    NSString *cellIdentifier;
    cellIdentifier = [NSString stringWithFormat:@"cellIdentifier"];
    __autoreleasing MsgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[MsgTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    
    [cell setLayout:[mUsers objectAtIndex:row]];
//    cell.textLabel.text = [NSString stringWithFormat:@"====%i",row];
    

    return cell;
}

- (void)dealloc{
    [mTableView release];
    [mUsers release];
    [super dealloc];
}

-(void) initTableViewData{
    mUsers = [[NSMutableArray alloc] init];
    GameUser *gameUser = [[GameUser alloc] init];
    gameUser.mNickName = @"afei";
    gameUser.mIcon = @"icon_example.jpg";
    gameUser.uuid = 0;
    [mUsers addObject:gameUser];
    [gameUser release];
    
    GameUser *gameUser1 = [[GameUser alloc] init];
    gameUser1.mNickName = @"afei";
    gameUser1.mIcon = @"icon_example.jpg";
    gameUser1.uuid = 0;
    [mUsers addObject:gameUser1];
    [gameUser1 release];
    
    GameUser *gameUser2 = [[GameUser alloc] init];
    gameUser2.mNickName = @"afei";
    gameUser2.mIcon = @"icon_example.jpg";
    gameUser2.uuid = 1;
    [mUsers addObject:gameUser2];
    [gameUser2 release];
    
    GameUser *gameUser3 = [[GameUser alloc] init];
    gameUser3.mNickName = @"afei";
    gameUser3.mIcon = @"icon_example.jpg";
    gameUser3.uuid = 3;
    [mUsers addObject:gameUser3];
    [gameUser3 release];
    
    GameUser *gameUser4 = [[GameUser alloc] init];
    gameUser4.mNickName = @"afei";
    gameUser4.mIcon = @"icon_example.jpg";
    gameUser4.uuid = 0;
    [mUsers addObject:gameUser4];
    [gameUser4 release];
    
    GameUser *gameUser5 = [[GameUser alloc] init];
    gameUser5.mNickName = @"afei";
    gameUser5.mIcon = @"icon_example.jpg";
    gameUser5.uuid = 1;
    [mUsers addObject:gameUser5];
    [gameUser5 release];
    
    GameUser *gameUser6 = [[GameUser alloc] init];
    gameUser6.mNickName = @"afei";
    gameUser6.mIcon = @"icon_example.jpg";
    gameUser6.uuid = 7;
    [mUsers addObject:gameUser6];
    [gameUser6 release];
}
@end
