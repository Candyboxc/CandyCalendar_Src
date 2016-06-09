//
//  myDB.m
//  CustomManager
//
//  Created by Lee MengHan on 2015/5/5.
//  Copyright (c) 2015年 Lee MengHan. All rights reserved.
//

#import "myDB.h"
#import "FMDatabase.h"

myDB *sharedInstance;;

@implementation myDB


-(void)loadDB{
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES); //獲取路徑對象
    NSString *documentsDirectory = paths[0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"mycalendarDB.sqlite"];  //獲取mycalendarDB.sqlite完整路徑
    
    NSString *bundleResourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *defaultdbPath = [bundleResourcePath stringByAppendingPathComponent:@"mycalendarDB.sqlite"];
    
    db = [FMDatabase databaseWithPath:dbPath];
    defaultdb = [FMDatabase databaseWithPath:defaultdbPath];
    
    
    if (![db open]) {
        NSLog(@"could not open db");
        return;
    }
    
    
    if (![defaultdb open]) {
        NSLog(@"could not open defaultdb");
        return;
    }
    
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadDB];
        _dataArray = [NSMutableArray new];
        _customStampArray = [NSMutableArray new];
    }
    return self;
}



+(myDB *)sharedInstance;{
    if (sharedInstance==nil) {
        sharedInstance = [[myDB alloc]init];
    }
    
    return sharedInstance;
}

#pragma mark - db method
-(id)querySechedule{
    NSMutableArray *rows = [NSMutableArray new];
    FMResultSet *result = [db executeQuery:@"select * from Schedules_event order by id"];
    //從Schedules_event 這個Table拿全部資料
    while ([result next]) { //BOF 1 2 3 4 5 ... EOF 只要下一筆有資料就繼續
        [rows addObject:result.resultDictionary];
    }
    return rows;
}

-(id)querySecheduleFromYear:(NSString*)fromyear ToYear:(NSString*)toyear{
    NSMutableArray *rows = [NSMutableArray new];
    FMResultSet *result = [db executeQuery:@"select * from Schedules_event where date_year >= ? AND date_year <= ? order by id",fromyear,toyear];
    //從Schedules_event 這個Table拿某年的資料
    while ([result next]) { //BOF 1 2 3 4 5 ... EOF 只要下一筆有資料就繼續
        [rows addObject:result.resultDictionary];
    }
    return rows;
}

-(NSString*)newCustNO{//取得流水號
    int maxno = 1;
    FMResultSet *result = [db executeQuery:@"select max(id) from Schedules_event"];
    //取出Schedules_event中cust_no最大的那一筆
    [result next]; //從BOF跳到第一筆
    maxno = [result intForColumnIndex:0]+1;
    
    return [NSString stringWithFormat:@"%05d",maxno]; //%5d是保留3位 %05d得0是前面有再補0
}

-(void)insertEvntDic:(NSDictionary*)eventDic{
    
    if(![db executeUpdate:@"insert into Schedules_event (id,date_year,date_month,date_day,position,stamp_id,memo,alarm_type,start_alarm,end_alarm,photo_id,record_id,photo_url) values (?,?,?,?,?,?,?,?,?,?,?,?,?)",eventDic[@"id"],eventDic[@"date_year"],eventDic[@"date_month"],eventDic[@"date_day"],eventDic[@"position"],eventDic[@"stamp_id"],eventDic[@"memo"],eventDic[@"alarm_type"],eventDic[@"start_alarm"],eventDic[@"end_alarm"],eventDic[@"photo_id"],eventDic[@"record_id"],eventDic[@"photo_url"]]){
        NSLog(@"Could not insert data:\n%@",[db lastErrorMessage]);
    }
    
}

-(void)updateEvntDic:(NSDictionary*)eventDic{
    if(![db executeUpdate:@"update Schedules_event set  date_year=?,date_month=?,date_day=?,position=?,stamp_id=?,memo=?,alarm_type=?,start_alarm=?,end_alarm=?,photo_id=?,record_id=?,photo_url=? where id=?",eventDic[@"date_year"],eventDic[@"date_month"],eventDic[@"date_day"],eventDic[@"position"],eventDic[@"stamp_id"],eventDic[@"memo"],eventDic[@"alarm_type"],eventDic[@"start_alarm"],eventDic[@"end_alarm"],eventDic[@"photo_id"],eventDic[@"record_id"],eventDic[@"photo_url"],eventDic[@"id"]]){
        NSLog(@"Could not insert data:\n%@",[db lastErrorMessage]);
    }
}

