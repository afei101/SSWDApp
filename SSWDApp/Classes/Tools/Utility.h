//
//  Utility.h
//  SSWDApp
//
//  Created by gaofei on 13-1-22.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConstantData.h"

@interface Utility : NSObject
+(UIImage*) scaleAndRotateImage:(UIImage*)photoimage:(CGFloat)bounds_width:(CGFloat)bounds_height;
+(UIImage *)generateCircleIcon:(UIImage*)sImage width:(int)width height:(int)height iconType:(ICON_STATE)icon_type;
+(UIImage *)generateImageMaskAlpha:(UIImage*)sImage alphaImage:(UIImage*)dImage2;
@end
