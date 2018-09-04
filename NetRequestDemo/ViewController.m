//
//  ViewController.m
//  NetRequestDemo
//
//  Created by yuyou on 2018/9/3.
//  Copyright © 2018年 hengtiansoft. All rights reserved.
//

#import "ViewController.h"
#import "WebService_Risk.h"



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [WebService_Risk getRiskListWithPageNum:1 PageSize:20 riskTypes:@[] searchWord:@"" completionBlock:^(BaseResponse *response) {
        NSLog(@"");
    }];
    
    
//    [WebService_Risk loginUserWithName:@"asdfasdf" password:@"asdfasdf" completionBlock:^(BaseResponse *response) {
//        NSLog(@"");
//    }];
//    
//    [WebService_Risk inviteFriendWithUrl:@"" friendEmail:@"yuyou@hengtiansoft.com" completionBlock:^(BaseResponse *response) {
//        NSLog(@"");
//    }];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
