//
//  YYLanguageTool.h
//  Mu
//
//  Created by yuyou on 16/12/22.
//  Copyright © 2016年 yuyou. All rights reserved.
//


#define YYGetStringWithKeyFromTable(key, tbl) [[YYLanguageTool sharedInstance] getStringForKey:key withTable:tbl]

#import <Foundation/Foundation.h>

@interface YYLanguageTool : NSObject

+ (id)sharedInstance;

/**
 *  返回table中指定的key的值
 *
 *  @param key   key
 *  @param table table
 *
 *  @return 返回table中指定的key的值
 */
-(NSString *)getStringForKey:(NSString *)key withTable:(NSString *)table;


/**
 *  设置新的语言
 *
 *  @param language 新语言
 */
-(void)setNewLanguage:(NSString*)language;



/** 两种语言之间快速的互相切换 */
-(void)changeNowLanguage;


- (NSString *)getLanguage;

- (NSBundle *)getBundle;

@end
