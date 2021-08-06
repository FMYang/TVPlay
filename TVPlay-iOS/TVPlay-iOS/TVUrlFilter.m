//
//  TVUrlFilter.m
//  TVPlay-iOS
//
//  Created by yfm on 2021/8/6.
//

#import "TVUrlFilter.h"
#import "TVModel.h"
#import "TVPingTools.h"

@interface TVUrlFilter()

@property (nonatomic, strong) TVPingTools *pingTools;

@end

@implementation TVUrlFilter

- (void)startFilter {
    NSArray<TVModel *> *models = [TVModel allModels];
    for(TVModel *model in models) {
        TVPingTools *tools = [[TVPingTools alloc] initWithHostName:model.videoUrl];
    }
}

@end
