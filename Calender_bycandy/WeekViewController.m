//
//  WeekViewController.m
//  Calender_bycandy
//
//  Created by Dong on 2015/6/2.
//  Copyright (c) 2015年 candy. All rights reserved.
//

#import "WeekViewController.h"
#import "Header.h"
#import "PicButton.h"
#import "JMWhenTapped.h"
#import "myDB.h"
#import "CustomStampFilter.h"
#import "TrashCanButton.h"



@interface WeekViewController ()<buttonDelegate,UITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
{
    PicButton *picButton2;
    NSMutableArray *timeLabelArray;
    NSMutableArray *classLabelArray;
    NSCalendar *CalenderOfMonth;
    NSDate *nowDate;
    int  weekBeginTime,classNumber;
    
    //貼圖
    NSMutableArray *imagePackage,*classImagePackage;
    BOOL classTypeSelected;
    BOOL customStampTypeSelected;
    NSMutableDictionary *classEventDict;
    NSMutableArray *classStampArray;
    NSMutableArray *customClassStampArray;
    NSMutableArray *defaultClassStampArray;
    NSString *stamptargetdir;
    NSArray *stampButtonArray;
}
@property (weak, nonatomic) IBOutlet UILabel *weekDateLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *stampCollectionView; //貼圖

@property (weak, nonatomic) IBOutlet UICollectionView *weekCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *dayBtn;
@property (weak, nonatomic) IBOutlet UIButton *monthBtn;

@property (weak, nonatomic) IBOutlet UIImageView *top;
@property (weak, nonatomic) IBOutlet UIButton *todayBtn;
@property (weak, nonatomic) IBOutlet UIButton *settingBtn;
@property (weak, nonatomic) IBOutlet UIButton *weekBtn;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UIButton *stampclass;
@property (weak, nonatomic) IBOutlet UIButton *stamp1;
@property (weak, nonatomic) IBOutlet UIButton *stamp2;
@property (weak, nonatomic) IBOutlet UIButton *stamp3;
@property (weak, nonatomic) IBOutlet UIButton *stamp4;
@property (weak, nonatomic) IBOutlet UIButton *stamp5;
@property (weak, nonatomic) IBOutlet UIView *wordBackView;
@property (weak, nonatomic) IBOutlet UIImageView *oneWeek;
@property (weak, nonatomic) IBOutlet UILabel *wordLabel;

@property (strong, nonatomic) TrashCanButton *trashCan;


@end

@implementation WeekViewController

- (IBAction)settingBtnClick:(id)sender {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Setting" bundle:nil]; //創建StoryBoard的實體
    
    id targetViewController = [storyBoard instantiateViewControllerWithIdentifier:@"Setting"];
    
    [self presentViewController:targetViewController animated:true completion:nil];
}


