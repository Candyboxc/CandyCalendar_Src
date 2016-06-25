#import "ViewController.h"
#import "Header.h"
#import "PicButton.h"
#import "JMWhenTapped.h"
#import "myDB.h"
#import <objc/runtime.h>
#import "CustomStamp.h"
#import "PopViewController.h"
#import "CustomStampFilter.h"
#import "TrashCanButton.h"


static char btnInfoKey;
static char btnTmpKey;

@interface ViewController ()<UIScrollViewDelegate,buttonDelegate,UITextViewDelegate>{
    
    NSCalendar *CalenderOfMonth;    //建立月曆
    
    /* 建立儲存今天的(日/月/年/section) / 這個月有幾天 */
    NSInteger todayDay,todayMonth,todayYear,todaySection;
    
    NSUInteger numberOfDaysInToday; //這個月有幾天
    float cellwidth;
    
    PicButton *picButton2;
    NSMutableArray *dataArray,*imagePackage;
    
    //popBtn_Trash -> 刪除
    UIButton *popBtn_Trash,*popBtn,*backView;
    
    NSInteger topYear,bottomYear;//目前資料的上下限年
    bool start;//判斷是否load TableView完畢
    
    int weekNumber; //寫入星期時用來判斷的變數
    NSArray *weekArray; //存一～日的array
    NSInteger nowSection;
    UIImageView *loadingview;
    BOOL customStampTypeSelected;//目前自訂貼圖是否被打開
    NSString *stamptargetdir;//自訂貼圖的路徑
    BOOL goToPopOver;//判斷是否進入popover
    
    NSString *currentType;//目前的type
    NSArray *stampButtonArray;
    
    
    CGSize cellSize6,cellSize5,cellSize4;
    
    // 貼圖的cellsize
    CGSize stampCollectionViewCellSize;
}

@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;    //設定月曆
@property (weak, nonatomic) IBOutlet UICollectionView *picCollectionView;   //設定貼圖
@property (weak, nonatomic) IBOutlet UIButton *weekBtn;
@property (weak, nonatomic) IBOutlet UIButton *dayBtn;
@property (strong, nonatomic) PopViewController *popViewController;

@property (weak, nonatomic) IBOutlet UIImageView *top;
@property (weak, nonatomic) IBOutlet UIButton *todayBtn;
@property (weak, nonatomic) IBOutlet UIButton *monthBtn;
@property (weak, nonatomic) IBOutlet UIButton *settingBtn;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UIButton *stamp1;
@property (weak, nonatomic) IBOutlet UIButton *stamp2;
@property (weak, nonatomic) IBOutlet UIButton *stamp3;
@property (weak, nonatomic) IBOutlet UIButton *stamp4;
@property (weak, nonatomic) IBOutlet UIButton *stamp5;

@property (strong, nonatomic) TrashCanButton *trashCan;


@end

@implementation ViewController



