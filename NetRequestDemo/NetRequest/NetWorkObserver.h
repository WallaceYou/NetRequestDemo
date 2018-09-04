//
//  NetWorkObserver.h
//  OCPRO
//
//  Created by shiqianren on 2017/5/3.
//  Copyright © 2017年 shiqianren. All rights reserved.
//

#import <Foundation/Foundation.h>
//net changed 网络变化通知
#define NET_CHANGED_NOTIFICATION   @"NetChangedNotification"

typedef enum {
    
    NETWORK_TYPE_NONE= 0,
    
    NETWORK_TYPE_2G= 1,
    
    NETWORK_TYPE_3G= 2,
    
    NETWORK_TYPE_4G= 3,
    
    NETWORK_TYPE_WIFI= 5,
    
}NETWORK_TYPE;

static NSString * NetChangedNotification = @"NetChangedNotification";

static int netStatus = 0;


@interface NetWorkObserver : NSObject
@property (nonatomic, strong) NSTimer *repeatingTimer;

+ (NetWorkObserver *)netWorkObserverShare;

+ (BOOL)networkAvailable;

- (int)dataNetworkTypeFromStatusBar;

- (NSString *)getNetWorkType;

- (void)startListening;
- (void)stopListening;

@end
