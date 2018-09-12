//
//  XZNetworkAgent.m
//  OCTestOne
//
//  Created by kkxz on 2018/9/11.
//  Copyright © 2018年 kkxz. All rights reserved.
//

#import "XZNetworkAgent.h"
#import "XZNetworkConfig.h"
#import "XZBaseRequest.h"
#import <pthread/pthread.h>
#import <AFNetworking/AFNetworking.h>

#define Lock() pthread_mutex_lock(&_lock)
#define Unlock() pthread_mutex_unlock(&_lock)
#define Lock2() pthread_mutex_lock(&_lock2)
#define Unlock2() pthread_mutex_unlock(&_lock2)

static dispatch_once_t onceToken;
@implementation XZNetworkAgent {
    AFHTTPSessionManager *_manager;
    NSMutableDictionary<NSNumber *, XZBaseRequest *> *_requestsRecord;
    pthread_mutex_t _lock,_lock2;
    NSMutableArray * _requestArr;
}

+(instancetype)sharedAgent
{
    static XZNetworkAgent * _netSharedInstance = nil;
    dispatch_once(&onceToken, ^{
        _netSharedInstance = [[self alloc] init];
    });
    return _netSharedInstance;
}

-(instancetype)init
{
    self = [super init];
    if(self){
        //创建串行队列
        dispatch_queue_t processingQueue = dispatch_queue_create("com.LuckyClient.network.processing",DISPATCH_QUEUE_CONCURRENT);
        
        _requestsRecord = [NSMutableDictionary dictionary];
        //多线程编程中，互斥锁的初始化
        pthread_mutex_init(&_lock, NULL);
        pthread_mutex_init(&_lock2, NULL);
        _requestArr = [[NSMutableArray alloc] initWithCapacity:2];
        
        //配置设置
         NSURLSessionConfiguration * sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        //AFHTTPSessionManager创建
         _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:sessionConfiguration];
         _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
         _manager.completionQueue = processingQueue;
        //网络安全策略
         AFSecurityPolicy * securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
         securityPolicy.allowInvalidCertificates = YES;
        [securityPolicy setValidatesDomainName:NO];
        _manager.securityPolicy = securityPolicy;
    }
    return self;
}

#pragma mark - 组织session队列
-(void)addRequest:(XZBaseRequest *)request
{
    [self runRequest:request];
}

-(void)runRequest:(XZBaseRequest *)request
{
    request.baseUrl = k_BaseUrlIP;
    request.domain = k_HostName;
    if(self.useDomain){
        request.baseUrl = k_HostName;
    }
    request.baseUrl = [@"https://" stringByAppendingString:request.baseUrl];
    //是否是域名
    if ([request.baseUrl containsString:@"coffee"]){
        request.needAddHeader = NO;
    }
    else{
        request.needAddHeader = YES;
    }
    
    NSError * __autoreleasing requestSerializationError = nil;
    //创建task
    request.requestTask = [self sessionTaskForRequest:request error:&requestSerializationError];
    
    if (requestSerializationError) {
        if (request.completionBlock) {
            request.completionBlock(request,requestSerializationError);
            [request clearCompletionBlock];
        }
        return;
    }
    
    NSAssert(request.requestTask != nil, @"requestTask should not be nil");
    
    //Retain request
    [self addRequestToRecord:request];
    [request.requestTask resume];
}

-(void)runRequestArr
{
    if(_requestArr.count<=0){
        return;
    }
    for(XZBaseRequest * request in _requestArr){
        Lock2();
        if(request){
            [self runRequest:request];
        }
        Unlock2();
    }
}

- (void)addRequestToRecord:(XZBaseRequest *)request {
    Lock();
    _requestsRecord[@(request.requestTask.taskIdentifier)] = request;
    Unlock();
}

-(void)removeAllRequest{
    Lock2();
    [_requestArr removeAllObjects];
    Unlock2();
}

#pragma mark - private_method
- (AFHTTPRequestSerializer *)requestSerializerForRequest:(XZBaseRequest *)request
{
    AFHTTPRequestSerializer *requestSerializer = nil;
    requestSerializer.HTTPShouldHandleCookies = NO;
    requestSerializer = [AFHTTPRequestSerializer serializer];
    requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    requestSerializer.allowsCellularAccess = [request allowsCellularAccess];
    
    if (request.needAddHeader) {
        [requestSerializer setValue:request.domain forHTTPHeaderField:@"Host"];
    }
    return requestSerializer;
}

