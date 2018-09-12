//
//  XZBaseRequest.m
//  OCTestOne
//
//  Created by kkxz on 2018/9/11.
//  Copyright © 2018年 kkxz. All rights reserved.
//

#import "XZBaseRequest.h"
#import "XZNetworkAgent.h"
#import "NSString+XZAES.h"
#import "NSString+Hashes.h"

@implementation XZBaseRequest
-(instancetype)init
{
    self = [super init];
    if(self){
        self.requestMethod = XZRequestMethodPOST;
        self.encryptionType = XZUseEncryptionType;
        self.autoHandleError = YES;
    }
    return self;
}

#pragma mark - request methods
-(void)start
{
    //断言
    assert(self.baseUrl);
    assert(self.subUrl);
    
    self.requsetUnencryptedArgument = self.requestArgument;
    switch (self.encryptionType) {
        case XZUseEncryptionType:
        {
            //加密
            self.requestArgument = [self reviseMAPIParameters:self.requestArgument];
        }
            break;
        default:
            break;
    }
     [[XZNetworkAgent sharedAgent] addRequest:self];
}

-(void)stop
{
    [[XZNetworkAgent sharedAgent] cancelRequest:self];
}

- (void)clearCompletionBlock
{
    if(self.completionBlock){
        self.completionBlock = nil;
    }
}

-(void)startWithCompletionBlockSuccess:(XZRequestSucessBlock _Nullable)success
                               failure:(XZRequestFailureBlock _Nullable)failure
{
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(XZRequestSucessBlock)success
                              failure:(XZRequestFailureBlock)failure
{
    __weak __typeof(self) weakSelf = self;
    self.completionBlock = ^(XZBaseRequest * _Nonnull request, NSError * _Nullable error) {
        [weakSelf responseHandleWithRequest:request Success:success failure:failure error:error];
    };
}

-(void)downLoadMovie:(NSURL *)URL
          targetPath:(NSURL *)targetPathURL
   completionHandler:(XZDownLoadCompletionBlock)downLoadCompletionBlock {
    
    [[XZNetworkAgent sharedAgent] downLoadMovie:URL
                                     targetPath:targetPathURL
                              completionHandler:downLoadCompletionBlock];
}

-(void)responseHandleWithRequest:(XZBaseRequest *)request
                         Success:(XZRequestSucessBlock)successBlock
                         failure:(XZRequestFailureBlock)failureBlock
                           error:(NSError *)error
{
    if(request.responseStatusCode == 0){
        //请求失败处理
    }
    
    switch (self.encryptionType) {
        case XZUseEncryptionType:
        {
            if(error.code){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(failureBlock){
                        failureBlock(request,error);
                    }
                });
                return;
            }
            
            //序列化、解密处理
            NSString * string = [[NSString alloc] initWithData:_responseObject encoding:NSUTF8StringEncoding];
            string = [NSString AESForDecry:string WithKey:k_MAPIKey];
            if(string==nil || string.length < 2){
                NSLog(@"解密失败");
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(failureBlock){
                        failureBlock(request,error);
                    }
                });
                return;
            }
            
            NSData *objectData = [string dataUsingEncoding:NSUTF8StringEncoding];
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];
            if (jsonError) {
                NSLog(@"jsonError：\n%@",jsonError);
                return;
            }
  
//调试状态打印
#if DEBUG
            NSString * requestStr = [NSString stringWithFormat:@"request 请求结束 -->>\n %@%@%@\n 原始参数-->%@", request.baseUrl,request.subUrl,request.requestArgument,request.requsetUnencryptedArgument];
            NSLog(@"\n================================\n%@\n================================\n",requestStr);
            
            NSLog(@"\n================================\n response json：\n %@ \n================================\n",json);
#endif
            self.responseJsonObject = json;
            
            //返回值业务处理
            BOOL logicOK = [self responseLogic:json];
            if(logicOK){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(successBlock){
                        successBlock(request);
                    }
                });
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failureBlock) {
                        failureBlock(request,error);
                    }
                });
            }
            NSAssert((successBlock) && (failureBlock), @"successBlock and failureBlock not found");
        }
            break;
            
        default:
        {
            return;
        }
            break;
    }
}

-(BOOL)responseLogic:(NSDictionary *)responseJson
{
    NSNumber * code = [responseJson objectForKey:@"code"];
    NSString * message    = responseJson[@"msg"];
    NSLog(@"message：%@",message);
    
    if([code integerValue] != XZHttpResponseCodeSuccess){
        [self handleNetStatusErrorCode:[code integerValue]];
        if(self.autoHandleError){
            dispatch_async(dispatch_get_main_queue(), ^{
                if([code intValue] == XZHttpResponseCodeNotLogin){
                    return;
                }
                //错误信息在UI层面展示处理逻辑...
            });
        }
        return NO;
    }
    return YES;
}

