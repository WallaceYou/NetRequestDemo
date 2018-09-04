//
//  WebService_Base.m
//  SupremeGolfPro
//
//  Created by youyu on 2018/4/19.
//  Copyright © 2018年 software. All rights reserved.
//

#import "WebService_Base.h"
#import "NetWorkObserver.h"
#import "Reachability.h"
#import "YYLanguageTool.h"
#import "ServerApiResponseCode.h"


static NSString *const internetErrorMessage = @"当前无网络连接";


#define ReturnNotNilObj(obj) ({\
id object = nil;\
if (obj) {\
object = obj;\
} else {\
object = @"";\
}\
object;\
})


//所有请求的域
#define AppNetAPIBaseDomain             AppNetAPIBaseFormalDomain

//测试环境域
#define AppNetAPIBaseTestDomain         @"http://coin.flyflyfish.com:9090/backend-web-service/api"

//线上环境域
#define AppNetAPIBaseFormalDomain       @"https://www.thecointrac.com/api"

static AFHTTPSessionManager *manager = nil;


@implementation WebService_Base

+ (AFHTTPSessionManager *)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:AppNetAPIBaseDomain]];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/json", @"text/json", @"image/png", @"text/javascript", @"text/plain", nil];
        
        //设置请求与相应的解析类型为JSON
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        //设置安全政策
        AFSecurityPolicy *security = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        [security setValidatesDomainName:NO];
        security.allowInvalidCertificates = YES;
        manager.securityPolicy = security;
        
        //设置头
        [manager.requestSerializer setValue:@"application/json"forHTTPHeaderField:@"Accept"];
        [manager.requestSerializer setValue:@"application/json;multipart/form-data; boundary=----WebKitFormBoundaryHzyefUottpz7ltKf"forHTTPHeaderField:@"Content-Type"];
        [manager.requestSerializer setValue:@"XMLHttpRequest"forHTTPHeaderField:@"X-Requested-With"];
        
        //拼接User-Agent
//        NSString *userAgent = [NSString stringWithFormat:@"%@,%@,%@",[FactoryUtils getSystemName],[FactoryUtils getSystemVersion],[FactoryUtils getIphoneType]];
//        [manager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
        
        
    });
    return manager;
}

+ (void)resetAcceptableContentTypes {
    [self shareInstance].responseSerializer = [AFHTTPResponseSerializer serializer];
}


+ (id)sendRequestUseAFN:(AFReqType)requestType requestPath:(NSString *)requestPath params:(NSDictionary *)params completionBlock:(void(^)(BaseResponse *))completionBlock {
    
    // 判断联网情况
    //如果没有联网，直接failBlock，并return
    // 借助Reachability 否则恢复网络之后，不能检测到
    BOOL isReachable = [AFNetworkReachabilityManager sharedManager].reachable;
    if (!isReachable) {
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [reachability currentReachabilityStatus];
        if (networkStatus != NotReachable) {
            isReachable = YES;
        } else {
            isReachable = NO;
        }
    }
    
    if (!isReachable) {//无网络连接
        NSDictionary *responseDic = @{@"success":@(NO),@"stateCode":@"NoNet",@"message":internetErrorMessage,@"responseObject":@"",@"params":ReturnNotNilObj(params),@"baseUrl":ReturnNotNilObj(requestPath)};
        BaseResponse *response = [BaseResponse modelObjectWithDictionary:responseDic];
        if (completionBlock) {
            completionBlock(response);
        }
        return nil;
    }
    
    //在每个请求的header中添加token
//    NSString *token = [UserManager getUserToken];
//    NSLog(@"token====%@",token);
//    [self setHeaderFieldWithKey:@"access-token" value:token];
    
    
    switch (requestType) {
            
        case AFREQ_GET:
            return [[self shareInstance]
                    GET:requestPath
                    parameters:params
                    progress:nil
                    success:[self successBlock:params completionBlock:completionBlock]
                    failure:[self failureBlock:params completionBlock:completionBlock]];
            break;
            
        case AFREQ_POST:
            return [[self shareInstance]
                    POST:requestPath
                    parameters:params
                    progress:nil
                    success:[self successBlock:params completionBlock:completionBlock]
                    failure:[self failureBlock:params completionBlock:completionBlock]];
            break;
            
        case AFREQ_PUT:
            return [[self shareInstance]
                    PUT:requestPath
                    parameters:params
                    success:[self successBlock:params completionBlock:completionBlock]
                    failure:[self failureBlock:params completionBlock:completionBlock]];
            break;
        default:
            break;
    }
    
}

