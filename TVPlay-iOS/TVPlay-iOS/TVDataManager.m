//
//  TVDataManager.m
//  TVPlay-iOS
//
//  Created by yfm on 2021/8/6.
//

#import "TVDataManager.h"

@implementation TVDataManager

+ (TVDataManager *)shared {
    static TVDataManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TVDataManager alloc] init];
    });
    return instance;
}

@end
