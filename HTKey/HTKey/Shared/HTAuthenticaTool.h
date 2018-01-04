//
//  HTAuthenticaTool.h
//  HTKey
//
//  Created by iMac on 2018/1/3.
//  Copyright © 2018年 iMac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTAuthenticaTool : NSObject

+ (BOOL)supportAuthentication;

+ (void)startAuth;

+ (void)open;
+ (void)close;

@end
