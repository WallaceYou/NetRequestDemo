//
//  BaseResponse.m
//  SupremeGolfPro
//
//  Created by yuyou on 2018/5/28.
//  Copyright © 2018年 software. All rights reserved.
//

#import "BaseResponse.h"

@implementation BaseResponse

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    
    self = [super init];
    
    if (self && dict && [dict isKindOfClass:[NSDictionary class]]) {
        self.success = [[self objectOrNilForKey:@"success" fromDictionary:dict] boolValue];
        self.stateCode = [self objectOrNilForKey:@"stateCode" fromDictionary:dict];
        self.message = [self objectOrNilForKey:@"message" fromDictionary:dict];
        self.responseObject = [self objectOrNilForKey:@"responseObject" fromDictionary:dict];
        self.params = [self objectOrNilForKey:@"params" fromDictionary:dict];
        self.baseUrl = [self objectOrNilForKey:@"baseUrl" fromDictionary:dict];
    }
    return self;
}

+ (BaseResponse *)modelObjectWithDictionary:(NSDictionary *)dict {
    
    return [[self alloc] initWithDictionary:dict];
}

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict {
    
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}

@end
