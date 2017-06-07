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
        AVPlayerStatus st = self.player.status;
        AVPlayerItemStatus status = self.playerItem.status;
        NSLog(@"%@", @(status));
        NSLog(@"%@", @(CMTimeGetSeconds(playerItem.duration)));
        
        [self playPause];
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
        AVPlayerItem *playerItem = [self getAVPlayItem];
        self.playerItem = playerItem;
        _player = [AVPlayer playerWithPlayerItem:self.playerItem];
        
        [self addProgressObserver];
        [self addObserverToPlayerItem:self.playerItem];
        
        if (self.player.currentItem != self.playerItem) {
            [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
        }
    }
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


@end
