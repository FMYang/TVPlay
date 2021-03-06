//
//  ViewController.m
//  TVPlay-iOS
//
//  Created by yfm on 2021/5/25.
//

#import "ViewController.h"
#import <IJKMediaFramework/IJKAVMoviePlayerController.h>
#import "IJKMoviePlayerViewController.h"
#import "TVModel.h"
#import <Masonry/Masonry.h>
#import "TVPingTools.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<TVModel *> *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"💗";
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self loadData];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)loadData {
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"TV.json" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSError *err = nil;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    for(NSDictionary *dic in arr) {
        TVModel *model = [[TVModel alloc] initWithDic:dic];
        [self.dataSource addObject:model];
    }
    [self.tableView reloadData];
}

- (void)playVideo:(NSString *)videoUrl {
    NSURL *url = [NSURL URLWithString:videoUrl];
    NSString *scheme = [[url scheme] lowercaseString];
    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"] || [scheme isEqualToString:@"rtmp"]) {
        [IJKVideoViewController presentFromViewController:self.navigationController withTitle:[NSString stringWithFormat:@"URL: %@", url] URL:url completion:nil];
    }
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataSource[indexPath.row].name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self playVideo:self.dataSource[indexPath.row].videoUrl];
}

#pragma mark -
- (NSMutableArray<TVModel *> *)dataSource {
    if(!_dataSource) {
        _dataSource = @[].mutableCopy;
    }
    return _dataSource;
}

- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

@end
