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

+ (NSMutableArray<TVModel *> *)allModels {
    NSMutableArray *models = @[].mutableCopy;
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"TV.json" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSError *err = nil;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    for(NSDictionary *dic in arr) {
        TVModel *model = [[TVModel alloc] initWithDic:dic];
        [models addObject:model];
    }
    return models;
}

@end
