//
//  BaseResponse.h
//  SupremeGolfPro
//
//  Created by yuyou on 2018/5/28.
//  Copyright © 2018年 software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseResponse : NSObject

@property (nonatomic, assign) BOOL success;

@property (nonatomic, copy) NSString *stateCode;

@property (nonatomic, copy) NSString *message;

@property (nonatomic, strong) id responseObject;

@property (nonatomic, copy) NSString *baseUrl;

@property (nonatomic, strong) NSDictionary *params;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
