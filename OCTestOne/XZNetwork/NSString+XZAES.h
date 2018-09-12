//
//  NSString+XZAES.h
//  OCTestOne
//
//  Created by kkxz on 2018/9/11.
//  Copyright © 2018年 kkxz. All rights reserved.
//加密解密封装

#import <Foundation/Foundation.h>

@interface NSString (XZAES)
+(NSString *)AESForEncry:(NSString*)message WithKey:(NSString*)key;//加密
+(NSString*)AESForDecry:(NSString*)message WithKey:(NSString*)key;//解密
@end