//根据code处理逻辑
-(void)handleNetStatusErrorCode:(NSInteger)code {
    if(code == XZHttpResponseCodeNotLogin){
        dispatch_async(dispatch_get_main_queue(), ^{
            //处理未登录操作
        });
    }
}

#pragma mark - session request param
-(NSHTTPURLResponse *)response {
    return (NSHTTPURLResponse*)self.requestTask.response;
}

-(NSInteger)responseStatusCode {
     return self.response.statusCode;
}

- (NSDictionary *)responseHeaders {
    return self.response.allHeaderFields;
}

- (NSURLRequest *)currentRequest {
    return self.requestTask.currentRequest;
}

- (NSURLRequest *)originalRequest {
    return self.requestTask.originalRequest;
}

-(BOOL)isCancelled {
    if(!self.requestTask){
        return NO;
    }
    return self.requestTask.state == NSURLSessionTaskStateCanceling;
}

- (BOOL)isExecuting {
    if (!self.requestTask) {
        return NO;
    }
    return self.requestTask.state == NSURLSessionTaskStateRunning;
}

-(NSTimeInterval)requestTimeoutInterval {
    if(_requestTimeoutInterval>0){
        return _requestTimeoutInterval;
    }
    return 15;
}

@synthesize responseObject = _responseObject;
-(id)responseObject
{
    switch (_encryptionType) {
        case XZUseEncryptionType:
        {
            NSString *string = [[NSString alloc] initWithData:_responseObject encoding:NSUTF8StringEncoding];
            return [NSString AESForDecry:string WithKey:k_MAPIKey];
        }
            break;
        default:
        {
            return _responseObject;
        }
            break;
    }
}

- (BOOL)allowsCellularAccess {
    return YES;
}

#pragma mark - 请求参数拼接
- (NSMutableDictionary *)reviseMAPIParameters:(NSDictionary *)params
{
    NSString * k_uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"global_uid"];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    dict[@"cid"] = k_cid;
    dict[@"uid"] = k_uid;
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000000;
    dict[@"event_id"] = @(interval);
    
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] initWithDictionary:params];
    [paramsDict setObject:k_Lucky_AppVersion forKey:@"appversion"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:paramsDict options:0 error:nil];
    NSString *qValue = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    qValue = [NSString AESForEncry:qValue WithKey:k_MAPIKey];
    //将请求参数编入url中
    dict[@"q"] = qValue;
    
    //计算签名
    NSMutableArray *dictArray = [NSMutableArray arrayWithCapacity:dict.count];
    for (NSString *key in dict.allKeys) {
        NSString *string = [NSString stringWithFormat:@"%@=%@", key, dict[key]];
        [dictArray addObject:string];
    }
    
    NSArray *array = [dictArray sortedArrayUsingSelector:@selector(compare:)];
    NSString *signStr = [array componentsJoinedByString:@";"];
    signStr = [NSString stringWithFormat:@"%@%@", signStr, k_MAPIKey];
    dict[@"sign"] = [signStr doMD5String];
    
    return dict;
    
}

#pragma mark - lazy init
@synthesize baseUrl = _baseUrl;
-(NSString *)baseUrl
{
    return [self lazyInitWith:_baseUrl];
}

@synthesize subUrl = _subUrl;
-(NSString *)subUrl
{
    return [self lazyInitWith:_subUrl];
}

@synthesize domain = _domain;
-(NSString *)domain
{
    return [self lazyInitWith:_domain];
}

@synthesize encryptionType = _encryptionType;
@synthesize requestMethod = _requestMethod;

@synthesize requestArgument = _requestArgument;
-(NSDictionary *)requestArgument
{
    if(!_requestArgument){
        _requestArgument = [[NSDictionary alloc] init];
    }
    return _requestArgument;
}

@synthesize requsetUnencryptedArgument = _requsetUnencryptedArgument;
-(NSDictionary *)requsetUnencryptedArgument
{
    if(!_requsetUnencryptedArgument){
        _requsetUnencryptedArgument = [[NSDictionary alloc] init];
    }
    return _requsetUnencryptedArgument;
}

@synthesize requestTask = _requestTask;
-(NSURLSessionTask *)requestTask
{
    if(!_requestTask){
        _requestTask = [[NSURLSessionTask alloc] init];
    }
    return _requestTask;
}

@synthesize constructingBodyBlock = _constructingBodyBlock;
@synthesize needAddHeader = _needAddHeader;
@synthesize completionBlock = _completionBlock;
@synthesize responseJsonObject = _responseJsonObject;
-(NSDictionary *)responseJsonObject
{
    if(!_responseJsonObject){
        _responseJsonObject = [[NSDictionary alloc] init];
    }
    return _responseJsonObject;
}

@synthesize autoHandleError = _autoHandleError;
@synthesize cancelled = _cancelled;
@synthesize executing = _executing;
@synthesize requestTimeoutInterval = _requestTimeoutInterval;

-(NSString*)lazyInitWith:(NSString*)str
{
    if(!str){
        str = @"";
    }
    return str;
}
@end
