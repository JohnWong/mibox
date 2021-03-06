//
//  JWRemoteControl.m
//  mibox
//
//  Created by John Wong on 12/16/15.
//  Copyright © 2015 John Wong. All rights reserved.
//

#import "JWRemoteControl.h"


@interface JWRemoteControl () <NSStreamDelegate>

@end


@implementation JWRemoteControl {
    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;
    unsigned int _sequence;
    dispatch_queue_t _queue;
}

- (instancetype)initWithHost:(NSString *)host port:(UInt32)port
{
    self = [super init];
    if (self) {
        NSString *url = host;
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)url, port, &readStream, &writeStream);
        _inputStream = (__bridge NSInputStream *)readStream;
        _outputStream = (__bridge NSOutputStream *)writeStream;
        [_inputStream setDelegate:self];
        [_outputStream setDelegate:self];
        _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return self;
}

- (void)start
{
    dispatch_async(_queue, ^{
        [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [_inputStream open];
        [_outputStream open];
        [[NSRunLoop currentRunLoop] run];
    });
}

- (void)stop
{
    [_inputStream close];
    [_outputStream close];
}

- (void)dealloc
{
    [self stop];
}

- (void)sendKeyCode:(JWKeyCode)keyCode
{
    dispatch_async(_queue, ^{
        NSData *data = [self dataWithKeyCode:keyCode isRep:NO];
        [_outputStream write:[data bytes] maxLength:data.length];
        data = [self dataWithKeyCode:keyCode isRep:YES];
        [_outputStream write:[data bytes] maxLength:data.length];
    });
}


- (NSData *)dataWithKeyCode:(JWKeyCode)event isRep:(BOOL)isReplicated
{
    _sequence += 1;
    uint32_t isRep = 0 + isReplicated;
    uint64_t keyCode = 0;
    switch (event) {
        case JWKeyCodeMenu:
            keyCode = 0x52040000008b0500;
            break;
        case JWKeyCodeReturn:
            keyCode = 0x04040000009e0500;
            break;
        case JWKeyCodeHome:
            keyCode = 0x0304000000660500;
            break;
        case JWKeyCodeOff:
            keyCode = 0x1a04000000740500;
            break;
        case JWKeyCodeConfirm:
            keyCode = 0x42040000001c0500;
            break;
        case JWKeyCodeVolumnUp:
            keyCode = 0x1804000000730500;
            break;
        case JWKeyCodeVolumnDown:
            keyCode = 0x1904000000720500;
            break;
        case JWKeyCodeUp:
            keyCode = 0x1304000000670500;
            break;
        case JWKeyCodeDown:
            keyCode = 0x14040000006c0500;
            break;
        case JWKeyCodeLeft:
            keyCode = 0x1504000000690500;
            break;
        case JWKeyCodeRight:
            keyCode = 0x16040000006a0500;
            break;
        default:
            break;
    }

    uint32_t bytes[] = {
        0x04004101,
        _sequence,
        0x003a0100,
        0x00000002,
        isRep,
        0x03000000,
        keyCode >> 32,
        keyCode & 0xffffffff,
        0x00000006,
        0x00000008,
        0x07000000,
        0x00000000,
        0x00080000,
        0x00000000,
        0x00000a00,
        0x0000020b,
        0x00000301};
    NSMutableData *mutableData = [[NSMutableData alloc] init];
    for (int i = 0; i < sizeof(bytes) / sizeof(bytes[0]); i++) {
        uint32_t swaped = CFSwapInt32(bytes[i]);
        [mutableData appendBytes:&swaped length:sizeof(swaped)];
    }
    return [mutableData copy];
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventHasSpaceAvailable: {
            if (stream == _outputStream) {
                NSLog(@"outputStream is ready.");
            }
            break;
        }
        case NSStreamEventHasBytesAvailable:
            if (stream == _inputStream) {
                //                NSLog(@"inputStream is ready.");

                uint8_t buf[1024];
                NSInteger len = 0;

                NSMutableData *data = [[NSMutableData alloc] initWithLength:0];
                if ((len = [_inputStream read:buf maxLength:1024]) > 0) {
                    [data appendBytes:(const void *)buf length:len];
                }
                //                NSLog(@"Result: %@", data);
            }
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"%@", stream.streamError);
            break;
        case NSStreamEventEndEncountered:
            [stream open];
            break;
        default:
            NSLog(@"Stream triggered %@", @(eventCode));
            break;
    }
}

@end
