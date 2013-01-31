//
//  LoginLayer.h
//  SSWDApp
//
//  Created by gaofei on 13-1-22.
//  Copyright (c) 2013年 share. All rights reserved.
//

#define kAppKey            @"3508530362"
#define kAppSecret         @"2b058229a31a15f19d671c594c3f4d14"
#define kAppRedirectURI        @"http://www.sina.com.cn/"

#import "CCLayer.h"
#import "cocos2d.h"
#import "SinaWeibo.h"
@interface LoginLayer : CCLayer<SinaWeiboDelegate, SinaWeiboRequestDelegate>
{
    NSDictionary *userInfo;
}
+(CCScene *) scene;
@end
