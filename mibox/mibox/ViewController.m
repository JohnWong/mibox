//
//  ViewController.m
//  mibox
//
//  Created by John Wong on 12/14/15.
//  Copyright © 2015 John Wong. All rights reserved.
//

#import "ViewController.h"
#import "JWBonjourManager.h"
#import "JWRemoteControl.h"


@interface ViewController () <JWBonjourObserver>
@property (weak, nonatomic) IBOutlet UIButton *tvButton;

@end


@implementation ViewController {
    JWRemoteControl *_remoteControl;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    JWBonjourManager *bonjourManager = [JWBonjourManager sharedInstance];
    bonjourManager.observer = self;
    [bonjourManager start];
}

- (void)setNetService:(NSNetService *)service
{
    if (_remoteControl) {
        [_remoteControl stop];
    }
    _remoteControl = [[JWRemoteControl alloc] initWithHost:service.hostName port:service.port];
    [_remoteControl start];
}

- (void)dealloc
{
    [[JWBonjourManager sharedInstance] stop];
    [_remoteControl stop];
}

- (void)didUpdateServices:(NSDictionary *)services
{
    NSLog(@"%@", services);
    if ([self.tvButton.titleLabel.text isEqualToString:@"Loading"]) {
        for (NSString *key in services) {
            [_tvButton setTitle:key forState:UIControlStateNormal];
            [self setNetService:services[key]];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendMenu:(id)sender
{
    [_remoteControl sendKeyCode:JWKeyCodeMenu];
}

- (IBAction)sendReturn:(id)sender
{
    [_remoteControl sendKeyCode:JWKeyCodeReturn];
}

- (IBAction)sendHome:(id)sender
{
    [_remoteControl sendKeyCode:JWKeyCodeHome];
}

- (IBAction)sendOff:(id)sender
{
    [_remoteControl sendKeyCode:JWKeyCodeOff];
}

- (IBAction)sendVolumnUp:(id)sender
{
    [_remoteControl sendKeyCode:JWKeyCodeVolumnUp];
}

- (IBAction)sendVolumnDown:(id)sender
{
    [_remoteControl sendKeyCode:JWKeyCodeVolumnDown];
}

- (IBAction)sendUp:(id)sender
{
    [_remoteControl sendKeyCode:JWKeyCodeUp];
}

- (IBAction)sendDown:(id)sender
{
    [_remoteControl sendKeyCode:JWKeyCodeDown];
}

- (IBAction)sendLeft:(id)sender
{
    [_remoteControl sendKeyCode:JWKeyCodeLeft];
}

- (IBAction)sendRight:(id)sender
{
    [_remoteControl sendKeyCode:JWKeyCodeRight];
}

- (IBAction)sendConfirm:(id)sender
{
    [_remoteControl sendKeyCode:JWKeyCodeConfirm];
}


@end
