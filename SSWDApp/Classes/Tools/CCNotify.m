//
//  CCNotify.m
//  SSWDApp
//
//  Created by gaofei on 13-1-28.
//  Copyright (c) 2013年 share. All rights reserved.
//

#import "CCNotify.h"
@implementation CCNotify

+ (id)getObj:(NSDictionary*)obj byNum:(NSInteger)i
{
    return [obj objectForKey:[NSNumber numberWithInt:i]];
}

+ (void)sentNotify:(NSString*)type obj:(id)content,...
{
    va_list args;
    va_start(args, content);
    __autoreleasing NSMutableDictionary * obj = [[NSMutableDictionary alloc] init];
    NSInteger i = 0;
    for(id arg = content; arg!=nil; arg = va_arg(args,id),i++){
        [obj setObject:arg forKey:[NSNumber numberWithInt:i]];
    }
    va_end(args);
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:type object:obj]];
}
@end
