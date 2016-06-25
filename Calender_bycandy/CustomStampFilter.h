//
//  CustomStampFilter.h
//  Calender_bycandy
//
//  Created by Dong on 2016/6/24.
//  Copyright © 2016年 candy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomStampFilter : NSObject



+ (NSMutableArray *)filterRemoveStamp:(NSArray *)originCustomStampArray;

+ (void)removeStamp:(NSString *)stampCode completionHandler:(void (^)(BOOL needReload))completionHandler;
;


@end
