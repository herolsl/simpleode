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
    
    VideoPlayer *player = [[VideoPlayer alloc] initWithFrame:self.view.frame];
    player.videoURL = @"http://flv2.bn.netease.com/videolib3/1706/05/gudXO1209/SD/gudXO1209-mobile.mp4";
//    [player playPause];
    [self.view addSubview:player];

    
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