//一開始會讀取的
- (void)viewDidLoad {
    [super viewDidLoad];
    
    goToPopOver = NO;
    _popViewController = self.childViewControllers[0];
    [_popViewController.view removeFromSuperview];//設定popview的父viewcontroller為自己 將popview隱藏
    
    // 設定loadingview
    [self setLoadingView];
    
    
    // 建立自訂貼圖路徑
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *stampdir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    stamptargetdir = [stampdir stringByAppendingPathComponent:@"customstamp"];
    //判斷若不存在的話,則創建一個
    if (![fileManager fileExistsAtPath:stamptargetdir]) {
        [fileManager createDirectoryAtPath:stamptargetdir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *settingPlistPath = [self getPathWithName:@"setting.plist"];
    if (![fileManager fileExistsAtPath:settingPlistPath]) {
        NSMutableDictionary *tmpSettingDict = [NSMutableDictionary new];
        //如果第一次開app建立setting.plist檔
        tmpSettingDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Sunday",@"weekBeginDay",@"YES",@"picVisiable",@"YES",@"pushNotification",@"fiveDay",@"weekDayNumber",@"8",@"weekBeginTime",@"10",@"classNumber",@"LOVELY",@"themeType", nil];
        [tmpSettingDict writeToFile:settingPlistPath atomically:YES];
        [myDB sharedInstance].settingDict = tmpSettingDict;
    }else{
        [myDB sharedInstance].settingDict=[[NSMutableDictionary alloc]initWithContentsOfFile:settingPlistPath];
        //如果setting存在則拿出來用
    }
    
    // 設定必要的值
    [self config];
    
    //建立日期
    NSDate *Today = [NSDate date];
    CalenderOfMonth = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *WeekdayComponents = [CalenderOfMonth components:(NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:Today];
    
    //分割今天的日期
    todayDay = [WeekdayComponents day];
    todayYear = [WeekdayComponents year];
    todayMonth = [WeekdayComponents month];
    
    dataArray = [NSMutableArray new];
    
    topYear = todayYear-1;//頂端一年
    bottomYear = todayYear +1;//最後一年
    
    for (int i = 0; i<36; i++) {
        NSMutableArray *tmpArray = [NSMutableArray new];
        NSMutableArray *calendarCreate =[self calendarCreate:todayYear-1 getmonth:1+i];
        [tmpArray addObject:calendarCreate[0]];//section的array(含有space)
        
        NSInteger tmpCount = [tmpArray[0] count];
        [tmpArray addObject:[NSString stringWithFormat:@"%li",(long)tmpCount]];//section的count(含有space)
        
        NSInteger space = tmpCount - [tmpArray[0][tmpCount-1] intValue];
        [tmpArray addObject:[NSString stringWithFormat:@"%li",(long)space]];//space的count
        
        NSMutableArray *tmpDayArray = [NSMutableArray new];
        for (int l = 0 ; l< tmpCount-space ; l++) {
            NSMutableArray *button = [NSMutableArray new];
            //加dic from sqlite
            [tmpDayArray addObject:button];
        }
        [tmpArray addObject:tmpDayArray];
        [tmpArray addObject:calendarCreate[1]];
        [dataArray addObject:tmpArray]; //增加一個dataArray用來之後存放圖片
    }
    
    
    //用eventsArray去接收這三年的資料===============
    NSArray *eventsArray = [[myDB sharedInstance] querySecheduleFromYear:[NSString stringWithFormat:@"%ld",(long)topYear] ToYear:[NSString stringWithFormat:@"%ld",(long)bottomYear]];
    //NSLog(@"events:%@",eventsArray);
    
    for(int i=0;i<eventsArray.count;i++){
        NSInteger sect = ([eventsArray[i][@"date_year"]integerValue] - topYear)*12 +  [eventsArray[i][@"date_month"]integerValue] - 1;  //取得section資訊
        [dataArray[sect][3][[eventsArray[i][@"date_day"] integerValue]-1] addObject:eventsArray[i]];   //置入完整的Dic
        
        for (UICollectionViewCell*cell in [_myCollectionView visibleCells]) {
            [cell setNeedsLayout];
        }
    }
    
    todaySection = (todayYear-topYear)*12+(todayMonth-1);
    
    //將所有資料存入singleton
    myDB *dataObject = [myDB sharedInstance];
    dataObject.dataArray = dataArray;
    dataObject.topYear = [NSNumber numberWithInteger:topYear];
    dataObject.bottomYear = [NSNumber numberWithInteger:bottomYear];
    dataObject.nowSection = [NSNumber numberWithInteger:todaySection];
    dataObject.nowRow = [NSNumber numberWithInteger:todayDay-1];

#pragma mark - 算分數
    NSDate *lastStartDate = [myDB sharedInstance].scoreDict[@"lastStartDate"];
    NSLog(@"%.f",[[NSDate date] timeIntervalSinceDate:lastStartDate]);
    NSDateFormatter *scoreDateFormatter = [NSDateFormatter new];
    [scoreDateFormatter setDateFormat:@"yyyy-MM-dd"];
    for (NSDictionary *dic in eventsArray) {
        if (dic[@"end_alarm"] != [NSNull null]) {
            
            NSDate *eventDate = [[NSDate alloc] initWithTimeIntervalSince1970:[dic[@"end_alarm"] intValue]];
            NSDate *nowDate = [NSDate date];
            if ([eventDate laterDate:lastStartDate] == eventDate && [eventDate earlierDate:[NSDate date]] == eventDate && ![dic[@"position"] isEqual: @(99)]) {

                NSLog(@"事件成立%@",dic[@"id"]);
                [myDB sharedInstance].score++;
                
            }
        }else{
            NSString *startDateStr = [scoreDateFormatter stringFromDate:lastStartDate];
            NSDate *startDate = [scoreDateFormatter dateFromString:startDateStr];
//            NSLog(@"%@",startDateStr);
            NSString *eventDateStr = [NSString stringWithFormat:@"%@-%@-%@",dic[@"date_year"],dic[@"date_month"],dic[@"date_day"]];
            NSDate *eventDate = [scoreDateFormatter dateFromString:eventDateStr];
            NSString *endDateStr = [scoreDateFormatter stringFromDate:[NSDate date]];
            NSDate *endDate = [scoreDateFormatter dateFromString:endDateStr];
            
            if ([eventDate laterDate:startDate] == eventDate && [eventDate earlierDate:[NSDate date]] == eventDate && ![dic[@"position"] isEqual: @(99)]) {
                
                NSLog(@"事件成立%@",dic[@"id"]);
                [myDB sharedInstance].score++;
            }
        }
    }
    NSString *startDateStr = [scoreDateFormatter stringFromDate:lastStartDate];
    NSDate *startDate = [scoreDateFormatter dateFromString:startDateStr];
    NSString *endDateStr = [scoreDateFormatter stringFromDate:[NSDate date]];
    NSDate *endDate = [scoreDateFormatter dateFromString:endDateStr];
    if (![startDate isEqual: endDate]) {
        [myDB sharedInstance].score++;
        [myDB sharedInstance].firstOpenAppBonus = @"YES";
    }
    
    [[myDB sharedInstance].scoreDict setObject:[NSString stringWithFormat:@"%li",(long)[myDB sharedInstance].score] forKey:@"score"];
    [[myDB sharedInstance].scoreDict setObject:[NSDate date] forKey:@"lastStartDate"];
    [[myDB sharedInstance].scoreDict writeToFile:[self getPathWithName:@"Score.plist"] atomically:YES];
    
    
    //NSLog(@"%.f",[[NSDate date] timeIntervalSinceDate:[myDB sharedInstance].scoreDict[@"lastStartDate"]]);
    
    // setAD
    [self setAD];
    
#pragma mark - 讀取自訂貼圖匯入mydb
    NSString *dbPathFromcustomStampPlist = [self getPathWithName:@"customstamp.plist"];
    
    if (![fileManager fileExistsAtPath:dbPathFromcustomStampPlist])
    {
        //如果第一次開app會建立customstamp.plist檔
        NSMutableArray *tmpCustomStampDir = [NSMutableArray new];
        
        [tmpCustomStampDir writeToFile:dbPathFromcustomStampPlist atomically:YES];
    }
    else
    {
        //讀取plist資料
        [myDB sharedInstance].customStampArray = [CustomStampFilter filterRemoveStamp:[[NSMutableArray alloc] initWithContentsOfFile:dbPathFromcustomStampPlist]];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    if (!goToPopOver) { //如果進入popover就不reload
        [_myCollectionView reloadData];
    }
    
    //NSLog(@"viewWillAppear");
    
    //隱藏tabbar
    [self.tabBarController.tabBar setHidden:YES];
    if (customStampTypeSelected)
    {
        [self.picCollectionView reloadData];
        
        [self stampBtnClick5:_stamp5];
    }
    int tmpSection = [myDB sharedInstance].nowSection.intValue;
    [_myCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[dataArray[tmpSection][1] intValue]-1
                                                                   inSection:tmpSection]
                              atScrollPosition:UICollectionViewScrollPositionBottom
                                      animated:NO];
    start = YES;//畫面reload完畢
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - buttonClick
- (IBAction)settingBtnClick:(id)sender {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Setting" bundle:nil]; //創建StoryBoard的實體
    
    id targetViewController = [storyBoard instantiateViewControllerWithIdentifier:@"Setting"];
    
    [self presentViewController:targetViewController animated:true completion:nil];
}

- (IBAction)weekBtnCkick:(UIButton *)sender {
    self.tabBarController.selectedIndex = 1;
}

- (IBAction)dayBtnClick:(UIButton *)sender {
    self.tabBarController.selectedIndex = 2;
}

/* 製作Today的按鈕動作 會回到今天的日期 */
- (IBAction)todayBtnClick:(id)sender {
 
    [_myCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[[self calendarCreate:topYear
                                                                                          getmonth:1+todaySection][0] count]-1
                                                                   inSection:todaySection]
                              atScrollPosition:UICollectionViewScrollPositionBottom
                                      animated:YES];
    [myDB sharedInstance].nowSection = [NSNumber numberWithInteger:todaySection];
    [myDB sharedInstance].nowRow = [NSNumber numberWithInteger:todayDay-1];
}


#pragma mark - 貼圖開始觸控事件
/* 按下去時,會增加一個view */
- (void)buttonBegin:(PicButton *)pic location:(CGPoint)loc{
    picButton2 = [PicButton new];
    picButton2.delegate=self;
    [picButton2 setImage:pic.currentImage forState:UIControlStateNormal];
    picButton2.userInteractionEnabled=YES;
    picButton2.frame = CGRectMake(loc.x, loc.y-50, pic.frame.size.width, pic.frame.size.height);
    [self.view addSubview:picButton2];
}


#pragma mark - 月曆格子
/* 移動時,判斷與cell有無接觸,若有則將cell變色 */
- (void)buttonMove:(PicButton *)pic location:(CGPoint)loc{
    
    picButton2.frame = CGRectMake(loc.x, loc.y-50, picButton2.frame.size.width, picButton2.frame.size.height);
    
    if (CGRectIntersectsRect(CGRectMake(picButton2.center.x, picButton2.center.y, 0, 0), _trashCan.frame))
    {
        [_trashCan hoverIn];
    }
    else
    {
        [_trashCan hoverOut];
    }
    
    for (UICollectionViewCell*cell in [_myCollectionView visibleCells]) {
        CGRect frame = [_myCollectionView convertRect:cell.frame toView:self.view];
        UILabel *cellLabel = (UILabel *)[cell viewWithTag:100];
        
        //判斷沒有日期要做什麼動作
        if (cellLabel.text == NULL) {

        }else{
        
            if (CGRectIntersectsRect(CGRectMake(picButton2.center.x, picButton2.center.y, 0, 0), frame)) {
                if (cell.userInteractionEnabled==YES) {
                    cell.contentView.backgroundColor =[UIColor colorWithCGColor:[self getColorFromRed:255
                                                                                                Green:239
                                                                                                 Blue:213
                                                                                                Alpha:1]];
                }
            }else{
                cell.contentView.backgroundColor = nil;
            }
        }
    }
}


#pragma mark - 貼圖結束事件
- (void)buttonEnd:(PicButton *)pic location:(CGPoint)loc
{
    if (CGRectIntersectsRect(CGRectMake(picButton2.center.x, picButton2.center.y, 0, 0), _trashCan.frame))
    {
        [_trashCan hoverOut];
        
        [CustomStampFilter removeStamp:pic.code completionHandler:^(BOOL needReload) {
            //
            if (needReload)
            {
                [_picCollectionView reloadData];
            }
        }];
    }
    else
    {
        [_trashCan hoverOut];
    }
    
    for (UICollectionViewCell*cell in [_myCollectionView visibleCells]) {
        
        CGRect frame = [_myCollectionView convertRect:cell.frame toView:self.view];
        UILabel *cellLabel = (UILabel *)[cell viewWithTag:100];
        
        if (cellLabel.text == NULL) {
            //不讓貼圖放上去
            
        }else{

            if (cell.userInteractionEnabled==YES) {
                if (CGRectIntersectsRect(CGRectMake(picButton2.center.x, picButton2.center.y, 0, 0), frame)) {
                    
                    NSInteger sect = [_myCollectionView indexPathForCell:cell].section;
                    //將cell在collection的section及row取出
                    //NSInteger ro = [_myCollectionView indexPathForCell:cell].row;
                    
                    //取出該格實際的日期
                    NSInteger year =  sect/12 + topYear;//計算cell的年份
                    NSInteger month = sect%12 + 1;//計算cell的月份
                    NSIndexPath *targetIndexPath = [_myCollectionView indexPathForCell:cell];
                    NSInteger day =[_myCollectionView cellForItemAtIndexPath:targetIndexPath].tag;
                    
                    NSInteger box;  //第幾個貼圖格
                    //NSLog(@"事件數目 %lu",(unsigned long)[dataArray[sect][3][day-1]count]);
                    
                    if ([dataArray[sect][3][day-1]count]<10) {  //上限十筆
                    
                        UIButton *button1 = (UIButton *)[cell viewWithTag:101];
                        UIButton *button2 = (UIButton *)[cell viewWithTag:102];
                        UIButton *button3 = (UIButton *)[cell viewWithTag:103];
                        if (button1.currentImage==nil) {
                            [button1 setImage:picButton2.currentImage forState:UIControlStateNormal];
                            box=1;
                        }else if (button2.currentImage==nil){
                            [button2 setImage:picButton2.currentImage forState:UIControlStateNormal];
                            box=2;
                        }else if (button3.currentImage==nil){
                            [button3 setImage:picButton2.currentImage forState:UIControlStateNormal];
                            box=3;
                        }else{
                            //NSLog(@"貼圖已滿");
                            box=99;
                        }
                        
                        
                        [cell setNeedsLayout];
                        //NSLog(@"reload結束");
                        //重整collectionview
                        cell.contentView.backgroundColor = nil;
                        UIView *popView = [UIView new];
                        popView.frame = CGRectMake(frame.origin.x, frame.origin.y+frame.size.height,
                                                   frame.size.width+12, 0.6*(frame.size.width+12));
                        UIImageView *popViewImage = [[UIImageView alloc]initWithFrame:popView.bounds];
                        popViewImage.image = [UIImage imageNamed:@"main_popover_under.png"];
                        
                        //跳出新增事件的視窗
                        popBtn = [[UIButton alloc]initWithFrame:CGRectMake(4, 0.21*(frame.size.width+12),
                                                                           frame.size.width/2, 0.35*(frame.size.width+12))];
                        popBtn_Trash = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width/2+8, 0.21*(frame.size.width+12),
                                                                                  frame.size.width/2, 0.35*(frame.size.width+12))];
                        
                        [popBtn_Trash setImage:[UIImage imageNamed:@"main_popover_trash.png"] forState:UIControlStateNormal];
                        
                        [popBtn setImage:[UIImage imageNamed:@"main_popover_edite.png"] forState:UIControlStateNormal];
                        
                        NSString *eventNo=[[myDB sharedInstance] newCustNO]; //取得事件流水號
                        
                        //將事件的基本資訊包成Dic帶到PopOver
                        NSDictionary *eventInfoDictionary = @{@"id":[NSNumber numberWithInteger:[eventNo integerValue]]
                                                              ,@"date_year":[NSNumber numberWithInteger:year]
                                                              ,@"date_month":[NSNumber numberWithInteger:month]
                                                              ,@"date_day":[NSNumber numberWithInteger:day]
                                                              ,@"position":[NSNumber numberWithInteger:box]
                                                              ,@"stamp_id":[NSString stringWithFormat:@"%@",[pic.code substringToIndex:4]]
                                                              ,@"memo":[NSNull null]
                                                              ,@"alarm_type":[NSNull null]
                                                              ,@"start_alarm":[NSNull null]
                                                              ,@"end_alarm":[NSNull null]
                                                              ,@"photo_id":[NSNull null]
                                                              ,@"record_id":[NSNull null]};
                        
                        //把事件的Cell跟Position帶到清除
                        NSDictionary *eventTmpDictionary = @{@"cell":cell,
                                                             @"position":[NSString stringWithFormat:@"%ld",(long)box],
                                                             };
                        //把Dic與popBtn關聯
                        objc_setAssociatedObject(popBtn, &btnInfoKey, eventInfoDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                        objc_setAssociatedObject(popBtn_Trash, &btnTmpKey, eventTmpDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                        
                        //NSLog(@" 年:%@ 月:%@ SECT:%ld",eventInfoDictionary[@"date_year"],eventInfoDictionary[@"date_month"],(long)sect);
                        
                        [popBtn addTarget:self action:@selector(popBtnClick:) forControlEvents:UIControlEventAllEvents];
                        [popBtn_Trash addTarget:self action:@selector(popTrashBtnClick:) forControlEvents:UIControlEventAllEvents];
                        
                        //跳出新增事件背景透明圖
                        backView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
                        
                        //注意順序
                        [self.view addSubview:backView];
                        [self.view addSubview:popView];
                        [popView addSubview:popViewImage];
                        [popView addSubview:popBtn];
                        [popView addSubview:popBtn_Trash];
                        popViewImage.tag=202;
                        popView.tag=202;
                        backView.tag=202;
                        popBtn.tag=202;
                        popBtn_Trash.tag=202;
                        
                        [backView whenTapped:^{
                            //沒註解直接新增貼圖
                            //儲存當前新增事件的的位址及貼圖資訊
                            
                            [self SaveEventWithFullDic:eventInfoDictionary];
                            
                            //移除pop
                            for (UIView *v in self.view.subviews) {
                                if (v.tag == 202 ) {
                                    [v removeFromSuperview];
                                }
                            }
                        }];
                        break;
                    
                    }else{
                    
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告" message:@"本日事件已達上限10筆，請回到日曆刪除事件後繼續新增。" preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                            //
                        }];
                        
                        [alertController addAction:cancelAction];
                        
                        [self presentViewController:alertController animated:YES completion:nil];
                    }
                }
            }
        }
    
    [picButton2 removeFromSuperview];
        
    }
}


#pragma mark - popVC BtnAction
-(void)SaveEventWithFullDic:(NSDictionary*)eventDic{
    
    //[self clearPopView];
    
    goToPopOver = NO;
    
    for (UIView *v in self.view.subviews) {
        if (v.tag == 200 || v.tag==201) {
            [v removeFromSuperview];
        }
    }
    
    //取得section資訊
    NSInteger sect = ([eventDic[@"date_year"]integerValue] - topYear)*12 +  [eventDic[@"date_month"]integerValue] - 1;
    
    //NSDictionary *tmpDic = [dataArray[sect][3][[eventDic[@"date_day"] integerValue]-1] lastObject]; //取得當前Event的tmpDic
    //[dataArray[sect][3][[eventDic[@"date_day"] integerValue]-1] removeObject:tmpDic];               //刪除預覽貼圖用的tmpDic
    [dataArray[sect][3][[eventDic[@"date_day"] integerValue]-1] addObject:eventDic];                //置入完整的Dic
    
    [[myDB sharedInstance] insertEvntDic:eventDic];                                                 //上傳SQL
}

//清除popoverView
-(void)clearPopView{
    for (UIView *v in self.view.subviews) {
        if (v.tag == 200 || v.tag==201) {
            [v removeFromSuperview];
        }
    }
}


#pragma mark - popover系列
-(void)popTrashBtnClick:(UIButton *)sender{
    for (UIView *v in self.view.subviews) {
        if (v.tag == 202 ) {
            [v removeFromSuperview];
        }
    }
    NSDictionary *trashDic = (NSDictionary*)objc_getAssociatedObject(sender, &btnTmpKey);
    
    UICollectionViewCell *cell = trashDic[@"cell"];
    UIButton *button;
    if([trashDic[@"position"]integerValue] == 1){
        button = (UIButton *)[cell viewWithTag:101];
    }else if ([trashDic[@"position"]integerValue] == 2){
        button = (UIButton *)[cell viewWithTag:102];
    }else if ([trashDic[@"position"]integerValue] == 3){
        button = (UIButton *)[cell viewWithTag:103];
    }
    [button setImage:nil forState:UIControlStateNormal];
}

-(void)popBtnClick:(UIButton *)sender{
    for (UIView *v in self.view.subviews) {
        if (v.tag == 202 ) {
            [v removeFromSuperview];
        }
    }
    goToPopOver = YES;
    
    //接收關聯
    _popViewController.eventInfoDic = (NSDictionary*)objc_getAssociatedObject(sender, &btnInfoKey);
//    NSLog(@"帶過來的事件是：%@",_popViewController.eventInfoDic);
    
    
    //背景透明 popover編輯後的畫面背景
    UIView *addBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,
                                                                  self.view.frame.size.width, self.view.frame.size.height)];
    [addBackView setBackgroundColor:[UIColor blackColor]];
    addBackView.alpha = 0.2;
    
    //新增事項的視窗
    _popViewController.view.frame = CGRectMake(self.view.frame.size.width*0.1, 30,
                                               self.view.frame.size.width*0.8, self.view.frame.size.height*0.5);
    
    float height = _popViewController.view.frame.size.height;
    
    
    _datePicker = [[UIDatePicker alloc]init];
    _datePicker.tag=201;
    [_datePicker setDatePickerMode:UIDatePickerModeTime];
    [_datePicker setBackgroundColor:[UIColor whiteColor]];
    _datePicker.frame = CGRectMake(0, 3*self.view.frame.size.height/3, self.view.frame.size.width/2, height/5);
    [_datePicker addTarget:self action:@selector(dateChanged:)
          forControlEvents:UIControlEventValueChanged];//datePicker1時間轉換時的action
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//date的格式
    NSString *tmpNowTime = [formatter stringFromDate:[NSDate date]];//現在的時間
    NSString *dateString = [NSString stringWithFormat:@"%@-%@-%@ %@",
                                                    _popViewController.eventInfoDic[@"date_year"],
                                                    _popViewController.eventInfoDic[@"date_month"],
                                                    _popViewController.eventInfoDic[@"date_day"],
                                                    [tmpNowTime substringFromIndex:11]];
    //將cell年＋cell月＋cell日＋現在時間 合為一個string
    NSDate *cellTime = [formatter dateFromString:dateString];//格式化成NSDate
    [_datePicker setDate:cellTime];//設定datepicker時間
    
    _datePicker2 = [[UIDatePicker alloc]init];
    _datePicker2.tag=201;
    [_datePicker2 setDatePickerMode:UIDatePickerModeTime];
    [_datePicker2 setBackgroundColor:[UIColor whiteColor]];
    _datePicker2.frame = CGRectMake(0, 3*self.view.frame.size.height/3, self.view.frame.size.width/2, height/5);
    [_datePicker2 setDate:[_datePicker.date dateByAddingTimeInterval:60*60]];//設定datepicker2的時間後一小時
    [_datePicker2 addTarget:self action:@selector(dateChanged:)
           forControlEvents:UIControlEventValueChanged];//datePicker2時間轉換時的action
    
    _popViewController.textView.text=@"請輸入事項";
    _popViewController.textView.delegate=self;
    NSDateFormatter *formatter2 = [NSDateFormatter new];
    [formatter2 setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *tmpDateBtnStr = [NSString stringWithFormat:@"開始時間：   %@\n結束時間：   %@",
                                                       [formatter2 stringFromDate:self.datePicker.date],
                                                       [formatter2 stringFromDate:self.datePicker2.date]];
    [_popViewController.dateBtn setTitle:tmpDateBtnStr forState:UIControlStateNormal];
    
    [addBackView whenTapped:^{
        [_popViewController.textView resignFirstResponder];
        [_datePicker removeFromSuperview];
        [_datePicker2 removeFromSuperview];
    }];
    
    
    addBackView.tag=200;
    _popViewController.view.tag = 200;
    _popViewController.view.alpha= 0;
    [self.view addSubview:addBackView];
    [self.view addSubview:_popViewController.view];
    [UIView transitionWithView:_popViewController.view duration:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
        
        _popViewController.view.alpha=1.0;
        
    } completion:^(BOOL finished) {
        
        [self performSelector:@selector(openKeyBoard) withObject:nil afterDelay:0];
        
    }];
}

