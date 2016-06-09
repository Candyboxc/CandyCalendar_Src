//
//  PopViewController.h
//  Calender_bycandy
//
//  Created by Dong on 2015/6/8.
//  Copyright (c) 2015年 candy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"


@interface PopViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *dateBtn;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong,nonatomic) NSDictionary *eventInfoDic;
@property (strong,nonatomic) ViewController *parentVC;
@property (strong, nonatomic) UIPickerView *pushTimePicker;
@end
