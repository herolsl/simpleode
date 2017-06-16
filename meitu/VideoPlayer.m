//
//  VideoPlayer.m
//  meitu
//
//  Created by Ivan Liu on 2017/6/5.
//  Copyright © 2017年 Sven Liu. All rights reserved.
//

#define POSITION_X      self.frame.origin.x
#define POSITION_Y      self.frame.origin.y
#define VS_WIDTH        self.frame.size.width
#define VS_HEIGHT       self.frame.size.height

#import "VideoPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "VideoSlider.h"

static const NSInteger VS_BAR_HEIGHT = 44;

typedef enum : NSUInteger {
    kPanGesturemMoveNone,
    kPanGesturemMoveHorizontal,
    kPanGesturemMoveVertical,
} PanGestureDirection;

@interface VideoPlayer()
<
    UIGestureRecognizerDelegate
>

@property(nonatomic) PanGestureDirection currentDirection;

@property(nonatomic, strong) AVPlayerLayer *playerLayer;
@property(nonatomic, strong) AVPlayerItem *playerItem;
@property(nonatomic, strong) AVPlayer *player;
@property(nonatomic) CGRect originalFrame;

@property(nonatomic, strong) UIView *bottomBar;
@property(nonatomic, strong) UIButton *playButton;
@property(nonatomic, strong) UIButton *next;
@property(nonatomic, strong) UIButton *fullScreen;
@property(nonatomic, strong) UILabel *progressLabel;
@property(nonatomic, strong) VideoSlider *videoSlider;

@property(nonatomic) CGFloat currentProgress;
@property(nonatomic) CGFloat vpDurtaion;

@end

@implementation VideoPlayer

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.originalFrame = frame;
        [self creatInitialUI];
        [self registerSystemNotigication];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(tapGestureAction:)];
        [self addGestureRecognizer:tap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(panGestureAction:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)creatInitialUI {
    
    self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, VS_HEIGHT-VS_BAR_HEIGHT, VS_WIDTH, VS_BAR_HEIGHT)];
    self.bottomBar.backgroundColor = [UIColor blueColor];
    self.bottomBar.hidden = NO;
    [self addSubview:self.bottomBar];
    
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.playButton setImage:[UIImage imageNamed:@"VideoPlayerResource.bundle/vp_play.png"]
                     forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"VideoPlayerResource.bundle/vp_pause.png"]
                     forState:UIControlStateSelected];
    self.playButton.center = CGPointMake(CGRectGetMidX(self.playButton.frame), VS_BAR_HEIGHT/2);
    [self.playButton addTarget:self action:@selector(playOrPause)
              forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:self.playButton];

    self.next = [[UIButton alloc] initWithFrame:CGRectMake(35, 0, 30, 30)];
    [self.next setImage:[UIImage imageNamed:@"VideoPlayerResource.bundle/vp_next.png"]
               forState:UIControlStateNormal];
    self.next.center = CGPointMake(CGRectGetMidX(self.next.frame), VS_BAR_HEIGHT/2);
    [self.bottomBar addSubview:self.next];
    
    self.videoSlider = [[VideoSlider alloc] initWithFrame:CGRectMake(70, 0, VS_WIDTH-190, 30)];
    [self.videoSlider addTarget:self
                         action:@selector(sliderAction:)
               forControlEvents:UIControlEventValueChanged];
    self.videoSlider.center = CGPointMake(CGRectGetMidX(self.videoSlider.frame), VS_BAR_HEIGHT/2);
    [self.bottomBar addSubview:self.videoSlider];
    
    self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(VS_WIDTH-110, 0, 70, 30)];
    self.progressLabel.textColor = [UIColor whiteColor];
    self.progressLabel.font = [UIFont systemFontOfSize:10.0f];
    self.progressLabel.center = CGPointMake(CGRectGetMidX(self.progressLabel.frame), VS_BAR_HEIGHT/2);
    [self.bottomBar addSubview:self.progressLabel];
    
    self.fullScreen = [[UIButton alloc] initWithFrame:CGRectMake(VS_WIDTH-35, 0, 30, 30)];
    [self.fullScreen setImage:[UIImage imageNamed:@"VideoPlayerResource.bundle/vp_maximize.png"]
                forState:UIControlStateNormal];
    [self.fullScreen setImage:[UIImage imageNamed:@"VideoPlayerResource.bundle/vp_minimize.png"]
                     forState:UIControlStateSelected];
    self.fullScreen.center = CGPointMake(CGRectGetMidX(self.fullScreen.frame), VS_BAR_HEIGHT/2);
    [self.fullScreen addTarget:self action:@selector(fullScreenButtonActon:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:self.fullScreen];
}


