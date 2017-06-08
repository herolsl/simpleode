//
//  FingerDrawLine.h
//  meitu
//
//  Created by Ivan Liu on 2017/6/5.
//  Copyright © 2017年 Sven Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FingerDrawLine : UIView

//所有的线条信息，包含了颜色，坐标和粗细信息 @see DrawPaletteLineInfo
@property(nonatomic, strong) NSMutableArray  *allDrawLineInfos;
//从外部传递的 笔刷长度和宽度，在包含画板的VC中 要是颜色、粗细有所改变 都应该将对应的值传进来
@property(nonatomic, strong) UIColor *currentPaintColor;
@property(nonatomic)float currentPaintWidth;

//外部调用的清空画板和撤销上一步
- (void)cleanAllDrawBySelf;//清空画板
- (void)cleanFinallyDraw;//撤销上一条线条

@end
