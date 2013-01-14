//
//  SSWDData.h
//  SSWDApp
//
//  Created by gaofei on 13-1-10.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "NXRecvDelegate.h"

@interface SSWDData : NSObject{
    AsyncSocket *mSockPtr;
//    回调实例
    NXRecvDelegate *mRecvDelegate;
}

@property(nonatomic,retain)AsyncSocket *mSockPtr;
@property(nonatomic,retain)NXRecvDelegate *mRecvDelegate;

+ (SSWDData *)getInstance;
@end