- (void)setVideoURL:(NSString *)videoURL {
    _videoURL = videoURL;
    [self.layer addSublayer:self.playerLayer];
    [self bringSubviewToFront:self.bottomBar];
}

- (void)playPause {
    [self playOrPause];
}

- (void)playOrPause {
    if(self.player.rate == 0.0){      //pause
        self.playButton.selected = YES;
        [self.player play];
    }else if(self.player.rate == 1.0f){    //playing
        [self.player pause];
        self.playButton.selected = NO;
    }
}

- (void)sliderAction:(VideoSlider *)sender {
    
    [self.player pause];
    if (sender.vsState == VideoSliderStateChanging) {
        self.progressLabel.text = [NSString stringWithFormat:@"%@/%@",
                                   [self timeFormatted:sender.vsValue*self.vpDurtaion],
                                   [self timeFormatted:self.vpDurtaion]];
    } else {
        CMTime currentCMTime = CMTimeMake(self.videoSlider.vsValue * self.vpDurtaion, 1);
        [self.player seekToTime:currentCMTime completionHandler:^(BOOL finished) {
            [self.player play];
        }];
    }
}

- (void)bottomBarAnimation {
    if (self.bottomBar.hidden) {
            self.bottomBar.hidden = NO;
            [UIView animateWithDuration:0.3f animations:^{
                self.bottomBar.layer.opacity = 1.0;
            }];
    } else {
            [UIView animateWithDuration:0.3f animations:^{
                self.bottomBar.layer.opacity = 0.f;
            } completion:^(BOOL finished) {
                self.bottomBar.hidden = YES;
            }];
    }
}

#pragma mark - System Notifications 
- (void)registerSystemNotigication {
    //screen orientation change
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fullScreenWithNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appwillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - Screen Orientation

- (void)fullScreenButtonActon:(UIButton *)sender {
    if (sender.selected) {
        [self backOriginalFrame];
    } else {
        [self fullScreenWithNotification:nil];
    }
}

- (void)fullScreenWithNotification:(NSNotification *)notification {
    
    NSInteger current = [[UIDevice currentDevice] orientation];
    if (current == UIDeviceOrientationFaceUp || current == UIDeviceOrientationFaceDown) {
        return;
    }

    if (!notification) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeRight] forKey:@"orientation"];
    }
    [self updateConstraintsIfNeeded];

    current = [[UIDevice currentDevice] orientation];
    NSLog(@"orientation is %@", @(current));
    [UIView animateWithDuration:0.3f animations:^{
        
        if (current != UIDeviceOrientationLandscapeLeft && current != UIDeviceOrientationLandscapeRight) {
            
            self.frame = self.originalFrame;
            self.playerLayer.frame = self.bounds;
        } else {
            
            self.frame = [UIScreen mainScreen].bounds;
            self.playerLayer.frame = self.frame;
        }
    } completion:^(BOOL finished) {
        
        self.fullScreen.selected = !CGRectEqualToRect(self.frame, self.originalFrame);
    }];
}

- (void)backOriginalFrame {
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    [self updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.frame = self.originalFrame;
        self.playerLayer.frame = self.bounds;
    } completion:^(BOOL finished) {
        
        self.fullScreen.selected = NO;
    }];
}