-(void)deleteEventByID:(NSString *)eventId{
    if(![db executeUpdate:@"delete from Schedules_event where id=?",eventId]){
        NSLog(@"Could not delete data:\n%@",[db lastErrorMessage]);
    }
}


-(void)changeThemeType:(NSString *)type{
    self.typeDic = [NSMutableDictionary new];
    
    if ([type isEqualToString:@"basicType"]) {
        
        //
        [self.typeDic setObject:@"customstamp_under.png" forKey:@"background"];
        [self.typeDic setObject:@"Screen_top.png" forKey:@"top"];
        [self.typeDic setObject:@"button_today.png" forKey:@"todayBtn"];
        [self.typeDic setObject:@"button_setting.png" forKey:@"settingBtn"];
        [self.typeDic setObject:@"week-月曆上的星期.png" forKey:@"oneWeek"];
        [self.typeDic setObject:@"button_月.png" forKey:@"month"];
        [self.typeDic setObject:@"button_日.png" forKey:@"day"];
        [self.typeDic setObject:@"button_課表.png" forKey:@"week"];
        [self.typeDic setObject:@"class_stamp_課程.png" forKey:@"stampclass"];
        [self.typeDic setObject:@"stamp_事項.png" forKey:@"stamp1"];
        [self.typeDic setObject:@"stamp_學校.png" forKey:@"stamp2"];
        [self.typeDic setObject:@"stamp_場所.png" forKey:@"stamp3"];
        [self.typeDic setObject:@"stamp_特殊.png" forKey:@"stamp4"];
        [self.typeDic setObject:@"stamp_自訂.png" forKey:@"stamp5"];
        [self.typeDic setObject:@"popover_save.png" forKey:@"save"];
        [self.typeDic setObject:@"popover_cancel.png" forKey:@"cancel"];
        [self.typeDic setObject:[UIColor blackColor] forKey:@"wordColor"];
        [self.typeDic setObject:[UIColor colorWithCGColor:[self getColorFromRed:239 Green:239 Blue:239 Alpha:1]] forKey:@"wordBackColor"];
        [self.typeDic setObject:@"customstamp_stampunder.png" forKey:@"stampunder"];
        
    }else if ([type isEqualToString:@"LOVELY"]){
        [self.typeDic setObject:@"LOVELY_background.png" forKey:@"background"];
        [self.typeDic setObject:@"LOVELY_top.png" forKey:@"top"];
        [self.typeDic setObject:@"LOVELY_today.png" forKey:@"todayBtn"];
        [self.typeDic setObject:@"LOVELY_setting.png" forKey:@"settingBtn"];
        [self.typeDic setObject:@"week-月曆上的星期.png" forKey:@"oneWeek"];
        [self.typeDic setObject:@"LOVELY_month.png" forKey:@"month"];
        [self.typeDic setObject:@"LOVELY_day.png" forKey:@"day"];
        [self.typeDic setObject:@"LOVELY_week.png" forKey:@"week"];
        [self.typeDic setObject:@"LOVELY_class.png" forKey:@"stampclass"];
        [self.typeDic setObject:@"LOVELY_stamp1.png" forKey:@"stamp1"];
        [self.typeDic setObject:@"LOVELY_stamp2.png" forKey:@"stamp2"];
        [self.typeDic setObject:@"LOVELY_stamp3.png" forKey:@"stamp3"];
        [self.typeDic setObject:@"LOVELY_stamp4.png" forKey:@"stamp4"];
        [self.typeDic setObject:@"LOVELY_stamp5.png" forKey:@"stamp5"];
        [self.typeDic setObject:@"LOVELY_save.png" forKey:@"save"];
        [self.typeDic setObject:@"LOVELY_cancel.png" forKey:@"cancel"];
        [self.typeDic setObject:[UIColor blackColor] forKey:@"wordColor"];
        [self.typeDic setObject:[UIColor colorWithCGColor:[self getColorFromRed:200 Green:223 Blue:220 Alpha:1]] forKey:@"wordBackColor"];
        [self.typeDic setObject:@"" forKey:@"stampunder"];
    }else if ([type isEqualToString:@"WONDERFUL"]){
        [self.typeDic setObject:@"WONDERFUL_background.png" forKey:@"background"];
        [self.typeDic setObject:@"WONDERFUL_top.png" forKey:@"top"];
        [self.typeDic setObject:@"WONDERFUL_today.png" forKey:@"todayBtn"];
        [self.typeDic setObject:@"WONDERFUL_setting.png" forKey:@"settingBtn"];
        [self.typeDic setObject:@"WONDERFUL_oneweek.png" forKey:@"oneWeek"];
        [self.typeDic setObject:@"button_月.png" forKey:@"month"];
        [self.typeDic setObject:@"button_日.png" forKey:@"day"];
        [self.typeDic setObject:@"button_課表.png" forKey:@"week"];
        [self.typeDic setObject:@"class_stamp_課程.png" forKey:@"stampclass"];
        [self.typeDic setObject:@"stamp_事項.png" forKey:@"stamp1"];
        [self.typeDic setObject:@"stamp_學校.png" forKey:@"stamp2"];
        [self.typeDic setObject:@"stamp_場所.png" forKey:@"stamp3"];
        [self.typeDic setObject:@"stamp_特殊.png" forKey:@"stamp4"];
        [self.typeDic setObject:@"stamp_自訂.png" forKey:@"stamp5"];
        [self.typeDic setObject:@"popover_save.png" forKey:@"save"];
        [self.typeDic setObject:@"popover_cancel.png" forKey:@"cancel"];
        [self.typeDic setObject:[UIColor whiteColor] forKey:@"wordColor"];
        [self.typeDic setObject:[UIColor blackColor] forKey:@"wordBackColor"];
        [self.typeDic setObject:@"" forKey:@"stampunder"];
    }else if([type isEqualToString:@"Mouse"]){
        
        [self.typeDic setObject:@"Mouse_background.png" forKey:@"background"];
        [self.typeDic setObject:@"Mouse_top.png" forKey:@"top"];
        [self.typeDic setObject:@"Mouse_today.png" forKey:@"todayBtn"];
        [self.typeDic setObject:@"Mouse_setting.png" forKey:@"settingBtn"];
        [self.typeDic setObject:@"week-月曆上的星期.png" forKey:@"oneWeek"];
        [self.typeDic setObject:@"Mouse_month.png" forKey:@"month"];
        [self.typeDic setObject:@"Mouse_day.png" forKey:@"day"];
        [self.typeDic setObject:@"Mouse_week.png" forKey:@"week"];
        [self.typeDic setObject:@"Mouse_class.png" forKey:@"stampclass"];
        [self.typeDic setObject:@"Mouse_stamp1.png" forKey:@"stamp1"];
        [self.typeDic setObject:@"Mouse_stamp2.png" forKey:@"stamp2"];
        [self.typeDic setObject:@"Mouse_stamp3.png" forKey:@"stamp3"];
        [self.typeDic setObject:@"Mouse_stamp4.png" forKey:@"stamp4"];
        [self.typeDic setObject:@"Mouse_stamp5.png" forKey:@"stamp5"];
        [self.typeDic setObject:@"Mouse_save.png" forKey:@"save"];
        [self.typeDic setObject:@"Mouse_cancel.png" forKey:@"cancel"];
        [self.typeDic setObject:[UIColor colorWithCGColor:[self getColorFromRed:112 Green:60 Blue:4 Alpha:1]] forKey:@"wordColor"];
        [self.typeDic setObject:[UIColor colorWithCGColor:[self getColorFromRed:226 Green:202 Blue:170 Alpha:1]] forKey:@"wordBackColor"];
        [self.typeDic setObject:@"" forKey:@"stampunder"];
        
    
    }
    
    
    
}
-(CGColorRef) getColorFromRed:(int)red Green:(int)green Blue:(int)blue Alpha:(int)alpha
{
    CGFloat r = (CGFloat) red/255.0;
    CGFloat g = (CGFloat) green/255.0;
    CGFloat b = (CGFloat) blue/255.0;
    CGFloat a = (CGFloat) alpha/1.0;
    CGFloat components[4] = {r,g,b,a};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGColorRef color = (CGColorRef)CGColorCreate(colorSpace, components);
    CGColorSpaceRelease(colorSpace);
    
    return color;
}


