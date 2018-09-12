//
//  LuckinAFNViewController.m
//  OCTestOne
//
//  Created by kkxz on 2018/9/5.
//  Copyright © 2018年 kkxz. All rights reserved.

//GitHub地址：https://github.com/AFNetworking/AFNetworking

#import "LuckinAFNViewController.h"
#import "Masonry.h"
#import <AFNetworking/AFNetworking.h>

@interface LuckinAFNViewController ()
@property(nonatomic,strong)UIButton * buttonOne;
@property(nonatomic,strong)UIButton * buttonTwo;
@property(nonatomic,strong)UIButton * buttonThree;
@property(nonatomic,strong)UIButton * buttonFour;
@property(nonatomic,strong)UIButton * buttonFive;
@end

@implementation LuckinAFNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"AFN";
    self.view.backgroundColor = [UIColor whiteColor];
    [self createSubViews];
    [self createAutoLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createSubViews
{
     [self.view addSubview:self.buttonOne];
     [self.view addSubview:self.buttonTwo];
     [self.view addSubview:self.buttonThree];
     [self.view addSubview:self.buttonFour];
     [self.view addSubview:self.buttonFive];
    
}

-(void)createAutoLayout
{
    __weak __typeof(self)myself = self;
    [self.buttonOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(myself.view.mas_top).offset(100.0f);
        make.centerX.mas_equalTo(myself.view.mas_centerX);
    }];
    [self.buttonTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(myself.buttonOne.mas_bottom).offset(40.0f);
        make.centerX.mas_equalTo(myself.view.mas_centerX);
    }];
    [self.buttonThree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(myself.buttonTwo.mas_bottom).offset(40.0f);
        make.centerX.mas_equalTo(myself.view.mas_centerX);
    }];
    [self.buttonFour mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(myself.buttonThree.mas_bottom).offset(40.0f);
        make.centerX.mas_equalTo(myself.view.mas_centerX);
    }];
    [self.buttonFive mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(myself.buttonFour.mas_bottom).offset(40.0f);
        make.centerX.mas_equalTo(myself.view.mas_centerX);
    }];
    
}

#pragma mark - private methods
-(AFHTTPSessionManager*)sharedManager
{
    AFHTTPSessionManager * manager = [[AFHTTPSessionManager alloc] init];
    manager.operationQueue.maxConcurrentOperationCount = 5;//最大请求并发任务数
    // 请求格式
    // AFHTTPRequestSerializer            二进制格式
    // AFJSONRequestSerializer            JSON
    // AFPropertyListRequestSerializer    Plist(是一种特殊的XML,解析起来相对容易)
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];//上传普通格式
    manager.requestSerializer.timeoutInterval = 30.0f;//超时时间
    // 设置请求头
    [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    // 设置接收的Content-Type
    manager.responseSerializer.acceptableContentTypes = [[NSSet alloc]
                                                         initWithObjects:@"application/xml", @"text/xml",@"text/html", @"application/json",@"text/plain",nil];
    
    // 返回格式
    // AFHTTPResponseSerializer              二进制格式
    // AFJSONResponseSerializer              JSON
    // AFXMLParserResponseSerializer       XML,只能返回XMLParser,还需要自己通过代理方法解析
    // AFXMLDocumentResponseSerializer  (Mac OS X)
    // AFPropertyListResponseSerializer      Plist
    // AFImageResponseSerializer               Image
    // AFCompoundResponseSerializer        组合
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//返回格式 JSON
    //设置返回的Content-type
    manager.responseSerializer.acceptableContentTypes=[[NSSet alloc]
                                                       initWithObjects:@"application/xml", @"text/xml",@"text/html", @"application/json",@"text/plain",nil];
    return manager;
}

