//
//  FingerDrawLine.m
//  meitu
//
//  Created by Ivan Liu on 2017/6/5.
//  Copyright © 2017年 Sven Liu. All rights reserved.
//

#import "FingerDrawLine.h"
#import "FingerLineInfo.h"

@implementation FingerDrawLine

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        _allDrawLineInfos = [NSMutableArray arrayWithCapacity:10];
        self.currentPaintColor = [UIColor redColor];
        self.backgroundColor = [UIColor clearColor];
        self.currentPaintWidth =  4.0f;
    }
    return self;
}

#pragma mark - 
- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    if (_allDrawLineInfos.count) {
        for (int i = 0; i < [self.allDrawLineInfos count]; i++) {
            FingerLineInfo *info = self.allDrawLineInfos[i];
            
            CGContextBeginPath(context);
            CGPoint myStartPoint=[[info.linePoints objectAtIndex:0] CGPointValue];
            CGContextMoveToPoint(context, myStartPoint.x, myStartPoint.y);
            
            if (info.linePoints.count > 1) {
                for (int j = 0; j < [info.linePoints count]-1; j++) {
                    CGPoint myEndPoint = [[info.linePoints objectAtIndex:j+1] CGPointValue];
                    CGContextAddLineToPoint(context, myEndPoint.x,myEndPoint.y);
                }
            }else {
                CGContextAddLineToPoint(context, myStartPoint.x,myStartPoint.y);
            }
            CGContextSetStrokeColorWithColor(context, info.lineColor.CGColor);
            CGContextSetLineWidth(context, info.lineWidth+1);
            CGContextStrokePath(context);
        }
    }
}

#pragma mark - touch event
//触摸开始
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    [self drawPaletteTouchesBeganWithWidth:self.currentPaintWidth andColor:self.currentPaintColor andBeginPoint:[touch locationInView:self ]];
//    [self setNeedsDisplay];
}
//触摸移动
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSArray *MovePointArray = [touches allObjects];
    [self drawPaletteTouchesMovedWithPonit:[[MovePointArray objectAtIndex:0] locationInView:self]];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    // 排除点击操作
    if (self.allDrawLineInfos.count) {
        FingerLineInfo *info = [self.allDrawLineInfos lastObject];
        if (info.linePoints.count <= 1) {
            [self.allDrawLineInfos removeObject:info];
        }
    }
}


#pragma mark draw info edite event
//在触摸开始的时候 添加一条新的线条 并初始化
- (void)drawPaletteTouchesBeganWithWidth:(float)width andColor:(UIColor *)color andBeginPoint:(CGPoint)bPoint {
    FingerLineInfo *info = [FingerLineInfo new];
    info.lineColor = color;
    info.lineWidth = width;
    [info.linePoints addObject:[NSValue valueWithCGPoint:bPoint]];
    
    [self.allDrawLineInfos addObject:info];
}

//在触摸移动的时候 将现有的线条的最后一条的 point增加相应的触摸过的坐标
- (void)drawPaletteTouchesMovedWithPonit:(CGPoint)mPoint {
    FingerLineInfo *lastInfo = [self.allDrawLineInfos lastObject];
    [lastInfo.linePoints addObject:[NSValue valueWithCGPoint:mPoint]];
}

- (void)cleanAllDrawBySelf {
    if ([self.allDrawLineInfos count]>0)  {
        [self.allDrawLineInfos removeAllObjects];
        [self setNeedsDisplay];
    }
}

- (void)cleanFinallyDraw {
    if ([self.allDrawLineInfos count]>0) {
        [self.allDrawLineInfos  removeLastObject];
    }
    [self setNeedsDisplay];
}

@end
