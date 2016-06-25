//
//  TableViewController.m
//  Calender_bycandy
//
//  Created by candy on 2015/5/27.
//  Copyright (c) 2015年 candy. All rights reserved.
//

#import "TableViewController.h"
#import "ViewController.h"
#import "myDB.h"
#import "PicButton.h"
#import <objc/runtime.h>
#import "JMWhenTapped.h"
#import "PopTableViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CustomStampFilter.h"
#import "TrashCanButton.h"


static char btnInfoKey;
static char btnTmpKey;

@interface TableViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,buttonDelegate,AVAudioPlayerDelegate>{
    
    NSMutableArray *dataArray;
    NSCalendar *CalenderOfMonth;
    NSInteger TodaySection,TodayDay,TodayMonth,TodayYear,topYear,bottomYear;
    UIButton *popBtn_Trash,*popBtn,*backView;
    //貼圖
    NSMutableArray *imagePackage;
    PicButton *picButton2;
    BOOL customStampTypeSelected;//目前自訂貼圖是否被打開
    NSString *stamptargetdir;
    
    BOOL goToPopOver;//判斷是否進入popover
    
    int count;  //計算進入錄音次數
    UIButton *onPlayBtn;
    NSArray *stampButtonArray;
    
    NSArray *weekArray;
    
    // 貼圖的cellsize
    CGSize stampCollectionViewCellSize;
}
@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (weak, nonatomic) IBOutlet UIButton *monthBtn;
@property (weak, nonatomic) IBOutlet UIButton *weekBtn;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *stampCollectionView; //貼圖
@property (strong, nonatomic) PopTableViewController *popViewController;

@property (weak, nonatomic) IBOutlet UIImageView *top;
@property (weak, nonatomic) IBOutlet UIButton *dayBtn;
@property (weak, nonatomic) IBOutlet UIButton *todayBtn;
@property (weak, nonatomic) IBOutlet UIButton *settingBtn;
@property (weak, nonatomic) IBOutlet UIButton *stamp1;
@property (weak, nonatomic) IBOutlet UIButton *stamp2;
@property (weak, nonatomic) IBOutlet UIButton *stamp3;
@property (weak, nonatomic) IBOutlet UIButton *stamp4;
@property (weak, nonatomic) IBOutlet UIButton *stamp5;
@property (weak, nonatomic) IBOutlet UIImageView *background;

//播放錄音
@property (strong, nonatomic) AVAudioPlayer *voicePlayer;

@property (strong, nonatomic) TrashCanButton *trashCan;


@end

@implementation TableViewController

- (IBAction)settingBtnClick:(id)sender {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Setting" bundle:nil]; //創建StoryBoard的實體
    
    id targetViewController = [storyBoard instantiateViewControllerWithIdentifier:@"Setting"];
    
    [self presentViewController:targetViewController animated:true completion:nil];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // 用來算日期的
    weekArray = @[@"Sun",@"Mon",@"Tue",@"Wed",@"Thu",@"Fri",@"Sat"];
    
    goToPopOver = NO;
    _popViewController = self.childViewControllers[0];
    [_popViewController.view removeFromSuperview];
    stampButtonArray = @[_stamp1,_stamp2,_stamp3,_stamp4,_stamp5];
    stampCollectionViewCellSize = CGSizeMake(self.stampCollectionView.frame.size.height*0.40,
                                             self.stampCollectionView.frame.size.height*0.40);
    
    NSString *stampdir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    stamptargetdir = [stampdir stringByAppendingPathComponent:@"customstamp"];
    
    //設定popview的父viewcontroller為自己 將popview隱藏
    
    [self changeTheme:nil];
    //增加一個換主題的observer
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(changeTheme:)
                                                name:@"CHANGETHEME"
                                              object:nil];
    
    //貼圖
    [self stampBtnClick1:self.stamp1];
    
    myDB *d = [myDB sharedInstance];
    _weekBtn.alpha = 0.5 ;
    _monthBtn.alpha = 0.5;
    dataArray = [NSMutableArray new];
    dataArray = d.dataArray;
    
    CalenderOfMonth = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *Today = [NSDate date];
    CalenderOfMonth = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *WeekdayComponents = [CalenderOfMonth components:(NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:Today];
    
    //分割今天的日期
    TodayDay = [WeekdayComponents day];
    TodayYear = [WeekdayComponents year];
    TodayMonth = [WeekdayComponents month];
    
    // 在螢幕上方建立標準大小的視圖，
    // 可用的 AdSize 常值已在 GADAdSize.h 中解釋。
    //    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    // 在畫面下方建立標準廣告大小的畫面。  //4s:480   //5:568    //6:736
    //GAD_SIZE_320x50 就是你的bannerView的size 其中320就是寬度(width), 50就是高度(height)
    
    if(self.view.frame.size.height < 500){
        
        bannerView_ = [[GADBannerView alloc]
                       initWithFrame:CGRectMake(0.0,
                                                self.view.frame.size.height - GAD_SIZE_320x50.height + 10,
                                                self.view.frame.size.width,
                                                GAD_SIZE_320x50.height)];
        
    }else if (self.view.frame.size.height > 500 && self.view.frame.size.height < 700 ){
        
        bannerView_ = [[GADBannerView alloc]
                       initWithFrame:CGRectMake(0.0,
                                                self.view.frame.size.height - GAD_SIZE_320x50.height + 5,
                                                self.view.frame.size.width,
                                                GAD_SIZE_320x50.height)];
        
    }else if (self.view.frame.size.height > 700){
        
        bannerView_ = [[GADBannerView alloc]
                       initWithFrame:CGRectMake(0.0,
                                                self.view.frame.size.height - GAD_SIZE_320x50.height,
                                                self.view.frame.size.width,
                                                GAD_SIZE_320x50.height)];
        
    }
    
    bannerView_.adUnitID = @"ca-app-pub-7556127145229222/1403677991";// 指定廣告單元編號
    
    /* 通知執行階段,將使用者帶往廣告到達頁面後,該恢復哪個UIViewController 並將其加入檢視階層中*/
    bannerView_.rootViewController = self;
    
    GADRequest *gadRequest = [GADRequest request];
    
    gadRequest.testDevices = @[kGADSimulatorID,@"6dfe062fe11f7bc378aa9f92c86f54f7"];
    
    // 啟動一般請求，隨著廣告一起載入。
    [bannerView_ loadRequest:gadRequest];   //實際
    
    [self.view addSubview:bannerView_];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    if (!goToPopOver) {
        [self.myTable reloadData];
    };
    
    myDB *d = [myDB sharedInstance];
    topYear =[d.topYear integerValue];
    bottomYear = [d.bottomYear integerValue];
    TodaySection = (TodayYear-topYear)*12+(TodayMonth-1);
    _monthLabel.text = [self getMonthFromSection:[[myDB sharedInstance].nowSection intValue]];
    
    if (goToPopOver == NO) {
        [_myTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:[[myDB sharedInstance].nowRow intValue]
                                                          inSection:[[myDB sharedInstance].nowSection intValue]]
                              animated:NO
                        scrollPosition:UITableViewScrollPositionTop];
    }
    
    if (customStampTypeSelected) {
        [_stampCollectionView reloadData];
    }
    
    [self addTrashCan];
}