#pragma mark - system actions

- (void)brightnessChange:(CGFloat)value {
    CGFloat currentLight = [[UIScreen mainScreen] brightness];
    [[UIScreen mainScreen] setBrightness:currentLight+value];
}

- (void)volumeChange:(CGFloat)value {
    CGFloat currentVolume = [self getSystemVolumValue];
    [self setSysVolumWith:currentVolume + value];
}

#pragma mark - gesture recognizer

- (void)tapGestureAction:(UITapGestureRecognizer *)sender {
    [self bottomBarAnimation];
}

#warning 待优化
- (void)panGestureAction:(UIPanGestureRecognizer *)sender {
    
    if (sender.state != UIGestureRecognizerStateChanged) {
        self.currentDirection = kPanGesturemMoveNone;
    } else {
        if (self.currentDirection == kPanGesturemMoveNone) {
            CGPoint transP = [sender translationInView:self];
            self.currentDirection = transP.x == 0 ? kPanGesturemMoveHorizontal:kPanGesturemMoveVertical;
        }
    }
    
    BOOL isFullScreen = VS_WIDTH == [UIScreen mainScreen].bounds.size.width ? NO:YES;
    CGPoint touchPoint = [sender locationInView:self];
//    NSLog(@"touchPoint is x:%@,   y:%@", @(touchPoint.x), @(touchPoint.y));

    CGPoint transPoint = [sender translationInView:self];
    
    if (isFullScreen) {
        if (self.currentDirection == kPanGesturemMoveHorizontal) {
            // 音量与亮度调节
            if (touchPoint.y < VS_HEIGHT/2) {
//                [self brightnessChange:transPoint.y>0 ? 0.015:(-0.015)];
                [self brightnessChange:transPoint.x/VS_HEIGHT];
            } else {
//                CGPoint transPoint = [sender translationInView:self];
                [self volumeChange:transPoint.x/VS_HEIGHT];
            }
        } else {
            self.videoSlider.vsValue += transPoint.y/VS_WIDTH;
            [self sliderAction:self.videoSlider];
        }
    } else {
        if (self.currentDirection == kPanGesturemMoveHorizontal) {
            // 音量与亮度调节
            if (touchPoint.x < VS_WIDTH/2) {
                [self brightnessChange:transPoint.y/VS_HEIGHT];
            } else {
                NSLog(@"音量改变：%@", @(transPoint.y/VS_HEIGHT));
                [self volumeChange:transPoint.y/VS_HEIGHT];
            }
        } else {
            
            self.videoSlider.vsValue += transPoint.x/VS_WIDTH;
            [self sliderAction:self.videoSlider];
        }
    }
}

#pragma mark - observers

-(void)addProgressObserver {
    
    AVPlayerItem *playerItem = self.player.currentItem;
    __weak typeof(self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1f, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        __strong typeof(weakSelf)strongSelf = weakSelf;
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds([playerItem duration]);
        strongSelf.currentProgress = current/total;
        weakSelf.progressLabel.text = [NSString stringWithFormat:@"%@/%@",
                                       [weakSelf timeFormatted:current], [weakSelf timeFormatted:total]];
    }];
}