-(void)openKeyBoard{
    [_popViewController.textView becomeFirstResponder];
}


/*date的值改變*/
-(void)dateChanged:(UIDatePicker *)sender{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    if (sender == _datePicker) {
        [_datePicker2 setDate:[sender.date dateByAddingTimeInterval:60*60] animated:YES];
        
    }else{
        if ([_datePicker2.date earlierDate:_datePicker.date] == _datePicker2.date) {
            [_datePicker setDate:[sender.date dateByAddingTimeInterval:-60] animated:YES];
        }
    }
    NSString *tmpDateBtnStr = [NSString stringWithFormat:@"開始時間：   %@\n結束時間：   %@",
                                                       [formatter stringFromDate:_datePicker.date],
                                                       [formatter stringFromDate:_datePicker2.date]];
    
    [_popViewController.dateBtn setTitle:tmpDateBtnStr forState:UIControlStateNormal];
}



#pragma mark - collectionview delegate
//建立Section數量
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (collectionView == self.picCollectionView) {
        return 1;
    }else{
        return dataArray.count;
    }
}

//每個section的item數量
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == self.picCollectionView) {
        return [imagePackage count];
    }else{
        if ([dataArray[section][1] intValue]%7==0) {
            return [dataArray[section][1] intValue];
        }else{
            return [dataArray[section][1] intValue] + (7 - [dataArray[section][1] intValue]%7);
        }
    }
}