-(void)getClick
{
    //GET请求
    //创建请求地址
    NSString *url=@"http://api.nohttp.net/method";
    //构造参数
    NSDictionary *parameters=@{@"name":@"yanzhenjie",@"pwd":@"123"};
    //GET请求
    [[self sharedManager] GET:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        //返回请求进度
        NSLog(@"downloadProgress-->%@",downloadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //请求成功返回数据 根据responseSerializer 返回不同的数据格式
        NSLog(@"responseObject-->%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //请求失败
        NSLog(@"error-->%@",error);
    }];
}

-(void)postClick
{
    //POST请求
    //创建请求地址
    NSString *url=@"http://api.nohttp.net/postBody";
    //构造参数
    NSDictionary *parameters=@{@"name":@"yanzhenjie",@"pwd":@"123"};
    //POST请求
    [[self sharedManager] POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        //返回请求返回进度
        NSLog(@"downloadProgress-->%@",uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //请求成功返回数据 根据responseSerializer 返回不同的数据格式
        NSLog(@"responseObject-->%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //请求失败
        NSLog(@"error-->%@",error);
    }];
    
}


-(void)uploadClick
{
    //处理文件上传
    // 创建URL资源地址
    NSString *url = @"http://api.nohttp.net/upload";
    // 参数
    NSDictionary *parameters=@{@"name":@"yanzhenjie",@"pwd":@"123"};
    [[self sharedManager] POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval a=[dat timeIntervalSince1970];
        NSString* fileName = [NSString stringWithFormat:@"file_%0.f.txt", a];
        //[FileUtils writeDataToFile:fileName data:[@"upload_file_to_server" dataUsingEncoding:NSUTF8StringEncoding]];
        // 获取数据转换成data
        NSString *filePath = @"hdlal";//[FileUtils getFilePath:fileName];
        // 拼接数据到请求体中
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"headUrl" fileName:fileName mimeType:@"application/octet-stream" error:nil];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        // 上传进度
        NSLog(@"%lf",1.0 *uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //请求成功
        NSLog(@"请求成功：%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //请求失败
        NSLog(@"请求失败：%@",error);
    }];
    
}

-(void)downloadClick
{
    //处理文件下载
    NSString *urlStr =@"http://images2015.cnblogs.com/blog/950883/201701/950883-20170105104233581-62069155.png";
    // 设置请求的URL地址
    NSURL *url = [NSURL URLWithString:urlStr];
    // 创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //下载任务
    NSURLSessionDownloadTask * task = [[self sharedManager] downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        // 下载进度
        NSLog(@"当前下载进度为:%lf", 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        // 下载地址
        NSLog(@"默认下载地址%@",targetPath);
        //这里模拟一个路径 真实场景可以根据url计算出一个md5值 作为fileKey
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval a=[dat timeIntervalSince1970];
        NSString* fileKey = [NSString stringWithFormat:@"/file_%0.f.txt", a];
        // 设置下载路径,通过沙盒获取缓存地址,最后返回NSURL对象
        NSString *filePath =@""; //[FileUtils getFilePath:fileKey];
        return [NSURL fileURLWithPath:filePath]; // 返回的是文件存放在本地沙盒的地址
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        // 下载完成调用的方法
        NSLog(@"filePath---%@", filePath);
        NSData *data=[NSData dataWithContentsOfURL:filePath];
        UIImage *image=[UIImage imageWithData:data];
        // 刷新界面...
        UIImageView *imageView =[[UIImageView alloc]init];
        imageView.image=image;
        [self.view addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(300, 300));
        }];
    }];
    [task resume];//启动下载任务
}


-(void)statusClick
{
    //网络状态监听
    //创建网络监测者
    AFNetworkReachabilityManager * manager = [AFNetworkReachabilityManager sharedManager];
    /*枚举里面四个状态  分别对应 未知 无网络 数据 WiFi
     typedef NS_ENUM(NSInteger, AFNetworkReachabilityStatus) {
     AFNetworkReachabilityStatusUnknown          = -1,      未知
     AFNetworkReachabilityStatusNotReachable     = 0,       无网络
     AFNetworkReachabilityStatusReachableViaWWAN = 1,       蜂窝数据网络
     AFNetworkReachabilityStatusReachableViaWiFi = 2,       WiFi
     };
     */
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络状态");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"无网络");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"蜂窝数据网");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WiFi网络");
                break;
                
            default:
                break;
        }
    }];
    
    [manager startMonitoring];//开始监测
}

#pragma mark - lazy init
@synthesize buttonOne = _buttonOne;
-(UIButton *)buttonOne
{
    if(_buttonOne == nil){
        _buttonOne = [UIButton buttonWithType:UIButtonTypeSystem];
        [_buttonOne setTitle:@"GET" forState:UIControlStateNormal];
        [_buttonOne.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_buttonOne setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_buttonOne addTarget:self action:@selector(getClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonOne;
}

@synthesize buttonTwo = _buttonTwo;
-(UIButton *)buttonTwo
{
    if(_buttonTwo == nil){
        _buttonTwo = [UIButton buttonWithType:UIButtonTypeSystem];
        [_buttonTwo setTitle:@"POST" forState:UIControlStateNormal];
        [_buttonTwo.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_buttonTwo setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_buttonTwo addTarget:self action:@selector(postClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonTwo;
}

@synthesize buttonThree = _buttonThree;
-(UIButton *)buttonThree
{
    if(_buttonThree == nil){
        _buttonThree = [UIButton buttonWithType:UIButtonTypeSystem];
        [_buttonThree setTitle:@"Upload" forState:UIControlStateNormal];
        [_buttonThree.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_buttonThree setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_buttonThree addTarget:self action:@selector(uploadClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonThree;
}

@synthesize buttonFour = _buttonFour;
-(UIButton *)buttonFour
{
    if(_buttonFour == nil){
        _buttonFour = [UIButton buttonWithType:UIButtonTypeSystem];
        [_buttonFour setTitle:@"Download" forState:UIControlStateNormal];
        [_buttonFour.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_buttonFour setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_buttonFour addTarget:self action:@selector(downloadClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonFour;
}

@synthesize buttonFive = _buttonFive;
-(UIButton *)buttonFive
{
    if(_buttonFive == nil){
        _buttonFive = [UIButton buttonWithType:UIButtonTypeSystem];
        [_buttonFive setTitle:@"NetworkStatus" forState:UIControlStateNormal];
        [_buttonFive.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_buttonFive setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_buttonFive addTarget:self action:@selector(statusClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonFive;
}

@end
