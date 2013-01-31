//
//  NetRespManager.h
//  SSWDApp
//
//  Created by gaofei on 13-1-28.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPNetEngine.h"

@interface NetRespManager : NSObject

+ (NetRespManager *)getInstance;
-(void)handleRsp:(NSData*)rspData;

@end
