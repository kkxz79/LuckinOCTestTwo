//
//  LuckinURLSessionViewController.m
//  OCTestOne
//
//  Created by kkxz on 2018/9/3.
//  Copyright © 2018年 kkxz. All rights reserved.
//

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n",[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...)
#endif

#import "LuckinURLSessionViewController.h"
#import "Masonry.h"

/*
 工作模式：
 默认会话模式（default）：工作模式类似于原来的NSURLConnection，使用的是基于磁盘缓存的持久化策略，使用用户keychain中保存的证书进行认证授权。
 瞬时会话模式（ephemeral）：该模式不使用磁盘保存任何数据。所有和会话相关的caches，证书，cookies等都被保存在RAM中，因此当程序使会话无效，这些缓存的数据就会被自动清空。
 后台会话模式（background）：该模式在后台完成上传和下载，在创建Configuration对象的时候需要提供一个NSString类型的ID用于标识完成工作的后台会话。
 NSURLSession类支持三种类型的任务：加载数据，下载和上传。
 */

@interface LuckinURLSessionViewController ()
<NSURLSessionDelegate,NSURLSessionTaskDelegate>
@property(nonatomic,strong)UIButton * textReqButton;
@property(nonatomic,strong)UIButton * picReqButton;
@property(nonatomic,strong)UIButton * picUploadButton;
@property(nonatomic,strong)UIButton * downloadButton;

@property(nonatomic,strong)UIButton * pauseButton;
@property(nonatomic,strong)UIButton * startButton;
@property(nonatomic,strong)UIButton * cancelButton;

@property(nonatomic,strong)NSURLSession * session;
@property(nonatomic,strong)NSURLSessionTask * task;
@property(nonatomic)NSData * resumeData;
@property (nonatomic) NSMutableData * data;
@property (nonatomic) BOOL isjsonTest;
@property (nonatomic)NSUInteger expectlength;

@property(nonatomic,strong)UIProgressView * progressView;
@property(nonatomic,strong)UITextView * resTextView;
@property(nonatomic,strong)UIImageView * resImgView;

@end

@implementation LuckinURLSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Session网络";
    self.view.backgroundColor = [UIColor whiteColor];
    [self createSubViews];
    [self createAutoLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createSubViews
{
    [self.view addSubview:self.textReqButton];
    [self.view addSubview:self.picReqButton];
    [self.view addSubview:self.picUploadButton];
    [self.view addSubview:self.downloadButton];
    [self.view addSubview:self.startButton];
    [self.view addSubview:self.pauseButton];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.resTextView];
    [self.view addSubview:self.resImgView];
}

-(void)createAutoLayout
{
    __weak __typeof(self)myself = self;
    [self.textReqButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(myself.view.mas_top).offset(100.0f);
        make.centerX.mas_equalTo(myself.view.mas_centerX);
    }];
    [self.picReqButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(myself.textReqButton.mas_bottom).offset(20.0f);
        make.centerX.mas_equalTo(myself.view.mas_centerX);
    }];
    [self.picUploadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(myself.picReqButton.mas_bottom).offset(20.0f);
        make.centerX.mas_equalTo(myself.view.mas_centerX);
    }];
    [self.downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(myself.picUploadButton.mas_bottom).offset(20.0f);
        make.centerX.mas_equalTo(myself.view.mas_centerX);
    }];
    [self.startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(myself.downloadButton.mas_bottom).offset(50.0f);
        make.centerX.mas_equalTo(myself.view.mas_centerX);
    }];
    [self.pauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(myself.startButton.mas_top);
        make.right.mas_equalTo(myself.startButton.mas_left).offset(-20.0f);
    }];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(myself.startButton.mas_top);
        make.left.mas_equalTo(myself.startButton.mas_right).offset(20.0f);
    }];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(myself.startButton.mas_bottom).offset(20.0f);
        make.centerX.mas_equalTo(myself.view.mas_centerX);
        make.width.equalTo(@300.0f);
        make.height.equalTo(@2.0f);
    }];
    
    [self.resTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(myself.progressView.mas_bottom).offset(20.0f);
        make.left.mas_equalTo(myself.view.mas_left).offset(5.0f);
        make.width.equalTo(@180.0f);
        make.height.equalTo(@180.0f);
    }];
    
    [self.resImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(myself.resTextView.mas_top);
        make.right.mas_equalTo(myself.view.mas_right).offset(-5.0f);
        make.width.equalTo(@180.0f);
        make.height.equalTo(@180.0f);
    }];
    
}

