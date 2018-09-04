//
//  WebService_Risk.h
//  NetRequestDemo
//
//  Created by yuyou on 2018/9/4.
//  Copyright © 2018年 hengtiansoft. All rights reserved.
//

#import "WebService_Base.h"

@interface WebService_Risk : WebService_Base

/** 获取风险列表 */
+ (id)getRiskListWithPageNum:(NSInteger)pageNum PageSize:(NSInteger)pageSize riskTypes:(NSArray *)riskTypes searchWord:(NSString *)searchWord completionBlock:(void(^)(BaseResponse *response))completionBlock;


//登录
+ (id)loginUserWithName:(NSString *)userName password:(NSString *)password completionBlock:(void (^)(BaseResponse *))completionBlock;


/** 邀请朋友 */
+ (id)inviteFriendWithUrl:(NSString *)inviteUrl friendEmail:(NSString *)friendEmail completionBlock:(void(^)(BaseResponse *response))completionBlock;


@end
