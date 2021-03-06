//
//  YZBaseRequest.m
//  YZNetwork
//
//  Created by 黄亚州 on 2019/12/21.
//  Copyright © 2019 iOS开发者. All rights reserved.
//

#import "YZBaseRequest.h"
#import "YZNetworkManager.h"

@interface YZBaseRequest ()
/// 请求接口会话任务
@property (nonatomic, strong, readwrite) NSURLSessionTask *requestTask;
/// 请求返回原始数据，如果请求失败则为nil，开放读写权限
@property (nonatomic, strong, readwrite, nullable) id responseObject;
/// 请求返回数据json字符串，如果请求失败则为nil，开放读写权限
@property (nonatomic, strong, readwrite, nullable) NSString *responseString;
/// 请求过程中发生的错误
@property (nonatomic, strong, readwrite, nullable) NSError *error;

@end

@implementation YZBaseRequest

#pragma mark - 请求配置，可根据自己的使用场景重写以下方法

- (NSTimeInterval)requestTimeoutInterval {
    return 30.0f;
}

- (BOOL)allowsCellularAccess {
    return YES;
}

- (YZRequestMethod)requestMethod {
    return YZRequestMethodPOST;
}

- (YZRequestSerializerType)requestSerializerType {
    return YZRequestSerializerTypeHTTP;
}

- (YZResponseSerializerType)responseSerializerType {
    return YZResponseSerializerTypeJSON;
}

- (NSArray <NSString *> *)requestAuthorizationHeaderFieldArray {
    return nil;
}

- (NSDictionary <NSString *, NSString *> *)requestHeaderFieldValueDictionary {
    return nil;
}

- (YZSchemeProtocolType)requestSchemeProtocolType {
    return YZSchemeProtocolTypeHttp;
}

- (NSString *)requestRealmNameString {
    return @"";
}

- (NSString *)requestInterfaceURLString {
    return @"";
}

- (NSString *)requestFullURLString {
    NSString *schemeStr = [self requestSchemeProtocolType] == YZSchemeProtocolTypeHttps ? @"https" : @"http";
    // (http)://(example.com)(/api/v1/login)
    return [NSString stringWithFormat:@"%@://%@%@", schemeStr, [self requestRealmNameString], [self requestInterfaceURLString]];
}

- (id)requestParam {
    return @{};
}

- (YZConstructingBlock)constructingBodyBlock {
    return nil;
}

- (BOOL)statusCodeValidator {
    NSInteger statusCode = [self responseStatusCode];
    return (statusCode >= 200 && statusCode <= 299);
}

- (void)setCompletionBlock:(YZRequestCompletionBlock)block {
    self.requestCompletionBlock = block;
}

- (void)clearCompletionBlock {
    // nil out to break the retain cycle.
    self.requestCompletionBlock = nil;
}

- (BOOL)networkBadValidator {
    NSInteger errorCode = self.responseStatusCode;
    if (errorCode == -1001) { // 网络超时
        return YES;
    }
    
    if (errorCode == -1009) { // 网络断开
        return YES;
    }
    
    if (errorCode == 3840) { // 数据返回的json格式不规范
        return YES;
    }
    
    return NO;
}

#pragma mark - 请求操作

- (void)startRequest {
    [[YZNetworkManager sharedManager] addRequest:self];
}

- (void)stopRequest {
    self.delegate = nil;
    [[YZNetworkManager sharedManager] cancelRequest:self];
}

- (void)startRequestWithCompletionBlock:(YZRequestCompletionBlock)block {
    [self setCompletionBlock:block];
    [self startRequest];
}

#pragma mark - Private Methods

#pragma mark - Getter

- (YZRequestPriority)requestPriority {
    return YZRequestPriorityDefault;
}

- (NSHTTPURLResponse *)response {
    return (NSHTTPURLResponse *)self.requestTask.response;
}

- (NSInteger)responseStatusCode {
    if (self.response != nil) {
        return self.response.statusCode;
    }
    
    if (self.error != nil) {
        return self.error.code;
    }
    
    if (self.requestTask != nil && self.requestTask.error != nil) {
        return self.requestTask.error.code;
    }
    return NSNotFound;
}

#pragma mark - Setter


@end
