//
//  HODelegateInterceptor.h
//  hopOn
//
//  Created by Andrew Lopez-Vass on 1/26/15.
//  Copyright (c) 2015 hopOn, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALVDelegateInterceptor : NSObject

@property (nonatomic, weak) id interceptor;
@property (nonatomic, weak) id originalTarget;
@property (nonatomic, readonly, copy) NSArray *interceptedProtocols;

- (instancetype)initWithInterceptedProtocol:(Protocol *)interceptedProtocol;
- (instancetype)initWithInterceptedProtocols:(Protocol *)firstInterceptedProtocol, ... NS_REQUIRES_NIL_TERMINATION;
- (instancetype)initWithArrayOfInterceptedProtocols:(NSArray *)arrayOfInterceptedProtocols;

@end
