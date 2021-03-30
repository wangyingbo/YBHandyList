//
//  YBHandyAction.m
//  YBHandyListDemo
//
//  Created by yingbo5 on 2021/3/30.
//  Copyright © 2021 迎博. All rights reserved.
//

#import "YBHandyAction.h"
#import <objc/runtime.h>

@interface YBHandyAction ()
@property (nonatomic, strong) NSMutableSet *forwardDelegates;
@property (nonatomic, strong) Protocol *actionProtocol;
@end

@implementation YBHandyAction

- (instancetype)initWithProtocol:(Protocol *)protocol {
    if (self = [super init]) {
        _actionProtocol = protocol;
    }
    return self;
}

- (void)forwardingTo:(id)forwardDelegate {
    [self.forwardDelegates addObject:forwardDelegate];
}

- (void)removeForwarding:(id)forwardDelegate {
    [self.forwardDelegates removeObject:forwardDelegate];
}

#pragma mark - Forward Invocations

- (BOOL)shouldForwardSelector:(SEL)selector {
  struct objc_method_description description;
  description = protocol_getMethodDescription(_actionProtocol, selector, NO, YES);
  return (description.name != NULL && description.types != NULL);
}

- (BOOL)respondsToSelector:(SEL)selector {
  if ([super respondsToSelector:selector]) {
    return YES;
    
  } else if ([self shouldForwardSelector:selector]) {
    for (id delegate in self.forwardDelegates) {
      if ([delegate respondsToSelector:selector]) {
        return YES;
      }
    }
  }
  return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
  NSMethodSignature *signature = [super methodSignatureForSelector:selector];
  if (signature == nil) {
    for (id delegate in self.forwardDelegates) {
      if ([delegate respondsToSelector:selector]) {
        signature = [delegate methodSignatureForSelector:selector];
      }
    }
  }
  return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  BOOL didForward = NO;
  
  if ([self shouldForwardSelector:invocation.selector]) {
    for (id delegate in self.forwardDelegates) {
      if ([delegate respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:delegate];
        didForward = YES;
        break;
      }
    }
  }
  
  if (!didForward) {
    [super forwardInvocation:invocation];
  }
}

#pragma mark - setter && getter
- (NSMutableSet *)forwardDelegates {
    if (!_forwardDelegates) {
        _forwardDelegates = ActionCreateNonRetainingMutableSet();
    }
    return _forwardDelegates;
}

FOUNDATION_STATIC_INLINE NSMutableSet* ActionCreateNonRetainingMutableSet(void) {
  return (__bridge_transfer NSMutableSet *)CFSetCreateMutable(nil, 0, nil);
}

@end
