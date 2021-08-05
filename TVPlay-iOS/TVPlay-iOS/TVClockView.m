//
//  TVClockView.m
//  TVPlay-iOS
//
//  Created by yfm on 2021/7/29.
//

#import "TVClockView.h"
#import <Masonry/Masonry.h>

@interface TVClockView() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *datasource;
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
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = UIColor.clearColor;
    cell.textLabel.text = self.datasource[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark -
- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.8];;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (NSArray *)datasource {
    if(!_datasource) {
        _datasource = @[@"不开启", @"30", @"60", @"90"];
    }
    return _datasource;
}

@end
