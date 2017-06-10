//
//  VideoSlider.m
//  meitu
//
//  Created by Ivan Liu on 2017/6/6.
//  Copyright © 2017年 Sven Liu. All rights reserved.
//

#define POSITION_X      self.frame.origin.x
#define POSITION_Y      self.frame.origin.y
#define VS_WIDTH        self.frame.size.width
#define VS_HEIGHT       self.frame.size.height

#define LINE_HEIGHT     2
#define BUTTON_HEIGHT   28

#import "VideoSlider.h"

@interface VideoSlider()

// 进度条背景
@property(nonatomic, strong) UIView *sliderBottom;
// 未滑动进度条
@property(nonatomic, strong) UIImageView *sliderMid;
// 已滑动进度条
@property(nonatomic, strong) UIImageView *sliderAbove;
// 滑动按钮
@property(nonatomic, strong) UIImageView *sliderButtonBack;
@property(nonatomic, strong) UIImageView *sliderButton;

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
    [self addSubview:self.sliderBottom];
    
    self.sliderMid = [[UIImageView alloc] init];
    [self addSubview:self.sliderMid];
    
    self.sliderAbove = [[UIImageView alloc] init];
    [self addSubview:self.sliderAbove];
    
    self.sliderButton = [[UIImageView alloc] init];
    self.sliderButton.userInteractionEnabled = YES;
    self.sliderButton.layer.shadowOffset = CGSizeMake(0, 3);
    self.sliderButton.layer.shadowRadius = 3;
    self.sliderButton.layer.shadowOpacity = 0.4f;
    self.sliderButton.layer.shadowColor = [UIColor blackColor].CGColor;
    [self addSubview:self.sliderButton];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sliderValueChange:)];
    [self.sliderButton addGestureRecognizer:pan];

//    self.sliderButtonBack = [[UIImageView alloc] init];
//    self.sliderButtonBack.image = [UIImage imageNamed:@"timg.jpg"];
//    [self.sliderButtonBack setFrame:CGRectMake(0, 0, BUTTON_HEIGHT*2, BUTTON_HEIGHT*1.5)];
//    self.sliderButtonBack.center = CGPointMake(BUTTON_HEIGHT/2, BUTTON_HEIGHT/2);
//    self.sliderButtonBack.backgroundColor = [UIColor clearColor];
//    [self.sliderButton addSubview:self.sliderButtonBack];
    
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
        
        if (self.vsLoadingValue > 1) {
            self.vsLoadingValue = 1.0f;
        }

        [self setNeedsLayout];
    }
}

#pragma mark - setMethods
- (void)setMaxProgressColor:(UIColor *)maxProgressColor {
    _maxProgressColor = maxProgressColor;
    [self setNeedsDisplay];
}

- (void)setCurrentProgressColor:(UIColor *)currentProgressColor {
    _currentProgressColor = currentProgressColor;
    [self setNeedsDisplay];
}

- (void)setBufferProgressColor:(UIColor *)bufferProgressColor {
    _bufferProgressColor = bufferProgressColor;
    [self setNeedsDisplay];
}

- (void)setThumbColor:(UIColor *)thumbColor {
    _thumbColor = thumbColor;
    [self setNeedsDisplay];
}

#pragma mark - layoutSubviews
- (void)layoutSubviews {
    
    [super layoutSubviews];
    CGRect frame = self.frame;
    if (CGRectGetHeight(frame) <= 30) {
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 30);
    }
    
    [self.sliderBottom setFrame:CGRectMake(self.vsValue*VS_WIDTH, VS_HEIGHT/2-LINE_HEIGHT, (1-self.vsValue)*VS_WIDTH, LINE_HEIGHT)];
    self.sliderBottom.backgroundColor = self.maxProgressColor ? :[UIColor lightGrayColor];
    self.sliderBottom.layer.cornerRadius = LINE_HEIGHT/2;
    
    CGFloat midWidth = 0;
    if ((self.vsLoadingValue-self.vsValue)*VS_WIDTH-BUTTON_HEIGHT/2 > 0) {
        midWidth = (self.vsLoadingValue-self.vsValue)*VS_WIDTH-BUTTON_HEIGHT/2;
    }
    [self.sliderMid setFrame:CGRectMake(self.vsValue*VS_WIDTH+BUTTON_HEIGHT/2, VS_HEIGHT/2-LINE_HEIGHT, midWidth, LINE_HEIGHT)];
    self.sliderMid.backgroundColor = self.bufferProgressColor ? :[UIColor darkGrayColor];
    
    [self.sliderAbove setFrame:CGRectMake(0, VS_HEIGHT/2-LINE_HEIGHT, self.vsValue*VS_WIDTH, LINE_HEIGHT)];
    self.sliderAbove.backgroundColor = self.currentProgressColor ? :[UIColor blueColor];
    self.sliderAbove.layer.cornerRadius = LINE_HEIGHT/2;

    CGFloat btnCenterX;
    if (self.vsValue*VS_WIDTH-BUTTON_HEIGHT/2 < 0) {
        btnCenterX = BUTTON_HEIGHT/2;
    } else if ((self.vsValue*VS_WIDTH+BUTTON_HEIGHT/2) > VS_WIDTH) {
        btnCenterX = VS_WIDTH-BUTTON_HEIGHT/2;
    } else {
        btnCenterX = self.vsValue*VS_WIDTH;
    }
    [self.sliderButton setFrame:CGRectMake(0, 0, BUTTON_HEIGHT, BUTTON_HEIGHT)];
    [self.sliderButton setCenter:CGPointMake(btnCenterX, VS_HEIGHT/2)];
    self.sliderButton.backgroundColor = self.thumbColor ? :[UIColor whiteColor];
    self.sliderButton.layer.cornerRadius = BUTTON_HEIGHT/2;
}

#pragma mark - gestureRecognizer
- (void)sliderValueChange:(UIGestureRecognizer *)gesture {
    self.vsValue = [gesture locationInView:self].x/VS_WIDTH;
    
//    NSSet *tar = [self allTargets];
//    NSEnumerator *em = [tar objectEnumerator];
//    id target;
//    while (target = [em nextObject]) {
//        id tarr = [tar anyObject];
//        NSArray *arr = [self actionsForTarget:tarr forControlEvent:UIControlEventValueChanged];
//        [tarr performSelector:NSSelectorFromString(arr[0])];
//        NSLog(@"action is %@", arr);
//    }
//    
//    NSLog(@"event is %@", @(self.allControlEvents));
//    NSLog(@"%@", self.allTargets);
}

#pragma mark - dealloc
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"vsValue"];
    [self removeObserver:self forKeyPath:@"vsLoadingValue"];
}

#pragma mark - super methods
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event {
    NSLog(@"begin state=[%zd]", self.state);
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event {
    NSLog(@"continue state=[%zd]", self.state);
    self.vsValue = [touch locationInView:self].x/VS_WIDTH;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

// 当点击屏幕释放时，调用该方法
- (void)endTrackingWithTouch:(nullable UITouch *)touch withEvent:(nullable UIEvent *)event {
    NSLog(@"end state=[%zd]", self.state);
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [super endTrackingWithTouch:touch withEvent:event];  // 系统默认处理
}

// 取消时会调用，如果当前视图被移除。或者来电
- (void)cancelTrackingWithEvent:(nullable UIEvent *)event {
    NSLog(@"cancel state=[%zd]", self.state);
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [super cancelTrackingWithEvent:event];  // 系统默认处理
}

@end
