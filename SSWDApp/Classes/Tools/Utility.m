//
//  Utility.m
//  SSWDApp
//
//  Created by gaofei on 13-1-22.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import "Utility.h"

@implementation Utility

//缩放图片
+(UIImage*) scaleAndRotateImage:(UIImage*)photoimage:(CGFloat)bounds_width:(CGFloat)bounds_height
{
    CGImageRef imgRef =photoimage.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);	
	if ((width-height)*(bounds_width-bounds_height)<0 ) {
		CGFloat a = bounds_width;
		bounds_width = bounds_height;
		bounds_height = a;
	}
	
    bounds.size.width = bounds_width;
    bounds.size.height = bounds_height;
	
    CGFloat scaleRatio = bounds.size.width / width;
    CGFloat scaleRatioheight = bounds.size.height / height;


    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGContextScaleCTM(context, scaleRatio, -scaleRatioheight);
    CGContextTranslateCTM(context, 0, -height);

	
    CGContextConcatCTM(context, transform);
	
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
}

//混合两张图片，混合的方式为R = S*Da，即将第一个图片和第二个图片的Alpha值进行混合
//如果第二张图片是透明的，则第一张图片相应的部分也是透明的
+(UIImage *)generateImageMaskAlpha:(UIImage*)sImage alphaImage:(UIImage*)dImage2{
    UIGraphicsBeginImageContext(sImage.size);
    [sImage drawInRect:CGRectMake(0, 0, sImage.size.width, sImage.size.height)];
    
    [dImage2 drawInRect:CGRectMake(0, 0, dImage2.size.width, dImage2.size.height) blendMode:kCGBlendModeSourceIn alpha:1.0];
    
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//获取圆形头像
+(UIImage *)generateCircleIcon:(UIImage*)sImage width:(int)width height:(int)height iconType:(ICON_STATE)icon_type{
    
    //然后对头像图片进行压缩
    UIImage *iconImageC = [Utility scaleAndRotateImage:sImage :width :height];

    UIImage *dImage = nil;
    switch (icon_type) {
        case ICON_STATE_SMALL:
            dImage = [UIImage imageNamed:@"icon_background_1.png"];
            break;
        case ICON_STATE_MIDDLE:
            dImage = [UIImage imageNamed:@""];
            break;
        case ICON_STATE_BIG:
            dImage = [UIImage imageNamed:@"icon_background_2.png"];
            break;
        default:
            break;
    }
    
    UIImage *newImage= [Utility generateImageMaskAlpha:dImage alphaImage:iconImageC];
    
    return newImage;
}

@end
