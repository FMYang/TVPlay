//
//  TVPingTools.h
//  TVPlay-iOS
//
//  Created by yfm on 2021/8/6.
//

#import <Foundation/Foundation.h>
#import "SimplePing.h"

NS_ASSUME_NONNULL_BEGIN

@interface TVPingTools : NSObject

@property (nonatomic, strong) NSMutableDictionary *resultArray;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithHostName:(NSString*)hostName NS_DESIGNATED_INITIALIZER;
- (void)startPing;
- (BOOL)isPinging;
- (void)stopPing;

@end

@interface XFPingItem : NSObject

@property (nonatomic, assign) uint16_t sequence;

@end

NS_ASSUME_NONNULL_END
