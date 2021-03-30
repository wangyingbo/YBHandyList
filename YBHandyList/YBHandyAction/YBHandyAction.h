//
//  YBHandyAction.h
//  YBHandyListDemo
//
//  Created by yingbo5 on 2021/3/30.
//  Copyright © 2021 迎博. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YBHandyAction<P> : NSObject

- (instancetype)initWithProtocol:(Protocol * _Nonnull)protocol;

- (void)forwardingTo:(id)forwardDelegate;

- (void)removeForwarding:(id)forwardDelegate;
@end


NS_ASSUME_NONNULL_END
