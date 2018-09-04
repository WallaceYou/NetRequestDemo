//
//  YYLanguageTool.m
//  Mu
//
//  Created by yuyou on 16/12/22.
//  Copyright © 2016年 yuyou. All rights reserved.
//

#define CNS @"zh-Hans"
#define EN @"en"
#define LANGUAGE_SET @"langeuageset"

#import "YYLanguageTool.h"
#import "AppDelegate.h"

static YYLanguageTool *languageTool;

@interface YYLanguageTool ()

@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, copy) NSString *language;

@end

@implementation YYLanguageTool

#pragma mark - Init
- (instancetype)init {
    
    if (self = [super init]) {
        [self initLanguage];
    }
    return self;
}

- (void)initLanguage {
    NSString *tmp = [[NSUserDefaults standardUserDefaults] objectForKey:LANGUAGE_SET];
    
    if (!tmp) {//如果第一次设置，则将系统语言作为默认
        NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
        NSString *languageName = [appLanguages objectAtIndex:0];
        tmp = [languageName containsString:CNS]?CNS:EN;//这里如果你的App支持5种语言，则这里再加else if判断，即：如果都不是这5种语言，再设为英文
    }
    
    self.language = tmp;
    
    //对系统语言进行校验，如果不是此App支持的语言，则设为英语
    self.language = [self verifyLanguage:self.language];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:self.language ofType:@"lproj"];
    self.bundle = [NSBundle bundleWithPath:path];
}



#pragma mark - Public Func
+ (id)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        languageTool = [[YYLanguageTool alloc] init];
    });
    return languageTool;
}


- (NSString *)getLanguage {
    return self.language;
}

- (NSBundle *)getBundle {
    return self.bundle;
}



- (NSString *)getStringForKey:(NSString *)key withTable:(NSString *)table {
    
    if (self.bundle) {
        return NSLocalizedStringFromTableInBundle(key, table, self.bundle, @"");
    }
    
    return NSLocalizedStringFromTable(key, table, @"");
}

- (void)setNewLanguage:(NSString *)language {
    
    //这里还需对language进行合法校验，传过来的language不一定是此App所支持的一种语言，甚至不一定是一种语言
    language = [self verifyLanguage:language];
    
    if ([language isEqualToString:self.language]) {
        return;
    }
    
    //这里可以加个加载的菊花框
//    [MBProgressHUD showProgressOnWindowText:kLocalizedString(@"language_setting")];
    //模拟，假装用了很久
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [MBProgressHUD hideHUD];
        NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj"];
        self.bundle = [NSBundle bundleWithPath:path];//重置self.bundle
        self.language = language;//重置当前语言
        [[NSUserDefaults standardUserDefaults] setObject:language forKey:LANGUAGE_SET];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self resetRootViewController];
    });
}

- (void)changeNowLanguage {
    
    if ([self.language isEqualToString:EN]) {
        [self setNewLanguage:CNS];
    } else {
        [self setNewLanguage:EN];
    }
}

#pragma mark - Private Func
//重新设置
- (void)resetRootViewController {
    
    //如果是storyboard则这样写
    //    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    //    [UIApplication sharedApplication].keyWindow.rootViewController = storyBorad.instantiateInitialViewController;
    
    //如果是纯代码，则这样写(需在AppDelegate类中写一个获得rootViewController的方法)
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [UIApplication sharedApplication].keyWindow.rootViewController = [appDelegate getRootViewController];
    
}



/* 对一种语言进行合法性校验，如果language是你app内所不支持的语言，则默认返回英语 */
- (NSString *)verifyLanguage:(NSString *)language {
    
    NSString *resultLanguage = language;
    if (![language isEqualToString:CNS]) {
        resultLanguage = EN;//如果不是中文，则一律设为英文（因为此app只支持中英，如果你支持5种语言，则这里再加else if判断，即：如果都不是这5种语言，再设为英文）
    }
    return resultLanguage;
}





@end