//製作cell內容
-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //Identifier名稱要取cell
    
#pragma mark - 貼圖的cellforrow
    if (collectionView == self.picCollectionView) {
        
        PicButton *picButton;
        UICollectionViewCell *cell;
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"twocell" forIndexPath:indexPath];
        
        //NSLog(@"%@",cell.contentView.subviews);
        if ([[cell.contentView.subviews firstObject] isKindOfClass:[PicButton class]]) {
            //
            picButton  = (PicButton *)[cell viewWithTag:106];
            if (customStampTypeSelected)
            {
                CGRect picCollectionFrame = _picCollectionView.frame;
                if (picCollectionFrame.size.width >= self.view.frame.size.width)
                {
                    picCollectionFrame.size.width = (self.view.frame.size.width + 8) - _stamp1.frame.size.width*1.3;
                    _picCollectionView.frame = picCollectionFrame;
                }
                
                picButton.delegate = self;
                NSString* path = [stamptargetdir stringByAppendingPathComponent:
                                  [myDB sharedInstance].customStampArray[indexPath.row]];
                
                [picButton setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
                picButton.code = [myDB sharedInstance].customStampArray[indexPath.row];
            }else {//如果目前是貼圖選擇
                
                CGRect picCollectionFrame = _picCollectionView.frame;
                if (picCollectionFrame.size.width != self.view.frame.size.width + 8)
                {
                    picCollectionFrame.size.width = self.view.frame.size.width + 8;
                    _picCollectionView.frame = picCollectionFrame;
                }
                
                picButton.delegate = self;
                [picButton setImage:[UIImage imageNamed:imagePackage[indexPath.row]] forState:UIControlStateNormal];
                picButton.code = imagePackage[indexPath.row];
            }
            
            
        }else{//如果第一次reload
            
            picButton = [[PicButton alloc] init];
            picButton.frame = cell.bounds;
            picButton.tag=106;
            picButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [cell.contentView addSubview:picButton];
            picButton  = (PicButton *)[cell viewWithTag:106];
            
            if (customStampTypeSelected){
                picButton.delegate = self;
                NSString* path = [stamptargetdir stringByAppendingPathComponent:
                                  [myDB sharedInstance].customStampArray[indexPath.row]];
                
                [picButton setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
                picButton.code = [myDB sharedInstance].customStampArray[indexPath.row];
            }else{//如果目前是貼圖選擇
                picButton.delegate = self;
                [picButton setImage:[UIImage imageNamed:imagePackage[indexPath.row]] forState:UIControlStateNormal];
                picButton.code = imagePackage[indexPath.row];
            }
        }

        
        return cell; //回傳值至cell
        
#pragma mark - 月曆的cellforrow
    }else{
        if (start) {
            if (indexPath.section==dataArray.count-1) {
                bottomYear ++;
                for (int i = 0; i<12; i++) {
                    NSMutableArray *tmpArray = [NSMutableArray new];
                    NSMutableArray *calendarCreate =[self calendarCreate:bottomYear getmonth:1+i];
                    
                    [tmpArray addObject:calendarCreate[0]];//section的array(含有space)
                    NSInteger tmpCount = [tmpArray[0] count];
                    [tmpArray addObject:[NSString stringWithFormat:@"%li",(long)tmpCount]];//section的count(含有space)
                    NSInteger space = tmpCount - [tmpArray[0][tmpCount-1] intValue];
                    [tmpArray addObject:[NSString stringWithFormat:@"%li",(long)space]];//space的count
                    
                    NSMutableArray *tmpDayArray = [NSMutableArray new];
                    for (int l = 0 ; l< tmpCount-space ; l++) {
                        NSMutableArray *button = [NSMutableArray new];
                        [tmpDayArray addObject:button];
                    }
                    
                    [tmpArray addObject:tmpDayArray];
                    [tmpArray addObject:calendarCreate[1]];
                    [dataArray addObject:tmpArray];//增加一個dataArray用來之後存放圖片
                }
                
                //用eventsArray去接收新Botyear的資料===============
                NSArray *eventsArray = [[myDB sharedInstance] querySecheduleFromYear:[NSString stringWithFormat:@"%ld",(long)bottomYear]
                                                                              ToYear:[NSString stringWithFormat:@"%ld",(long)bottomYear]];
//                NSLog(@"events:%@",eventsArray);
                
                for(int i=0;i<eventsArray.count;i++){
                    NSInteger sect = ([eventsArray[i][@"date_year"]integerValue] - topYear)*12 + [eventsArray[i][@"date_month"]integerValue] - 1;  //取得section資訊
                    [dataArray[sect][3][[eventsArray[i][@"date_day"] integerValue]-1] addObject:eventsArray[i]];//置入完整的Dic
                }
                
                [self performSelector:@selector(reload) withObject:nil afterDelay:0.1];
                //將修改後的資料存入singleton
                myDB *dataObject = [myDB sharedInstance];
                dataObject.dataArray = dataArray;
                dataObject.bottomYear = [NSNumber numberWithInteger:bottomYear];
                //往後增加一年
            }else if (indexPath.section==0&& indexPath.row==27){
                [_myCollectionView setScrollEnabled:NO];
                [_myCollectionView setUserInteractionEnabled:NO];
                [self performSelector:@selector(reloadTop) withObject:nil afterDelay:0];
                NSLog(@"reloadTop");
                //往前增加一年
                //將修改後的資料存入singleton
            }
        }
        
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        
        //將cell中的Label.Tag設為100 就會自動找到相對應的Label
        UILabel *label = (UILabel *)[cell viewWithTag:100];
        UIButton *button1 = (UIButton *)[cell viewWithTag:101];
        UIButton *button2 = (UIButton *)[cell viewWithTag:102];
        UIButton *button3 = (UIButton *)[cell viewWithTag:103];
        UIButton *cellBtn = (UIButton *)[cell viewWithTag:388];
        
        //設定框線及框線顏色
        cell.contentView.backgroundColor =nil;
        cell.backgroundColor =nil;
        
        //設定當cell中的Label被點時會做什麼動作
        
//        [label addGestureRecognizer:TapGesture];
        label.userInteractionEnabled = NO;
        label.text = nil;
        
        cellBtn.userInteractionEnabled = NO;
        [button1 setImage:nil forState:UIControlStateNormal];
        [button2 setImage:nil forState:UIControlStateNormal];
        [button3 setImage:nil forState:UIControlStateNormal];
        
        //設定cell中的Label要show日期
        if (indexPath.row<[dataArray[indexPath.section][1] intValue]) {
            NSString *strs = dataArray[indexPath.section][0][indexPath.row];
            if ([strs isEqualToString:@"space"]) {
                label.text = nil;
            }else{
//                cell.userInteractionEnabled = YES;
                cellBtn.userInteractionEnabled = YES;
                [cellBtn addTarget:self action:@selector(cellBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                label.text = strs;
                cell.tag = [strs integerValue];
                
                //cell的todayHighlight
                if (indexPath.section == todaySection && [strs isEqualToString:[NSString stringWithFormat:@"%li",(long)todayDay]]) {
                    cell.backgroundColor = [UIColor colorWithCGColor:[self getColorFromRed:254 Green:255 Blue:157 Alpha:1]];
                }
            }
            
            int tmp= [dataArray[indexPath.section][2] intValue];
            if (indexPath.row >= tmp) {
                
                NSArray *tmpBtnArray = @[button1,button2,button3];
                
                //TODO:是否不需要？
                /*
                 for (int i = 0 ; i<[dataArray[indexPath.section][3][indexPath.row - tmp] count]; i++) {
                 [tmpBtnArray[i] setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",dataArray[indexPath.section][3][indexPath.row - tmp][i][@"stamp_id"]]] forState:UIControlStateNormal];
                 }
                 */
                
                //將貼圖依據position擺放正確位置
                for (int i = 0 ; (i<[dataArray[indexPath.section][3][indexPath.row - tmp] count]) && (i<3); i++) {
                    
                    int box = [dataArray[indexPath.section][3][indexPath.row - tmp][i][@"position"] intValue]-1;
                    if (box != 98) {
                        NSString *imageStr = dataArray[indexPath.section][3][indexPath.row - tmp][i][@"stamp_id"];
                        
                        //如果存的是自訂貼圖
                        if ([[imageStr substringToIndex:1]isEqualToString:@"6"]) {
                            
                            NSString* path = [stamptargetdir stringByAppendingPathComponent:imageStr];
                            
                            [tmpBtnArray[box] setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
                        }else{
                            [tmpBtnArray[box] setImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
                        }
                    }
                }
            }
            
            //設定六日的日期要灰色顏色
            if (indexPath.row % 7 == 6 || indexPath.row % 7 == 0) {
                label.textColor = [UIColor lightGrayColor];
            }else{
                label.textColor = [UIColor blackColor];
            }
        }
        return cell;
    }
}


-(void)reload{
    [_myCollectionView reloadData];
}

-(void)reloadTop{
    start = NO;
    topYear--;
    for (int i = 12; i>0; i--) {
        NSMutableArray *tmpArray = [NSMutableArray new];
        NSMutableArray *calendarCreate =[self calendarCreate:topYear getmonth:i];
        
        [tmpArray addObject:calendarCreate[0]];//section的array(含有space)
        NSInteger tmpCount = [tmpArray[0] count];
        [tmpArray addObject:[NSString stringWithFormat:@"%li",(long)tmpCount]];//section的count(含有space)
        NSInteger space = tmpCount - [tmpArray[0][tmpCount-1] intValue];
        [tmpArray addObject:[NSString stringWithFormat:@"%li",(long)space]];//space的count
        
        NSMutableArray *tmpDayArray = [NSMutableArray new];
        for (int l = 0 ; l< tmpCount-space ; l++) {
            NSMutableArray *button = [NSMutableArray new];
            [tmpDayArray addObject:button];
        }
        
        [tmpArray addObject:tmpDayArray];
        [tmpArray addObject:calendarCreate[1]];
        [dataArray insertObject:tmpArray atIndex:0];//增加一個dataArray用來之後存放圖片
    }
    
    //用eventsArray去接收新Topyear的資料===============
    NSArray *eventsArray = [[myDB sharedInstance] querySecheduleFromYear:[NSString stringWithFormat:@"%ld",(long)topYear]
                                                                  ToYear:[NSString stringWithFormat:@"%ld",(long)topYear]];
//    NSLog(@"events:%@",eventsArray);
    
    
    for(int i=0;i<eventsArray.count;i++){
        NSInteger sect = ([eventsArray[i][@"date_year"]integerValue] - topYear)*12 + [eventsArray[i][@"date_month"]integerValue] - 1;  //取得section資訊
        [dataArray[sect][3][[eventsArray[i][@"date_day"] integerValue]-1] addObject:eventsArray[i]];                //置入完整的Dic
    }
    
    todaySection = (todayYear-topYear)*12+(todayMonth-1);
    
    [_myCollectionView reloadData];
    
    [_myCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[[self calendarCreate:topYear
                                                                                          getmonth:13][0] count]-1 inSection:12]
                              atScrollPosition:UICollectionViewScrollPositionBottom
                                      animated:NO];
    myDB *dataObject = [myDB sharedInstance];
    dataObject.dataArray = dataArray;
    dataObject.topYear = [NSNumber numberWithInteger:topYear];
    start = YES;
    [_myCollectionView setScrollEnabled:YES];
    [_myCollectionView setUserInteractionEnabled:YES];
    
}


//cell的Size大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView == self.picCollectionView) {
        return  stampCollectionViewCellSize;
    }
    else{
        if ([dataArray[indexPath.section][1]integerValue]>35) {
            return cellSize6;
        }else if ([dataArray[indexPath.section][1]integerValue]<29){
            return cellSize4;
        }else{
            return cellSize5;
        }
    }
}

//cell 被選擇時改變cell顏色
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //TODO:是否不需要？
    
//    if (collectionView == self.picCollectionView) {
//        
//    }
//    else{
//        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//        UILabel *label = (UILabel *)[cell viewWithTag:100];
//        cell.contentView.backgroundColor = [UIColor orangeColor];
//        [myDB sharedInstance].nowSection = [NSNumber numberWithInteger:indexPath.section];
//        [myDB sharedInstance].nowRow = [NSNumber numberWithInteger:[label.text intValue]-1];
////        [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionTransitionNone animations:^{
////            //
////        } completion:^(BOOL finished) {
////            //
////            self.tabBarController.selectedIndex = 2;
////        }];
//        
//    }
}

