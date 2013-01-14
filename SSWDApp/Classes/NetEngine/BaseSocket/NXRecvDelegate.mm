//
//  NXRecvDelegate.m
//  NoxEngine
//
//  Created by 飞 高 on 12-2-9.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#import "NXRecvDelegate.h"

@implementation NXRecvDelegate

-(NXRecvDelegate *)init{
    if (self = [super init]) {
        
        return self;
    }
    return nil;
}

- (void) dealloc
{
    [super dealloc];
    NSLog(@"[sice] NXRecvDelegate dealloc");
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    NSLog(@"willDisconnectWithError:(NSError *)err called!");
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    NSLog(@"onSocketDidDisconnect:(AsyncSocket *)sock called!") ;
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket {
    NSLog(@"onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket called!") ;
}

- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket {
    NSLog(@"onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket called!") ; 
    return nil ;   
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock {
    NSLog(@"onSocketWillConnect:(AsyncSocket *)sock called!") ; 
    return YES ; 
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port called!") ;
}

- (void)receivePacketData:(NSData*)data
{
    NSMutableData* tempData = [[NSMutableData alloc] init];
    [tempData appendData:m_fixbuffer];
    [tempData appendData:data];
   
    unsigned int dataLength = [tempData length];
    unsigned char * temp = (unsigned char *)[tempData bytes];
    while (dataLength>0) {
        if (dataLength<=6) {
            [m_fixbuffer setLength:0];
            [m_fixbuffer appendBytes:(void *)(temp) length:dataLength];
            return ;
        }
        unsigned short mark = (unsigned short)*temp;
        mark = (mark<<8|*(temp+1));
        temp = temp+2;
        
        if (mark != 0xffee) {
            [m_fixbuffer setLength:0];
            NSLog(@"包头不正确");
            return ;
        }
        
        unsigned int length = (unsigned int)*(temp);
        length = (length<<8|*(temp+1));
        length = (length<<8|*(temp+2));
        length = (length<<8|*(temp+3));
        temp += 4;

        if (m_fixbuffer == nil) {
            m_fixbuffer = [[NSMutableData alloc] init];
        }
        
        if (length <= 0) {
            NSLog(@"receivepacketData length too small");
            [m_fixbuffer setLength:0];
            return;
        }
        
        if (dataLength < length) {
            [m_fixbuffer setLength:0];
            [m_fixbuffer appendBytes:(void *)(temp-6) length:dataLength];
            return ;
            
        } else if(dataLength > length){
            [m_fixbuffer setLength:0];
            NSData *packageData = [[NSData alloc] initWithBytes:(void *)(temp) length:(length)];
            
            temp += (length-6);
            dataLength -= length;

             //完成粘包处理，回调上层应用
//            Nox *queueEngine = [Nox getInstance];
//            [queueEngine.recvQ inQueue:packageData]; 
//            
//            if(queueEngine != nil){
//                CFRunLoopSourceSignal(queueEngine->recvWorkerRecvSource);
//                CFRunLoopWakeUp(queueEngine->recvWorkerRunLoop);
//            }
        } else if(dataLength == length){
            [m_fixbuffer setLength:0];
            NSData *packageData = [[NSData alloc] initWithBytes:(void *)(temp) length:(length)];
            
            dataLength -= length;
            index ++;
            
            //完成粘包处理，回调上层应用
//            Nox *queueEngine = [Nox getInstance];
//            [queueEngine.recvQ inQueue:packageData];
//            if(queueEngine != nil){
//                CFRunLoopSourceSignal(queueEngine->recvWorkerRecvSource);
//                CFRunLoopWakeUp(queueEngine->recvWorkerRunLoop);
//            }
        }
    }
//    [tempData release];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag");
//    [self receivePacketData:data];
//    [sock readDataWithTimeout:25 tag:0 ] ;
}


- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    [sock readDataWithTimeout:25 tag:0 ] ; 
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag called!") ; 
}

- (void)onSocket:(AsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    NSLog(@"onSocket:(AsyncSocket *)sock didWritePartialDataOfLength: partialLength=%d tag:(long)tag called!", partialLength) ; 
}

- (NSTimeInterval)onSocket:(AsyncSocket *)sock
  shouldTimeoutReadWithTag:(long)tag
                   elapsed:(NSTimeInterval)elapsed
                 bytesDone:(NSUInteger)length { 
    NSTimeInterval val = 1000;
    return val ; 
}

- (NSTimeInterval)onSocket:(AsyncSocket *)sock
 shouldTimeoutWriteWithTag:(long)tag
                   elapsed:(NSTimeInterval)elapsed
                 bytesDone:(NSUInteger)length {
    NSTimeInterval val = 1000;
    NSLog(@"onSocket:(AsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed one:(NSUInteger)length called!") ; 
    return val ; 
}

- (void)onSocketDidSecure:(AsyncSocket *)sock {
    NSLog(@"onSocketDidSecure:(AsyncSocket *)sock called!") ; 
}


@end