#pragma mark - ButtonAction
//文本请求
-(void)textReqClick
{
    self.isjsonTest = YES;
    [self reload];
    [self jsonTest];
}

-(void)picReqClick
{
    self.isjsonTest = NO;
    [self reload];
    [self imgTest];
}

-(void)picUploadReqClick
{
    self.isjsonTest = YES;
    [self reload];
    [self upDataTest];
}

-(void)downloadReqClick
{
    self.isjsonTest = NO;
    [self reload];
    [self downLoadTest];
}

-(void)pauseClick
{
    if(self.task.state == NSURLSessionTaskStateRunning){
        [self.task suspend];
    }
}

-(void)startClick
{
    if (self.task.state == NSURLSessionTaskStateSuspended)
    {
        [self.task resume];
    }
}

-(void)cancelClick
{
    switch (self.task.state) {
        case NSURLSessionTaskStateRunning:
        case NSURLSessionTaskStateSuspended:
            if([self.task isKindOfClass:[NSURLSessionDownloadTask class]]){
                [(NSURLSessionDownloadTask*)(self.task) cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                    self.resumeData = resumeData;
                }];
            }
            else{
                [self.task cancel];
            }
            break;
        default:
            break;
    }
}

#pragma mark - private methods
-(void)reload
{
    self.task = nil;
    self.resImgView.image = nil;
    self.resTextView.text = nil;
    self.progressView.hidden = NO;
    self.progressView.progress = 0;
    self.data = nil;
}

-(void)jsonTest
{
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSString * url = [NSString stringWithFormat:@"http://api.androidhive.info/volley/person_object.json"];
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDataTask * task = [session dataTaskWithRequest:request];
    self.task = task;
}

-(void)imgTest
{
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSString * url = [NSString stringWithFormat:@"https://upfile.asqql.com/2009pasdfasdfic2009s305985-ts/2018-4/2018423202071807.gif"];
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDataTask * task = [session dataTaskWithRequest:request];
    self.task = task;
}

-(void)upDataTest
{
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSString * url = [NSString stringWithFormat:@"http://www.chuantu.biz/upload.php"];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    NSString * imagePath = [self pathForResource:@"luckinpic" ofType:@"jpg"];
    NSURLSessionUploadTask * task = [session uploadTaskWithRequest:request fromFile:[NSURL URLWithString:imagePath]];
    self.task = task;
}

-(void)downLoadTest
{
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSString * url = [NSString stringWithFormat:@"https://upfile.asqql.com/2009pasdfasdfic2009s305985-ts/2018-4/2018423202071807.gif"];
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDownloadTask * task;
    if(self.resumeData){
        //需要服务器支持断点续传
        NSLog(@"断点续传...");
        task = [session downloadTaskWithResumeData:self.resumeData];
    }
    else{
        NSLog(@"常规下载...");
        task = [session downloadTaskWithRequest:request];
    }
    self.task = task;
}

//TODO:获取库图片
- (NSString *)pathForResource:(NSString *)resource ofType:(NSString *)type
{
    NSBundle *selfBundle = [NSBundle bundleForClass:[self class]];
    NSString *bundlePath = [selfBundle pathForResource:@"LuckinTimeDate" ofType:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
    return [resourceBundle pathForResource:resource ofType:type];
}

#pragma mark - 会话总代理
#pragma mark - NSURLSessionDelegate

#pragma mark 通知>>session被关闭
//[session invalidateAndCancel]或者[session finishTasksAndInvalidate]
//session被关闭时调用、持有的delegate将被清空
-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    NSLog(@"NSURLSessionDelegate:::通知>>session被关闭");
}

