//
//  PopTableViewController.h
//  Calender_bycandy
//
//  Created by Dong on 2015/6/10.
//  Copyright (c) 2015年 candy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController.h"

@interface PopTableViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *dateBtn;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong,nonatomic) NSDictionary *eventInfoDic;
@property (assign,nonatomic) NSInteger eventFlag;
@property (strong,nonatomic) TableViewController *parentVC;
@property (strong, nonatomic) UIPickerView *pushTimePicker;
@property (strong,nonatomic) NSString *type;
@end
