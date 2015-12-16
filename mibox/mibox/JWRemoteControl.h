//
//  JWRemoteControl.h
//  mibox
//
//  Created by John Wong on 12/16/15.
//  Copyright © 2015 John Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    JWKeyCodeMenu = 1,
    JWKeyCodeReturn,
    JWKeyCodeHome,
    JWKeyCodeOff,
    JWKeyCodeConfirm,
    JWKeyCodeVolumnUp,
    JWKeyCodeVolumnDown,
    JWKeyCodeUp,
    JWKeyCodeDown,
    JWKeyCodeLeft,
    JWKeyCodeRight
} JWKeyCode;


@interface JWRemoteControl : NSObject

- (instancetype)initWithHost:(NSString *)host port:(UInt32)port;
- (void)start;
- (void)stop;
- (void)sendKeyCode:(JWKeyCode)keyCode;

@end