#pragma mark - avatar query
-(id)queryAvatarWithPart:(NSString*)part{
    NSMutableArray *rows = [NSMutableArray new];
    NSLog(@"part:%@",part);
    FMResultSet *result = [db executeQuery:@"Select * from avatar where part = ? order by point ",part];
    //從avatar 這個Table拿某part的資料
    while ([result next]) { //BOF 1 2 3 4 5 ... EOF 只要下一筆有資料就繼續
        [rows addObject:result.resultDictionary];
    }
    return rows;
}

-(id)queryAvatar{
    NSMutableArray *rows = [NSMutableArray new];
    FMResultSet *result = [db executeQuery:@"Select * from avatar"];
    //從avatar 這個Table拿某part的資料
    while ([result next]) { //BOF 1 2 3 4 5 ... EOF 只要下一筆有資料就繼續
        [rows addObject:result.resultDictionary];
    }
    return rows;
}

-(id)queryDefaultAvatar{
    NSMutableArray *rows = [NSMutableArray new];
    FMResultSet *result = [defaultdb executeQuery:@"Select * from avatar"];
    //從avatar 這個Table拿某part的資料
    while ([result next]) { //BOF 1 2 3 4 5 ... EOF 只要下一筆有資料就繼續
        [rows addObject:result.resultDictionary];
    }
    return rows;
}