//collection翻頁的時候 滑完的時候
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == self.picCollectionView) {
        [picButton2 removeFromSuperview];
    }
    else{
        NSIndexPath *indexPath =
        [self.myCollectionView indexPathForItemAtPoint:
         [self.view convertPoint:[self.view center] toView:self.myCollectionView]];
        [myDB sharedInstance].nowSection = [NSNumber numberWithInteger:indexPath.section];
        if (indexPath.section == todaySection) {
            [myDB sharedInstance].nowRow = [NSNumber numberWithInteger:todayDay-1];
        }else{
            [myDB sharedInstance].nowRow = [NSNumber numberWithInteger:0];
        }
    }
}

//滑動的時候
-(void)scrollViewDidScroll:(UIScrollView *)sender {
    [picButton2 removeFromSuperview];
}

//cell 不被選擇時清空cell顏色
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.picCollectionView) {
    
    }else{
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        cell.contentView.backgroundColor = nil;
    }
}

-(void)LabelClicked:(UITapGestureRecognizer *)sender{
    
    //TODO:是否不需要？
    
    //測試Label是否有被點擊到並輸出點擊的日期
//    NSLog(@"%@",sender);
    
}

//顯示Header的方法
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView == self.picCollectionView) {
        return nil;
    }else{
        UICollectionReusableView *ReusableView = nil;
        
        //去尋找Header的Identifier為HeaderView 並建立
        Header *HeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                withReuseIdentifier:@"HeaderView"
                                                                       forIndexPath:indexPath];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        
        //設定date顯示
        [formatter setDateFormat:@"yyyy-MM"];
        
        //設定日期
        NSDateComponents *components = [[NSDateComponents alloc]init];

        [components setDay:1];
        [components setMonth:1+indexPath.section];
        [components setYear:topYear];

        NSDate *Firstday = [CalenderOfMonth dateFromComponents:components];
        
        //在Header輸出年.月
        HeaderView.CalendarHeaderLabel.text = [formatter stringFromDate:Firstday];
        
        NSMutableDictionary *typeDic = [myDB sharedInstance].typeDic;
        HeaderView.CalendarHeaderLabel.textColor = typeDic[@"wordColor"];
        HeaderView.view.backgroundColor = typeDic[@"wordBackColor"];
        
        HeaderView.oneWeek.image =[UIImage imageNamed: typeDic[@"oneWeek"]];
        
        ReusableView = HeaderView;
        
        return ReusableView;
    }
}


