//
//  XZNetworkAgent.h
//  OCTestOne
//
//  Created by kkxz on 2018/9/11.
//  Copyright © 2018年 kkxz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class XZBaseRequest;
typedef void (^XZDownLoadCompletionBlock) (NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError *  _Nullable error);

@interface XZNetworkAgent : NSObject
@property (nonatomic,assign) BOOL useDomain;

+(instancetype)sharedAgent;

-(void)runRequestArr;
-(void)removeAllRequest;
//  Add request to session and start it.
- (void)addRequest:(XZBaseRequest * _Nullable)request;
//  Cancel a request that was previously added.
- (void)cancelRequest:(XZBaseRequest * _Nullable)request;
//  Cancel all requests that were previously added.
- (void)cancelAllRequests;

-(void)downLoadMovie:(NSURL * _Nonnull)URL targetPath:(NSURL *_Nullable)targetPathURL
   completionHandler:(XZDownLoadCompletionBlock _Nullable )downLoadCompletionBlock;

NS_ASSUME_NONNULL_END
@end
