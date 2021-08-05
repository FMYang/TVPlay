/*
 * Copyright (C) 2013-2015 Bilibili
 * Copyright (C) 2013-2015 Zhang Rui <bbcallen@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "IJKMoviePlayerViewController.h"
#import <Masonry/Masonry.h>
#import "TVClockView.h"

@interface IJKVideoViewController()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) UIView *controlView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *clockButton;
@property (nonatomic, assign) BOOL isShowControlView;
@property (nonatomic, strong) TVClockView *clockView;

// 定时关闭时间（默认30min）
@property (nonatomic, assign) NSInteger closeTime;

@end

@implementation IJKVideoViewController

- (UIActivityIndicatorView *)indicatorView {
    if(!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        _indicatorView.color = UIColor.whiteColor;
    }
    return _indicatorView;
}

- (void)dealloc
{
}

+ (void)presentFromViewController:(UIViewController *)viewController withTitle:(NSString *)title URL:(NSURL *)url completion:(void (^)())completion {
    
    IJKVideoViewController *vc = [[IJKVideoViewController alloc] initWithURL:url];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [viewController presentViewController:vc animated:YES completion:completion];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define EXPECTED_IJKPLAYER_VERSION (1 << 16) & 0xFF) | 
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    // Do any additional setup after loading the view from its nib.

//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:NO];

#ifdef DEBUG
    [IJKFFMoviePlayerController setLogReport:YES];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif

    [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];

    IJKFFOptions *options = [IJKFFOptions optionsByDefault];

//    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.url withOptions:options];
//    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//    self.player.view.frame = self.view.bounds;
//    self.player.view.backgroundColor = UIColor.blackColor;
//    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
//    self.player.shouldAutoplay = YES;

    self.view.autoresizesSubviews = YES;
    [self.view addSubview:self.player.view];
        
    [self.view addSubview:self.indicatorView];
    [self.indicatorView startAnimating];
    
    [self setupUI];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.view addGestureRecognizer:tapGes];
}

- (void)tapAction {
    self.isShowControlView = !self.isShowControlView;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:2.0];
}

- (void)hideControlView {
    self.isShowControlView = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.indicatorView.center = self.view.center;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self installMovieNotificationObservers];

    [self.player prepareToPlay];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.player shutdown];
    [self removeMovieNotificationObservers];
}

- (BOOL)shouldAutorotate {
    return UIInterfaceOrientationIsLandscape(UIDevice.currentDevice.orientation);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started

    IJKMPMovieLoadState loadState = _player.loadState;

    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicatorView stopAnimating];
        });
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicatorView startAnimating];
        });
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];

    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;

        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;

        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;

        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    //    MPMoviePlaybackStateStopped,
    //    MPMoviePlaybackStatePlaying,
    //    MPMoviePlaybackStatePaused,
    //    MPMoviePlaybackStateInterrupted,
    //    MPMoviePlaybackStateSeekingForward,
    //    MPMoviePlaybackStateSeekingBackward

    switch (_player.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

#pragma mark Install Movie Notifications

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
}

#pragma mark - UI
- (void)setupUI {
    UIEdgeInsets safeAreaInsets = [[UIApplication sharedApplication].keyWindow safeAreaInsets];
    
    [self.view addSubview:self.controlView];
    [self.controlView addSubview:self.closeButton];
    [self.controlView addSubview:self.clockButton];
    [self.view addSubview:self.clockView];
    
    [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(safeAreaInsets.top);
        make.top.equalTo(self.controlView);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(44);
    }];
    
    [self.clockButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.controlView);
        make.right.equalTo(self.controlView.mas_right).offset(-safeAreaInsets.bottom);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(44);
    }];
    
    [self.clockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.right.equalTo(self.view.mas_right).offset(-200);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
}

#pragma mark - action
- (void)closeAction {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)clockAction {
    NSLog(@"fm 开启定时关闭，30s后退出");
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(exitApp) withObject:nil afterDelay:30*60];
}

- (void)exitApp {
    NSLog(@"fm 定时关闭啦😋");
    exit(0);
}

- (void)setIsShowControlView:(BOOL)isShowControlView {
    _isShowControlView = isShowControlView;
    self.controlView.hidden = !isShowControlView;
}

#pragma mark - getter
- (UIView *)controlView {
    if(!_controlView) {
        _controlView = [[UIView alloc] init];
        _controlView.hidden = YES;
    }
    return _controlView;
}

- (UIButton *)closeButton {
    if(!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setTitle:@"close" forState:UIControlStateNormal];
        [_closeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIButton *)clockButton {
    if(!_clockButton) {
        _clockButton = [[UIButton alloc] init];
        _clockButton.titleLabel.textAlignment = NSTextAlignmentRight;
        [_clockButton setTitle:@"定时关闭" forState:UIControlStateNormal];
        [_clockButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_clockButton addTarget:self action:@selector(clockAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clockButton;
}

- (TVClockView *)clockView {
    if(!_clockView) {
        _clockView = [[TVClockView alloc] init];
    }
    return _clockView;
}

@end