- (NSURLSessionTask *)sessionTaskForRequest:(XZBaseRequest *)request error:(NSError * _Nullable __autoreleasing *)error
{
    XZRequestMethod method = request.requestMethod;
    NSString *url = [self buildRequestUrl:request];
    NSDictionary * param = request.requestArgument;
    AFHTTPRequestSerializer * requestSerializer = [self requestSerializerForRequest:request];
    // 通常我们会用到上传图片或者其他文件就需要用到 multipart/form-data,同样的只需要实现- (AFConstructingBlock)constructingBodyBlock;协议方法即可
    AFConstructingBlock constructingBlock = request.constructingBodyBlock;
    
    switch (method) {
        case XZRequestMethodGET:
            {
                return [self dataTaskWithHTTPMethod:@"GET"
                                  requestSerializer:requestSerializer
                                          URLString:url
                                         parameters:param
                                              error:error];
            }
            break;
        case XZRequestMethodPOST:
        {
            //此处做正常请求和上传图片的兼容
            if (constructingBlock) {
                NSMutableString * urlStr = [[NSMutableString alloc] initWithString:url];
                [urlStr appendString:@"?"];
                [param enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    [urlStr appendFormat:@"%@=%@&",key,obj];
                }];
                url = [urlStr substringToIndex:([urlStr length]-1)];// 去掉最后一个"&"
                param = nil;
            }
#if DEBUG
            NSString * fullUrl = [self jointUrlWithParam:url Param:param];
            NSLog(@"\n===================================\nrequest 请求开始  完整路径 -->>\n %@\n===================================\n",fullUrl);
#endif
            return [self dataTaskWithHTTPMethod:@"POST"
                              requestSerializer:requestSerializer
                                      URLString:url
                                     parameters:param
                      constructingBodyWithBlock:constructingBlock
                                          error:error];
            
        }
            break;
            
        default:
        {
            return nil;
        }
            break;
    }
}

//GET
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                           error:(NSError * _Nullable __autoreleasing *)error
{
    NSMutableURLRequest * URLRequest = nil;
    URLRequest = [requestSerializer requestWithMethod:method
                                            URLString:URLString
                                           parameters:parameters
                                                error:error];
    NSLog(@"requestUrl：\n%@",URLRequest.URL);
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [_manager dataTaskWithRequest:URLRequest uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
                    //
                } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
                    //
                } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                    //response 返回数据解析处理
                    [self handleRequestResult:dataTask responseObject:responseObject error:error];
                }];
    
    return dataTask;
}

//POST
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                       constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
                                           error:(NSError * _Nullable __autoreleasing *)error
{
    NSMutableURLRequest *request = nil;
    
    if (block) {
        request = [requestSerializer multipartFormRequestWithMethod:method
                                                          URLString:URLString
                                                         parameters:parameters
                                          constructingBodyWithBlock:block
                                                              error:error];
    } else {
        request = [requestSerializer requestWithMethod:method
                                             URLString:URLString
                                            parameters:parameters
                                                 error:error];
    }
    
    __block NSURLSessionDataTask * dataTask = nil;
    dataTask = [_manager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
                    //
                } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
                    //
                } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                    //reponse 返回数据解析处理
                    [self handleRequestResult:dataTask responseObject:responseObject error:error];
                }];
    return dataTask;
}

- (void)handleRequestResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error
{
    Lock();
    XZBaseRequest *request = _requestsRecord[@(task.taskIdentifier)];
    Unlock();
    
    if(!request){
        return;
    }
    
    request.responseObject = responseObject;
    
    if(error){
        NSLog(@"Request %@ failed, status code = %d, error = %@ , url = %@%@?%@",NSStringFromClass([request class]), (int)request.responseStatusCode, error.localizedDescription,request.baseUrl,request.subUrl,request.requestArgument);
    }
    
    //返回解析数据
    if (request.completionBlock) {
        request.completionBlock(request,error);
        [request clearCompletionBlock];
    }
    
     [self removeRequestFromRecord:request];
    
}