#pragma mark - customstamp
- (IBAction)customstamp:(id)sender {
    [self stampBtnClick5:self.stamp5];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CustomStamp" bundle:nil];
    id targetVC = [storyBoard instantiateViewControllerWithIdentifier:@"CustomStamp"];
    [self presentViewController:targetVC animated:true completion:nil];
}


#pragma mark - textView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"請輸入事項"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"請輸入事項";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}


#pragma mark - createCalendar method
//建立月曆日期
-(NSMutableArray *)calendarCreate:(NSInteger)getyear getmonth:(NSInteger)getMonth{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    //設定date顯示
    [formatter setDateFormat:@"yyyy-MM"];
    
    //設定要回傳月份的Array
    NSMutableArray *DateArray = [NSMutableArray new];
    NSMutableArray *tmpWeekArray = [NSMutableArray new];
    
    //設定日期
    NSDateComponents *components = [[NSDateComponents alloc]init];
    [components setDay:1];
    [components setMonth:getMonth];
    [components setYear:getyear];
    
    NSDate *Firstday = [CalenderOfMonth dateFromComponents:components];
    
    //求出這個月有幾天
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSRange range = [cal rangeOfUnit:NSDayCalendarUnit
                              inUnit:NSMonthCalendarUnit forDate:Firstday];
    NSUInteger NumberOfDaysInMonth = range.length;
    
    //求出這個月第一天是星期幾 星期日:1 星期一:2
    NSDateComponents *DayComponents = [CalenderOfMonth components:(NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitMonth | NSCalendarUnitYear)
                                                         fromDate:Firstday];
    NSInteger FirstDay = [DayComponents weekday];
    
    //利用Firstday的值算出這個月前面要空幾天並加入DateArray
    switch (FirstDay) {
        case 1:
            weekNumber = 0;
            for (int i=1; i<=NumberOfDaysInMonth; i++) {
                
                [DateArray addObject:[NSString stringWithFormat:@"%i",i]];
                
                [tmpWeekArray addObject:[NSNumber numberWithInt:weekNumber]];
                weekNumber++;
                if (weekNumber>6) {
                    weekNumber=0;
                }
            }
            break;
        case 2:
            weekNumber = 1;
            for (int i=1; i<=NumberOfDaysInMonth+1; i++) {
                if (i<2) {
                    [DateArray addObject:@"space"];
                }
                else {
                    [DateArray addObject:[NSString stringWithFormat:@"%i",i-1]];
                }
                
                [tmpWeekArray addObject:[NSNumber numberWithInt:weekNumber]];
                weekNumber++;
                if (weekNumber>6) {
                    weekNumber=0;
                }
            }
            break;
        case 3:
            weekNumber = 2;
            for (int i=1; i<=NumberOfDaysInMonth+2; i++) {
                if (i<3) {
                    [DateArray addObject:@"space"];
                }
                else {
                    [DateArray addObject:[NSString stringWithFormat:@"%i",i-2]];
                }
                
                [tmpWeekArray addObject:[NSNumber numberWithInt:weekNumber]];
                weekNumber++;
                if (weekNumber>6) {
                    weekNumber=0;
                }
            }
            break;
        case 4:
            weekNumber = 3;
            for (int i=1; i<=NumberOfDaysInMonth+3; i++) {
                if (i<4) {
                    [DateArray addObject:@"space"];
                }
                else {
                    [DateArray addObject:[NSString stringWithFormat:@"%i",i-3]];
                }
                
                [tmpWeekArray addObject:[NSNumber numberWithInt:weekNumber]];
                weekNumber++;
                if (weekNumber>6) {
                    weekNumber=0;
                }
            }
            break;
        case 5:
            weekNumber = 4;
            
            for (int i=1; i<=NumberOfDaysInMonth+4; i++) {
                if (i<5) {
                    [DateArray addObject:@"space"];
                }
                else {
                    [DateArray addObject:[NSString stringWithFormat:@"%i",i-4]];
                }
                [tmpWeekArray addObject:[NSNumber numberWithInt:weekNumber]];
                weekNumber++;
                if (weekNumber>6) {
                    weekNumber=0;
                }
            }
            break;
        case 6:
            weekNumber = 5;
            
            for (int i=1; i<=NumberOfDaysInMonth+5; i++) {
                if (i<6) {
                    [DateArray addObject:@"space"];
                }
                else {
                    [DateArray addObject:[NSString stringWithFormat:@"%i",i-5]];
                }
                [tmpWeekArray addObject:[NSNumber numberWithInt:weekNumber]];
                weekNumber++;
                if (weekNumber>6) {
                    weekNumber=0;
                }
            }
            break;
        case 7:
            weekNumber = 6;
            for (int i=1; i<=NumberOfDaysInMonth+6; i++) {
                if (i<7) {
                    [DateArray addObject:@"space"];
                }
                else {
                    [DateArray addObject:[NSString stringWithFormat:@"%i",i-6]];
                }
                
                [tmpWeekArray addObject:[NSNumber numberWithInt:weekNumber]];
                weekNumber++;
                if (weekNumber>6) {
                    weekNumber=0;
                }
            }
            break;
        default:
            break;
            
    }
    NSMutableArray *tmp = [[NSMutableArray alloc]initWithObjects:DateArray,tmpWeekArray, nil];
    
    //傳回值至DateArray
    return tmp;
}


