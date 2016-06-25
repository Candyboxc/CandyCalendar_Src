//
//  TrashCanButton.m
//  Calender_bycandy
//
//  Created by Dong on 2016/6/24.
//  Copyright © 2016年 candy. All rights reserved.
//

#import "TrashCanButton.h"


@interface TrashCanButton()
{
    BOOL _isHover;
}

@end


@implementation TrashCanButton


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil) return self;
    
    // default
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"trashcan" ofType:@"png"]];
    
    [self addSubview:imageView];
    
    return self;
}

- (void)hoverIn
{
    if (_isHover == YES) return;
    
    _isHover = YES;
    
    CGAffineTransform transform = CGAffineTransformScale(self.transform,1.2,1.2);
    
    [UIView animateWithDuration:0.2 animations:^{
        //
        self.transform = transform;
    }];
    
}

- (void)hoverOut
{
    if (_isHover == NO) return;
    
    _isHover = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        //
        self.transform = CGAffineTransformIdentity;
    }];
}


@end
