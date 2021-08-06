//
//  TVDataManager.h
//  TVPlay-iOS
//
//  Created by yfm on 2021/8/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TVDataManager : NSObject

@property (class, readonly) TVDataManager *shared;

@property (nonatomic, assign) BOOL backgroundModeOn;

@property (nonatomic, assign) NSInteger clockTime;

@end

NS_ASSUME_NONNULL_END