/*得到RGB顏色*/
#pragma mark - RGB method
-(CGColorRef) getColorFromRed:(int)red Green:(int)green Blue:(int)blue Alpha:(int)alpha{
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


-(void)stopAnimating:(UIImageView *)sender{
    [sender setUserInteractionEnabled:NO];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"didFinishLaunchingWithOptions" object:nil];

    [self.view addSubview:bannerView_];
    for (UIView *v in self.view.subviews) {
        if (v.tag == 999 ) {
            [v removeFromSuperview];
        }else if([v isKindOfClass:[UIImageView class]]){
            [(UIImageView *)v stopAnimating];
        }
    }
    
    UIView *tmpBgView = [[UIView alloc] initWithFrame:_picCollectionView.frame];
    tmpBgView.backgroundColor = _picCollectionView.backgroundColor;
    [self.view addSubview:tmpBgView];
    [self.view bringSubviewToFront:_picCollectionView];
    
    [self addTrashCan];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    PopViewController *vc = segue.destinationViewController;
    vc.parentVC = self;
}

-(void)toNotifDate:(NSNotification *)sender{
    self.tabBarController.selectedIndex = 2;
}


#pragma mark - stampBtn
- (IBAction)stampBtnClick1:(id)sender {
    imagePackage = [NSMutableArray new];
    for (int i = 2000; i<=2022; i++) {
        [imagePackage addObject:[NSString stringWithFormat:@"%d.png",i]];
    }
    [self normalStampSetting:sender];
}

- (IBAction)stampBtnClick2:(id)sender {
    imagePackage = [NSMutableArray new];
    for (int i = 3000; i<=3015; i++) {
        [imagePackage addObject:[NSString stringWithFormat:@"%d.png",i]];
    }
    [self normalStampSetting:sender];
}

- (IBAction)stampBtnClick3:(id)sender {
    imagePackage = [NSMutableArray new];
    for (int i = 4000; i<=4014; i++) {
        [imagePackage addObject:[NSString stringWithFormat:@"%d.png",i]];
    }
    [self normalStampSetting:sender];
}

- (IBAction)stampBtnClick4:(id)sender {
    imagePackage = [NSMutableArray new];
    for (int i = 5000; i<=5015; i++) {
        [imagePackage addObject:[NSString stringWithFormat:@"%d.png",i]];
    }
    [self normalStampSetting:sender];
}

- (IBAction)stampBtnClick5:(id)sender
{
    [self buttonSelectedTransform:sender];
    
    imagePackage = [NSMutableArray new];
    imagePackage = [myDB sharedInstance].customStampArray;
    customStampTypeSelected = YES;
    [self.picCollectionView reloadData];
    
    _trashCan.hidden = NO;
}

- (void)normalStampSetting:(id)nomalStampButton
{
    customStampTypeSelected = NO;
    [self.picCollectionView reloadData];
    [self buttonSelectedTransform:nomalStampButton];
    
    _trashCan.hidden = YES;
}



-(void)buttonSelectedTransform:(UIButton *)sender{
    for (UIButton *btn in stampButtonArray) {
        if (btn == sender) {
            [btn setTransform:CGAffineTransformMakeScale(1.3, 1.3)];
            [btn setAlpha:1.0];
        }else{
            [btn setTransform:CGAffineTransformMakeScale(1, 1)];
            [btn setAlpha:0.9];
        }
    }
}


#pragma mark - 切換主題
-(void)changeTheme:(id)sender{
    
    NSDictionary *typeDic = [myDB sharedInstance].typeDic;
    self.background.image = [UIImage imageNamed:typeDic[@"background"]];
    self.top.image = [UIImage imageNamed:typeDic[@"top"]];
    [self.todayBtn setImage:[UIImage imageNamed:typeDic[@"todayBtn"]] forState:UIControlStateNormal];
    [self.settingBtn setImage:[UIImage imageNamed:typeDic[@"settingBtn"]] forState:UIControlStateNormal];
    [self.weekBtn setImage:[UIImage imageNamed:typeDic[@"week"]] forState:UIControlStateNormal];
    [self.dayBtn setImage:[UIImage imageNamed:typeDic[@"day"]] forState:UIControlStateNormal];
    [self.monthBtn setImage:[UIImage imageNamed:typeDic[@"month"]] forState:UIControlStateNormal];
    [self.stamp1 setImage:[UIImage imageNamed:typeDic[@"stamp1"]] forState:UIControlStateNormal];
    [self.stamp2 setImage:[UIImage imageNamed:typeDic[@"stamp2"]] forState:UIControlStateNormal];
    [self.stamp3 setImage:[UIImage imageNamed:typeDic[@"stamp3"]] forState:UIControlStateNormal];
    [self.stamp4 setImage:[UIImage imageNamed:typeDic[@"stamp4"]] forState:UIControlStateNormal];
    [self.stamp5 setImage:[UIImage imageNamed:typeDic[@"stamp5"]] forState:UIControlStateNormal];
}

-(void)cellBtnClick:(UIButton *)sender{
    UICollectionViewCell *cell = (UICollectionViewCell *)[[sender superview]superview ];
     NSIndexPath *targetIndexPath = [self.myCollectionView indexPathForCell:cell];
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    
    [myDB sharedInstance].nowSection = [NSNumber numberWithInteger:targetIndexPath.section];
    [myDB sharedInstance].nowRow = [NSNumber numberWithInteger:[label.text intValue]-1];
    self.tabBarController.selectedIndex = 2;
}

#pragma mark - CustomLoading
- (IBAction)CustomeLoadingBtn:(id)sender {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CustomLoading" bundle:nil];
    id targetVC = [storyBoard instantiateViewControllerWithIdentifier:@"CustomLoading"];
    [self presentViewController:targetVC animated:true completion:nil];
}

#pragma mark - 新增老鼠裝扮
-(void)changeMouseSuit{
    UIImageView *face = [UIImageView new];
    UIImageView *cloth = [UIImageView new];
    UIImageView *head = [UIImageView new];
    UIImageView *equipment = [UIImageView new];
    
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,
                                                                     self.view.frame.size.height/1.937,
                                                                     (self.view.frame.size.height/1.937)*0.93)];
    
    backgroundView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height*0.4);
    UIImageView *mouse = [UIImageView new];
    
    float width = backgroundView.frame.size.width;
    float height = backgroundView.frame.size.height;
    mouse.frame = CGRectMake(0, 0, width, height);
    face.frame = CGRectMake(width/2-width*0.704*0.5, height*0.115, width*0.704, height*0.552);
    cloth.frame = CGRectMake(width/2-width*0.5633*0.5-3, height*0.6, width*0.5633, height*0.3421);
    head.frame = CGRectMake(width/2-width*0.845*0.5, 0, width*0.845, height*0.763);
    equipment.frame = CGRectMake(width*0.031, height*0.0606, width*0.7042, height*0.8026);
    
    
    //製作動畫
//    mouse.image = [UIImage imageNamed:@"customloading_mouse.png"];
    face.image = [UIImage imageNamed:[myDB sharedInstance].scoreDict[@"face"]];
    head.image = [UIImage imageNamed:[myDB sharedInstance].scoreDict[@"head"]];
    
    NSArray *clothArray = [[NSArray alloc]initWithObjects:[UIImage imageNamed:[myDB sharedInstance].scoreDict[@"cloth1"]],
                                                        [UIImage imageNamed:[myDB sharedInstance].scoreDict[@"cloth2"]], nil];
    [cloth setAnimationImages:clothArray];
    [cloth setAnimationDuration:0.5];   //total
    [cloth setAnimationRepeatCount:0];    //重複
    
    NSArray *mouseArray = [[NSArray alloc]initWithObjects:[UIImage imageNamed:@"customloading_mouse.png"],
                                                        [UIImage imageNamed:@"customloading_mouse_1.png"], nil];
    [mouse setAnimationImages:mouseArray];
    [mouse setAnimationDuration:0.5];   //total
    [mouse setAnimationRepeatCount:0];    //重複
    
    NSString *clothStr = [myDB sharedInstance].scoreDict[@"equipment"];
    NSString *cloth_1Str = [NSString stringWithFormat:@"%@_1",clothStr];
    NSArray *equipmentArray = [[NSArray alloc]initWithObjects:[UIImage imageNamed:clothStr],[UIImage imageNamed:cloth_1Str], nil];
    [equipment setAnimationImages:equipmentArray];
    [equipment setAnimationDuration:0.5];   //total
    [equipment setAnimationRepeatCount:0];    //重複
    
    
    [self.view addSubview:backgroundView];
    [backgroundView addSubview:mouse];
    [backgroundView addSubview:face];
    [backgroundView addSubview:cloth];
    [backgroundView addSubview:head];
    [backgroundView addSubview:equipment];
    backgroundView.tag  = 999;
    
    [cloth startAnimating];
    [mouse startAnimating];
    [equipment startAnimating];