/* 成功回调 */
+ (void(^)(NSURLSessionDataTask * _Nonnull, id  _Nullable))successBlock:(NSDictionary *)params completionBlock:(void(^)(BaseResponse *))completionBlock {
    
    return ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //这里对成功的返回结果进行BaseResponse的封装
        NSString *stateCode = [[responseObject valueForKey:@"code"] stringValue];
        
        NSString *message = nil;
        
        BOOL success = YES;//先设置为yes
        
        if (![stateCode isEqualToString:ASK_SERVER_SUCCESS]) {//接口返回错误，即应用层错误，也称业务逻辑错误
            
            //这里，如果显示给App端的提示信息，直接显示服务器的msg的话，则直接等于[responseObject valueForKey:@"msg"]，如果不是用服务器的msg，是要根据服务器返回的code来，显示的话，则App内部要有一张对应表，里面有所有的异常状态码对应的msg
            message = YYGetStringWithKeyFromTable(stateCode, @"ApplicationStateCode");//通过状态码对应表得到message
            success = NO;
            
        } else {
            message = @"接口请求成功";
        }
        
        NSDictionary *responseDic = @{@"success":@(success),@"stateCode":stateCode,@"message":message,@"responseObject":[responseObject valueForKey:@"data"],@"params":ReturnNotNilObj(params),@"baseUrl":task.currentRequest.URL.absoluteString};
        BaseResponse *response = [BaseResponse modelObjectWithDictionary:responseDic];
        
        completionBlock(response);
    };
}

/* 失败回调 */
+ (void(^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failureBlock:(NSDictionary *)params completionBlock:(void(^)(BaseResponse *))completionBlock {
    
    return ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSString *netType = [[NetWorkObserver netWorkObserverShare] getNetWorkType];
        if ([netType isEqualToString:@"unknown"]) {//网络无连接错误
            
            NSDictionary *responseDic = @{@"success":@(NO),@"stateCode":@"NoNet",@"message":internetErrorMessage,@"responseObject":@"",@"params":ReturnNotNilObj(params),@"baseUrl":task.currentRequest.URL.absoluteString};
            BaseResponse *response = [BaseResponse modelObjectWithDictionary:responseDic];
            
            if (completionBlock) {
                completionBlock(response);
            }
            
        } else {//有网络，则是操作系统错误或者HTTP错误
            
            //解析ERROR
            NSHTTPURLResponse *errorResponse = nil;
            NSData *errorData = nil;
            
            NSError *underlyingError = error.userInfo[@"NSUnderlyingError"];
            if (underlyingError) {
                errorResponse = underlyingError.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                errorData = underlyingError.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            } else {
                errorResponse = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            }
            
            if (errorResponse) {//如果有response，说明是HTTP错误
                
                //其实解析出errorMsg出来，没什么用，因为，如果需要弹框，大多数情况下不会根据HTTP错误解析出来的error进行显示，而是在项目内部使用代码判断不同的错误类型应该显示什么信息，但是，有些情况就是服务器连逻辑错误那一层都没有包，直接将业务逻辑错误显示在这里
                NSString *errorMsg = nil;
                if (errorData) {
                    NSDictionary *errorDic = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingMutableLeaves error:nil];
                    //                id errorObj = errorDic.allValues.firstObject;//这段代码在5c，ipod上都会闪退
                    id errorObj = errorDic[@"msg"];
                    errorMsg = [errorObj isKindOfClass:[NSString class]]?errorObj:[errorObj stringValue];
                }
                
                NSString *stateCode = [NSString stringWithFormat:@"%ld",(long)errorResponse.statusCode];
                
                //对于HTTP错误，如果不是仅仅弹一个提示语，而是需要截断的在这里判断
                if ([stateCode isEqualToString:HTTP_ERROR_UNAUTHORIZED]) {//如果是401错误，全局跳转登陆
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"JumpToLoginPage" object:nil];
                    //判断一下，此时是否有token，如果有token，说明之前登录过，现在报401是因为token失效了，如果没有token，说明是没登录，两种情况应该分别处理一下
//                    NSString *token = [UserManager getUserToken];
//                    if (![token isEqualToString:@""] && token != nil) {//如果有token，说明是token失效了，则修改为相应的token失效的状态码为401-1（我自己定义的），并且删除用户信息，然后刷新个人中心的界面显示
//                        stateCode = @"401-1";
//
//                        [UserManager removeUserInfo];
//
//                        //临时写到这里的，其他项目用的时候要删掉
//                        //刷新sidemenu
//                        RESideMenu *sideMenu = (RESideMenu *)[UIApplication sharedApplication].keyWindow.rootViewController;
//                        RightMenuController *rightMenu = (RightMenuController *)sideMenu.rightMenuViewController;
//                        [rightMenu refreshUserData];
//
//                    }
                }
                
                errorMsg = YYGetStringWithKeyFromTable(stateCode, @"HttpStateCode");//通过状态码对应表得到message
                
                NSDictionary *responseDic = @{@"success":@(NO),@"stateCode":stateCode,@"message":ReturnNotNilObj(errorMsg),@"responseObject":@"",@"params":ReturnNotNilObj(params),@"baseUrl":task.currentRequest.URL.absoluteString};
                BaseResponse *response = [BaseResponse modelObjectWithDictionary:responseDic];
                
                if (completionBlock) {
                    completionBlock(response);
                }
                
            } else {//是操作系统错误
                
                //这里先直接获取error的错误，如果有需求，对操作系统错误进行多语言适配，则需要再创建一张操作系统的错误状态码对应表，通过error的code找到对应语言的msg
                NSString *errorMsg = (NSString *)(error.localizedDescription);
                NSString *stateCode = [NSString stringWithFormat:@"%ld",error.code];
                
                NSDictionary *responseDic = @{@"success":@(NO),@"stateCode":stateCode,@"message":ReturnNotNilObj(errorMsg),@"responseObject":@"",@"params":ReturnNotNilObj(params),@"baseUrl":task.currentRequest.URL.absoluteString};
                BaseResponse *response = [BaseResponse modelObjectWithDictionary:responseDic];
                
                if (completionBlock) {
                    completionBlock(response);
                }
                
            }
            
            
        }
    };
}


