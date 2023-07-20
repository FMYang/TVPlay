//
//  TVModel.m
//  TVPlay
//
//  Created by yfm on 2021/5/24.
//

#import "TVModel.h"

@implementation TVModel

+ (NSArray<TVModel *> *)allModels {
    NSMutableArray *models = @[].mutableCopy;
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"TV.json" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSError *err = nil;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    for(NSDictionary *dic in arr) {
        TVModel *model = [[TVModel alloc] init];
        model.title = dic[@"title"];
        model.url = dic[@"url"];
        [models addObject:model];
    }
    return models;
}

@end
