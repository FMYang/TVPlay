//
//  TVModel.h
//  TVPlay
//
//  Created by yfm on 2021/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TVModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;

+ (NSArray<TVModel *> *)allModels;

@end

NS_ASSUME_NONNULL_END