- (IBAction)monthBtnClick:(UIButton *)sender {
    self.tabBarController.selectedIndex = 0;
}

- (IBAction)weekBtnClick:(UIButton *)sender {
    self.tabBarController.selectedIndex = 1;
}

- (IBAction)todayBtnClick:(UIButton *)sender {
    [_myTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:TodayDay-1 inSection:TodaySection]
                          animated:YES
                    scrollPosition:UITableViewScrollPositionTop];
    [myDB sharedInstance].nowSection = [NSNumber numberWithInteger:TodaySection];
    [myDB sharedInstance].nowRow = [NSNumber numberWithInteger:TodayDay-1];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - CollectionView 貼圖
//建立Section數量
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//每個section的item數量
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
        return [imagePackage count];
}

//製作cell內容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PicButton *picButton;
    UICollectionViewCell *cell;
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"stampcell" forIndexPath:indexPath];
    if ([[cell.contentView.subviews firstObject] isKindOfClass:[PicButton class]]) {
        picButton = (PicButton *)[cell viewWithTag:106];
        if (customStampTypeSelected)
        {
            
            CGRect picCollectionFrame = _stampCollectionView.frame;
            if (picCollectionFrame.size.width >= self.view.frame.size.width)
            {
                picCollectionFrame.size.width = (self.view.frame.size.width + 8) - _stamp1.frame.size.width*1.3;
                _stampCollectionView.frame = picCollectionFrame;
            }
            
            picButton.delegate = self;
            NSString* path = [stamptargetdir stringByAppendingPathComponent:
                              [myDB sharedInstance].customStampArray[indexPath.row]];
            
            [picButton setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
            picButton.code = [myDB sharedInstance].customStampArray[indexPath.row];
        }
        else
        {//如果目前是貼圖選擇
            
            CGRect picCollectionFrame = _stampCollectionView.frame;
            if (picCollectionFrame.size.width != self.view.frame.size.width + 8)
            {
                picCollectionFrame.size.width = self.view.frame.size.width + 8;
                _stampCollectionView.frame = picCollectionFrame;
            }
            
            picButton.delegate = self;
            [picButton setImage:[UIImage imageNamed:imagePackage[indexPath.row]] forState:UIControlStateNormal];
            picButton.code = imagePackage[indexPath.row];
        }
    }else{
        
        picButton = [[PicButton alloc] init];
        picButton.frame = cell.bounds;
        picButton.tag=106;
        [cell.contentView addSubview:picButton];
        
        picButton.delegate = self;
        [picButton setImage:[UIImage imageNamed:imagePackage[indexPath.row]] forState:UIControlStateNormal];
        picButton.code = imagePackage[indexPath.row];
    }
    
    return cell;
}

//cell的Size大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
        return  stampCollectionViewCellSize;
}

//滑動的時候
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [picButton2 removeFromSuperview];
}

- (void)buttonBegin:(PicButton *)pic location:(CGPoint)loc{
    picButton2 = [PicButton new];
    picButton2.delegate=self;
    [picButton2 setImage:pic.currentImage forState:UIControlStateNormal];
    picButton2.userInteractionEnabled=YES;
    picButton2.frame = CGRectMake(loc.x, loc.y-50, pic.frame.size.width, pic.frame.size.height);
    [self.view addSubview:picButton2];
}

//移動時判斷與cell有無接觸 若有則將cell變色
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
    
    for (UITableViewCell *cell in [_myTable visibleCells]) {
        CGRect frame = [_myTable convertRect:cell.frame toView:self.view];
        if (CGRectIntersectsRect(CGRectMake(picButton2.center.x, picButton2.center.y, 0, 0), frame)) {
            cell.contentView.backgroundColor =[UIColor colorWithCGColor:[self getColorFromRed:255 Green:239 Blue:213 Alpha:1]];
        }else{
            cell.contentView.backgroundColor = nil;
        }
    }
}

