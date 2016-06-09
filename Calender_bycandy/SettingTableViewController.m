//
//  SettingTableViewController.m
//  Calender_bycandy
//
//  Created by Man Man Yang on 2015/5/12.
//  Copyright (c) 2015年 candy. All rights reserved.
//

#import "SettingTableViewController.h"
#import "myDB.h"

@interface SettingTableViewController ()

@property (weak, nonatomic) IBOutlet UIStepper *myClassSetStepper;
@property (weak, nonatomic) IBOutlet UIStepper *myClassStartTimeStepper;

@property (strong, nonatomic) IBOutlet UITableView *SettingTableView;
@property (weak, nonatomic) IBOutlet UITextField *myClassSettingLabel;
@property (weak, nonatomic) IBOutlet UITextField *myClassStartTimeLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *StartDayChooseSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *ScheduleShowChooseSegment;
@property (weak, nonatomic) IBOutlet UISwitch *pushNotificationSwitch;

@end

@implementation SettingTableViewController

- (IBAction)ClassSettingAction:(id)sender {
    
    //設定課堂數
    [_myClassSettingLabel setText:[NSString stringWithFormat:@"%0.f",_myClassSetStepper.value]];
    [[myDB sharedInstance].settingDict setObject:_myClassSettingLabel.text forKey:@"classNumber"];
    [self valueChange];
}

- (IBAction)StartTimeSettingAction:(id)sender {
    
    //設定起始時間
    [self.myClassStartTimeLabel setText:[NSString stringWithFormat:@"%0.f",self.myClassStartTimeStepper.value]];
    [[myDB sharedInstance].settingDict setObject:_myClassStartTimeLabel.text forKey:@"weekBeginTime"];
    [self valueChange];
}