-(void)checkAvatarTable{
    if(![db executeUpdate:@"CREATE TABLE IF NOT EXISTS avatar (id integer not null primary key autoincrement unique, name text not null, part integer not null, point integer not null)"])
    {
        NSLog(@"Could not create table: %@", [db lastErrorMessage]);
    }
    
    NSArray *dbAvatar = [self queryAvatar];
    NSArray *defaultdbAvatar = [self queryDefaultAvatar];
    
    if((dbAvatar.count == defaultdbAvatar.count)){
        if(![dbAvatar[dbAvatar.count-1][@"id"] isEqualToNumber:defaultdbAvatar[defaultdbAvatar.count-1][@"id"]]){
            //如果user跟default 最後一筆資料id不同 或 資料比數不等
            
            if(![db executeUpdate:@"DELETE FROM avatar"]){
                NSLog(@"Could not clear table: %@", [db lastErrorMessage]);
            }
        
            for(int i=0;i<defaultdbAvatar.count;i++){
                //insert defaultdbAvatar[i]
                if(![db executeUpdate:@"insert into avatar (id,name,part,point) values (?,?,?,?)",defaultdbAvatar[i][@"id"],defaultdbAvatar[i][@"name"],defaultdbAvatar[i][@"part"],defaultdbAvatar[i][@"point"]]){
                    NSLog(@"Could not insert data:\n%@",[db lastErrorMessage]);
                }
            
            }
        
            NSLog(@"avatar 更新完成");
        }else{
            NSLog(@"avatar 資料一致");
        }
    }else{
        if(![db executeUpdate:@"DELETE FROM avatar"]){
            NSLog(@"Could not clear table: %@", [db lastErrorMessage]);
        }
        
        for(int i=0;i<defaultdbAvatar.count;i++){
            //insert defaultdbAvatar[i]
            if(![db executeUpdate:@"insert into avatar (id,name,part,point) values (?,?,?,?)",defaultdbAvatar[i][@"id"],defaultdbAvatar[i][@"name"],defaultdbAvatar[i][@"part"],defaultdbAvatar[i][@"point"]]){
                NSLog(@"Could not insert data:\n%@",[db lastErrorMessage]);
            }
            
        }
        NSLog(@"avatar 更新完成");
    }

}

@end