#pragma mark 询问>>服务器客户端配合验证--会话级别
/*
 参考：
 https://www.jianshu.com/p/2642e31919e7
 https://www.2cto.com/kf/201604/504149.html
 https://blog.csdn.net/jingcheng345413/article/details/65437649
 NSURLAuthenticationChallenge 类中最重要的一个属性是protectionSpace。
 该属性是一个 NSURLProtectionSpace 的实例，一个NSURLProtectionSpace对象通过属性host、isProxy、port、protocol、proxyType和realm代表了请求验证的服务器端的范围。
 而NSURLProtectionSpace类的authenticationMethod属性则指明了服务端的验证方式，可能的值包括:
 challenge.protectionSpace {
 // 默认
 NSURLAuthenticationMethodDefault
 // 基本的 HTTP 验证，通过 NSURLCredential 对象提供用户名和密码。
 NSURLAuthenticationMethodHTTPBasic
 // 类似于基本的 HTTP 验证，摘要会自动生成，同样通过 NSURLCredential 对象提供用户名和密码。
 NSURLAuthenticationMethodHTTPDigest
 // 不会用于 URL Loading System，在通过 web 表单验证时可能用到。
 NSURLAuthenticationMethodHTMLForm
 
 <<<<<***************>>>>>
 //Negotiate（协商，Kerberos or NTLM）
 NSURLAuthenticationMethodNegotiate
 //NTLM（WindowsNT使用的认证方式
 NSURLAuthenticationMethodNTLM
 // 验证客户端的证书
 NSURLAuthenticationMethodClientCertificate
 // 指明客户端要验证服务端提供的证书
 NSURLAuthenticationMethodServerTrust
 }
 其中后四个为会话级别验证
 将会优先调用会话级别验证、如果未实现再调用任务界别验证。
 */
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler;
{
    NSLog(@"NSURLSessionDelegate:::询问>>服务器客户端配合验证--会话级别");
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling,nil);
}

#pragma mark 通知>>所有后台下载任务全部完成
//必须在backgroundSessionConfiguration 并且在后台完成时才会调用
-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"NSURLSessionDelegate:::通知>>所有后台下载任务全部完成");
}

#pragma mark - 任务总代理
#pragma mark - NSURLSessionTaskDelegate

#pragma mark 通知>>延时任务被调用
/*
 当设置了earliestBeginDate属性
 (需要注意这个属性对于非后台任务并不有效、而且不能保证定时执行、只能保证不会在指定日期之前执行)
 的NSURLSessionTask被延迟调用的、会走这里 since iOS11.4
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
    willBeginDelayedRequest:(NSURLRequest *)request
    completionHandler:(void (^)(NSURLSessionDelayedRequestDisposition disposition, NSURLRequest * _Nullable newRequest))completionHandler {
        NSLog(@"NSURLSessionTaskDelegate:::通知>>延时任务被调用");
        /*
         typedef NS_ENUM(NSInteger, NSURLSessionDelayedRequestDisposition) {
         NSURLSessionDelayedRequestContinueLoading = 0,  //使用原始请求、参数忽略
         NSURLSessionDelayedRequestUseNewRequest = 1,    //使用新请求
         NSURLSessionDelayedRequestCancel = 2,   //取消任务、参数忽略
         }
         */
    completionHandler(NSURLSessionDelayedRequestContinueLoading,request);
}

#pragma mark 通知>>网络受限导致任务进入等待
/*
 如果NSURLSessionConfiguration的waitsForConnectivity属性为true
 并且由于网络不通(并不是并发受限)没有被立即发出时
 此方法最多只能在每个任务中调用一次、并且仅在连接最初不可用时调用。
 它永远不会被调用后台会话，因为这些会话会忽略waitsForConnectivity。
 */
- (void)URLSession:(NSURLSession *)session taskIsWaitingForConnectivity:(NSURLSessionTask *)task {
    NSLog(@"NSURLSessionTaskDelegate:::通知>>网络受限导致任务进入等待");
}

