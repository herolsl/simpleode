//
//  VideoSlider.h
//  meitu
//
//  Created by Ivan Liu on 2017/6/6.
//  Copyright © 2017年 Sven Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoSlider : UIControl

@property (nonatomic) CGFloat vsValue;
// 缓冲值
@property (nonatomic) CGFloat vsLoadingValue;

@end