- (void)buttonEnd:(PicButton *)pic location:(CGPoint)loc
{
    if (CGRectIntersectsRect(CGRectMake(picButton2.center.x, picButton2.center.y, 0, 0), _trashCan.frame))
    {
        [_trashCan hoverOut];
        
        [CustomStampFilter removeStamp:pic.code completionHandler:^(BOOL needReload) {
            //
            if (needReload)
            {
                [_stampCollectionView reloadData];
            }
        }];
    }
    else
    {
        [_trashCan hoverOut];
    }
    
    for (UITableViewCell *cell in [_myTable visibleCells]) {
        CGRect frame = [_myTable convertRect:cell.frame toView:self.view];
        if (CGRectIntersectsRect(CGRectMake(picButton2.center.x, picButton2.center.y, 0, 0), self.myTable.frame) && CGRectIntersectsRect(CGRectMake(picButton2.center.x, picButton2.center.y, 0, 0), frame)) {
            
            NSInteger sect = [_myTable indexPathForCell:cell].section;
            //將cell在collection的section及row取出
            NSInteger ro = [_myTable indexPathForCell:cell].row;
            
            //取出該格實際的日期
            NSInteger year =  sect/12 + topYear;//計算cell的年份
            NSInteger month = sect%12 + 1;//計算cell的月份
            NSIndexPath *targetIndexPath = [_myTable indexPathForCell:cell];
            NSInteger day =[_myTable cellForRowAtIndexPath:targetIndexPath].tag + 1;
//            NSLog(@"year:%ld,month:%ld,day:%ld",(long)year,(long)month,(long)day);
            if([dataArray[sect][3][day-1]count]<10){
            
                if([dataArray[sect][3][day-1]count] > 0){
    //                NSLog(@"Cell高 %f",cell.frame.size.height);
                    CGRect cellFrame = cell.frame;
                    
                    cellFrame.size.height +=108;
                    CGPoint cellPoint = CGPointMake(cell.frame.origin.x, cell.frame.origin.y+cell.frame.size.height+108-self.myTable.frame.size.height);
                    
                    [UIView transitionWithView:cell duration:0.1 options:UIViewAnimationOptionTransitionNone animations:^{
                       
                        [cell setFrame:cellFrame];
                        [cell setNeedsLayout];
                        
                    } completion:^(BOOL finished) {
                        //
                        [cell setNeedsLayout];
                        [self.myTable setContentOffset:cellPoint animated:YES];
    //                    [_myTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:ro inSection:sect] animated:YES scrollPosition:UITableViewScrollPositionBottom];
                    }];
                }
                
                NSInteger box;//第幾個貼圖格
                
                //先把圖放上去
                UIImageView *stampView = (UIImageView *)[cell viewWithTag:300+[dataArray[sect][3][ro]count]];
                [stampView setImage:pic.currentImage];
                
                //把圖先放到DayArray
                //每天的資料dic [格子位置-[         空格數目           ]]
                // if ([dataArray[sect][3][ro] count]<4) {
                BOOL eventOnBox1 = false; //已有事件在貼圖第一格
                BOOL eventOnBox2 = false; //已有事件在貼圖第二格
                BOOL eventOnBox3 = false; //已有事件在貼圖第三格
                for (NSDictionary* tmpDic in dataArray[sect][3][ro]) {
                    switch ([tmpDic[@"position"] intValue]) {
                        case 1:
                            eventOnBox1 = true;
                            break;
                        case 2:
                            eventOnBox2 = true;
                            break;
                        case 3:
                            eventOnBox3 = true;
                            break;
                        default:
                            break;
                    }
                }
                
                if(eventOnBox1 == false){
                    box = 1;
                }else if(eventOnBox2 == false){
                    box = 2;
                }else if(eventOnBox3 == false){
                    box = 3;
                }else{
                    box = 99;
                }
                
                [cell setNeedsLayout];
    //            NSLog(@"reload結束");
                
                //重整collectionview
                UIView *popView = [UIView new];
                popView.frame = CGRectMake(0, 0, (frame.size.width/5)+12, 45);
                if ([dataArray[sect][3][day-1]count]==0) {
                    popView.center = CGPointMake(frame.size.width/2, picButton2.center.y);
                
                }else{
                    popView.center = CGPointMake(frame.size.width/2,
                                                 self.myTable.frame.origin.y + self.myTable.frame.size.height-40);
                }
                
                UIImageView *popViewImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, (frame.size.width/5)+12, 45)];
                popViewImage.image = [UIImage imageNamed:@"main_popover_under.png"];
                
                //跳出新增事件的視窗
                popBtn = [[UIButton alloc]initWithFrame:CGRectMake(4, 15, frame.size.width/10, 27)];
                popBtn_Trash = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width/10+8, 15,
                                                                          frame.size.width/10, 27)];
                
                [popBtn_Trash setImage:[UIImage imageNamed:@"main_popover_trash.png"]
                              forState:UIControlStateNormal];
                
                //[popBtn setTitle:@"新增" forState:UIControlStateNormal];
                [popBtn setImage:[UIImage imageNamed:@"main_popover_edite.png"]
                        forState:UIControlStateNormal];
                
                NSString *eventNo=[[myDB sharedInstance] newCustNO]; //取得事件流水號
                
                //將事件的基本資訊包成Dic帶到PopOver
                NSDictionary *eventInfoDictionary = @{@"id":[NSNumber numberWithInteger:[eventNo integerValue]]
                                                      ,@"date_year":[NSNumber numberWithInteger:year]
                                                      ,@"date_month":[NSNumber numberWithInteger:month]
                                                      ,@"date_day":[NSNumber numberWithInteger:day]
                                                      ,@"position":[NSNumber numberWithInteger:box]
                                                      ,@"stamp_id":[NSString stringWithFormat:@"%@",pic.code]
                                                      ,@"memo":[NSNull null]
                                                      ,@"alarm_type":[NSNull null]
                                                      ,@"start_alarm":[NSNull null]
                                                      ,@"end_alarm":[NSNull null]
                                                      ,@"photo_id":[NSNull null]
                                                      ,@"record_id":[NSNull null]};
                
                //把事件帶到清除
                NSDictionary *eventTmpDictionary = @{@"cell":cell,
                                                     @"tag":[NSString stringWithFormat:@"%lu",300+[dataArray[sect][3][ro]count]],
                                                     };
                
                //關聯
                objc_setAssociatedObject(popBtn, &btnInfoKey, eventInfoDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                _popViewController.eventFlag = 1;//帶一個flag1 代表新增
                
                objc_setAssociatedObject(popBtn_Trash, &btnTmpKey, eventTmpDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                
                //NSLog(@" 年:%@ 月:%@ SECT:%ld",eventInfoDictionary[@"date_year"],eventInfoDictionary[@"date_month"],(long)sect);
                
                [popBtn addTarget:self action:@selector(popBtnClickNew:) forControlEvents:UIControlEventAllEvents];
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
            
            }else{
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告"
                                                                                         message:@"本日事件已達上限10筆，請刪除事件後繼續新增。"
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"確定"
                                                                       style:UIAlertActionStyleCancel
                                                                     handler:^(UIAlertAction *action) {
                }];
                
                [alertController addAction:cancelAction];
                
                [self presentViewController:alertController
                                   animated:YES
                                 completion:nil];
            }
        }
    }
    [picButton2 removeFromSuperview];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [dataArray[section][1]integerValue]-[dataArray[section][2]integerValue];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([dataArray[indexPath.section][3][indexPath.row] count]==0) {
        //    NSLog(@"Sect:%ld Row:%ld 高度108",(long)indexPath.section,(long)indexPath.row);
        return 108;
    }else {
        //      NSLog(@"*!*Sect:%ld Row:%ld 高度%lu",(long)indexPath.section,(long)indexPath.row,108*[dataArray[indexPath.section][3][indexPath.row] count]);
        return 108*[dataArray[indexPath.section][3][indexPath.row] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.clipsToBounds = YES;
    UILabel *label1 = (UILabel *)[cell viewWithTag:101];
    UILabel *label2 = (UILabel *)[cell viewWithTag:102];
     cell.contentView.backgroundColor = nil;
    
    // if (viewDidRoad) {
    for (int i = 0 ; i < 10; i++) {
        
        UIImageView *stampView = (UIImageView *)[cell viewWithTag:300+i];
        UIButton *editBtn = (UIButton *)[cell viewWithTag:310+i];
        UILabel *eventTime = (UILabel *)[cell viewWithTag:320+i];
        UIImageView *photoView = (UIImageView *)[cell viewWithTag:330+i];
        UIButton *deleteBtn = (UIButton *)[cell viewWithTag:360+i];
        UITextView *textView = (UITextView *)[cell viewWithTag:340+i];
        textView.backgroundColor = nil;
        UIButton *playBtn = (UIButton *)[cell viewWithTag:350+i];
        
        //貼圖ImageView+editBtn
        if (i < [dataArray[indexPath.section][3][indexPath.row] count]){
            
            NSString *imageStr = [NSString stringWithFormat:@"%@.png",dataArray[indexPath.section][3][indexPath.row][i][@"stamp_id"]];
            
            if ([[imageStr substringToIndex:1]isEqualToString:@"6"]) {
                //如果存的是自訂貼圖
                NSString* path = [stamptargetdir stringByAppendingPathComponent:
                                  imageStr];
                [stampView setImage:[UIImage imageWithContentsOfFile:path]];
            }else{
                //如果存的是普通貼圖
                [stampView setImage:[UIImage imageNamed:imageStr]];
            }

            editBtn.enabled = YES; editBtn.hidden = NO;
            deleteBtn.enabled = YES; deleteBtn.hidden = NO;
            
            //時間Label
            if (dataArray[indexPath.section][3][indexPath.row][i][@"start_alarm"] != [NSNull null]) {
                
                //NSLog(@"%@",dataArray[indexPath.section][3][indexPath.row][i]);
                //NSLog(@"%@",dataArray[indexPath.section][3][indexPath.row][i][@"start_alarm"]);
                //NSLog(@"%d",[dataArray[indexPath.section][3][indexPath.row][i][@"start_alarm"]intValue]);
                
                NSDateFormatter *formatter = [NSDateFormatter new];
                [formatter setDateFormat:@"HH:mm"];//date的格式
                
                NSDate *starttime = [NSDate dateWithTimeIntervalSince1970: [dataArray[indexPath.section][3][indexPath.row][i][@"start_alarm"]doubleValue] ];
                NSDate *endtime = [NSDate dateWithTimeIntervalSince1970:[dataArray[indexPath.section][3][indexPath.row][i][@"end_alarm"]doubleValue]];
                
                eventTime.text = [NSString stringWithFormat:@"開始時間：%@ / 結束時間：%@",[formatter stringFromDate:starttime],[formatter stringFromDate:endtime]];
                
            }else{
                eventTime.text = @"";
            }
            
            //讀取照片 照片View
            if (dataArray[indexPath.section][3][indexPath.row][i][@"photo_id"] != [NSNull null]) {
                
                photoView.hidden = NO;
    
                NSString *photo = dataArray[indexPath.section][3][indexPath.row][i][@"photo_id"];
                NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                NSString *photogetdir = [path stringByAppendingPathComponent:@"photo"];
                NSString *photoPath = [photogetdir stringByAppendingPathComponent:photo];
                
                photoView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",photoPath]];
                
            }else{
                photoView.hidden = YES;
            }
            
            //讀取錄音
            if (dataArray[indexPath.section][3][indexPath.row][i][@"record_id"] != [NSNull null]) {
                
                NSString *record = dataArray[indexPath.section][3][indexPath.row][i][@"record_id"];
                NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                NSString *recordgetdir = [path stringByAppendingPathComponent:@"recorde"];
                NSString *recordPath = [recordgetdir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",record]];
                
                [playBtn setHidden:NO];
                
                [playBtn whenTapped:^{
                    //
                    if (count == 0) {
                        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
                        self.voicePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:recordPath]
                                                                                  error:nil];
                        self.voicePlayer.numberOfLoops = 0;
                        [self.voicePlayer prepareToPlay];
                        [self.voicePlayer play];
                        self.voicePlayer.delegate = self;
                        [playBtn setImage:[UIImage imageNamed:@"popover_voice_stop.png"] forState:UIControlStateNormal];
                        onPlayBtn = playBtn;
                        count = 1;
                        
                    }else if(count == 1){
                    
                        [self.voicePlayer stop];
                        [onPlayBtn setImage:[UIImage imageNamed:@"popover_voice_play.png"] forState:UIControlStateNormal];
                        if (playBtn == onPlayBtn) {
                            //如果按的是同一個播放鈕
                            count = 0;
                        }else{
                            //如果是其他的播放鈕
                            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
                            self.voicePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:recordPath]
                                                                                      error:nil];
                            self.voicePlayer.numberOfLoops = 0;
                            [self.voicePlayer prepareToPlay];
                            [self.voicePlayer play];
                            self.voicePlayer.delegate = self;
                            [playBtn setImage:[UIImage imageNamed:@"popover_voice_stop.png"] forState:UIControlStateNormal];
                            onPlayBtn = playBtn;
                            count = 1;
                        }
                    }
                    
                }];
            }else{
            
                [playBtn setHidden:YES];
            }
            
            //讀取文字
            if (dataArray[indexPath.section][3][indexPath.row][i][@"memo"] != [NSNull null]) {
                [textView setHidden:NO];
                textView.text = [NSString stringWithFormat:@"%@",dataArray[indexPath.section][3][indexPath.row][i][@"memo"]];
            }else{
                [textView setHidden:YES];
            }
        
        }else{
            
            [stampView setImage:nil];
            editBtn.enabled = NO; editBtn.hidden = YES;
            deleteBtn.enabled = NO; deleteBtn.hidden = YES;
            playBtn.hidden = YES;
            textView.hidden = YES;
            eventTime.text = nil;
            [photoView setImage:nil];
            photoView.userInteractionEnabled = NO;
            photoView.hidden = YES;

        }
        
        //TODO:是否不需要?
        /*
         }else{
         for (int i = 0 ; i < 10; i++) {
         UIButton *tmpStampBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 100*i, 80, 80)];
         tmpStampBtn.tag = 301+i;
         if (i < [dataArray[indexPath.section][3][indexPath.row] count]) {
         UIButton *btn = (UIButton *)[cell viewWithTag:301+i];
         [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",dataArray[indexPath.section][3][indexPath.row][i][@"stamp_id"]]] forState:UIControlStateNormal];
         }else{
         [tmpStampBtn setImage:nil forState:UIControlStateNormal];
         }
         
         [cell.contentView addSubview:tmpStampBtn];
         }
         
         }
         */
        /*
         int day = [dataArray[indexPath.section][0][indexPath.row+[dataArray[indexPath.section][2]intValue]] intValue];
         for(int i=0;i<[dataArray[indexPath.section][3][day-1] count];i++){
         int y = i*55;
         UIButton *editBtn = [[UIButton alloc]initWithFrame:CGRectMake(80, 0+y, 320, 50)];
         [editBtn setBackgroundColor:[UIColor yellowColor]];
         UILabel *memoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,150,50)];
         [memoLabel setText:@"Your title"];
         [editBtn addSubview:memoLabel];
         [cell.contentView addSubview:editBtn];
         */
        
        
        //TODO: popview的X和Y (舊)
        [photoView whenTapped:^{
            //
            NSDictionary *eventInfoDictionary = dataArray[indexPath.section][3][indexPath.row][photoView.tag - 330];
            ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
            NSString *key = [NSString stringWithFormat:@"%@",eventInfoDictionary[@"photo_url"]];
//            NSLog(@"photourl=%@",key.description);
            [assetslibrary assetForURL:[NSURL URLWithString:key] resultBlock:^(ALAsset *asset) {
                //NSLog(@"asset:%@",asset);
               __block UIImage *image = nil;
//                image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
//                image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
                
                if (asset == nil) {//圖片已經被刪除
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"圖片已被刪除" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alert show];
                    });
                    
                }else{
                    
                    @autoreleasepool {
                        image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                    
                        dispatch_async(dispatch_get_main_queue(), ^{
                        
                            CGRect frame = [UIScreen mainScreen].bounds;
                            __block UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,
                                                                                                             frame.size.width*0.8,
                                                                                                             frame.size.height*0.8)];
                            scrollView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
                            scrollView.userInteractionEnabled = YES;
                            scrollView.maximumZoomScale = 2.5;
                            scrollView.minimumZoomScale = 1.0;
                            scrollView.zoomScale = 1.5;
                            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height);
                            scrollView.decelerationRate = 1.0;
                            scrollView.backgroundColor = [UIColor colorWithCGColor:[self getColorFromRed:242 Green:234 Blue:231 Alpha:1]];
    //                        scrollView.layer.borderColor = [self getColorFromRed:0 Green:0 Blue:0 Alpha:1];
    //                        scrollView.layer.borderWidth = 10;
                            scrollView.layer.cornerRadius = 10;
                            scrollView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight;
                            scrollView.delegate = self;
                            __block UIButton *cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0,
                                                                                                    scrollView.frame.size.width/6,
                                                                                                    scrollView.frame.size.width/6)];
                            cancelBtn.center = CGPointMake(scrollView.frame.origin.x+scrollView.frame.size.width,
                                                           scrollView.frame.origin.y);
                            [cancelBtn setImage:[UIImage imageNamed:@"cancelBtn.png"] forState:UIControlStateNormal];
                            __block UIImageView *imageview = [[UIImageView alloc]initWithFrame:scrollView.bounds];
                            objc_setAssociatedObject(scrollView, @"scrollImage", imageview, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    //                        imageview.center = CGPointMake(frame.size.width/2, frame.size.height/2);
                            [imageview setContentMode:UIViewContentModeScaleAspectFit];
                            
                            __block UIView *view = [[UIView alloc]initWithFrame:frame];
                            view.backgroundColor = [UIColor blackColor];
                            view.alpha = 0.5;
                            
                            [view whenTapped:^{
                                //
                                [imageview removeFromSuperview];
                                [view removeFromSuperview];
                                [scrollView removeFromSuperview];
                                [cancelBtn removeFromSuperview];
                                cancelBtn = nil;
                                scrollView = nil;
                                image = nil;
                                imageview = nil;
                                view = nil;
                            }];
                            
                            [cancelBtn whenTapped:^{
                                //
                                [imageview removeFromSuperview];
                                [view removeFromSuperview];
                                [scrollView removeFromSuperview];
                                [cancelBtn removeFromSuperview];
                                cancelBtn = nil;
                                scrollView = nil;
                                image = nil;
                                imageview = nil;
                                view = nil;
                            }];
                            
                            imageview.image = image;
                            [self.view addSubview:view];
                            [self.view addSubview:scrollView];
                            [scrollView addSubview:imageview];
                            [self.view addSubview:cancelBtn];
                        });
                    }
                }
                
                
                //handler(@{@"image":image});
            } failureBlock:^(NSError *error) {
                //handler(@{});
            }];
        }];
        
        [editBtn whenTapped:^{
            //
            NSIndexPath *targetPath = [_myTable indexPathForRowAtPoint:[[[editBtn superview] superview] superview].center];
//            NSLog(@"targetPath:%@",targetPath);
            
            //從dataArray讀取Dic
            NSDictionary *eventInfoDictionary = dataArray[targetPath.section][3][targetPath.row][editBtn.tag - 310];
            
            //關聯
            _popViewController.eventFlag = 2;//帶一個flag2 代表修改
            [self popBtnClick:eventInfoDictionary];
        }];
        
        [deleteBtn whenTapped:^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"確定要刪除嗎？"
                                                                           message:@"刪除的資料無法復原喔"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"確定"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           NSIndexPath *targetPath = [_myTable indexPathForRowAtPoint:[[[editBtn superview] superview] superview].center];
                                                           NSDictionary *eventInfoDictionary = dataArray[targetPath.section][3][targetPath.row][deleteBtn.tag - 360];
                                                           _popViewController.eventFlag = 2;//帶一個flag2 代表修改
                
                                                           [self popDeleteBtnClick:eventInfoDictionary];
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                
                                                       }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                           }];
            [alert addAction:cancel];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }];
    }
    
    
    label1.text = dataArray[indexPath.section][0][indexPath.row+[dataArray[indexPath.section][2]intValue]];
    
    if (indexPath.section == TodaySection && [label1.text isEqualToString:[NSString stringWithFormat:@"%li",(long)TodayDay]]) {
        //cell的todayHighlight
        cell.backgroundColor = [UIColor colorWithCGColor:[self getColorFromRed:254 Green:255 Blue:157 Alpha:1]];
    }else{
        cell.backgroundColor= nil;
    }
    
    label2.text = weekArray[[dataArray[indexPath.section][4][indexPath.row] intValue] ];
    
    if (indexPath.row< [dataArray[indexPath.section][3] count]-2 && indexPath.row> 1) {
        _monthLabel.text = [self getMonthFromSection:indexPath.section];
    }
    
    cell.tag = indexPath.row;
    
    return cell;
}