-(void)downLoadMovie:(NSURL * _Nonnull)URL
          targetPath:(NSURL *_Nullable)targetPathURL
   completionHandler:(XZDownLoadCompletionBlock _Nullable )downLoadCompletionBlock;
{
    BOOL isWiFi = [[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi];
    if (isWiFi == NO) {
        return;
    }
    
    //创建管理者
    AFHTTPSessionManager *manage  = [AFHTTPSessionManager manager];
    //创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manage downloadTaskWithRequest:request
                                                                    progress:nil
                                                                 destination:^NSURL * _Nonnull(NSURL * _Nonnull tempPath, NSURLResponse * _Nonnull response) {
                                                                     NSLog(@"====>>>缓存目录%@",tempPath);
                                                                     NSString *tempFilePath = [tempPath absoluteString];
                                                                     NSString *tempFileName = [tempFilePath lastPathComponent];
                                                                     NSString *targetFilePathStr = [targetPathURL absoluteString];
                                                                     NSString * targetFileName = [targetFilePathStr lastPathComponent];
                                                                     NSRange range = [targetFilePathStr rangeOfString:targetFileName];
                                                                     NSString * targetPrefixPath = [targetFilePathStr substringToIndex:range.location];
                                                                     
                                                                     NSString *targetFilePath = [NSString stringWithFormat:@"%@%@",targetPrefixPath,[NSString stringWithFormat:@"%@.mp4",[tempFileName stringByDeletingPathExtension]]];
                                                                     if (!targetFilePath) {
                                                                         targetFilePath = @"";
                                                                     }
                                                                     return [NSURL URLWithString:targetFilePath];
                                                                     
                                                                 } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error) {
                                                                     NSFileManager *fileManager = [NSFileManager defaultManager];
                                                                     NSError *moveError;
                                                                     NSString *filePathStr = [filePath absoluteString];
                                                                     NSString *fileName = [filePathStr lastPathComponent];
                                                                     NSRange range = [filePathStr rangeOfString:fileName];
                                                                     NSString *prefixPath = [filePathStr substringToIndex:range.location];
                                                                     NSString *targetFileName = [[targetPathURL absoluteString] lastPathComponent];
                                                                     NSString *targetFilePath = [NSString stringWithFormat:@"%@%@",prefixPath,targetFileName];
                                                                     
                                                                     BOOL isDir;
                                                                     BOOL isExist =[fileManager fileExistsAtPath:[NSURL URLWithString:targetFilePath].path isDirectory:&isDir];
                                                                     if (!isDir && isExist) {
                                                                         NSError *removeError;
                                                                         [fileManager removeItemAtURL:[NSURL URLWithString:targetFilePath] error:&removeError];
                                                                     }
                                                                     
                                                                     [fileManager moveItemAtURL:filePath toURL:[NSURL URLWithString:targetFilePath] error:&moveError];
                                                                     if(downLoadCompletionBlock){
                                                                         downLoadCompletionBlock(response,filePath,error);
                                                                     }
                                                                 }];
    
    //启动任务
    [downloadTask resume];
}

#pragma mark - deal request data
- (NSString *)buildRequestUrl:(XZBaseRequest *)request
{
    NSParameterAssert(request != nil);
    NSString * baseUrlStr = request.baseUrl;
    NSParameterAssert(baseUrlStr.length > 2);
    NSString * urlStr = [baseUrlStr stringByAppendingString:request.subUrl];
    return urlStr;
}

-(NSString *)jointUrlWithParam:(NSString *)url Param:(NSDictionary *)param
{
    
    NSMutableString * urlStr = [[NSMutableString alloc] initWithString:url];
    [urlStr appendString:@"?"];
    [param enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [urlStr appendFormat:@"%@=%@&",key,obj];
    }];
    url = [urlStr substringToIndex:([urlStr length]-1)];// 去掉最后一个"&"
    param = nil;
    
    return url;
}

- (void)removeRequestFromRecord:(XZBaseRequest *)request {
    Lock();
    [_requestsRecord removeObjectForKey:@(request.requestTask.taskIdentifier)];
    NSLog(@"Request queue size = %zd", [_requestsRecord count]);
    Unlock();
}

- (void)cancelRequest:(XZBaseRequest *)request
{
    NSParameterAssert(request != nil);
    [request.requestTask cancel];
    [self removeRequestFromRecord:request];
    [request clearCompletionBlock];
}

- (void)cancelAllRequests{
    Lock();
    NSArray *allKeys = [_requestsRecord allKeys];
    Unlock();
    if (allKeys && allKeys.count > 0) {
        NSArray *copiedKeys = [allKeys copy];
        for (NSNumber *key in copiedKeys) {
            Lock();
            XZBaseRequest *request = _requestsRecord[key];
            Unlock();
            [request stop];
        }
    }
}


@end
