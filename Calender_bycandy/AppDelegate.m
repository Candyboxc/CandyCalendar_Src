//
//  AppDelegate.m
//  Calender_bycandy
//
//  Created by candy on 2015/3/27.
//  Copyright (c) 2015年 candy. All rights reserved.
//

#import "AppDelegate.h"
#import "myDB.h"
#import <objc/runtime.h>
@import Firebase;


@interface AppDelegate (){
    
    NSDate *pushDate;
}
@end

@implementation AppDelegate

#pragma mark edit by Martin start:
- (NSString *)GetBundleFilePath:(NSString *)filename{
    //可讀取，不可寫入
    NSString *bundleResourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *dbPath = [bundleResourcePath stringByAppendingPathComponent:filename];
    return dbPath;
}

- (NSString *)GetDocumenFilePath:(NSString *)filename{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths firstObject];
    NSString *dbPath = [documentPath stringByAppendingPathComponent:filename];
    return dbPath;
}

-(void)CopyDBtoDocumentIfNeeded{
    //可讀寫 db:在Document 內的實際資料
    NSString *dbPath = [self GetDocumenFilePath:@"mycalendarDB.sqlite"];
    
    //發布安裝時，在套件Bundle的原始db（只可讀取）
    NSString *defaultDBPath = [self GetBundleFilePath:@"mycalendarDB.sqlite"];
    
    NSLog(@"\ndb:%@\ndefaultDB:%@",dbPath,defaultDBPath);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success;
    NSError *error;
    
    success = [fileManager fileExistsAtPath:dbPath]; //判斷db是否存在
    if (!success) {
        //copy
        success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        if (!success) {
            NSLog(@"Error:%@",[error localizedDescription]);
        }
    }else{
        /*
         異動 db/table資料結構
         1.連上db server 詢問db版本
         2.如果需要更新，alert問user
         3.user確定更新，下載新的db下來，並處理資料異動
         */
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [FIRApp configure];
    
    // Override point for customization after application launch.
    [self CopyDBtoDocumentIfNeeded];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:
        [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound
                                          categories:nil]];
    }
    UILocalNotification *localNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    
    if (localNotification){
        //[self callRefreshToNotifDate:localNotification.fireDate];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(callCallRefreshToNotifDate:) name:@"didFinishLaunchingWithOptions" object:nil];//設定點擊推播會進來的Observer
        pushDate=localNotification.fireDate;
        //NSLog(@"didFinishLaunchingWithOptions");
    }

    return YES;
}
#pragma mark edit by Martin end.

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    //app執行時，使用中
    //app在背景，沒有使用時，或點選了「橫幅」、「提醒」
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:notification.alertBody
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"查看", nil];
        [alertView show];
        
        objc_setAssociatedObject(alertView, @"key", notification.fireDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
    } else {
        [self callRefreshToNotifDate:notification.fireDate];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView firstOtherButtonIndex]){
        NSDate *associatedDate = objc_getAssociatedObject(alertView, @"key");
        [self callRefreshToNotifDate:associatedDate];
    }
}

-(void)callCallRefreshToNotifDate:(NSNotification *)notif{
    [self callRefreshToNotifDate:pushDate];
}

-(void)callRefreshToNotifDate:(NSDate *)date{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd"];//date的格式
    NSString *tmpNowTime = [formatter stringFromDate:date];//notif的時間
    NSInteger tmpNowSection =([[tmpNowTime substringToIndex:4]intValue] - [[myDB sharedInstance].topYear intValue])*12 + [[tmpNowTime substringWithRange:NSMakeRange(5, 2)]intValue] -1;
    NSInteger tmpNowRow =[[tmpNowTime substringFromIndex:8]intValue] -1;
    
    NSLog(@"callRefreshToNotifDate");
    
    
    [myDB sharedInstance].nowRow = [NSNumber numberWithInteger:tmpNowRow];
    [myDB sharedInstance].nowSection =[NSNumber numberWithInteger:tmpNowSection];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"REFRESHTONOTIFDATE" object:nil];
    
}
@end