#pragma mark - Avaudioplayerdelegate
//播放錄音結束時會做的動作
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    [onPlayBtn setImage:[UIImage imageNamed:@"popover_voice_play.png"] forState:UIControlStateNormal];
    count = 0;
}


#pragma mark - popup
//清除此筆資料(Add時把暫存的清除)
-(void)popTrashBtnClick:(UIButton *)sender{
    for (UIView *v in self.view.subviews) {
        if (v.tag == 202 ) {
            [v removeFromSuperview];
        }
    }
    
    NSDictionary *trashDic = (NSDictionary*)objc_getAssociatedObject(sender, &btnTmpKey);
    
    UITableViewCell *cell = trashDic[@"cell"];
    UIImageView *stampView = (UIImageView *)[cell viewWithTag:[trashDic[@"tag"]integerValue]];
    [stampView setImage:nil];

    //TODO:是否不需要？
//    if(cell.frame.size.height > 150){
//        NSLog(@"Cell高 %f",cell.frame.size.height);
//        CGRect cellFrame = cell.frame;
//        NSLog(@"%.f",cellFrame.size.height);
//        cellFrame.size.height -=108;
//        NSLog(@"%.f",cellFrame.size.height);
//        [UIView transitionWithView:cell duration:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
//            //
//            [cell setFrame:cellFrame];
//        } completion:nil];
////        return;
//    }
    [self.myTable reloadData];
}

