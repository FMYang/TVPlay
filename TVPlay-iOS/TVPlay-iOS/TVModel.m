//
//  TVModel.m
//  TVPlay-iOS
//
//  Created by yfm on 2021/5/25.
//

#import "TVModel.h"

@implementation TVModel

- (instancetype)initWithDic:(NSDictionary *)dic {
    if(self = [super init]) {
        _name = dic[@"name"];
        _videoUrl = dic[@"videoUrl"];
    }
    return self;
}

@end
