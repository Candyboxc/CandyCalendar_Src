//
//  ViewController.h
//  Calender_bycandy
//
//  Created by candy on 2015/3/27.
//  Copyright (c) 2015年 candy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleMobileAds/GADBannerView.h"

@interface ViewController : UIViewController<UICollectionViewDataSource,UIScrollViewDelegate>{
    GADBannerView *bannerView_; //廣告用
}
@property (strong, nonatomic) UIDatePicker *datePicker,*datePicker2;
-(void)SaveEventWithFullDic:(NSDictionary*)eventDic;
@end

