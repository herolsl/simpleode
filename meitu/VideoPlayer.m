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

#define VS_BAR_HEIGHT       44

#import "VideoPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "VideoSlider.h"

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

@end

@implementation VideoPlayer

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self creatInitialUI];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        [self addGestureRecognizer:tap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)creatInitialUI {
    
    self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, VS_HEIGHT-VS_BAR_HEIGHT, VS_WIDTH, VS_BAR_HEIGHT)];
    self.bottomBar.backgroundColor = [UIColor blueColor];
    self.bottomBar.hidden = NO;
    [self addSubview:self.bottomBar];
    
    UIButton *play = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    play.backgroundColor = [UIColor redColor];
    [self.bottomBar addSubview:play];

    UIButton *next = [[UIButton alloc] initWithFrame:CGRectMake(40, 0, 35, 35)];
    next.backgroundColor = [UIColor redColor];
    [self.bottomBar addSubview:next];
    
    self.videoSlider = [[VideoSlider alloc] initWithFrame:CGRectMake(80, 0, VS_WIDTH-100, 35)];
    [self.videoSlider addTarget:self action:@selector(printLog:) forControlEvents:UIControlEventValueChanged];
    [self.bottomBar addSubview:self.videoSlider];
}

- (void)printLog:(VideoSlider *)sender {
    NSLog(@"value is %@", @(sender.vsValue));
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

-(void)addProgressObserver{
    
    //get current playerItem object
//    AVPlayerItem *playerItem = self.player.currentItem;
//    //Set once per second
//    [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1f, NSEC_PER_SEC)  queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
//    }];
}

-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //network loading progress
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserverToPlayerItem:(AVPlayerItem *)playerItem {
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

/**
 *  通过KVO监控播放器状态
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
//        AVPlayerStatus st = self.player.status;
        AVPlayerItemStatus status = self.playerItem.status;
        NSLog(@"%@", @(status));
        NSLog(@"%@", @(CMTimeGetSeconds(playerItem.duration)));
        
        [self playPause];
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
//        NSArray *array = playerItem.loadedTimeRanges;
//        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
    }
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