+ (id)uploadData:(NSString *)path parameters:(NSDictionary *)params fileName:(NSString *)fileName dataSource:(id)dataSource completionHandle:(void (^)(id, NSError *))completionHandle {
    
    
    return [[self shareInstance] POST:path parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //        [formData appendPartWithFileData:data name:@"image" fileName:@"image.png" mimeType:@"image/png"];
        
        if ([dataSource isKindOfClass:[NSData class]]) {
            [formData appendPartWithFileData:dataSource name:fileName fileName:@"image.png" mimeType:@"image/png"];
        } else if ([dataSource isKindOfClass:[NSURL class]]) {
            [formData appendPartWithFileURL:dataSource name:fileName fileName:@"soundFile.mp3" mimeType:@"audio/mpeg" error:nil];
        } else {
            
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"已完成：%lld",uploadProgress.completedUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        completionHandle(responseObject,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionHandle(nil,error);
    }];
}



+ (void)setHeaderFieldWithKey:(NSString *)key value:(NSString *)value {
    [[self shareInstance].requestSerializer setValue:value forHTTPHeaderField:key];
}


+ (NSString *)pieceParamsWithBaseUrl:(NSString *)baseUrl params:(NSDictionary *)params {
    
    NSMutableString *resultUrl = [NSMutableString stringWithString:baseUrl];
    
    NSArray *keys = params.allKeys;
    
    for (NSString *key in keys) {
        id value = params[key];
        
        if ([value isKindOfClass:[NSArray class]]) {//value是数组，则拼接数组元素
            
            for (id valueObj in value) {
                
                NSString *valueObjStr = nil;
                
                if (![valueObj isKindOfClass:[NSString class]]) {
                    valueObjStr = [valueObj stringValue];
                } else {
                    valueObjStr = valueObj;
                }
                
                NSInteger index = [keys indexOfObject:key];
                
                if (index == 0) {
                    
                    NSInteger index2 = [value indexOfObject:valueObj];
                    if (index2 == 0) {
                        [resultUrl appendFormat:@"?%@=%@",key,valueObjStr];
                    } else {
                        [resultUrl appendFormat:@"&%@=%@",key,valueObjStr];
                    }
                    
                } else {
                    
                    [resultUrl appendFormat:@"&%@=%@",key,valueObjStr];
                }
            }
            
            continue;
            
        } else if (![value isKindOfClass:[NSString class]]) {//如果不是字符串则变为字符串
            value = [value stringValue];
        }
        
        NSInteger index = [keys indexOfObject:key];
        
        if (index == 0) {
            [resultUrl appendFormat:@"?%@=%@",key,value];
        } else {
            [resultUrl appendFormat:@"&%@=%@",key,value];
        }
    }
    
    //将有空格的转换为百分号
    NSString *percentUrl = [resultUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return percentUrl;
    
}

@end
