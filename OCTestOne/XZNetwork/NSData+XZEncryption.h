//
//  NSData+XZEncryption.h
//  OCTestOne
//
//  Created by kkxz on 2018/9/11.
//  Copyright © 2018年 kkxz. All rights reserved.
//加密解密处理类

#import <Foundation/Foundation.h>

@interface NSData (XZEncryption)
- (NSData *)AES256ParmEncryptWithKey:(NSString *)key;
- (NSData *)AES256ParmDecryptWithKey:(NSString *)key;
@end
