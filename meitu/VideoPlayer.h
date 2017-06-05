//
//  VideoPlayer.h
//  meitu
//
//  Created by Ivan Liu on 2017/6/5.
//  Copyright © 2017年 Sven Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPlayer : UIView

@property (nonatomic, copy) NSString *videoURL;

- (void)playPause;

- (void)destroyPlayer;

@end
