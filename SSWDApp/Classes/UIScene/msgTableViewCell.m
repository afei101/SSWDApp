//
//  MsgTableViewCell.m
//  SSWDApp
//
//  Created by BladeWang on 13-1-23.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import "MsgTableViewCell.h"
#import "Utility.h"

@implementation MsgTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setLayout:(GameUser *)user{
    
    if (user.uuid == 0) {
        //例子程序，首先获取头像的图片
        UIImageView *img = (UIImageView *)[self.contentView viewWithTag:0xAA];
        if (img == NULL) {
            UIImage *iconImage = [UIImage imageNamed:user.mIcon];
            
            //对头像处里，获取圆形icon
            UIImage *iconImageA = [Utility generateCircleIcon:iconImage width:70 height:70 iconType:ICON_STATE_SMALL];
            
            UIImageView *imgView = [[UIImageView alloc] initWithImage:iconImageA];
            imgView.frame = CGRectMake(self.frame.size.width - iconImageA.size.width - 10,
                                       (self.frame.size.height - iconImageA.size.height)/2,
                                       iconImageA.size.width,
                                       iconImageA.size.height);
            imgView.tag = 0xAA;
            [self.contentView addSubview:imgView];
            [imgView release];
            
            UILabel *msgLabel = [[UILabel alloc] init];
            msgLabel.font = [UIFont fontWithName:@"DFPHaiBaoW12-GB" size:12];
            msgLabel.textColor = [UIColor blackColor];
            msgLabel.text = @"aaaaa啊啊啊啊#￥#%";
            msgLabel.backgroundColor = [UIColor clearColor];
            [msgLabel sizeToFit];
            msgLabel.frame = CGRectMake(imgView.frame.origin.x - 5 - msgLabel.frame.size.width,
                                        (self.frame.size.height - msgLabel.frame.size.height)/2,
                                        msgLabel.frame.size.width, msgLabel.frame.size.height);
            [self.contentView addSubview:msgLabel];
            [msgLabel release];
            
            
        }

    }else{
        //例子程序，首先获取头像的图片
        UIImageView *img = (UIImageView *)[self.contentView viewWithTag:0xAA];
        if (img == NULL) {
            UIImage *iconImage = [UIImage imageNamed:user.mIcon];
            
            //对头像处里，获取圆形icon
            UIImage *iconImageA = [Utility generateCircleIcon:iconImage width:70 height:70 iconType:ICON_STATE_SMALL];
            
            UIImageView *imgView = [[UIImageView alloc] initWithImage:iconImageA];
            imgView.frame = CGRectMake(10,
                                       (self.frame.size.height - iconImageA.size.height)/2,
                                       iconImageA.size.width,
                                       iconImageA.size.height);
            imgView.tag = 0xAA;
            [self.contentView addSubview:imgView];
            [imgView release];
            
            UILabel *msgLabel = [[UILabel alloc] init];
            msgLabel.font = [UIFont fontWithName:@"DFPHaiBaoW12-GB" size:12];
            msgLabel.textColor = [UIColor blackColor];
            msgLabel.text = @"aaaaa啊啊啊啊#￥#%";
            msgLabel.backgroundColor = [UIColor clearColor];
            [msgLabel sizeToFit];
            msgLabel.frame = CGRectMake(imgView.frame.origin.x + imgView.frame.size.width + 5,
                                        (self.frame.size.height - msgLabel.frame.size.height)/2,
                                        msgLabel.frame.size.width, msgLabel.frame.size.height);
            [self.contentView addSubview:msgLabel];
            [msgLabel release];
    
    }
    }
}

@end
