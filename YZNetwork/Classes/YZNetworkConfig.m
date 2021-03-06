//
//  YZNetworkConfig.m
//  YZNetwork
//
//  Created by 黄亚州 on 2019/12/21.
//  Copyright © 2019 iOS开发者. All rights reserved.
//

#import "YZNetworkConfig.h"


#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

@implementation YZNetworkConfig

+ (YZNetworkConfig *)sharedConfig {
    static YZNetworkConfig *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _securityPolicy = [AFSecurityPolicy defaultPolicy];
    }
    
    return self;
}

@end