//一開始會讀取的
- (void)viewDidLoad {
    [super viewDidLoad];
    [self changeTheme:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeTheme:) name:@"CHANGETHEME" object:nil];//增加一個換主題的observer
    
    NSString *stampdir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    stamptargetdir = [stampdir stringByAppendingPathComponent:@"customstamp"];
    
    classTypeSelected = YES;
    customStampTypeSelected = NO;
    //貼圖
    imagePackage = [NSMutableArray new];
    stampButtonArray = @[_stamp1,_stamp2,_stamp3,_stamp4,_stamp5,_stampclass];
    
    NSString *dbPath = [self GetDBPathFromclassStamp];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:dbPath]) {
        NSMutableArray *tmpSettingArray = [NSMutableArray new];
        //如果第一次開app建立sclassStamp.plist檔
        for (int i = 0;  i < 192; i++) {
            [tmpSettingArray addObject:@"e"];
        }
        
        [tmpSettingArray writeToFile:dbPath atomically:YES];
        classStampArray = tmpSettingArray;
    }else{
        classStampArray=[[NSMutableArray alloc]initWithContentsOfFile:dbPath];
        //如果classStamp存在則拿出來用
        
    }
    customClassStampArray=[NSMutableArray new];
    
    if (![fileManager fileExistsAtPath:[self GetDBPathFromcustomClassStamp]]) {
        NSMutableArray *tmpCustomClassStampArray = [NSMutableArray new];
        //如果第一次開app建立customClassStamp.plist檔
        
        [tmpCustomClassStampArray writeToFile:[self GetDBPathFromcustomClassStamp] atomically:YES];
        
        
    }else{
        customClassStampArray = [[NSMutableArray alloc]initWithContentsOfFile:[self GetDBPathFromcustomClassStamp]];
        //如果classStamp存在則拿出來用
        
    }
    defaultClassStampArray = [NSMutableArray new];
    for (int i = 1001; i<=1009; i++) {
        [defaultClassStampArray addObject:[NSString stringWithFormat:@"%d.png",i]];
    }
    [self classStampBtnClick:self.stampclass];
    
    
    NSString *classEventStampStr = [self GetDBPathFromclassEventStamp];
    if (![fileManager fileExistsAtPath:classEventStampStr]) {
        NSMutableDictionary *tmpStampDict = [NSMutableDictionary new];
        //如果第一次開app建立classEventStamp.plist檔
        
        [tmpStampDict writeToFile:classEventStampStr atomically:YES];
        classEventDict = tmpStampDict;
    }else{
        classEventDict=[[NSMutableDictionary alloc]initWithContentsOfFile:classEventStampStr];
        //如果classEventStamp存在則拿出來用
    }
    
    
    CalenderOfMonth = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    nowDate = [NSDate date];
    _weekDateLabel.text = [self getDate:nowDate];
    
    _dayBtn.alpha = 0.5;
    _monthBtn.alpha = 0.5;
    _weekCollectionView.delegate = self;
    _weekCollectionView.dataSource = self;
    UISwipeGestureRecognizer *rightGesture =  [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchViews:)];
    rightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *leftGesture =  [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchViews:)];
    leftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [_weekCollectionView addGestureRecognizer:rightGesture];
    [_weekCollectionView addGestureRecognizer:leftGesture];
    
    classLabelArray = [NSMutableArray new];
    for (int i = 1 ; i<=24; i++) {
        [classLabelArray addObject:[NSString stringWithFormat:@"%d", i]];
    }
    
    
    timeLabelArray = [NSMutableArray new];
    for (int i = 0 ; i < 24; i++) {
        NSString *str = [NSString stringWithFormat:@"%02d:00",i];
        [timeLabelArray addObject:str];
    }
    
    //TODO:ADMOB廣告設置
    
    // 在螢幕上方建立標準大小的視圖，
    // 可用的 AdSize 常值已在 GADAdSize.h 中解釋。
    //    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    // 在畫面下方建立標準廣告大小的畫面。
    //GAD_SIZE_320x50 就是你的bannerView的size 其中320就是寬度(width), 50就是高度(height)
    
    if(self.view.frame.size.height < 500){
        bannerView_ = [[GADBannerView alloc]
                       initWithFrame:CGRectMake(0.0,
                                                self.view.frame.size.height -
                                                GAD_SIZE_320x50.height + 10,
                                                self.view.frame.size.width,
                                                GAD_SIZE_320x50.height)];
        
    }else if (self.view.frame.size.height > 500 && self.view.frame.size.height < 700 ){
        bannerView_ = [[GADBannerView alloc]
                       initWithFrame:CGRectMake(0.0,
                                                self.view.frame.size.height -
                                                GAD_SIZE_320x50.height + 5,
                                                self.view.frame.size.width,
                                                GAD_SIZE_320x50.height)];
        
    }else if (self.view.frame.size.height > 700){
        
        bannerView_ = [[GADBannerView alloc]
                       initWithFrame:CGRectMake(0.0,
                                                self.view.frame.size.height -
                                                GAD_SIZE_320x50.height,
                                                self.view.frame.size.width,
                                                GAD_SIZE_320x50.height)];
        
    }
    
    // 指定廣告單元編號。
    bannerView_.adUnitID = @"ca-app-pub-7556127145229222/1403677991";
    
    // 通知執行階段，將使用者帶往廣告到達網頁後，該恢復哪一個 UIViewController，
    // 並將其加入檢視階層中。
    bannerView_.rootViewController = self;
    
    GADRequest *gadRequest = [GADRequest request];
    
    gadRequest.testDevices = @[kGADSimulatorID,@"6dfe062fe11f7bc378aa9f92c86f54f7"];
    
    // 啟動一般請求，隨著廣告一起載入。
    [bannerView_ loadRequest:gadRequest];   //實際
    
    //4s:480   //5:568    //6:736
    [self.view addSubview:bannerView_];
}


#pragma mark - TodayAction
- (IBAction)todayBtnClick:(id)sender {
    nowDate =[NSDate date];
    _weekDateLabel.text = [self getDate:[NSDate date]];
    [_weekCollectionView reloadData];
    [UIView transitionWithView:_weekCollectionView duration:0.5 options:UIViewAnimationOptionTransitionCurlUp animations:^{
        //
    } completion:^(BOOL finished) {
        //
    }];
}


-(void)switchViews:(UISwipeGestureRecognizer *)gesture{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.2;
    //    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    transition.type = kCATransitionPush;
    
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        nowDate =[nowDate dateByAddingTimeInterval:60*60*24*7];
        _weekDateLabel.text = [self getDate:nowDate];
        transition.subtype = kCATransitionFromRight;
    }else{
        nowDate =[nowDate dateByAddingTimeInterval:-60*60*24*7];
        _weekDateLabel.text = [self getDate:nowDate];
        transition.subtype = kCATransitionFromLeft;
        
    }
    [_weekCollectionView reloadData];
    [_weekCollectionView.layer addAnimation:transition forKey:nil];
}

