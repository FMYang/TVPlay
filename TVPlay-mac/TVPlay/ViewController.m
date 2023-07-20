//
//  ViewController.m
//  TVPlay
//
//  Created by yfm on 2021/5/24.
//

#import "ViewController.h"
#import <VLCKit/VLCKit.h>
#import "TVModel.h"

@interface ViewController() <NSTableViewDelegate, NSTableViewDataSource, VLCMediaPlayerDelegate>

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
    _customView.window.backgroundColor = NSColor.clearColor;
    _videoView.autoresizingMask = NSViewHeightSizable | NSViewWidthSizable;
    _videoView.fillScreen = YES;

    [VLCLibrary sharedLibrary];

    _playList = [[VLCMediaList alloc] init];
    _player = [[VLCMediaPlayer alloc] initWithVideoView:_videoView];
    _player.delegate = self;

    for(TVModel *model in self.listArr) {
        VLCMedia *media = [VLCMedia mediaWithURL:[NSURL URLWithString:model.url]];
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
    NSLog(@"row %ld", selectedRow);
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
    self.tableviewWidthConstraint.constant = 200;
}

#pragma mark -
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.listArr.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *view = [tableView makeViewWithIdentifier:@"cell" owner:self];
    view.textField.stringValue = self.listArr[row].title;
    return view;
}

#pragma mark -
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
    VLCMediaPlayer *player = aNotification.object;
    switch (player.state) {
        case VLCMediaPlayerStateStopped:
            NSLog(@"Stopped");
            break;
            
        case VLCMediaPlayerStateOpening:
            NSLog(@"Opening");
            break;
            
        case VLCMediaPlayerStateBuffering:
            NSLog(@"Buffering");
            break;
            
        case VLCMediaPlayerStateEnded:
            NSLog(@"Ended");
            break;
            
        case VLCMediaPlayerStateError:
            NSLog(@"Error");
            break;
            
        case VLCMediaPlayerStatePlaying:
            NSLog(@"Playing");
            break;
            
        case VLCMediaPlayerStatePaused:
            NSLog(@"Paused");
            break;
            
        case VLCMediaPlayerStateESAdded:
            NSLog(@"Added");
            break;
            
        default:
            break;
    }
}

#pragma mark -
- (NSArray *)listArr {
    if(!_listArr) {
        _listArr = [TVModel allModels];
    }
    return _listArr;
}

@end
