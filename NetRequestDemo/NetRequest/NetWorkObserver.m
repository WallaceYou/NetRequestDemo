//
//  NetWorkObserver.m
//  OCPRO
//
//  Created by shiqianren on 2017/5/3.
//  Copyright © 2017年 shiqianren. All rights reserved.
//

#import "NetWorkObserver.h"
//#import "AppSetting.h"
@implementation NetWorkObserver

+ (NetWorkObserver *)netWorkObserverShare
{
    static NetWorkObserver *shareObserver;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObserver = [[NetWorkObserver alloc] init];
    });
    
    return shareObserver;
}

+ (BOOL)networkAvailable
{
    NetWorkObserver *observer = [[NetWorkObserver alloc] init];
    NETWORK_TYPE network_type = [observer dataNetworkTypeFromStatusBar];
    if (network_type == NETWORK_TYPE_NONE) {
        return NO;
    }
    return YES;
}

- (int)dataNetworkTypeFromStatusBar {
    NSArray *children;
    UIApplication *app = [UIApplication sharedApplication];
    NSString *state = [[NSString alloc] init];
    //iPhone X
    if ([[app valueForKeyPath:@"_statusBar"] isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) {
        children = [[[[app valueForKeyPath:@"_statusBar"] valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
        for (UIView *view in children) {
            for (id child in view.subviews) {
                //wifi
                if ([child isKindOfClass:NSClassFromString(@"_UIStatusBarWifiSignalView")]) {
                    state = @"wifi";
                }
                //2G 3G 4G
                if ([child isKindOfClass:NSClassFromString(@"_UIStatusBarStringView")]) {
                    if ([[child valueForKey:@"_originalText"] containsString:@"G"]) {
                        state = [child valueForKey:@"_originalText"];
                    }
                }
            }
        }
    }else {
        children = [[[app valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
        for (id child in children) {
            if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
                //获取到状态栏
                switch ([[child valueForKeyPath:@"dataNetworkType"] intValue]) {
                    case 0:
                        state = @"无网络";
                        //无网模式
                        break;
                    case 1:
                        state = @"2G";
                        break;
                    case 2:
                        state = @"3G";
                        break;
                    case 3:
                        state = @"4G";
                        break;
                    case 5:
                        state = @"wifi";
                        break;
                    default:
                        break;
                }
            }
        }
    }
    
    int netType = NETWORK_TYPE_NONE;
    if (state == nil)
    {
        netType = NETWORK_TYPE_NONE;
    }
    else
    {
        if ([state isEqualToString:@"无网络"]) {
            netType = NETWORK_TYPE_NONE;
        }else if ([state isEqualToString:@"2G"]){
            netType = NETWORK_TYPE_2G;
        }else if ([state isEqualToString:@"3G"]){
            netType = NETWORK_TYPE_3G;
        }else if ([state isEqualToString:@"4G"]){
            netType = NETWORK_TYPE_4G;
        }else{
            netType = NETWORK_TYPE_WIFI;
        }
    }
    if (netStatus != netType)
    {
        netStatus = netType;
        [[NSNotificationCenter defaultCenter] postNotificationName:NET_CHANGED_NOTIFICATION object:@(netType)];
    }
    return netType;
}

- (NSString *)getNetWorkType
{
    
    int netType = [self dataNetworkTypeFromStatusBar];
    
    if (netType == 0) {
        
        return @"unknown";
        
    }else if (netType == 1){
        
        return @"2g";
        
    }else if (netType == 2){
        
        return @"3g";
        
    }else if (netType == 3){
        
        return @"4g";
    }
    else{
        
        return @"wifi";
    }
}

- (void)startListening
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                      target:self selector:@selector(dataNetworkTypeFromStatusBar)
                                                    userInfo:nil repeats:YES];
    self.repeatingTimer = timer;
    [self.repeatingTimer fire];
}

- (void)stopListening
{
    [self.repeatingTimer invalidate];
}
@end
