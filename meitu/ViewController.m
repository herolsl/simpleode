//
//  ViewController.m
//  
//
//  Created by Sven Liu on 17/1/17.
//  Copyright © 2017年 Sven Liu. All rights reserved.
//

#import "ViewController.h"
#import "FingerDrawLine.h"
#import "VideoPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "VideoSlider.h"

@interface ViewController ()
{
    UIImageView *inputImageView;
    UIImageView *outputImageView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    inputImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    inputImageView.contentMode = UIViewContentModeCenter;
    inputImageView.image = [UIImage imageNamed:@"timg.jpg"];
//    [self.view addSubview:inputImageView];
//    outputImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 220, 300, 200)];
//    outputImageView.contentMode = UIViewContentModeCenter;
//    [self.view addSubview:outputImageView];
    
//    [self addLineAct:nil];
//    [self changeImage:inputImageView.image];
    
//    NSString *playString = @"http://flv2.bn.netease.com/videolib3/1706/05/gudXO1209/SD/gudXO1209-mobile.mp4";
//    NSURL *url = [NSURL URLWithString:playString];
//    //设置播放的项目
//    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
//    //初始化player对象
//    AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:item];
//    //设置播放页面
//    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
//    //设置播放页面的大小
//    layer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300);
//    layer.backgroundColor = [UIColor cyanColor].CGColor;
//    //设置播放窗口和当前视图之间的比例显示内容
//    layer.videoGravity = AVLayerVideoGravityResizeAspect;
//    //添加播放视图到self.view
//    [self.view.layer addSublayer:layer];
//    AVPlayerItemStatus status = player.currentItem.status;
//    
//    [player play];
    
    UISlider *sysSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 200, self.view.frame.size.width-40, 20)];
    sysSlider.minimumTrackTintColor = [UIColor redColor];
    sysSlider.maximumTrackTintColor = [UIColor blackColor];
    sysSlider.thumbTintColor = [UIColor blueColor];
    [self.view addSubview:sysSlider];

    VideoSlider *slider = [[VideoSlider alloc] initWithFrame:CGRectMake(20, 400, self.view.frame.size.width-40, 80)];
    slider.maxProgressColor = [UIColor lightGrayColor];
    slider.bufferProgressColor = [UIColor darkGrayColor];
    slider.currentProgressColor = [UIColor blackColor];
    [self.view addSubview:slider];

//    VideoPlayer *player = [[VideoPlayer alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 250)];
//    player.videoURL = @"http://flv2.bn.netease.com/videolib3/1706/05/gudXO1209/SD/gudXO1209-mobile.mp4";
////    [player playPause];
//    [self.view addSubview:player];

}


- (void)addLineAct:(id)sender{
    NSLog(@"测试按钮");
    
    
    FingerDrawLine *touchdrawView = [[FingerDrawLine alloc]initWithFrame:inputImageView.frame];
    touchdrawView.currentPaintColor = [UIColor yellowColor];
    touchdrawView.currentPaintWidth = 5.0;
    [self.view addSubview:touchdrawView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)changeImage:(UIImage *)image {
    
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIVignetteEffect"];
    NSLog(@"%@",filter.attributes);
    
    [filter setValue:inputImage forKey:kCIInputImageKey];
    
//    [filter setValue:[CIColor colorWithRed:1.000 green:0.165 blue:0.176 alpha:1.000] forKey:kCIInputColorKey];
    CIImage *outImage = filter.outputImage;
    [self addFilterLinkerWithImage:outImage];
    
}

//再次添加滤镜  形成滤镜链
- (void)addFilterLinkerWithImage:(CIImage *)image{
    
//    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"];
//    [filter setValue:image forKey:kCIInputImageKey];
//    [filter setValue:@(0.5) forKey:kCIInputIntensityKey];
    
    //    在这里创建上下文  把滤镜和图片进行合并
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef resultImage = [context createCGImage:image fromRect:image.extent];
    outputImageView.image = [UIImage imageWithCGImage:resultImage];
    
}

@end