#pragma mark 准备开始请求、询问是否重定向
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
    willPerformHTTPRedirection:(NSHTTPURLResponse *)response
            newRequest:(NSURLRequest *)request
     completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler
{
    NSLog(@"NSURLSessionTaskDelegate:::询问>>是否重定向");
    completionHandler(request);
}

#pragma mark 询问>>服务器需要客户端配合验证--任务级别
//会话级别除非未实现对应代理、否则不会调用任务级别验证方法
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
    didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
     completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler;
{
    NSLog(@"NSURLSessionTaskDelegate:::询问>>服务器需要客户端配合验证--任务级别");
    NSURLCredential * cre =[NSURLCredential credentialWithUser:@"kirito_song" password:@"psw" persistence:NSURLCredentialPersistenceNone];
    completionHandler(NSURLSessionAuthChallengeUseCredential,cre);
}

#pragma mark 询问>>流任务的方式上传--需要客户端提供数据源
/* 当任务需要新的请求主体流发送到远程服务器时，告诉委托。
 这种委托方法在两种情况下被调用：
 1、如果使用uploadTaskWithStreamedRequest创建任务，则提供初始请求正文流：
 2、如果任务因身份验证质询或其他可恢复的服务器错误需要重新发送包含正文流的请求，则提供替换请求正文流。
 注：如果代码使用文件URL或NSData对象提供请求主体，则不需要实现此功能。
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream * _Nullable bodyStream))completionHandler {
    NSLog(@"NSURLSessionTaskDelegate:::询问>>数据流的方式上传--需要客户端提供数据源");
}

#pragma mark 通知>>上传进度
/* 定期通知代理向服务器发送主体内容的进度。*/
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    NSLog(@"NSURLSessionTaskDelegate:::通知>>上传进度");
    self.progressView.progress = (float)totalBytesSent/(float)totalBytesExpectedToSend;
}

