//
//  ViewController.m
//  TVPlay
//
//  Created by yfm on 2021/5/24.
//

#import "ViewController.h"
#import <VLCKit/VLCKit.h>
#import "TVModel.h"

@interface ViewController() <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, strong) NSArray<TVModel *> *listArr;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSView *customView;
@property (weak) IBOutlet NSLayoutConstraint *tableviewWidthConstraint;

///
@property (nonatomic, strong) VLCVideoView *videoView;
@property (nonatomic, strong) VLCMediaList *playList;
@property (nonatomic, strong) VLCMediaPlayer *player;

@end

@implementation ViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.view.layer setBackgroundColor:[NSColor.clearColor CGColor]];
    self.tableView.backgroundColor = NSColor.clearColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.doubleAction = @selector(doubleClick:);
        
    NSRect rect = NSMakeRect(0, 0, 0, 0);
    rect.size = _customView.frame.size;

    _videoView = [[VLCVideoView alloc] initWithFrame:rect];
    _videoView.backColor = NSColor.clearColor;
    [_customView addSubview:_videoView];
    _videoView.autoresizingMask = NSViewHeightSizable | NSViewWidthSizable;
    _videoView.fillScreen = YES;
    
    [VLCLibrary sharedLibrary];
    
    _playList = [[VLCMediaList alloc] init];
    _player = [[VLCMediaPlayer alloc] initWithVideoView:_videoView];

    for(TVModel *model in self.listArr) {
        VLCMedia *media = [VLCMedia mediaWithURL:[NSURL URLWithString:model.tvPath]];
        [_playList addMedia:media];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterFull:)
                                                 name:NSWindowWillEnterFullScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willExitFull:)
                                                 name:NSWindowWillExitFullScreenNotification
                                               object:nil];
}

- (void)viewDidDisappear {
    [super viewDidDisappear];
    
    [self.player setMedia:nil];
}

- (void)viewDidLayout {
    [super viewDidLayout];
    self.videoView.frame = self.customView.bounds;
}

- (void)doubleClick:(NSTableView *)tableView {
    self.videoView.frame = self.customView.bounds;
    
    NSInteger selectedRow = tableView.selectedRow;
    [self play:selectedRow];
}

- (void)play:(NSInteger)index {
    [self.player setMedia:[self.playList mediaAtIndex:index]];
    if(!self.player.isPlaying && self.playList.count > 0) {
        [self.player play];
    }
}

#pragma mark - noti
- (void)willEnterFull:(NSNotification *)noti {
    self.tableviewWidthConstraint.constant = 0;
}

- (void)willExitFull:(NSNotification *)noti {
    self.tableviewWidthConstraint.constant = 150;
}

#pragma mark -
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.listArr.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *view = [tableView makeViewWithIdentifier:@"cell" owner:self];
    view.textField.stringValue = self.listArr[row].tvName;
    return view;
}

#pragma mark -
- (NSArray *)listArr {
    if(!_listArr) {
        _listArr = [TVModel allModels];
    }
    return _listArr;
}

@end
