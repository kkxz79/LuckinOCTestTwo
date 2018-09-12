//
//  XZNetworkConfig.h
//  OCTestOne
//
//  Created by kkxz on 2018/9/11.
//  Copyright © 2018年 kkxz. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifdef DEBUG
#define NSLog(fmt, ...) {NSLog((fmt), ##__VA_ARGS__);}
#else
#define NSLog(...) {}
#endif

FOUNDATION_EXPORT NSString * const k_BaseUrlIP;
FOUNDATION_EXPORT NSString * const k_HostName;
FOUNDATION_EXPORT NSString * const k_MAPIKey;
FOUNDATION_EXPORT NSString * const k_cid;
FOUNDATION_EXPORT NSString * const k_Lucky_AppVersion;

typedef NS_ENUM(NSInteger,XZEncryptionType) {
    XZUnUseEncryptionType = 0,
    XZUseEncryptionType,
};

typedef NS_ENUM(NSInteger, XZRequestMethod) {
    XZRequestMethodGET = 0,
    XZRequestMethodPOST,
};

typedef NS_ENUM(NSInteger, XZHttpResponseCode)
{
    // SUCCESS 成功。
    XZHttpResponseCodeSuccess = 1,
    // API_NOT_FIND API 不存在。
    XZHttpResponseCodeAPINotFound = 2,
    // LIMIT_ERROR 调用频率超过限制。
    XZHttpResponseCodeLimitError = 3,
    // NO_AUTH 客户端的 API 权限不足。
    XZHttpResponseCodeNOAuth = 4,
    // NOT_LOGIN 未登录或者登录已超时。
    XZHttpResponseCodeNotLogin = 5,
    // MAPI_ERROR 服务器内部错误（未知错误）。
    XZHttpResponseCodeMAPIError = 6,
    // BASE_ERROR 业务错误。此时具体业务错误，请参考 busiCode。
    XZHttpResponseCodeBaseError = 7,
    // SECURITY_ERROR 客户端身份检查未通过。
    XZHttpResponseCodeSecurityError = 8,
    // PARAM_ERROR 参数错误。
    XZHttpResponseCodeParamError = 9,
    // INVOKER_INIT_FAIL 客户端身份初始化失败。
    XZHttpResponseCodeInvokerInitFail = 10,
    // PROTOCOL_ERROR 请求协议不支持。
    XZHttpResponseCodeProtocolError = 12,
    // SECRETKEY_EXPIRED 秘钥过期。
    XZHttpResponseCodeSecretKeyExpired = 13,
    // APIVersionNotSupport MAPI版本不再支持。
    XZHttpResponseCodeAPIVersionNotSupport = 16,
    // SECURITY_KEY_IS_NULL 密钥为空。
    XZHttpResponseCodeSecretKeyIsNull = 17,
    // ASYNC_TOKEN_MISSING 异步token缺失。
    XZHttpResponseCodeAsyncTokenMissing = 18,
    // FILTER_INTERRUPT 过滤器拒绝了该请求。
    XZHttpResponseCodeFilterInterrupy = 19,
    // INTERCEPTOR_INTERRUPT 拦截器拒绝了该请求。
    XZHttpResponseCodeInterceptorInterrupt = 20,
    // API_UNABLE 该API已暂停使用。
    XZHttpResponseCodeAPIUnable = 21,
    // INNER_SERVICE_ERROR API与内部服务通信出现异常。
    XZHttpResponseCodeInnerServiceError = 22
};