- (IBAction)pushNotificationSettingAction:(id)sender {
    if (_pushNotificationSwitch.isOn) {
        [[myDB sharedInstance].settingDict setObject:@"YES" forKey:@"pushNotification"];
        NSArray *eventsArray = [[myDB sharedInstance] querySecheduleFromYear:@"2015" ToYear:@"2100"];
//        NSLog(@"eventsArraycount = %lu",(unsigned long)eventsArray.count);
        for (NSDictionary *d in eventsArray) {
            if (d[@"alarm_type"] != [NSNull null] && [d[@"alarm_type"]intValue] > [[NSDate date]timeIntervalSince1970] ) {
//                NSLog(@"%@",d[@"alarm_type"]);
                NSDate *pushDate = [NSDate dateWithTimeIntervalSince1970:[d[@"alarm_type"]intValue]];
//                NSLog(@"%@",pushDate.description);
                UILocalNotification *localNotif = [UILocalNotification new];
                localNotif.fireDate = pushDate;
                localNotif.timeZone = [NSTimeZone defaultTimeZone];
                NSDateFormatter *formatter = [NSDateFormatter new];
                [formatter setDateFormat:@"HH:mm"];//date的格式
                localNotif.alertBody = d[@"memo"];
                NSDictionary *info = [[NSDictionary alloc]initWithObjectsAndKeys: d[@"id"],@"uid", nil];
                localNotif.userInfo = info;
                localNotif.soundName = UILocalNotificationDefaultSoundName;
                localNotif.applicationIconBadgeNumber = 0;
                [[UIApplication sharedApplication]scheduleLocalNotification:localNotif];
                NSLog(@"uid=%@",localNotif.userInfo[@"uid"]);
                //設定推播
            }
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            NSLog(@"push的數量%lu",(unsigned long)[[UIApplication sharedApplication]scheduledLocalNotifications].count);
        });
    }else{
        [[myDB sharedInstance].settingDict setObject:@"NO" forKey:@"pushNotification"];
        [[UIApplication sharedApplication]cancelAllLocalNotifications];//將所有PUSH取消
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            NSLog(@"push的數量%lu",(unsigned long)[[UIApplication sharedApplication]scheduledLocalNotifications].count);
        });
    }
    [self valueChange];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //設定stepper大小
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;

    if (screenSize.height < 600.0f)
    {
        // iPhone 5 以下機種
        
        CGAffineTransform smallStartTimeStepper = CGAffineTransformMakeScale(0.76, 0.76);
        [self.myClassStartTimeStepper setTransform:smallStartTimeStepper];
        
        CGAffineTransform smallClassSetStepper = CGAffineTransformMakeScale(0.76, 0.76);
        [self.myClassSetStepper setTransform:smallClassSetStepper];
        
        CGAffineTransform smallPushNotificationSwitch = CGAffineTransformMakeScale(0.84, 0.84);
        [self.pushNotificationSwitch setTransform:smallPushNotificationSwitch];
        
//        NSLog(@"iPhone 5 以下機種");
    }
    else if (screenSize.height > 601.0f)
    {
        // iPhone 6 以上機種
        
        CGAffineTransform smallStartTimeStepper = CGAffineTransformMakeScale(0.85, 0.85);
        [self.myClassStartTimeStepper setTransform:smallStartTimeStepper];
        
        CGAffineTransform smallClassSetStepper = CGAffineTransformMakeScale(0.85, 0.85);
        [self.myClassSetStepper setTransform:smallClassSetStepper];
        
        CGAffineTransform smallPushNotificationSwitch = CGAffineTransformMakeScale(0.92, 0.92);
        [self.pushNotificationSwitch setTransform:smallPushNotificationSwitch];
        
//        NSLog(@"iPhone 6 以上機種");
    }
    
    //保留推播通知Switch開關
    if ([[myDB sharedInstance].settingDict[@"pushNotification"] isEqualToString:@"YES"]) {
        _pushNotificationSwitch.on = YES;
    }else{
        _pushNotificationSwitch.on = NO;
    }
    
    //設定課堂數
    _myClassSetStepper.value = [[myDB sharedInstance].settingDict[@"classNumber"]doubleValue];
    [_myClassSettingLabel setText:[NSString stringWithFormat:@"%0.f",_myClassSetStepper.value]];
    
    
    //設定起始時間
    _myClassStartTimeStepper.value = [[myDB sharedInstance].settingDict[@"weekBeginTime"]doubleValue];
    [self.myClassStartTimeLabel setText:[NSString stringWithFormat:@"%0.f",self.myClassStartTimeStepper.value]];
    
    
    //一週起始日
    [self.StartDayChooseSegment setImage:[UIImage imageNamed:@"Setting_週日.png"] forSegmentAtIndex:0];
    [self.StartDayChooseSegment setImage:[UIImage imageNamed:@"Setting_週一.png"] forSegmentAtIndex:1];
    
    //課表顯示
    [self.ScheduleShowChooseSegment setImage:[UIImage imageNamed:@"Setting_一至五.png"] forSegmentAtIndex:0];
    [self.ScheduleShowChooseSegment setImage:[UIImage imageNamed:@"Setting_一至日.png"] forSegmentAtIndex:1];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        //選擇type
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //設定Setting項目row高度
    CGSize SettingRowSize = CGSizeMake(self.tableView.frame.size.width, (self.tableView.frame.size.height+2)/4);
    return SettingRowSize.height;
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 
 ScheduleTimeTableViewController *tvc = segue.destinationViewController;
 tvc.scheduleTimeSelect = _scheduleTimeSelect;
 
 NSLog(@"scheduleTimeSelect:%0d",_scheduleTimeSelect);
 
 }
 */

-(void)valueChange{//存檔
    NSString *dbPath = [self GetDBPath];
    [[myDB sharedInstance].settingDict writeToFile:dbPath atomically:YES];
}

-(NSString *)GetDBPath{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask, YES);
    NSString *documentPath = [paths firstObject];
    NSString *dbPath = [documentPath stringByAppendingPathComponent:@"setting.plist"];
//    NSLog(@"dbPath=%@",dbPath);
    return dbPath;
}

@end