//刪除此筆資料（Edit時把原有的刪除)
-(void)popDeleteBtnClick:(NSDictionary *)sender{
   
    NSDictionary *deletDic = sender;
    
    //取得section資訊
    NSInteger sect = ([deletDic[@"date_year"]integerValue] - topYear)*12 +  [deletDic[@"date_month"]integerValue] - 1;
    
    for (int i=0; i<[dataArray[sect][3][[deletDic[@"date_day"] integerValue]-1] count]; i++) {
        if([dataArray[sect][3][[deletDic[@"date_day"] integerValue]-1][i][@"id"] isEqualToNumber: deletDic[@"id"]] ){

            //判斷要修改的Dic
//            NSLog(@"原本的本機端Dic:%@",dataArray[sect][3][[deletDic[@"date_day"] integerValue]-1][i]);
            
            [dataArray[sect][3][[deletDic[@"date_day"] integerValue]-1] removeObjectAtIndex:i]; //移除舊Dic
            
            [[myDB sharedInstance] deleteEventByID:deletDic[@"id"]];  //deleteSQL
            
        }
    }
    
    
    if ([deletDic[@"position"] intValue]<4 && [dataArray[sect][3][[deletDic[@"date_day"] integerValue]-1] count]>=3) {
        
        //如果刪除的是position1～3 且後面還有其他事件
        
        NSNumber *n = deletDic[@"position"];
        NSMutableDictionary *dic = [NSMutableDictionary new];
        NSArray *key = [dataArray[sect][3][[deletDic[@"date_day"] integerValue]-1][2] allKeys];
        for (int i = 0; i<key.count; i++) {
            if ([key[i] isEqualToString:@"position"]) {
                [dic setObject:n forKey:@"position"];
            }else{
                [dic setObject:dataArray[sect][3][[deletDic[@"date_day"] integerValue]-1][2][key[i]] forKey:key[i]];
            }
            
        }
        [dic setObject:@"haha"  forKey:@"id2"];
        [self EditEventWithFullDic:dic];
    }
    
    //刪除此筆資料的推播通知
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    
    for (int i=0; i<[eventArray count]; i++) {
        
        UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
        NSDictionary *userInfoCurrent = oneEvent.userInfo;
        NSString *uid=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:@"uid"]];
        
        if ([uid isEqualToString:[NSString stringWithFormat:@"%@",deletDic[@"id"]]]) {
            
            //Cancelling local notification
           [app cancelLocalNotification:oneEvent];
            break;
        }
    }
    
    //刪除此筆資料的照片及錄音。
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    if (deletDic[@"record_id"] != [NSNull null]) {
        NSString *recordegetdir = [path stringByAppendingPathComponent:@"recorde"];
        NSString *recorde = deletDic[@"record_id"];
        NSString *recordePath = [recordegetdir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",recorde]];
        NSFileManager *recordefileManager = [NSFileManager defaultManager];
        [recordefileManager removeItemAtPath:recordePath error:nil];
    }
    
    if (deletDic[@"photo_id"] != [NSNull null]) {
        NSString *photogetdir = [path stringByAppendingPathComponent:@"photo"];
        NSString *photo = deletDic[@"photo_id"];
        NSString *photoPath = [photogetdir stringByAppendingPathComponent:photo];
        NSFileManager *photofileManager = [NSFileManager defaultManager];
        [photofileManager removeItemAtPath:photoPath error:nil];
    }
    
    [_myTable reloadData];
}