- (IBAction)dayBtnClick:(UIButton *)sender {
    
    /*
     UIViewController* presentingViewController = self.presentingViewController;
     UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
     id targetViewController = [storyBoard instantiateViewControllerWithIdentifier:@"dayView"];
     [self dismissViewControllerAnimated:NO completion:^{
     //
     
     [presentingViewController presentViewController:targetViewController animated:NO completion:nil];
     }];
     */
    
    
    self.tabBarController.selectedIndex = 2;
    
}



- (IBAction)monthBtnClick:(UIButton *)sender {
    // [self dismissViewControllerAnimated:NO completion:nil];
    self.tabBarController.selectedIndex = 0;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //隱藏tabbar
    [self.tabBarController.tabBar setHidden:YES];
    weekBeginTime = [[myDB sharedInstance].settingDict[@"weekBeginTime"]intValue];
    classNumber = [[myDB sharedInstance].settingDict[@"classNumber"]intValue];
    [_weekCollectionView reloadData];
    [_weekCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:weekBeginTime*8 inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionTop
                                        animated:NO];
    if (customStampTypeSelected) {
        [_stampCollectionView reloadData];
    }
    
    [self addTrashCan];
}

-(void)dealloc{
//    NSLog(@"weekViewDied");
}





///////////////貼圖觸控事件////////////////

- (void)buttonBegin:(PicButton *)pic location:(CGPoint)loc{
    picButton2 = [PicButton new];
    picButton2.delegate=self;
    [picButton2 setImage:pic.currentImage forState:UIControlStateNormal];
    picButton2.code = pic.code;
    picButton2.userInteractionEnabled=YES;
    picButton2.frame = CGRectMake(loc.x, loc.y-50, pic.frame.size.width, pic.frame.size.height);
    picButton2.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:picButton2];
}//貼圖按下去時增加一個view

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
    
    for (UICollectionViewCell*cell in [_weekCollectionView visibleCells]) {
        CGRect frame = [_weekCollectionView convertRect:cell.frame toView:self.view];
        if (CGRectIntersectsRect(CGRectMake(picButton2.center.x, picButton2.center.y, 0, 0), frame)) {
            if (cell.userInteractionEnabled==YES) {
                cell.contentView.backgroundColor =[UIColor colorWithCGColor:[self getColorFromRed:209 Green:209 Blue:209 Alpha:1]];
            }
        }else{
            cell.contentView.backgroundColor = nil;
            
        }
        
    }
}//移動時判斷與cell有無接觸 若有則將cell變色

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
    
    for (UICollectionViewCell*cell in [_weekCollectionView visibleCells]) {
        
        
        CGRect frame = [_weekCollectionView convertRect:cell.frame toView:self.view];
        if (cell.userInteractionEnabled==YES) {
            if (CGRectIntersectsRect(CGRectMake(picButton2.center.x, picButton2.center.y, 0, 0), frame)) {
                
                
                //                NSInteger sect = [_weekCollectionView indexPathForCell:cell].section;
                NSInteger ro = [_weekCollectionView indexPathForCell:cell].row;
                //將cell在collection的section及row取出
                
                //
                if (classTypeSelected) {//如果目前是課程選擇
                    [classStampArray replaceObjectAtIndex:ro withObject:picButton2.code];
                    
                    [classStampArray writeToFile:[self GetDBPathFromclassStamp] atomically:YES];
                    UIButton *classBtn = (UIButton *)[cell viewWithTag:103];
                    [classBtn setImage:pic.currentImage forState:UIControlStateNormal];
                }else{
                    UIButton *eventBtn;
                    if (classEventDict[_weekDateLabel.text] == nil) {//如果這週還沒加過plist
                        
                        NSMutableArray *eventArray = [NSMutableArray new];
                        [eventArray addObject:picButton2.code];
                        NSMutableDictionary *dict = [NSMutableDictionary new];
                        [classEventDict setObject:dict forKey:_weekDateLabel.text];
                        [classEventDict[_weekDateLabel.text] setObject:eventArray forKey:[NSString stringWithFormat:@"%ld",(long)ro]];
                        eventBtn = (UIButton *)[cell viewWithTag:104];
                        
                    }else{//plist已經存在
                        if (classEventDict[_weekDateLabel.text][[NSString stringWithFormat:@"%ld",(long)ro]] == nil) {
                            //如果這個row還沒有資料
                            NSMutableArray *eventArray = [NSMutableArray new];
                            [eventArray addObject:picButton2.code];
                            [classEventDict[_weekDateLabel.text] setObject:eventArray forKey:[NSString stringWithFormat:@"%ld",(long)ro]];
                            eventBtn = (UIButton *)[cell viewWithTag:104];
                        }else if([classEventDict[_weekDateLabel.text][[NSString stringWithFormat:@"%ld",(long)ro]] count] == 1 && [classEventDict[_weekDateLabel.text][[NSString stringWithFormat:@"%ld",(long)ro]][0] isEqualToString:@"space"] ){//如果這個row被刪除過
                            [classEventDict[_weekDateLabel.text][[NSString stringWithFormat:@"%ld",(long)ro]] replaceObjectAtIndex:0 withObject:picButton2.code];
                            eventBtn = (UIButton *)[cell viewWithTag:104];
                            
                        }
                        else if([classEventDict[_weekDateLabel.text][[NSString stringWithFormat:@"%ld",(long)ro]] count] == 1 ){//如果這個row只有一筆資料
                            [classEventDict[_weekDateLabel.text][[NSString stringWithFormat:@"%ld",(long)ro]] addObject:picButton2.code];
                            [classEventDict[_weekDateLabel.text][[NSString stringWithFormat:@"%ld",(long)ro]] addObject:@"two"];
                            eventBtn = (UIButton *)[cell viewWithTag:105];
                            
                        }else {//如果這個row有兩筆資料
                            if ([classEventDict[_weekDateLabel.text][[NSString stringWithFormat:@"%ld",(long)ro]][2] isEqualToString:@"two"]) {//如果這個最後一筆資料是two
                                [classEventDict[_weekDateLabel.text][[NSString stringWithFormat:@"%ld",(long)ro]] replaceObjectAtIndex:2 withObject:@"one"];
                                [classEventDict[_weekDateLabel.text][[NSString stringWithFormat:@"%ld",(long)ro]] replaceObjectAtIndex:0 withObject:picButton2.code];
                                eventBtn = (UIButton *)[cell viewWithTag:104];
                            }else{//如果這個最後一筆資料是one
                                [classEventDict[_weekDateLabel.text][[NSString stringWithFormat:@"%ld",(long)ro]] replaceObjectAtIndex:2 withObject:@"two"];
                                [classEventDict[_weekDateLabel.text][[NSString stringWithFormat:@"%ld",(long)ro]] replaceObjectAtIndex:1 withObject:picButton2.code];
                                eventBtn = (UIButton *)[cell viewWithTag:105];
                                
                            }
                            
                        }
                    }
                    [eventBtn setImage:pic.currentImage forState:UIControlStateNormal];
                    [classEventDict writeToFile:[self GetDBPathFromclassEventStamp] atomically:YES];
                }
                
                
                [cell setNeedsLayout];
                
                //重整collectionviewCell
                cell.contentView.backgroundColor = nil;
                
                break;//跳出FOR迴圈
            }
        }
    }
    [picButton2 removeFromSuperview];
    
    
    
}

