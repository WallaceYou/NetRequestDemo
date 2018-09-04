//
//  WebService_Risk.m
//  NetRequestDemo
//
//  Created by yuyou on 2018/9/4.
//  Copyright © 2018年 hengtiansoft. All rights reserved.
//

#import "WebService_Risk.h"

#define kGetRiskListDomain @"risk/risklist"

#define kLoginUserDomain                    @"user/login"
#define kInviteFriendDomain @"user/invite_friend"

@implementation WebService_Risk

+ (id)getRiskListWithPageNum:(NSInteger)pageNum PageSize:(NSInteger)pageSize riskTypes:(NSArray *)riskTypes searchWord:(NSString *)searchWord completionBlock:(void (^)(BaseResponse *))completionBlock {
    
    NSDictionary *params = @{@"pageNum":@(pageNum),@"pageSize":@(pageSize),@"riskTypes":riskTypes,@"searchWord":searchWord?searchWord:@""};
    
    //由于服务器POST请求写的不规范，没有将参数添加到body里面，所以需要用这个方法手动拼接参数，然后传入AF的params为nil
    NSString *requestUrl = [self pieceParamsWithBaseUrl:kGetRiskListDomain params:params];
    
    return [self sendRequestUseAFN:AFREQ_POST requestPath:requestUrl params:nil completionBlock:^(BaseResponse *response) {
        //在这里将字典转为模型（或字典数组转为模型数组）
        if (response.success) {
//            response.responseObject = [RiskModel mj_objectWithKeyValues:response.responseObject];
        }
        completionBlock(response);
    }];
    
}




//登录
+ (id)loginUserWithName:(NSString *)userName password:(NSString *)password completionBlock:(void (^)(BaseResponse *))completionBlock {
    NSDictionary *params = @{@"password" : password,@"username" : userName};
    
    NSString *requestUrl = [self pieceParamsWithBaseUrl:kLoginUserDomain params:params];
    
    return [self sendRequestUseAFN:AFREQ_POST requestPath:requestUrl params:nil completionBlock:^(BaseResponse *response) {
        if (response.success) {
            //            response.responseObject = [UserModel mj_objectWithKeyValues:response.responseObject];
        }
        completionBlock(response);
    }];
}


+ (id)inviteFriendWithUrl:(NSString *)inviteUrl friendEmail:(NSString *)friendEmail completionBlock:(void (^)(BaseResponse *))completionBlock {
    
    NSDictionary *params = @{@"content":inviteUrl, @"email":friendEmail};
    
    //由于服务器POST请求写的不规范，没有将参数添加到body里面，所以需要用这个方法手动拼接参数，然后传入AF的params为nil
    NSString *requestUrl = [self pieceParamsWithBaseUrl:kInviteFriendDomain params:params];
    
    return [self sendRequestUseAFN:AFREQ_POST requestPath:requestUrl params:nil completionBlock:^(BaseResponse *response) {
        //在这里将字典转为模型（或字典数组转为模型数组）
        if (response.success) {
            //            response.responseObject = [RiskModel mj_objectWithKeyValues:response.responseObject];
        }
        completionBlock(response);
    }];
}


@end