-(void)popBtnClickNew:(UIButton *)sender{
    for (UIView *v in self.view.subviews) {
        if (v.tag == 202 ) {
            [v removeFromSuperview];
        }
    }
    NSDictionary *dic = (NSDictionary*)objc_getAssociatedObject(sender, &btnInfoKey);
    [self popBtnClick:dic];
}

-(void)popBtnClick:(NSDictionary *)sender{
    
    //接收關聯
    goToPopOver = YES;
    _popViewController.eventInfoDic = sender;
//    NSLog(@"帶過來的事件是：%@，目標行為%ld",_popViewController.eventInfoDic, (long)_popViewController.eventFlag);
    
    //背景透明
    UIView *addBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,
                                                                  self.view.frame.size.width,
                                                                  self.view.frame.size.height)];
    [addBackView setBackgroundColor:[UIColor blackColor]];
    addBackView.alpha = 0.2;
    
    //新增事項的視窗
    _popViewController.view.frame = CGRectMake(self.view.frame.size.width*0.1, 30,
                                               self.view.frame.size.width*0.8, self.view.frame.size.height*0.5);

    float height = _popViewController.view.frame.size.height;
    
    //popover編輯後的畫面背景
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//date的格式
    NSString *tmpNowTime = [formatter stringFromDate:[NSDate date]];//現在的時間
    NSString *dateString = [NSString stringWithFormat:@"%@-%@-%@ %@",
                                                    _popViewController.eventInfoDic[@"date_year"],
                                                    _popViewController.eventInfoDic[@"date_month"],
                                                    _popViewController.eventInfoDic[@"date_day"],
                                                    [tmpNowTime substringFromIndex:11]];
    //將cell年＋cell月＋cell日＋現在時間 何為一個string
    NSDate *cellTime = [formatter dateFromString:dateString];//格式化成NSDate
    _datePicker = [[UIDatePicker alloc]init];
    _datePicker.tag=201;
    [_datePicker setDatePickerMode:UIDatePickerModeTime];
    [_datePicker setBackgroundColor:[UIColor whiteColor]];
    _datePicker.frame = CGRectMake(0, 3*self.view.frame.size.height/3, self.view.frame.size.width/2, height/5);
    [_datePicker addTarget:self action:@selector(dateChanged:)
          forControlEvents:UIControlEventValueChanged];//datePicker1時間轉換時的action
    
    _datePicker2 = [[UIDatePicker alloc]init];
    _datePicker2.tag=201;
    [_datePicker2 setDatePickerMode:UIDatePickerModeTime];
    [_datePicker2 setBackgroundColor:[UIColor whiteColor]];
    _datePicker2.frame = CGRectMake(0, 3*self.view.frame.size.height/3, self.view.frame.size.width/2, height/5);
    [_datePicker2 addTarget:self action:@selector(dateChanged:)
           forControlEvents:UIControlEventValueChanged];//datePicker2時間轉換時的action

    
    //新增時 !!!!! 2015.07.26 新增時要幹嘛!!!!!!!!!!! by糖
    if(_popViewController.eventFlag == 1){
        
        [_datePicker setDate:cellTime];//設定datepicker時間
        [_datePicker2 setDate:[_datePicker.date dateByAddingTimeInterval:60*60]];//設定datepicker2的時間後一小時
        _popViewController.textView.text=@"請輸入事項";
        
        
        //修改且原事件不包含StartAlarm時 !!!!!
    }else if((_popViewController.eventFlag == 2) &&
             (_popViewController.eventInfoDic[@"start_alarm"] ==  [NSNull null])){
        
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//date的格式
        NSString *tmpNowTime = [formatter stringFromDate:[NSDate date]];//現在的時間
        NSString *dateString = [NSString stringWithFormat:@"%@-%@-%@ %@",_popViewController.eventInfoDic[@"date_year"],_popViewController.eventInfoDic[@"date_month"],_popViewController.eventInfoDic[@"date_day"],[tmpNowTime substringFromIndex:11]];
        //將cell年＋cell月＋cell日＋現在時間 何為一個string
        NSDate *cellTime = [formatter dateFromString:dateString];//格式化成NSDate
        
        [_datePicker setDate:cellTime];//設定datepicker時間
        [_datePicker2 setDate:[_datePicker.date dateByAddingTimeInterval:60*60]];//設定datepicker2的時間後一小時
        [_datePicker2 addTarget:self action:@selector(dateChanged:)
               forControlEvents:UIControlEventValueChanged];//datePicker2時間轉換時的action
        _popViewController.textView.text=@"請輸入事項";
        
        //修改且原事件包含StartAlarm時 !!!!!
        
    }else{
        
        NSDate *starttime = [NSDate dateWithTimeIntervalSince1970: [_popViewController.eventInfoDic[@"start_alarm"]doubleValue] ];
        NSDate *endtime = [NSDate dateWithTimeIntervalSince1970:[_popViewController.eventInfoDic[@"end_alarm"]doubleValue]];
        
        [_datePicker setDate:starttime];
        [_datePicker2 setDate:endtime];
        
        
        if(_popViewController.eventInfoDic[@"memo"] != [NSNull null]){
            _popViewController.textView.text=_popViewController.eventInfoDic[@"memo"];
        }else{
            _popViewController.textView.text=@"請輸入事項";
        }
        
    }
    
    NSDateFormatter *formatter2 = [NSDateFormatter new];
    [formatter2 setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *tmpDateBtnStr = [NSString stringWithFormat:@"開始時間：   %@\n結束時間：   %@",[formatter2 stringFromDate:self.datePicker.date],[formatter2 stringFromDate:self.datePicker2.date]];
    [_popViewController.dateBtn setTitle:tmpDateBtnStr forState:UIControlStateNormal];
    
    _popViewController.textView.delegate=(id)self;
    
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
    [UIView transitionWithView:_popViewController.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionNone animations:^{
                           _popViewController.view.alpha=1.0;
                       }
                    completion:^(BOOL finished) {
                        [self performSelector:@selector(openKeyBoard) withObject:nil afterDelay:0];
                    }];
    
}