///////////////貼圖觸控事件////////////////


#pragma mark - popup

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


//建立月曆日期
-(NSString *)GetDBPathFromclassStamp{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask, YES);
    NSString *documentPath = [paths firstObject];
    NSString *dbPath = [documentPath stringByAppendingPathComponent:@"classStamp.plist"];
    
    //    NSLog(@"MY documentPath : %@",documentPath);
    return dbPath;
}
-(NSString *)GetDBPathFromclassEventStamp{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask, YES);
    NSString *documentPath = [paths firstObject];
    NSString *dbPath = [documentPath stringByAppendingPathComponent:@"classEventStamp.plist"];
    
    //    NSLog(@"MY documentPath : %@",documentPath);
    return dbPath;
}
-(NSString *)GetDBPathFromcustomClassStamp{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask, YES);
    NSString *documentPath = [paths firstObject];
    NSString *dbPath = [documentPath stringByAppendingPathComponent:@"customClassStamp.plist"];
    
    //    NSLog(@"MY documentPath : %@",documentPath);
    return dbPath;
}



#pragma mark - collectionview delegate

//建立Section數量
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
    
}

//每個section的item數量
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (collectionView == self.stampCollectionView) {
        return [imagePackage count];
    }else{
        return 192;
    }
}


//製作cell內容
-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //Identifier名稱要取cell
    
    if (collectionView == self.stampCollectionView) {
        UICollectionViewCell *cell;
        if (classTypeSelected == YES && indexPath.row == 0) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"addCell" forIndexPath:indexPath];
            UIButton *btn = (UIButton *)[cell viewWithTag:888];
            [btn whenTapped:^{
                //
//                NSLog(@"新增課程");
                [self addClassStamp];
                
            }];
            
        }else{
            PicButton *picButton;
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"stampcell" forIndexPath:indexPath];
            if ([[cell.contentView.subviews firstObject] isKindOfClass:[PicButton class]]) {//如果之後reload
                picButton = (PicButton *)[cell viewWithTag:106];
                if (classTypeSelected)
                {//如果目前是課程選擇
                    
                    CGRect picCollectionFrame = _stampCollectionView.frame;
                    if (picCollectionFrame.size.width != self.view.frame.size.width + 8)
                    {
                        picCollectionFrame.size.width = self.view.frame.size.width + 8;
                        _stampCollectionView.frame = picCollectionFrame;
                    }
                    
                    if (indexPath.row<imagePackage.count-defaultClassStampArray.count) {
                        NSString* path = [stamptargetdir stringByAppendingPathComponent:
                                          imagePackage[indexPath.row]];
//                        NSLog(@"%@",[UIImage imageWithContentsOfFile:path].description);
                        [picButton setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
                    }else{
                        [picButton setImage:[UIImage imageNamed:imagePackage[indexPath.row]] forState:UIControlStateNormal];
                    }

                    
                    picButton.delegate = self;
                    picButton.code = imagePackage[indexPath.row];
                }
                else if (customStampTypeSelected)
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
                
                
                
            }else{//如果第一次reload
                
                picButton = [[PicButton alloc] init];
                picButton.frame = cell.bounds;
                picButton.tag=106;
                picButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
                [cell.contentView addSubview:picButton];
                picButton  = (PicButton *)[cell viewWithTag:106];
                
                if (classTypeSelected) {//如果目前是課程選擇
                    if (indexPath.row<imagePackage.count-defaultClassStampArray.count) {
                        NSString* path = [stamptargetdir stringByAppendingPathComponent:
                                          imagePackage[indexPath.row]];
                        
                        [picButton setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
                    }else{
                        [picButton setImage:[UIImage imageNamed:imagePackage[indexPath.row]] forState:UIControlStateNormal];
                    }

                    picButton.delegate = self;
                    picButton.code = imagePackage[indexPath.row];
                    
                    
                    
                    
                }else if (customStampTypeSelected){
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
        }
        
        //        cell.backgroundColor = [UIColor blackColor];
        
        
        //取得貼圖名稱 並設成貼圖欄各貼圖的code屬性
        //        NSString *tmpString=[NSString stringWithFormat:@"%@",imagePackage[indexPath.row]];
        //        NSArray *tmpArray = [tmpString componentsSeparatedByString:@"."];
        //        picButton.code=[NSString stringWithFormat:@"%@",[tmpArray objectAtIndex:0]];
        
        
        return cell;

        
    }else{
        
        //判斷cell的底色
        if (indexPath.row%8 == 0) {
            UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TimeCell" forIndexPath:indexPath];
            UILabel *label1 = (UILabel *)[cell viewWithTag:101];
            UILabel *label2 = (UILabel *)[cell viewWithTag:102];
            
            
            label1.text = timeLabelArray[indexPath.row/8];
            label2.text = @"";
            
            if (indexPath.row+1>weekBeginTime*8 && indexPath.row<weekBeginTime*8+classNumber*8) {
                
                label2.text = classLabelArray[(indexPath.row-weekBeginTime*8)/8];
            }else if(indexPath.row+1<weekBeginTime*8+classNumber*8-191){
                label2.text = classLabelArray[(indexPath.row+192-weekBeginTime*8)/8];
            }
            
            return cell;
        }else{
            UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
            
            //將cell中的Label.Tag設為100 就會自動找到相對應的Label
            
            //            UIButton *button1 = (UIButton *)[cell viewWithTag:103];
            //            UIButton *button2 = (UIButton *)[cell viewWithTag:104];
            //            UIButton *button3 = (UIButton *)[cell viewWithTag:105];
            UIButton *eventStampBtn1 = (UIButton *)[cell viewWithTag:104];
            UIButton *eventStampBtn2 = (UIButton *)[cell viewWithTag:105];
            [eventStampBtn1 setImage:nil forState:UIControlStateNormal];
            [eventStampBtn2 setImage:nil forState:UIControlStateNormal];
            if (classEventDict[_weekDateLabel.text] != nil) {
                if (classEventDict[_weekDateLabel.text][[NSString stringWithFormat:@"%ld",(long)indexPath.row]] != nil) {
                    NSString *imageStr = classEventDict[_weekDateLabel.text][[NSString stringWithFormat:@"%ld",(long)indexPath.row]][0];
                    if ([[imageStr substringToIndex:1] isEqualToString:@"6"]) {//如果貼圖是自訂的
                        NSString* path = [stamptargetdir stringByAppendingPathComponent:
                                          imageStr];
                        
                        [eventStampBtn1 setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
                        
                    }else{//如果貼圖是預設的
                        [eventStampBtn1 setImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
                    }
                    
                    if ([classEventDict[_weekDateLabel.text][[NSString stringWithFormat:@"%ld",(long)indexPath.row]]count] > 1) {
                        NSString *imageStr2 = classEventDict[_weekDateLabel.text][[NSString stringWithFormat:@"%ld",(long)indexPath.row]][1];
                        if ([[imageStr2 substringToIndex:1] isEqualToString:@"6"]) {//如果貼圖是自訂的
                            NSString* path = [stamptargetdir stringByAppendingPathComponent:
                                              imageStr2];
                            
                            [eventStampBtn2 setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
                            
                        }else{//如果貼圖是預設的
                            [eventStampBtn2 setImage:[UIImage imageNamed:imageStr2] forState:UIControlStateNormal];
                        }
                    }
                    
                }
                
                
            }
            
            
            
            //設定框線及框線顏色
            //            [cell.layer setBorderWidth:0.5f];
            //            [cell.layer setBorderColor:[UIColor grayColor].CGColor];
            UIButton *classBtn = (UIButton *)[cell viewWithTag:103];
            if ([classStampArray[indexPath.row] isEqualToString:@"e"]) {//如果這個row是空的
                [classBtn setImage:nil forState:UIControlStateNormal];
            }else if([[classStampArray[indexPath.row] substringFromIndex:5] isEqualToString:@"png"]){
                //如果這個row的圖是default(1001.png)
                [classBtn setImage:[UIImage imageNamed:classStampArray[indexPath.row]] forState:UIControlStateNormal];
            }else{//如果這個row的圖是custom
                NSString* path = [stamptargetdir stringByAppendingPathComponent:
                                  classStampArray[indexPath.row]];
                
                [classBtn setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
            }
            
            [eventStampBtn1 addTarget:self action:@selector(selectedStamp:) forControlEvents:UIControlEventAllEvents];
            [eventStampBtn2 addTarget:self action:@selector(selectedStamp:) forControlEvents:UIControlEventAllEvents];
            [classBtn addTarget:self action:@selector(selectedStamp:) forControlEvents:UIControlEventAllEvents];
            
            cell.backgroundColor =nil;
            if ((indexPath.row>weekBeginTime*8 && indexPath.row<weekBeginTime*8+classNumber*8)||indexPath.row<weekBeginTime*8+classNumber*8-191) {
                cell.backgroundColor =[UIColor colorWithCGColor:[self getColorFromRed:255 Green:218 Blue:199 Alpha:1]];
                //            button1.backgroundColor = [UIColor colorWithRed:1 green:209/255 blue:209/255 alpha:1];
                //                [cell.layer setBorderWidth:1.5f];
                //                [cell.layer setBorderColor:[UIColor blackColor].CGColor];
            }
            
            return cell;
        }
        
    }
}


//cell的Size大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView == self.stampCollectionView) {
        if ((classTypeSelected == YES && indexPath.row==0)) {
            return  CGSizeMake(self.view.frame.size.width*0.1, self.view.frame.size.width*0.2);
        
        }else{
            
            return  CGSizeMake(_stampCollectionView.frame.size.height*0.4, _stampCollectionView.frame.size.height*0.4);
        }
        
    }else{
        if (self.view.frame.size.width>410) {
            return CGSizeMake(self.view.frame.size.width/8 -0.5, self.view.frame.size.width/8);
        }else{
            return CGSizeMake(self.view.frame.size.width/8, self.view.frame.size.width/8);
        }
        
    }
}



- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView == self.stampCollectionView) {
        
    }else{
        //UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        //cell.contentView.backgroundColor = [UIColor greenColor];

    }
}

//collection翻頁的時候 滑完的時候
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == self.stampCollectionView) {
        [picButton2 removeFromSuperview];
    }
    
}

