//
//  ServerApiResponseCode.h
//  MyCoinRisk
//
//  Created by yuyou on 2018/7/25.
//  Copyright © 2018年 hengtiansoft. All rights reserved.
//

#ifndef ServerApiResponseCode_h
#define ServerApiResponseCode_h

//业务逻辑状态码

//恒天规范
//#define ASK_SERVER_SUCCESS      @"ACK"                      //接口回调成功
//#define ASK_SERVER_FAILED       @"NACK"                     //接口回调失败
//#define ASK_SERVER_RELOGIN      @"2"                        //重新登录 TOKEN_ID_ERROR
//#define ASK_SERVER_LOWVERSION   @"4"                        //版本太低
//#define ASK_SERVER_BINDPHONE    @"BIND_PHONE"               //绑定手机号
//#define ASK_NET_FAILED          @"NET_CONNECT_FAILED"       //网络未连接
//#define ASK_SERVER_FIRST_LOGIN  @"FIRST_LOGIN"              //第一次登陆
//#define ASK_SERVER_ERROR        @"<null>"                   //后台报null


//其他服务器
#define ASK_SERVER_SUCCESS              @"200"                      //接口回调成功






//HTTP错误
#define HTTP_ERROR_UNAUTHORIZED         @"401"                      //未经允许的（没有token）


#endif /* ServerApiResponseCode_h */