#pragma mark 通知>>任务信息收集完成
/*
 对发送请求/DNS查询/TLS握手/请求响应等各种环节时间上的统计. 更易于我们检测, 分析我们App的请求缓慢到底是发生在哪个环节, 并对此进行优化提升我们APP的性能.
 
 NSURLSessionTaskMetrics对象与NSURLSessionTask对象一一对应. 每个NSURLSessionTaskMetrics对象内有3个属性 :
 
 taskInterval : task从开始到结束总共用的时间
 redirectCount : task重定向的次数
 transactionMetrics : 一个task从发出请求到收到数据过程中派生出的每个子请求, 它是一个装着许多NSURLSessionTaskTransactionMetrics对象的数组. 每个对象都代表下图的一个子过程
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics {
    NSLog(@"NSURLSessionTaskDelegate:::通知>>任务信息收集完成");
    NSLog(@"::::::::::::相关讯息::::::::::::\n总时间:%@\n,重定向次数:%zd\n,派生的子请求:%zd",metrics.taskInterval,metrics.redirectCount,metrics.transactionMetrics.count);
}

#pragma mark 通知>>任务完成
//无论成功、失败或者取消
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
    didCompleteWithError:(NSError *)error
{
    NSLog(@"NSURLSessionTaskDelegate:::通知>>任务完成");
    self.progressView.hidden = YES;
    if(!error){
        if(self.isjsonTest){
            NSString * str = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
            self.resTextView.text = str;
        }
        else{
            UIImage * image = [UIImage imageWithData:self.data];
            self.resImgView.image = image;
        }
    }
    else{
        self.resTextView.text = error.localizedDescription;
    }
}

#pragma mark - 数据任务代理
#pragma mark - NSURLSessionDataDelegate
#pragma mark 通知>>服务器返回响应头
#pragma mark 询问>>下一步操作
//服务器返回响应头、询问下一步操作(取消操作、普通传输、下载、数据流传输)
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveResponse:(NSURLResponse *)response
     completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
        NSLog(@"NSURLSessionDataDelegate:::通知>>服务器返回响应头。询问>>下一步操作");
        self.expectlength = [response expectedContentLength];
        completionHandler(NSURLSessionResponseAllow);
//    completionHandler(NSURLSessionResponseBecomeDownload);
//    completionHandler(NSURLSessionResponseBecomeStream);
}

#pragma mark 通知>>数据任务已更改为下载任务
//你可以通过上面的 completionHandler(NSURLSessionResponseBecomeDownload);进行测试
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    NSLog(@"NSURLSessionDataDelegate:::通知>>数据任务已更改为下载任务");
}

#pragma mark 通知>>数据任务已更改为流任务
//你可以通过上面的 completionHandler(NSURLSessionResponseBecomeStream);进行测试
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask {
    NSLog(@"NSURLSessionDataDelegate:::通知>>数据任务已更改为下载任务");
}

#pragma mark 通知>>服务器成功返回数据
//已经收到了一些(大数据可能多次调用)数据
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    NSLog(@"NSURLSessionDataDelegate:::通知>>服务器成功返回数据");
    [self.data appendData:data];
    self.progressView.progress = [self.data length]/((float) self.expectlength);
}

#pragma mark 询问>>是否把Response存储到Cache中
//任务是否应将响应存储在缓存中
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * _Nullable cachedResponse))completionHandler {
    NSLog(@"NSURLSessionDataDelegate:::询问>>是否把Response存储到Cache中");
    NSCachedURLResponse * res = [[NSCachedURLResponse alloc]initWithResponse:proposedResponse.response data:proposedResponse.data userInfo:nil storagePolicy:NSURLCacheStorageNotAllowed];
    completionHandler(res);
}

#pragma mark - 下载任务代理
#pragma mark - NSURLSessionDownloadDelegate

#pragma mark 通知>>下载任务已经完成
//location 临时文件的位置url 需要手动移动文件至需要保存的目录
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"NSURLSessionDownloadDelegate:::通知>>下载任务已经完成");
    NSData * data = [NSData dataWithContentsOfURL:location.filePathURL];
    [self.data appendData:data];
    self.resumeData = nil;
}

#pragma mark 通知>>下载任务进度
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    NSLog(@"NSURLSessionTaskDelegate:::通知>>下载任务进度");
    if (totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown) {
        self.progressView.progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
    }
}

#pragma mark 通知>>下载任务已经恢复下载
//filrOffest 已经下载的文件大小  expectedTotalBytes预期总大小
/*
 你可以通过 [session downloadTaskWithResumeData：resumeData]之类的方法来重新恢复一个下载任务
 resumeData在下载任务失败的时候会通过error.userInfo[NSURLSessionDownloadTaskResumeData]来返回以供保存
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"NSURLSessionTaskDelegate:::通知>>下载任务已经恢复下载");
}

#pragma mark - 流任务代理
#pragma mark - NSURLSessionStreamDelegate

#pragma mark 通知>>数据流的连接中读数据的一边已经关闭
- (void)URLSession:(NSURLSession *)session readClosedForStreamTask:(NSURLSessionStreamTask *)streamTask {
    NSLog(@"NSURLSessionStreamDelegate:::通知>>数据流的连接中读数据的一边已经关闭");
}

#pragma mark 通知>>数据流的连接中写数据的一边已经关闭
- (void)URLSession:(NSURLSession *)session writeClosedForStreamTask:(NSURLSessionStreamTask *)streamTask {
    NSLog(@"NSURLSessionStreamDelegate:::通知>>数据流的连接中写数据的一边已经关闭");
}

#pragma mark 通知>>系统已经发现了一个更好的连接主机的路径
- (void)URLSession:(NSURLSession *)session betterRouteDiscoveredForStreamTask:(NSURLSessionStreamTask *)streamTask {
    NSLog(@"NSURLSessionStreamDelegate:::通知>>系统已经发现了一个更好的连接主机的路径");
}

#pragma mark 通知>>流任务已完成
- (void)URLSession:(NSURLSession *)session streamTask:(NSURLSessionStreamTask *)streamTask
didBecomeInputStream:(NSInputStream *)inputStream
      outputStream:(NSOutputStream *)outputStream {
    NSLog(@"NSURLSessionStreamDelegate:::通知>>流任务已完成");
}


#pragma mark - lazy init
@synthesize textReqButton = _textReqButton;
-(UIButton *)textReqButton
{
    if(_textReqButton == nil){
        _textReqButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_textReqButton setTitle:@"文本请求" forState:UIControlStateNormal];
        [_textReqButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_textReqButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_textReqButton addTarget:self action:@selector(textReqClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _textReqButton;
}
@synthesize picReqButton = _picReqButton;
-(UIButton *)picReqButton
{
    if(_picReqButton == nil){
        _picReqButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_picReqButton setTitle:@"图片请求" forState:UIControlStateNormal];
        [_picReqButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_picReqButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_picReqButton addTarget:self action:@selector(picReqClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _picReqButton;
}
@synthesize picUploadButton = _picUploadButton;
-(UIButton *)picUploadButton
{
    if(_picUploadButton == nil){
        _picUploadButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_picUploadButton setTitle:@"图片上传" forState:UIControlStateNormal];
        [_picUploadButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_picUploadButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_picUploadButton addTarget:self action:@selector(picUploadReqClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _picUploadButton;
}
@synthesize downloadButton = _downloadButton;
-(UIButton *)downloadButton
{
    if(_downloadButton == nil){
        _downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_downloadButton setTitle:@"下载任务" forState:UIControlStateNormal];
        [_downloadButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_downloadButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_downloadButton addTarget:self action:@selector(downloadReqClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadButton;
}
@synthesize pauseButton = _pauseButton;
-(UIButton *)pauseButton
{
    if(_pauseButton == nil){
        _pauseButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_pauseButton setTitle:@"暂停" forState:UIControlStateNormal];
        [_pauseButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_pauseButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_pauseButton addTarget:self action:@selector(pauseClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pauseButton;
}
@synthesize startButton = _startButton;
-(UIButton *)startButton
{
    if(_startButton == nil){
        _startButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_startButton setTitle:@"开始" forState:UIControlStateNormal];
        [_startButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_startButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_startButton addTarget:self action:@selector(startClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startButton;
}
@synthesize cancelButton = _cancelButton;
-(UIButton *)cancelButton
{
    if(_cancelButton == nil){
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

@synthesize data = _data;
-(NSMutableData *)data
{
    if(_data == nil){
        _data = [[NSMutableData alloc] init];
    }
    return _data;
}

@synthesize session = _session;
-(NSURLSession *)session
{
    if(!_session){
        NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

@synthesize task = _task;
-(NSURLSessionTask *)task
{
    if(!_task){
        _task = [[NSURLSessionTask alloc] init];
    }
    return _task;
}

@synthesize progressView = _progressView;
-(UIProgressView *)progressView
{
    if(!_progressView){
        _progressView = [[UIProgressView alloc] init];
        _progressView.progressTintColor = [UIColor blueColor];
        _progressView.progress = 0;
        _progressView.progressViewStyle = UIProgressViewStyleDefault;
    }
    return _progressView;
}

@synthesize resTextView = _resTextView;
-(UITextView *)resTextView
{
    if(!_resTextView){
        _resTextView = [[UITextView alloc] init];
        _resTextView.font = [UIFont fontWithName:@"Arial" size:15.0f];
        _resTextView.textColor = [UIColor blackColor];
        _resTextView.backgroundColor = [UIColor whiteColor];
        _resTextView.textAlignment = NSTextAlignmentLeft;
        _resTextView.layer.borderColor = [UIColor grayColor].CGColor;
        _resTextView.layer.borderWidth = 1;
        _resTextView.layer.cornerRadius =5;
        _resTextView.returnKeyType = UIReturnKeyDefault;
    }
    return _resTextView;
}

@synthesize resImgView = _resImgView;
-(UIImageView *)resImgView
{
    if(_resImgView == nil){
        _resImgView = [[UIImageView alloc] init];
        _resImgView.backgroundColor = [UIColor lightGrayColor];
    }
    return _resImgView;
}

@end
