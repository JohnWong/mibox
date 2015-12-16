//
//  JWBonjourManager.m
//  RevealIt
//
//  Created by John Wong on 8/13/15.
//  Copyright © 2015 John Wong. All rights reserved.
//

#import "JWBonjourManager.h"


@interface JWBonjourManager () <NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@end


@implementation JWBonjourManager {
    NSNetServiceBrowser *_netBrowser;
    NSMutableDictionary *_services;
    BOOL _isRunning;
    dispatch_queue_t _queue;
}

+ (instancetype)sharedInstance
{
    static JWBonjourManager *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[JWBonjourManager alloc] init];
    });
    return helper;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _services = [NSMutableDictionary dictionary];
        _netBrowser = [[NSNetServiceBrowser alloc] init];
        _netBrowser.delegate = self;
        _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return self;
}

- (void)start
{
    if (!_isRunning) {
        _isRunning = YES;
        dispatch_async(_queue, ^{
            [_netBrowser scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
            [_netBrowser searchForServicesOfType:@"_rc._tcp" inDomain:@"local"];
            [[NSRunLoop currentRunLoop] run];
        });
    }
}

- (void)stop
{
    dispatch_async(_queue, ^{
        [_services removeAllObjects];
        [_netBrowser stop];
    });
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDict
{
    NSLog(@"%@:%s %@", self.class, __FUNCTION__, errorDict);
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
    _isRunning = NO;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    _services[service.name] = service;
    service.delegate = self;
    [service resolveWithTimeout:12];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    if ([_services.allKeys containsObject:service.name]) {
        [_services removeObjectForKey:service.name];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_observer didUpdateServices:[_services copy]];
        });
    }
}

- (void)netServiceDidResolveAddress:(NSNetService *)service
{
    if ([_services.allKeys containsObject:service.name]) {
        NSLog(@"%@:%s %@ %@ %ld", self.class, __FUNCTION__, service.name, service.hostName, (long)service.port);
        dispatch_async(dispatch_get_main_queue(), ^{
            [_observer didUpdateServices:[_services copy]];
        });
    }
}


- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    NSLog(@"%@:%s %@", self.class, __FUNCTION__, errorDict);
}

@end
