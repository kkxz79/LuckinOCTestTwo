//
//  XZBaseRequest.h
//  OCTestOne
//
//  Created by kkxz on 2018/9/11.
//  Copyright © 2018年 kkxz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XZNetworkConfig.h"
#import "XZNetworkAgent.h"
#import <AFNetworking/AFNetworking.h>

@interface XZBaseRequest : NSObject
//__nullable表示对象可以是NULL或nil、__nonnull表示对象不应该为空
typedef void (^XZRequestSucessBlock) (XZBaseRequest * _Nonnull request);
typedef void (^XZRequestFailureBlock) (XZBaseRequest * _Nonnull request, NSError *_Nullable error);
typedef void (^XZRequestCompletionBlock)(XZBaseRequest * _Nonnull request, NSError *_Nullable error);

typedef void (^HttpSuccessBlock)(NSURLSessionTask * _Nullable task , id _Nullable responseObject);
typedef void (^HttpFailureBlock)(NSURLSessionTask * _Nullable operation,NSError * _Nullable error);
typedef void (^AFConstructingBlock) (id<AFMultipartFormData> _Nonnull formData);

//域名、url
@property(nonatomic,strong)NSString * _Nonnull baseUrl;
@property(nonatomic,strong)NSString * _Nonnull subUrl;
@property(nonatomic,strong)NSString * _Nonnull domain;

//加密参数
@property(nonatomic,strong)NSDictionary * _Nullable requestArgument;
//非加密参数
@property(nonatomic,strong)NSDictionary * _Nullable requsetUnencryptedArgument;

//session网络请求相关参数
@property(nonatomic,strong,readwrite)NSURLSessionTask * _Nullable requestTask;
@property (nonatomic, strong, readonly)NSError * _Nullable error;
@property (nonatomic, readonly)NSInteger responseStatusCode;

@property (nonatomic, copy, nullable) AFConstructingBlock constructingBodyBlock;

//是否需要添加header
@property (nonatomic, assign) BOOL needAddHeader;

//加密类型
@property(nonatomic,assign) XZEncryptionType encryptionType;
//请求类型
@property(nonatomic,assign) XZRequestMethod requestMethod;

//请求完成回调block
@property (nonatomic, copy) XZRequestCompletionBlock _Nullable completionBlock;
//返回值
@property(nonatomic,strong) id _Nullable responseObject;
//返回json
@property (nonatomic, strong) NSDictionary * _Nullable responseJsonObject;
//是否自动处理错误值，默认YES
@property(nonatomic,assign) BOOL autoHandleError;

//  Return cancelled state of request task.
@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;
//  Executing state of request task.
@property (nonatomic, readonly, getter=isExecuting) BOOL executing;

//超时时间 默认15s
@property (nonatomic, assign ) NSTimeInterval requestTimeoutInterval;

//允许移动网络
- (BOOL)allowsCellularAccess;

//请求方法
-(void)start;
-(void)stop;
-(void)startWithCompletionBlockSuccess:(XZRequestSucessBlock _Nullable)success
                               failure:(XZRequestFailureBlock _Nullable)failure;
- (void)clearCompletionBlock;

//视频下载
-(void)downLoadMovie:(NSURL *_Nonnull)URL
          targetPath:(NSURL *_Nonnull)targetPathURL
   completionHandler:(XZDownLoadCompletionBlock _Nullable )downLoadCompletionBlock;

@end







