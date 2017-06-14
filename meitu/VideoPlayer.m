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

@property(nonatomic, strong) UIView *bottomBar;
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
        self.currentProgress = 0.0f;
        [self creatInitialUI];
        
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
    
    UIButton *play = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    play.backgroundColor = [UIColor redColor];
    [self.bottomBar addSubview:play];

    UIButton *next = [[UIButton alloc] initWithFrame:CGRectMake(35, 0, 30, 30)];
    next.backgroundColor = [UIColor redColor];
    [self.bottomBar addSubview:next];
    
    self.videoSlider = [[VideoSlider alloc] initWithFrame:CGRectMake(70, 0, VS_WIDTH-190, 30)];
    [self.videoSlider addTarget:self
                         action:@selector(sliderAction:)
               forControlEvents:UIControlEventValueChanged];
    [self.bottomBar addSubview:self.videoSlider];
    
    self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(VS_WIDTH-110, 0, 70, 30)];
    self.progressLabel.textColor = [UIColor whiteColor];
    self.progressLabel.font = [UIFont systemFontOfSize:10.0f];
    [self.bottomBar addSubview:self.progressLabel];
    
    UIButton *fullScreen = [[UIButton alloc] initWithFrame:CGRectMake(VS_WIDTH-35, 0, 30, 30)];
    fullScreen.backgroundColor = [UIColor redColor];
    [self.bottomBar addSubview:fullScreen];
}

- (void)sliderAction:(VideoSlider *)sender {
    
    [self.player pause];
    if (sender.vsState == VideoSliderStateEnded) {
        CMTime currentCMTime = CMTimeMake(self.videoSlider.vsValue * self.vpDurtaion, 1);
        [self.player seekToTime:currentCMTime completionHandler:^(BOOL finished) {
            [self.player play];
        }];
    } else if (sender.vsState == VideoSliderStateChanging) {
        self.progressLabel.text = [NSString stringWithFormat:@"%@/%@",
                                   [self timeFormatted:sender.vsValue*self.vpDurtaion],
                                   [self timeFormatted:self.vpDurtaion]];
    }
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
//        btn.selected = YES;
        [self.player play];
    }else if(self.player.rate == 1.0f){    //playing
        [self.player pause];
//        btn.selected = NO;
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

- (void)panGestureAction:(UIPanGestureRecognizer *)sender {
    
    if (sender.state != UIGestureRecognizerStateChanged) {
        self.currentDirection = kPanGesturemMoveNone;
    } else {
        if (self.currentDirection == kPanGesturemMoveNone) {
            CGPoint transP = [sender translationInView:self];
            self.currentDirection = transP.x == 0 ? kPanGesturemMoveHorizontal:kPanGesturemMoveVertical;
        }
    }
    
//    NSLog(@"state is %@", @(self.currentDirection));
    BOOL isFullScreen = VS_WIDTH == [UIScreen mainScreen].bounds.size.width ? NO:YES;
    CGPoint touchPoint = [sender locationInView:self];
    CGPoint transPoint = [sender translationInView:self];
    
    if (isFullScreen) {
        if (self.currentDirection == kPanGesturemMoveHorizontal) {
            // 音量与亮度调节
            if (touchPoint.y < VS_HEIGHT/2) {
                [self brightnessChange:transPoint.y>0 ? 0.015:(-0.015)];
            } else {
                CGPoint transPoint = [sender translationInView:self];
                [self volumeChange:transPoint.y>0 ? 0.015:(-0.015)];
            }
        } else {
//            self.videoSlider.vsValue
        }
    } else {
        if (self.currentDirection == kPanGesturemMoveHorizontal) {
            // 音量与亮度调节
            if (touchPoint.x < VS_WIDTH/2) {
                [self brightnessChange:transPoint.y>0 ? 0.015:(-0.015)];
            } else {
                CGPoint transPoint = [sender translationInView:self];
                [self volumeChange:transPoint.y>0 ? 0.015:(-0.015)];
            }
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

-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    
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
}

/**
 *  通过KVO监控播放器状态
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        
        AVPlayerItemStatus status = self.playerItem.status;
        if(status == AVPlayerStatusReadyToPlay){
            self.vpDurtaion = CMTimeGetSeconds(playerItem.duration);
        }
        NSLog(@"%@", @(status));
        NSLog(@"%@", @(CMTimeGetSeconds(playerItem.duration)));
        [self playPause];
        
    } else if([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        NSArray *array = playerItem.loadedTimeRanges;
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
        [self.player play];
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
    
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self removeObserver:self forKeyPath:@"currentProgress"];
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