//滑動的時候
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [picButton2 removeFromSuperview];
}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = nil;
    
}


#pragma mark - customstamp
- (IBAction)customstamp:(id)sender {
    [self stampBtnClick5:self.stamp5];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CustomStamp" bundle:nil];
    id targetVC = [storyBoard instantiateViewControllerWithIdentifier:@"CustomStamp"];
    [self presentViewController:targetVC animated:true completion:nil];
}



#pragma mark - stampBtn
- (IBAction)classStampBtnClick:(id)sender {
    imagePackage = [NSMutableArray new];
    
    [imagePackage addObject:@"class_stamp_新增課程.png"];
    [imagePackage addObjectsFromArray:customClassStampArray];
    [imagePackage addObjectsFromArray:defaultClassStampArray];
    
    classTypeSelected = YES;
    customStampTypeSelected = NO;
    [_stampCollectionView reloadData];
    [self buttonSelectedTransform:sender];
    
    _trashCan.hidden = YES;
}
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
    classTypeSelected = NO;
    customStampTypeSelected = YES;
    [self.stampCollectionView reloadData];
    
    _trashCan.hidden = NO;
}

- (void)normalStampSetting:(id)nomalStampButton
{
    classTypeSelected = NO;
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



-(NSString *)getDate:(NSDate *)getDate{
    
    NSDateComponents *WeekdayComponents = [CalenderOfMonth components:(NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:getDate];
    
    NSInteger i = [WeekdayComponents weekday];
    
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    //設定date顯示
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    //設定要回傳月份的Array
    
    
    //設定日期
    NSDateComponents *components1 = [[NSDateComponents alloc]init];
    [components1 setDay:[WeekdayComponents day]-i+1];
    [components1 setMonth:[WeekdayComponents month]];
    [components1 setYear:[WeekdayComponents year]];
    NSDate *date1=[CalenderOfMonth dateFromComponents:components1];
    NSString *tmpString1 = [formatter stringFromDate:date1];
    NSDateComponents *components2 = [[NSDateComponents alloc]init];
    [components2 setDay:[WeekdayComponents day]+(7-i)];
    [components2 setMonth:[WeekdayComponents month]];
    [components2 setYear:[WeekdayComponents year]];
    NSDate *date2=[CalenderOfMonth dateFromComponents:components2];
    NSString *tmpString2 = [formatter stringFromDate:date2];
    
    return [NSString stringWithFormat:@"%@~%@",tmpString1,tmpString2];
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

#pragma mark - 新增課程method
-(void)addClassStamp{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"請輸入您要新增的課程名稱" message:@"最多四個字" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        
        
        
        
        
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UITextField *inputTextField = alert.textFields[0];
        
        if(inputTextField.text == nil)
        {
        }
        else
        {
            [self takeClassStamp:inputTextField.text];
        }
        
        [alert dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        
        [alert dismissViewControllerAnimated:YES completion:nil];
        
        
    }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)takeClassStamp:(NSString *)str{
    
    UIColor *aColor = [UIColor colorWithCGColor:[self getColorFromRed:0 Green:146 Blue:199 Alpha:1]];
    UIColor *bColor = [UIColor colorWithCGColor:[self getColorFromRed:159 Green:224 Blue:246 Alpha:1]];
    UIColor *cColor = [UIColor colorWithCGColor:[self getColorFromRed:243 Green:229 Blue:154 Alpha:1]];
    UIColor *dColor = [UIColor colorWithCGColor:[self getColorFromRed:243 Green:181 Blue:155 Alpha:1]];
    UIColor *eColor = [UIColor colorWithCGColor:[self getColorFromRed:242 Green:156 Blue:156 Alpha:1]];
    UIColor *fColor = [UIColor colorWithCGColor:[self getColorFromRed:138 Green:140 Blue:178 Alpha:1]];
    UIColor *gColor = [UIColor colorWithCGColor:[self getColorFromRed:255 Green:140 Blue:120 Alpha:1]];
    UIColor *hColor = [UIColor colorWithCGColor:[self getColorFromRed:140 Green:214 Blue:181 Alpha:1]];
    NSArray *colorArray = [[NSArray alloc]initWithObjects:aColor,bColor,cColor,dColor,eColor,fColor,gColor,hColor, nil];
    
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 100)];
    backgroundView.backgroundColor = colorArray[arc4random()%8];
    UILabel *textLabel = [[UILabel alloc]initWithFrame:backgroundView.frame];
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.numberOfLines = 4;
    
    
    
    
    
    switch (str.length) {
        case 1:
            //
            [textLabel setFont:[UIFont fontWithName:@"DFPErW4-B5" size:50]];
            break;
        case 2:
            //
            [textLabel setFont:[UIFont fontWithName:@"DFPErW4-B5" size:50]];
            break;
        case 3:
            //
            [textLabel setFont:[UIFont fontWithName:@"DFPErW4-B5" size:32]];
            break;
        case 4:
            //
            [textLabel setFont:[UIFont fontWithName:@"DFPErW4-B5" size:25]];
            textLabel.bounds = CGRectMake(0, 0, 49, 100);
            break;
        default:
            str = [str substringToIndex:4];
            [textLabel setFont:[UIFont fontWithName:@"DFPErW4-B5" size:25]];
            textLabel.bounds = CGRectMake(0, 0, 49, 100);
            break;
    }
    textLabel.text = str;
    [backgroundView addSubview:textLabel];
    
    
    UIGraphicsBeginImageContext(CGSizeMake(backgroundView.frame.size.width, backgroundView.frame.size.height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [backgroundView.layer renderInContext:context];
    UIImage *Screenofstamp = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsGetImageFromCurrentImageContext();
    //資料夾
    
    NSData *imageData = UIImagePNGRepresentation(Screenofstamp);
    int lastStamp;
    if (customClassStampArray.count == 0) {//如果第一次使用自訂貼圖的話
        lastStamp = 10000;
    }else{
        NSString *lastStampStr = [customClassStampArray[0] substringToIndex:5];
        lastStamp = [lastStampStr intValue];
        lastStamp++;
    }
    
    NSString *imageName = [NSString stringWithFormat:@"%i.png",lastStamp];
    [imageData writeToFile:[stamptargetdir stringByAppendingPathComponent:imageName] atomically:YES];
    [customClassStampArray insertObject:imageName atIndex:0];
    [customClassStampArray writeToFile:[self GetDBPathFromcustomClassStamp] atomically:YES];
    [self classStampBtnClick:nil];
}


#pragma mark - 切換theme
-(void)changeTheme:(id)sender{
    //切換type
    
    NSDictionary *typeDic = [myDB sharedInstance].typeDic;
    self.background.image = [UIImage imageNamed:typeDic[@"background"]];
    self.top.image = [UIImage imageNamed:typeDic[@"top"]];
    [self.todayBtn setImage:[UIImage imageNamed:typeDic[@"todayBtn"]] forState:UIControlStateNormal];
    [self.settingBtn setImage:[UIImage imageNamed:typeDic[@"settingBtn"]] forState:UIControlStateNormal];
    [self.weekBtn setImage:[UIImage imageNamed:typeDic[@"week"]] forState:UIControlStateNormal];
    [self.dayBtn setImage:[UIImage imageNamed:typeDic[@"day"]] forState:UIControlStateNormal];
    [self.monthBtn setImage:[UIImage imageNamed:typeDic[@"month"]] forState:UIControlStateNormal];
    [self.stampclass setImage:[UIImage imageNamed:typeDic[@"stampclass"]] forState:UIControlStateNormal];
    [self.stamp1 setImage:[UIImage imageNamed:typeDic[@"stamp1"]] forState:UIControlStateNormal];
    [self.stamp2 setImage:[UIImage imageNamed:typeDic[@"stamp2"]] forState:UIControlStateNormal];
    [self.stamp3 setImage:[UIImage imageNamed:typeDic[@"stamp3"]] forState:UIControlStateNormal];
    [self.stamp4 setImage:[UIImage imageNamed:typeDic[@"stamp4"]] forState:UIControlStateNormal];
    [self.stamp5 setImage:[UIImage imageNamed:typeDic[@"stamp5"]] forState:UIControlStateNormal];
    self.wordLabel.textColor = typeDic[@"wordColor"];
    self.wordBackView.backgroundColor = typeDic[@"wordBackColor"];
    self.oneWeek.image = [UIImage imageNamed:typeDic[@"oneWeek"]];
}



#pragma mark - 選到貼圖要刪除
-(void)selectedStamp:(UIButton *)sender{

    
    NSIndexPath *indexPath =[self.weekCollectionView indexPathForCell:(UICollectionViewCell *)[[sender superview] superview]];
//    NSLog(@"%li",(long)indexPath.row);
    if (sender.tag == 103) {
        //
        [classStampArray replaceObjectAtIndex:indexPath.row withObject:@"e"];
        
        [classStampArray writeToFile:[self GetDBPathFromclassStamp] atomically:YES];
//        UIButton *classBtn = (UIButton *)[[[sender superview] superview] viewWithTag:103];
//        [classBtn setImage:nil forState:UIControlStateNormal];
    }else if (sender.tag == 104) {
        //
        if ([classEventDict[_weekDateLabel.text][[NSString stringWithFormat:@"%ld",(long)indexPath.row]] count]==1) {
            [classEventDict[_weekDateLabel.text][[NSString stringWithFormat:@"%ld",(long)indexPath.row]] replaceObjectAtIndex:0 withObject:@"space"];
            
        }else{
            [classEventDict[_weekDateLabel.text][[NSString stringWithFormat:@"%ld",(long)indexPath.row]] replaceObjectAtIndex:2 withObject:@"two"];
            [classEventDict[_weekDateLabel.text][[NSString stringWithFormat:@"%ld",(long)indexPath.row]] replaceObjectAtIndex:0 withObject:@"space"];
        }
        
        
        [classEventDict writeToFile:[self GetDBPathFromclassEventStamp] atomically:YES];
        

    }else if (sender.tag == 105) {
        [classEventDict[_weekDateLabel.text][[NSString stringWithFormat:@"%ld",(long)indexPath.row]] replaceObjectAtIndex:2 withObject:@"one"];
        [classEventDict[_weekDateLabel.text][[NSString stringWithFormat:@"%ld",(long)indexPath.row]] replaceObjectAtIndex:1 withObject:@"space"];
        [classEventDict writeToFile:[self GetDBPathFromclassEventStamp] atomically:YES];
    }
    [sender setImage:nil forState:UIControlStateNormal];
}


#pragma mark - CustomLoading
- (IBAction)CustomeLoadingBtn:(id)sender {
    
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
