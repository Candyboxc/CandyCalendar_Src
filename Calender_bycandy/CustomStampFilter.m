//
//  CustomStampFilter.m
//  Calender_bycandy
//
//  Created by Dong on 2016/6/24.
//  Copyright © 2016年 candy. All rights reserved.
//

#import "CustomStampFilter.h"
#import "myDB.h"


@implementation CustomStampFilter


+ (NSMutableArray *)filterRemoveStamp:(NSArray *)originCustomStampArray
{
    NSArray *removedStampArray = [CustomStampFilter getRemovedStampArray];
    
    NSMutableArray *resultArray = [originCustomStampArray mutableCopy];
    
    [resultArray removeObjectsInArray:removedStampArray];
    
    return resultArray;
}

+ (void)removeStamp:(NSString *)stampCode completionHandler:(void (^)(BOOL needReload))completionHandler;
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"刪除貼圖" message:@"確定要刪除貼圖嗎 ?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //
        completionHandler(NO);
    }];
    
    UIAlertAction *remove = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //
        [[myDB sharedInstance].customStampArray removeObject:stampCode];
        
        NSMutableArray *removedStampArray = [CustomStampFilter getRemovedStampArray];
        [removedStampArray addObject:stampCode];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask, YES);
        NSString *documentPath = [paths firstObject];
        NSString *plistPath = [documentPath stringByAppendingPathComponent:@"removedStamp.plist"];
        
        [removedStampArray writeToFile:plistPath atomically:YES];
        
        completionHandler(YES);
        
    }];
    
    [alertController addAction:cancel];
    [alertController addAction:remove];
    
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    
    [topVC presentViewController:alertController animated:YES completion:nil];
}

+ (NSMutableArray *)getRemovedStampArray
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask, YES);
    NSString *documentPath = [paths firstObject];
    NSString *plistPath = [documentPath stringByAppendingPathComponent:@"removedStamp.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        NSMutableArray *removedArray = [NSMutableArray new];
        
        [removedArray writeToFile:plistPath atomically:YES];
        
        return removedArray;
    }
    else
    {
        // 讀取plist資料
        NSMutableArray *removedArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
        
        return removedArray;
    }
}



@end
