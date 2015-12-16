//
//  JWBonjourManager.h
//  RevealIt
//
//  Created by John Wong on 8/13/15.
//  Copyright © 2015 John Wong. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JWBonjourManager : NSObject {
    NSNetServiceBrowser *_netBrowser;
    NSMutableDictionary *_services;
}

+ (instancetype)sharedInstance;
- (void)start;

@end
