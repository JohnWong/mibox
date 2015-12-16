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


@implementation JWBonjourManager

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
    }
    return self;
}

- (void)startWithComplation:(void (^completion)())
{
    [_services removeAllObjects];
    [_netBrowser searchForServicesOfType:@"_rc._tcp" inDomain:@"local"];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDict
{
    NSLog(@"%@:%s %@", self.class, __FUNCTION__, errorDict);
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    _services[service.name] = service;
    service.delegate = self;
    [service startMonitoring];
    [service resolveWithTimeout:5];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    if ([_services.allKeys containsObject:service.name]) {
        [_services removeObjectForKey:service.name];
    }
}

- (void)netServiceDidResolveAddress:(NSNetService *)service
{
    if ([_services.allKeys containsObject:service.name]) {
        NSLog(@"%@:%s %@ %@ %ld", self.class, __FUNCTION__, service.name, service.hostName, (long)service.port);
    }
}


- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    NSLog(@"%@:%s", self.class, __FUNCTION__);
}

- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data
{
    if ([_services.allKeys containsObject:sender.name]) {
        NSLog(@"%@:%s %@", self.class, __FUNCTION__, [NSNetService dictionaryFromTXTRecordData:data]);
    }
}

@end
