//
//  TVClockView.m
//  TVPlay-iOS
//
//  Created by yfm on 2021/7/29.
//

#import "TVClockView.h"
#import <Masonry/Masonry.h>
#import "TVClockCell.h"
#import "TVDataManager.h"

@interface TVClockView() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation TVClockView

- (instancetype)init {
    if(self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self addSubview:self.blurView];
    [self addSubview:self.tableView];
    [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TVClockCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.timeLabel.text = self.datasource[indexPath.row];
    if(indexPath.row == [self selectedIndex]) {
        cell.timeLabel.textColor = UIColor.yellowColor;
    } else {
        cell.timeLabel.textColor = UIColor.whiteColor;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        TVDataManager.shared.backgroundModeOn = NO;
        return;
    }
    
    TVDataManager.shared.backgroundModeOn = YES;
    TVDataManager.shared.clockTime = [self.datasource[indexPath.row] integerValue];
     
    [self.tableView reloadData];
    
    if(self.clockSetBlock) {
        self.clockSetBlock();
    }
}

#pragma mark -
- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.2];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:TVClockCell.class forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (UIVisualEffectView *)blurView {
    if(!_blurView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
    }
    return _blurView;
}

- (NSArray *)datasource {
    if(!_datasource) {
        _datasource = @[@"不开启", @"30", @"60", @"90", @"120"];
    }
    return _datasource;
}

- (NSInteger)selectedIndex {
    if(!TVDataManager.shared.backgroundModeOn) {
        return 0;
    }
    
    return [self.datasource indexOfObject:[NSString stringWithFormat:@"%ld", TVDataManager.shared.clockTime]];
}

@end
