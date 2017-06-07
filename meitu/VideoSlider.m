//
//  VideoSlider.m
//  meitu
//
//  Created by Ivan Liu on 2017/6/6.
//  Copyright © 2017年 Sven Liu. All rights reserved.
//

#define POSITION_X      CGRectGetMinX(self.frame)
#define POSITION_Y      CGRectGetMinY(self.frame)
#define VS_WIDTH        CGRectGetWidth(self.frame)
#define VS_HEIGHT       CGRectGetHeight(self.frame)

#define LINE_HEIGHT     2
#define BUTTON_HEIGHT   26

#import "VideoSlider.h"

@interface VideoSlider()

// 进度条背景
@property (nonatomic, strong) UIView *sliderBottom;
// 未滑动进度条
@property (nonatomic, strong) UIImageView *sliderMid;
// 已滑动进度条
@property (nonatomic, strong) UIImageView *sliderAbove;
// 滑动按钮
@property (nonatomic, strong) UIView *sliderButton;

@end

@implementation VideoSlider

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self creatStartUI];
    }
    return self;
}

- (void)creatStartUI {
    self.sliderBottom = [[UIView alloc] init];
    self.sliderBottom.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:self.sliderBottom];
    
    self.sliderMid = [[UIImageView alloc] init];
    self.sliderMid.backgroundColor = [UIColor blueColor];
    [self addSubview:self.sliderMid];
    
    self.sliderAbove = [[UIImageView alloc] init];
    self.sliderAbove.backgroundColor = [UIColor redColor];
    [self addSubview:self.sliderAbove];
    
    self.sliderButton = [[UIView alloc] init];
    self.sliderButton.backgroundColor = [UIColor brownColor];
    [self addSubview:self.sliderButton];
    
    [self addValueObserve];
}

- (void)addValueObserve {
    [self addObserver:self forKeyPath:@"vsValue" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"vsLoadingValue" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"vsValue"] || [keyPath isEqualToString:@"vsLoadingValue"]) {
        if (self.vsValue > 1) {
            self.vsValue = 1.0f;
        } else if (self.vsValue < 0 ) {
            self.vsValue = 0.f;
        }
        self.vsLoadingValue = self.vsValue + 0.2;
        [self setNeedsLayout];
    }
}

#pragma mark - layoutSubviews
- (void)layoutSubviews {
    
    [super layoutSubviews];
    CGRect frame = self.frame;
    if (CGRectGetHeight(frame) <= 30) {
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 30);
    }
    
    [self.sliderBottom setFrame:CGRectMake(self.vsValue*VS_WIDTH, VS_HEIGHT/2-LINE_HEIGHT, (1-self.vsValue)*VS_WIDTH, LINE_HEIGHT)];
    self.sliderBottom.layer.cornerRadius = LINE_HEIGHT/2;
    if (self.vsLoadingValue > 1) {
        self.vsLoadingValue = 1.0f;
    }
    [self.sliderMid setFrame:CGRectMake(self.vsValue*VS_WIDTH, VS_HEIGHT/2-LINE_HEIGHT, (self.vsLoadingValue-self.vsValue)*VS_WIDTH, LINE_HEIGHT)];
    
    [self.sliderAbove setFrame:CGRectMake(0, VS_HEIGHT/2-LINE_HEIGHT, self.vsValue*VS_WIDTH, LINE_HEIGHT)];
    self.sliderAbove.layer.cornerRadius = LINE_HEIGHT/2;

    CGFloat btnCenterX;
    [self.sliderButton setFrame:CGRectMake(0, 0, BUTTON_HEIGHT, BUTTON_HEIGHT)];
    if (self.vsValue*VS_WIDTH-BUTTON_HEIGHT/2 < 0) {
        btnCenterX = BUTTON_HEIGHT/2;
    } else if ((self.vsValue*VS_WIDTH+BUTTON_HEIGHT/2) > VS_WIDTH) {
        btnCenterX = VS_WIDTH;
    } else {
        btnCenterX = self.vsValue*VS_WIDTH;
    }
    [self.sliderButton setCenter:CGPointMake(btnCenterX, VS_HEIGHT/2)];
    self.sliderButton.layer.cornerRadius = BUTTON_HEIGHT/2;
}

#pragma mark - touch event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    self.vsValue = [touch locationInView:self].x/VS_WIDTH;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSArray *MovePointArray = [touches allObjects];
    self.vsValue = [[MovePointArray objectAtIndex:0] locationInView:self].x/VS_WIDTH;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

}

#pragma mark - dealloc
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"vsValue"];
    [self removeObserver:self forKeyPath:@"vsLoadingValue"];
}

@end
