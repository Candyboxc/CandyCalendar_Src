//
//  TableViewController.h
//  Calender_bycandy
//
//  Created by candy on 2015/5/27.
//  Copyright (c) 2015年 candy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleMobileAds/GADBannerView.h"

@interface TableViewController : UIViewController{
    GADBannerView *bannerView_; //廣告用
}
@property (strong, nonatomic) UIDatePicker *datePicker,*datePicker2;
-(void)clearPopView;
-(void)SaveEventWithFullDic:(NSDictionary*)eventDic;
-(void)EditEventWithFullDic:(NSDictionary*)eventDic;
@end
