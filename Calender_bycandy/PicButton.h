//
//  PicButton.h
//  Calender_bycandy
//
//  Created by Dong on 2015/4/5.
//  Copyright (c) 2015年 candy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PicButton;
@protocol buttonDelegate <NSObject>

@optional
- (void)buttonBegin:(PicButton *)pic location:(CGPoint)loc;
- (void)buttonMove:(PicButton *)pic location:(CGPoint)loc;
- (void)buttonEnd:(PicButton *)pic location:(CGPoint)loc;
@end

@interface PicButton : UIButton
{
    CGPoint point;
    CGPoint location;
    BOOL runStart;
    int n ;
}
#pragma mark by Martin edit start:
@property (nonatomic,strong) NSString *code;
#pragma mark by Martin edit end.
@property (nonatomic, weak) id<buttonDelegate> delegate;
@end
