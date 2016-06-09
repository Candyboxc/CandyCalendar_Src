//
//  PicButton.m
//  Calender_bycandy
//
//  Created by Dong on 2015/4/5.
//  Copyright (c) 2015年 candy. All rights reserved.
//

#import "PicButton.h"

@implementation PicButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [[self superview] bringSubviewToFront:self];
    point = [[touches anyObject] locationInView:[[[[self superview]superview]superview]superview]];
    location = point;
    n=0;
//    NSLog(@"touchbegin");
    
    [self.delegate buttonBegin:self location:point];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    point = [[touches anyObject] locationInView:[[[[self superview]superview]superview]superview]];
    //    CGPoint location = point;
     [self.delegate buttonMove:self location:point];
//            [self.delegate buttonEnd:nil];
    
    
 
    
    
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    point= [[touches anyObject]locationInView:[[[self superview]superview]superview]];
    [self.delegate buttonEnd:self location:point];
}
@end
