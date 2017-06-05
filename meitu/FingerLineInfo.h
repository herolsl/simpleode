//
//  FingerLineInfo.h
//  meitu
//
//  Created by Ivan Liu on 2017/6/5.
//  Copyright © 2017年 Sven Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FingerLineInfo : NSObject

@property (nonatomic, strong) NSMutableArray <__kindof NSValue *> *linePoints;//线条所包含的所有点
@property (nonatomic, strong) UIColor *lineColor;//线条的颜色
@property (nonatomic) float lineWidth;//线条的粗细

@end
