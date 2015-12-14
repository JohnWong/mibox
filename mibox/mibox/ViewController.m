//
//  ViewController.m
//  mibox
//
//  Created by John Wong on 12/14/15.
//  Copyright © 2015 John Wong. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <NSStreamDelegate>

@end

@implementation ViewController {
    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;
    unsigned int _sequence;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    ((UIScrollView *)self.view).contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height * 2);
    [self tcpInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tcpInit
{
    NSString *url = @"192.168.10.102";
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)url, 6091, &readStream, &writeStream);
    _inputStream = (__bridge NSInputStream *)readStream;
    _outputStream = (__bridge NSOutputStream *)writeStream;
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream open];
    [_outputStream open];
}

- (IBAction)sendMenu:(id)sender {
    NSData *data = [self dataWithEvent];
    NSLog(@"%@", data);
    const uint8_t *buf = (const uint8_t*)[data bytes];
    [_outputStream write:buf maxLength:data.length];
}

- (NSData *)dataWithEvent
{
    NSMutableData *mutableData = [[NSMutableData alloc] init];
    {
        Byte bytes[] = {0x04, 0x00, 0x41, 0x01};
        [mutableData appendBytes:bytes length:sizeof(bytes)];
    }
    _sequence += 1;
    uint32_t littleEndian = CFSwapInt32(_sequence);
    [mutableData appendBytes:&littleEndian length:sizeof(&_sequence)];
    {
        Byte bytes[] = {0x00, 0x3a, 0x01, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00};
        [mutableData appendBytes:bytes length:sizeof(bytes)];
    }
    Byte isRep = 0;
    [mutableData appendBytes:&isRep length:sizeof(isRep)];
    {
        Byte bytes[] = {0x03, 0x00, 0x00, 0x00};
        [mutableData appendBytes:bytes length:sizeof(bytes)];
    }
    {
        Byte keyCode[] = {0x52, 0x04, 0x00, 0x00, 0x00, 0x8b};
        [mutableData appendBytes:keyCode length:sizeof(keyCode)];
    }
    {
        Byte bytes[] = {0x05, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x08, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0a, 0x00, 0x00, 0x00, 0x02, 0x0b, 0x00, 0x00, 0x03, 0x01};
        [mutableData appendBytes:bytes length:sizeof(bytes)];
    }
    return [mutableData copy];
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    NSLog(@"Stream triggered %@", @(eventCode));
    
    switch(eventCode) {
        case NSStreamEventHasSpaceAvailable: {
            if(stream == _outputStream) {
                NSLog(@"outputStream is ready.");
            }
            break;
        }
        case NSStreamEventHasBytesAvailable: {
            if(stream == _inputStream) {
                NSLog(@"inputStream is ready.");
                
                uint8_t buf[1024];
                NSInteger len = 0;
                
                NSMutableData* data=[[NSMutableData alloc] initWithLength:0];
                if ((len = [_inputStream read:buf maxLength:1024]) > 0) {
                    [data appendBytes: (const void *)buf length:len];
                }
                NSLog(@"Result: %@", data);
            }
            break;
        }
        default: {
            break;
        }
    }
}

@end
