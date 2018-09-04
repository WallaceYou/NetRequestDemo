//
//  WebService_Base.h
//  SupremeGolfPro
//
//  Created by youyu on 2018/4/19.
//  Copyright © 2018年 software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseResponse.h"

typedef NS_ENUM(NSUInteger, AFReqType) {
    AFREQ_GET = 1,
    AFREQ_POST = 2,
    AFREQ_PUT = 3,
};


@interface WebService_Base : NSObject


/** 不用AF帮助解析，返回最原始的二进制文件 */
+ (void)resetAcceptableContentTypes;




/**
 *  对AFHTTPSessionManager的GET,POST,PUT请求方法进行了封装
 *
 *  @param requestType      请求类型，是POST，GET，还是PUT
 *  @param requestPath      请求URL
 *  @param params           请求参数
 *  @param completionBlock  请求回调
 *
 *  @return 返回网络请求任务
 */
+ (id)sendRequestUseAFN:(AFReqType)requestType requestPath:(NSString *)requestPath params:(NSDictionary *)params completionBlock:(void(^)(BaseResponse *response))completionBlock;





/**
 *  对AFHTTPSessionManager的POST（MultipartDataForm）请求方法进行了封装
 *
 *  @param path             请求URL
 *  @param params           请求参数
 *  @param dataSource       要上传的文件（有可能是文件本身，也有可能是文件的路径）
 *  @param fileName         要上传的文件的参数名称
 *  @param completionHandle block回调
 *
 *  @return 返回网络请求任务
 */
+ (id)uploadData:(NSString *)path parameters:(NSDictionary *)params fileName:(NSString *)fileName dataSource:(id)dataSource completionHandle:(void(^)(id responseObj, NSError *error))completionHandle;




/** 设置请求头 */
+ (void)setHeaderFieldWithKey:(NSString *)key value:(NSString *)value;


/**
 *  拼接参数，注：一般来说，用AF请求，不需要拼接参数的，直接将参数字典传入到params参数中就可以了，但是有些服务器写的不规范，POST请求的参数是跟在url后面的，对于这种情况，如果你用AF的POST方法，然后传入参数后，AF会将参数拼接到Body里（这本身是对的），导致你请求出错，这是个坑！！所以对于这种不规范的POST请求，需要自己手动拼接参数
 *
 *  @param baseUrl        baseUrl
 *  @param params        拼接参数
 *
 */
+ (NSString *)pieceParamsWithBaseUrl:(NSString *)baseUrl params:(NSDictionary *)params;




@end