-(void)openKeyBoard{
    [_popViewController.textView becomeFirstResponder];
}

//date的值改變
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

//tableview翻頁的時候  collection翻頁的時候 滑完的時候
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (scrollView == self.stampCollectionView) {
        //[picButton2 removeFromSuperview];
    }else if(scrollView == self.myTable){
        NSIndexPath *indexPath =
        [self.myTable indexPathForRowAtPoint:
         [self.view convertPoint:[self.view center] toView:self.myTable]];
        [myDB sharedInstance].nowSection = [NSNumber numberWithInteger:indexPath.section];
        [myDB sharedInstance].nowRow = [NSNumber numberWithInteger:indexPath.row];
//        NSLog(@"section%@ / row%@",[myDB sharedInstance].nowSection,[myDB sharedInstance].nowRow);
    }
}


-(NSString *)getMonthFromSection:(NSInteger)section{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    //設定date顯示
    [formatter setDateFormat:@"yyyy-MM"];
    //設定日期
    NSDateComponents *components = [[NSDateComponents alloc]init];
    [components setDay:1];
    [components setMonth:1+section];
    [components setYear:topYear];
    NSDate *Firstday = [CalenderOfMonth dateFromComponents:components];
    
    //在Header輸出年.月
    return [formatter stringFromDate:Firstday];
}