- (void)addObserverToPlayer:(AVPlayer *)player {
    [player addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserverToPlayer:(AVPlayer *)player {
    [player removeObserver:self forKeyPath:@"timeControlStatus"];
}

- (void)addObserverToPlayerItem:(AVPlayerItem *)playerItem {
    
    // 监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监控缓冲数据
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionOld context:nil];
    // 监控是否缓冲不足，会自动暂停播放
    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    // 监控缓冲足够播放
    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserverToPlayerItem:(AVPlayerItem *)playerItem {
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}

/**
 *  通过KVO监控播放器状态
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        
        AVPlayerItemStatus status = self.playerItem.status;
        if(status == AVPlayerStatusReadyToPlay){
            self.vpDurtaion = CMTimeGetSeconds(self.playerItem.duration);
        }
//        NSLog(@"%@", @(status));
//        NSLog(@"%@", @(CMTimeGetSeconds(playerItem.duration)));
        [self playPause];
        
    } else if([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        NSArray *array = self.playerItem.loadedTimeRanges;
        //本次缓冲时间范围
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        
        if (self.vpDurtaion) {
            CGFloat loadBuffer = (startSeconds + durationSeconds)/self.vpDurtaion;
            self.videoSlider.vsLoadingValue = loadBuffer;
            NSLog(@"缓冲数据： %@", @(loadBuffer));
        }
        
    } else if ([keyPath isEqualToString:@"currentProgress"]) {
        
        if (isnan(self.currentProgress)) {
            self.currentProgress = 0.0f;
        }
        self.videoSlider.vsValue = self.currentProgress;
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        //监听播放器在缓冲数据的状态
        NSLog(@"缓冲不足暂停了");
        
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        
        NSLog(@"缓冲达到可播放程度了");
        //由于 AVPlayer 缓存不足就会自动暂停，所以缓存充足了需要手动播放，才能继续播放
        if (self.playButton.selected) {
            [self.player play];
        }
    } else if ([keyPath isEqualToString:@"timeControlStatus"]) {
        // 播放器播放状态监控
        self.playButton.selected = (self.player.timeControlStatus != AVPlayerTimeControlStatusPaused);
    }
}

#pragma mark - timeFormat

- (NSString *)timeFormatted:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    if (minutes <= 0) {
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

#pragma mark - lazy loading

- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _playerLayer.backgroundColor = [UIColor blackColor].CGColor;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        _playerLayer.frame = self.bounds;
    }
    return _playerLayer;
}

- (AVPlayer *)player {
    if (!_player) {
        AVPlayerItem *playerItem = [self getAVPlayItem];
        self.playerItem = playerItem;
        _player = [AVPlayer playerWithPlayerItem:self.playerItem];
        
        [self addProgressObserver];
        [self addObserverToPlayerItem:self.playerItem];
        [self addObserverToPlayer:self.player];
        [self addObserver:self forKeyPath:@"currentProgress" options:NSKeyValueObservingOptionOld context:nil];
        
        if (self.player.currentItem != self.playerItem) {
            [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
        }
    }
    
    // 静音播放声音
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    [session setActive:YES error:nil];
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    return _player;
}

- (AVPlayerItem *)getAVPlayItem {
    
    NSAssert(self.videoURL != nil, @"视频url不能为空!");

    if ([self.videoURL rangeOfString:@"http"].location == NSNotFound) {
        AVAsset *movieAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:self.videoURL] options:nil];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
        return playerItem;
    } else {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:[self.videoURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        return playerItem;
    }
}

#pragma mark - destory
- (void)destroyPlayer {
    
    [self.player pause];
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [self removeFromSuperview];
}

- (void)dealloc {
    
    [self removeObserverToPlayerItem:self.playerItem];
    [self removeObserver:self forKeyPath:@"currentProgress"];
    [self removeObserverToPlayer:self.player];
}

#pragma mark - system volume

- (UISlider *)getSystemVolumSlider {
    static UISlider * volumeViewSlider = nil;
    if (volumeViewSlider == nil) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        
        for (UIView* newView in volumeView.subviews) {
            if ([newView.class.description isEqualToString:@"MPVolumeSlider"]){
                volumeViewSlider = (UISlider *)newView;
                break;
            }
        }
    }
    return volumeViewSlider;
}

/*
 *获取系统音量大小
 */
- (CGFloat) getSystemVolumValue {
    return [[self getSystemVolumSlider] value];
}
/*
 *设置系统音量大小
 */
- (void) setSysVolumWith:(double)value {
    [self getSystemVolumSlider].value = value;
}


@end
