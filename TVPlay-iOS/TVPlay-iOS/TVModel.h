//
//  TVModel.h
//  TVPlay-iOS
//
//  Created by yfm on 2021/5/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TVModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *videoUrl;

- (instancetype)initWithDic:(NSDictionary *)dic;

+ (NSMutableArray<TVModel *> *)allModels;

@end

NS_ASSUME_NONNULL_END
