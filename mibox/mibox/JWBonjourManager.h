//
//  JWBonjourManager.h
//  RevealIt
//
//  Created by John Wong on 8/13/15.
//  Copyright © 2015 John Wong. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol JWBonjourObserver <NSObject>

- (void)didUpdateServices:(NSDictionary *)services;

@end


@interface JWBonjourManager : NSObject

@property (nonatomic, weak) id<JWBonjourObserver> observer;

+ (instancetype)sharedInstance;

- (void)start;
- (void)stop;

@end
