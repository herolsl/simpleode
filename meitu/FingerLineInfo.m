//
//  FingerLineInfo.m
//  meitu
//
//  Created by Ivan Liu on 2017/6/5.
//  Copyright © 2017年 Sven Liu. All rights reserved.
//

#import "FingerLineInfo.h"

@implementation FingerLineInfo

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.linePoints = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

@end
