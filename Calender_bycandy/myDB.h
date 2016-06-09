//
//  myDB.h
//  CustomManager
//
//  Created by Lee MengHan on 2015/5/5.
//  Copyright (c) 2015年 Lee MengHan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import <UIKit/UIKit.h>
@interface myDB : NSObject{
    FMDatabase *db;
    FMDatabase *defaultdb;
}
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableDictionary *settingDict,*scoreDict;
@property (strong, nonatomic) NSNumber *topYear,*bottomYear,*nowSection,*nowRow;
@property (strong, nonatomic) NSMutableArray *customStampArray;
@property (strong, nonatomic) NSMutableDictionary *typeDic;
@property (assign, nonatomic) NSInteger lastScore,score;
@property (strong, nonatomic) NSString *firstOpenAppBonus;


+ (myDB *)sharedInstance;

#pragma mark - db method
-(id)querySechedule;
-(id)querySecheduleFromYear:(NSString*)fromyear ToYear:(NSString*)toyear;
-(NSString*)newCustNO;

-(void)insertEvntDic:(NSDictionary*)eventDic;
-(void)updateEvntDic:(NSDictionary*)eventDic;
-(void)deleteEventByID:(NSString *)eventId;

-(void)changeThemeType:(NSString *)type;

-(id)queryAvatarWithPart:(NSString*)part;
-(id)queryAvatar;
-(void)checkAvatarTable;
@end
