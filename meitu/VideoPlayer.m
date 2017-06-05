//
//  VideoPlayer.m
//  meitu
//
//  Created by Ivan Liu on 2017/6/5.
//  Copyright © 2017年 Sven Liu. All rights reserved.
//

#import "VideoPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface VideoPlayer()

@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;

@end

@implementation VideoPlayer

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playOrPause)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setVideoURL:(NSString *)videoURL {
    _videoURL = videoURL;
    [self.layer addSublayer:self.playerLayer];
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


-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //network loading progress
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

/**
 *  通过KVO监控播放器状态
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        NSLog(@"%@", @(status));
        NSLog(@"%@", @(CMTimeGetSeconds(playerItem.duration)));
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
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
        _player = [AVPlayer playerWithPlayerItem:self.playerItem];
        
        [self addObserverToPlayerItem:self.playerItem];
    }
    return _player;
}

- (AVPlayerItem *)playerItem {
    
    NSAssert(self.videoURL != nil, @"视频url不能为空!");

    if (!_playerItem) {
        if ([self.videoURL rangeOfString:@"http"].location == NSNotFound) {
            AVAsset *movieAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:self.videoURL] options:nil];
            _playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
        } else {
            _playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:[self.videoURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        }
    }
    return _playerItem;
}

#pragma mark - destory
- (void)destroyPlayer {
    
    [self.player pause];
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [self removeFromSuperview];
}

- (void)dealloc {
    
}


@end