#pragma mark - customstamp
- (IBAction)customstamp:(id)sender {
    [self stampBtnClick5:self.stamp5];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CustomStamp" bundle:nil];
    id targetVC = [storyBoard instantiateViewControllerWithIdentifier:@"CustomStamp"];
    [self presentViewController:targetVC animated:true completion:nil];
}


#pragma mark - popVC BtnAction
-(void)clearPopView{
    //清除popoverView
    goToPopOver = NO;
    for (UIView *v in self.view.subviews) {
        if (v.tag == 200 || v.tag==201) {
            [v removeFromSuperview];
        }
    }
}

-(void)SaveEventWithFullDic:(NSDictionary*)eventDic{
    
    goToPopOver = NO;
    
    for (UIView *v in self.view.subviews) {
        if (v.tag == 200 || v.tag==201) {
            [v removeFromSuperview];
        }
    }
    //新增Dic
    NSInteger sect = ([eventDic[@"date_year"]integerValue] - topYear)*12 +  [eventDic[@"date_month"]integerValue] - 1;  //取得section資訊
    [dataArray[sect][3][[eventDic[@"date_day"] integerValue]-1] addObject:eventDic];                //置入完整的Dic
    
    [[myDB sharedInstance] insertEvntDic:eventDic];
    
    [self.myTable reloadData];
}

-(void)EditEventWithFullDic:(NSDictionary*)eventDic{
//    [self clearPopView];
//    NSLog(@"EditOld");
    goToPopOver = NO;
    for (UIView *v in self.view.subviews) {
        if (v.tag == 200 || v.tag==201) {
            [v removeFromSuperview];
        }
    }
    //修改Dic
    NSInteger sect = ([eventDic[@"date_year"]integerValue] - topYear)*12 +  [eventDic[@"date_month"]integerValue] - 1;  //取得section資訊
    
    for (int i=0; i<[dataArray[sect][3][[eventDic[@"date_day"] integerValue]-1] count]; i++) {
        if([dataArray[sect][3][[eventDic[@"date_day"] integerValue]-1][i][@"id"] isEqualToNumber: eventDic[@"id"]] ){ //判斷要修改的Dic
            
//            NSLog(@"原本的本機端Dic:%@",dataArray[sect][3][[eventDic[@"date_day"] integerValue]-1][i]);
            
            [dataArray[sect][3][[eventDic[@"date_day"] integerValue]-1] removeObjectAtIndex:i];             //移除舊Dic
            [dataArray[sect][3][[eventDic[@"date_day"] integerValue]-1] insertObject:eventDic atIndex:i];   //插入新Dic
            [[myDB sharedInstance] updateEvntDic:eventDic];                                                 //updateSQL
            
//            NSLog(@"新的本機端Dic:%@",dataArray[sect][3][[eventDic[@"date_day"] integerValue]-1][i]);
        }
    }
    
    [self.myTable reloadData];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    PopTableViewController *vc = segue.destinationViewController;
    vc.parentVC = self;
}


#pragma mark - RGB method
//得到RGB顏色
-(CGColorRef) getColorFromRed:(int)red Green:(int)green Blue:(int)blue Alpha:(int)alpha {
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
    [self.stampCollectionView reloadData];
    
    _trashCan.hidden = NO;
}

- (void)normalStampSetting:(id)nomalStampButton
{
    customStampTypeSelected = NO;
    [self.stampCollectionView reloadData];
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



#pragma mark - 切換theme
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
    self.monthLabel.textColor = typeDic[@"wordColor"];
    self.monthLabel.backgroundColor = typeDic[@"wordBackColor"];
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

- (UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    UIImageView *imageView = (UIImageView *)objc_getAssociatedObject(scrollView, @"scrollImage");
    return imageView;
}

#pragma mark - CustomLoading
- (IBAction)CustomLoadingBtn:(id)sender {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CustomLoading" bundle:nil];
    id targetVC = [storyBoard instantiateViewControllerWithIdentifier:@"CustomLoading"];
    [self presentViewController:targetVC animated:true completion:nil];
}

- (void)addTrashCan
{
    if (_trashCan == nil)
    {
        UIView *tmpBgView = [[UIView alloc] initWithFrame:_stampCollectionView.frame];
        tmpBgView.backgroundColor = _stampCollectionView.backgroundColor;
        [self.view addSubview:tmpBgView];
        [self.view bringSubviewToFront:_stampCollectionView];
        
        CGFloat width = _stamp5.frame.size.width;
        
        CGRect rect = CGRectMake(0, 0, width, width);
        
        _trashCan = [[TrashCanButton alloc] initWithFrame:rect];
        
        _trashCan.center = CGPointMake(self.view.frame.size.width - width/2, _stampCollectionView.frame.origin.y + _stampCollectionView.frame.size.height/2);
        
        [self.view addSubview:_trashCan];
        
        _trashCan.hidden = YES;
    }
}

@end