//    [equipment setTransform:CGAffineTransformMakeRotation(30*M_PI_2/180)];
    
}

- (void) setLoadingView{
    //do loading
    
    NSArray *loadingwords = @[[UIImage imageNamed:@"Loading_1.png"],
                              [UIImage imageNamed:@"Loading_2.png"],
                              [UIImage imageNamed:@"Loading_3.png"],
                              [UIImage imageNamed:@"Loading_4.png"],
                              [UIImage imageNamed:@"Loading_5.png"],
                              [UIImage imageNamed:@"Loading_6.png"],
                              [UIImage imageNamed:@"Loading_7.png"],
                              [UIImage imageNamed:@"Loading_8.png"],
                              [UIImage imageNamed:@"Loading_9.png"],
                              [UIImage imageNamed:@"Loading_10.png"]];
    
    loadingview = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIImageView *loadingwordsview = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-292)/2+100,
                                                                                  self.view.frame.size.height*0.8,
                                                                                  146,
                                                                                  30)];
    
    [loadingwordsview setAnimationImages:loadingwords];
    [loadingwordsview setAnimationDuration:1.0];  //total
    [loadingwordsview setAnimationRepeatCount:0];  //重複
    
    [loadingview setUserInteractionEnabled:YES];
    loadingview.image = [UIImage imageNamed:@"loadingScreen1.png"];
    loadingview.tag = 999;
    [self.view addSubview:loadingview];
    [self.view addSubview:loadingwordsview];
    
    
#pragma mark - 讀取分數和裝備
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *scorePlistPath = [self getPathWithName:@"Score.plist"];
    
    if (![fileManager fileExistsAtPath:scorePlistPath]) {
        //若第一次開app,則建立score.plist檔
        
        NSMutableDictionary *tmpSettingDict = [NSMutableDictionary new];
        //        NSDate *nowDate = [NSDate date];
        //        nowDate settime
        tmpSettingDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"0",@"score",[NSDate date],@"lastStartDate",@"",@"face",@"",@"cloth1",@"",@"cloth2",@"",@"head",@"",@"equipment", nil];
        
        [tmpSettingDict writeToFile:scorePlistPath atomically:YES];
        [myDB sharedInstance].scoreDict = tmpSettingDict;
        [myDB sharedInstance].firstOpenAppBonus = @"YES";
        [myDB sharedInstance].lastScore = 0;
        [myDB sharedInstance].score = 1;
    }else{
        [myDB sharedInstance].scoreDict=[[NSMutableDictionary alloc]initWithContentsOfFile:scorePlistPath];
        //如果score.plist存在則拿出來用
        [myDB sharedInstance].lastScore = [[myDB sharedInstance].scoreDict[@"score"] integerValue];
        [myDB sharedInstance].score = [myDB sharedInstance].lastScore;
    }
    
    
    [self changeMouseSuit];
    [loadingview startAnimating];
    [loadingwordsview startAnimating];
    
    // loginview time
    [self performSelector:@selector(stopAnimating:) withObject:loadingview afterDelay:2.5];
    
}

#pragma mark - getPath
- (NSString *) getPathWithName:(NSString *)name{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask, YES);
    NSString *documentPath = [paths firstObject];
    NSString *plistPath = [documentPath stringByAppendingPathComponent:name];
    return  plistPath;
}

#pragma mark - setAD
- (void) setAD{
    //在螢幕上方建立標準大小的視圖，
    //可用的 AdSize 常值已在 GADAdSize.h 中解釋。
    //bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    //在畫面下方建立標準廣告大小的畫面。  //4s:480   //5:568    //6:736
    //GAD_SIZE_320x50 就是你的bannerView的size 其中320就是寬度(width), 50就是高度(height)
    
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    
    if(self.view.frame.size.height < 500){
        
        bannerView_.frame = CGRectMake(0.0,
                                                                      self.view.frame.size.height - GAD_SIZE_320x50.height + 10,
                                                                      self.view.frame.size.width,
                                                                      GAD_SIZE_320x50.height);
        
    }else if (self.view.frame.size.height > 500 && self.view.frame.size.height < 700 ){
        
        bannerView_.frame = CGRectMake(0.0,
                                                                      self.view.frame.size.height - GAD_SIZE_320x50.height + 5,
                                                                      self.view.frame.size.width,
                                                                      GAD_SIZE_320x50.height);
        
    }else if (self.view.frame.size.height > 700){
        
        bannerView_.frame = CGRectMake(0.0,
                                                                      self.view.frame.size.height - GAD_SIZE_320x50.height,
                                                                      self.view.frame.size.width,
                                                                      GAD_SIZE_320x50.height);
    }
    
    bannerView_.adUnitID = @"ca-app-pub-7556127145229222/1403677991";  //指定廣告單元編號。
    
    /* 通知執行階段,將使用者帶往廣告到達頁面後,該恢復哪個UIViewController 並將其加入檢視階層中*/
    bannerView_.rootViewController = self;
    
    GADRequest *gadRequest = [GADRequest request];
    
    gadRequest.testDevices = @[kGADSimulatorID,@"6dfe062fe11f7bc378aa9f92c86f54f7"];
    
    // 啟動一般請求，隨著廣告一起載入。
    [bannerView_ loadRequest:gadRequest];   //實際
    
    
    //[bannerView_ loadRequest:[self createTestRequest]];  //測試
    
    //NSLog(@"height: %f",self.view.frame.size.height);
}

// 設定一些必要的值
- (void)config
{
    // 貼圖列按鈕
    stampButtonArray = @[_stamp1,_stamp2,_stamp3,_stamp4,_stamp5];
    
    // 預設貼圖為stamp1
    [self stampBtnClick1:_stamp1];
    
    // 用來算日期的
    weekArray = @[@"Sun",@"Mon",@"Tue",@"Wed",@"Thu",@"Fri",@"Sat"];
    
    // 透明度
    _dayBtn.alpha = 0.5;
    _weekBtn.alpha = 0.5;
    
    // 增加一個換主題的observer
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeTheme:) name:@"CHANGETHEME" object:nil];
    
    //設定點擊推播會進來的Observer
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(toNotifDate:) name:@"REFRESHTONOTIFDATE" object:nil];
    
    // 設定初始theme type
    currentType =[myDB sharedInstance].settingDict[@"themeType"];
    [[myDB sharedInstance]changeThemeType:currentType];
    [self changeTheme:nil];
    
    // 設定cellwidth
    cellwidth = self.view.frame.size.width/7.01 ;
    
    //設定collecctionView的位置在第幾個section
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSRange range = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:[NSDate date]];
    numberOfDaysInToday = range.length;
    
    // 設定cellsize變數
    cellSize4 = CGSizeMake(cellwidth,(self.view.frame.size.height/2-50)/4);
    cellSize5 = CGSizeMake(cellwidth,(self.view.frame.size.height/2-50)/5);
    cellSize6 = CGSizeMake(cellwidth,(self.view.frame.size.height/2-50)/6);
    
    stampCollectionViewCellSize = CGSizeMake(self.picCollectionView.frame.size.height*0.4, self.picCollectionView.frame.size.height*0.4);
}

- (void)addTrashCan
{
    if (_trashCan == nil)
    {
        CGFloat width = _stamp5.frame.size.width;
        
        CGRect rect = CGRectMake(0, 0, width, width);
        
        _trashCan = [[TrashCanButton alloc] initWithFrame:rect];
        
        _trashCan.center = CGPointMake(self.view.frame.size.width - width/2, _picCollectionView.frame.origin.y + _picCollectionView.frame.size.height/2);
        
        [self.view addSubview:_trashCan];
        
        _trashCan.hidden = YES;
    }
    else
    {
        _trashCan.hidden = NO;
    }
}


@end
