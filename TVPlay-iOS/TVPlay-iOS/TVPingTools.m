//
//  TVPingTools.m
//  TVPlay-iOS
//
//  Created by yfm on 2021/8/6.
//

#import "TVPingTools.h"

@interface TVPingTools() <SimplePingDelegate> {
    NSTimer *_timer;
    CFTimeInterval _beginDate;
}


@property (nonatomic, strong) SimplePing *simplePing;

@property (nonatomic, strong) NSMutableArray<XFPingItem *> *pingItems;

@property (nonatomic, strong) NSString *hostName;

@end

@implementation TVPingTools

- (instancetype)initWithHostName:(NSString*)hostName
{
    if (self = [super init])
    {
        self.hostName = hostName;
        self.simplePing = [[SimplePing alloc] initWithHostName:hostName];
        self.simplePing.delegate = self;
        self.simplePing.addressStyle = SimplePingAddressStyleAny;

        self.pingItems = [NSMutableArray new];
    }
    return self;
}

- (void)startPing
{
    [self.simplePing start];
}

- (BOOL)isPinging
{
    return [_timer isValid];
}

- (void)stopPing
{
    [_timer invalidate];
    _timer = nil;
    [self.simplePing stop];
}


- (void)actionTimer
{
    if (_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(sendPingData) userInfo:nil repeats:YES];
}

- (void)sendPingData
{
    [self.simplePing sendPingWithData:nil];
}


#pragma mark - Ping Delegate
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address
{
    [self actionTimer];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error
{
    NSLog(@"hostname:%@, ping失败--->%@", self.hostName, error);
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    XFPingItem* item = [XFPingItem new];
    item.sequence = sequenceNumber;
    [self.pingItems addObject:item];
    
    _beginDate = CFAbsoluteTimeGetCurrent();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.pingItems containsObject:item])
        {
            NSLog(@"hostname:%@, 超时---->", self.hostName);
            [self.pingItems removeObject:item];
        }
    });
}
- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error
{
    NSLog(@"hostname:%@, 发包失败--->%@", self.hostName, error);
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    float delayTime = CFAbsoluteTimeGetCurrent() - _beginDate;
    [self.pingItems enumerateObjectsUsingBlock:^(XFPingItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.sequence == sequenceNumber)
        {
            [self.pingItems removeObject:obj];
        }
    }];
    
    if(![self.resultArray.allKeys containsObject:self.hostName]) {
        
        [self.resultArray addEntriesFromDictionary:@{@"key":self.hostName, @"value": @(delayTime)}];
    }
//    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didPingSucccessWithHostName:withTime:withError:)])
//    {
//        [self.delegate didPingSucccessWithHostName:self.hostName withTime:delayTime withError:nil];
//    }
}

- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet
{
}

@end


@implementation XFPingItem

@end
