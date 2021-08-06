//
//  TVClockView.h
//  TVPlay-iOS
//
//  Created by yfm on 2021/7/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TVClockView : UIView

@property (nonatomic, copy) dispatch_block_t clockSetBlock;

@end

NS_ASSUME_NONNULL_END
