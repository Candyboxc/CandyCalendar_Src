//
//  PopViewController.m
//  Calender_bycandy
//
//  Created by Dong on 2015/6/8.
//  Copyright (c) 2015年 candy. All rights reserved.
//

#import "PopViewController.h"
#import "myDB.h"
#import "JMWhenTapped.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef enum
{
    PhotoType_Album = 0,
    PhotoType_Camera
} PhotoType;


@interface PopViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,AVAudioPlayerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    
    NSArray *pushDateArray,*pushDateMinusTimeArray;
    
    /*是否支援相機,是否第一次點擊,錄音檔案是否存在,播放錄音,拍照或選擇照片回來是否讀取*/
    Boolean CameraExists,recordNumber,recordfileExist,playRecordVoice,photoLoad;
    
    /*存錄音的檔名(新/舊) / 路徑(1/2) */
    NSString *newRecordName, *oldRecordName,*recordepath, *recordegetdir;
    
    //Timer
    NSTimer *recordeTimer;
    int count;
    
    //相簿代碼
    __block NSString *url;
}
@property (weak, nonatomic) IBOutlet UIButton *pushTimeBtn;

//show image
@property (weak, nonatomic) IBOutlet UIImageView *showImage;

//record
@property (strong, nonatomic) AVAudioRecorder *voiceRecorder;
@property (weak, nonatomic) IBOutlet UIButton *recorde;

//播放錄音
@property (strong, nonatomic) AVAudioPlayer *voicePlayer;
@property (weak, nonatomic) IBOutlet UIButton *playRecord;

//存檔名
@property (strong, nonatomic) IBOutlet NSString *recordfilename;
@property (strong, nonatomic) IBOutlet NSString *photofilename;

//照片用
@property (strong, nonatomic) UIImagePickerController *photo;
@property (weak, nonatomic) UIImagePickerController *ImagePicker;

//Timer用
@property (weak, nonatomic) IBOutlet UIProgressView *timerCount;

//貼圖
@property (weak, nonatomic) IBOutlet UIImageView *stampImage;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@end

@implementation PopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    pushDateArray = @[@"無",@"事件的發生時間",@"5 分鐘前",@"15 分鐘前",@"30 分鐘前",@"1 小時前",@"2 小時前",@"1 天前",@"2 天前"];
    pushDateMinusTimeArray = @[@"無",@"0",@"300",@"900",@"1800",@"3600",@"7200",@"86400",@"172800"];
    
    CGRect superViewFrame = _parentVC.view.frame;
    _pushTimePicker = [UIPickerView new];
    _pushTimePicker.delegate = (id)self;
    _pushTimePicker.dataSource = (id)self;
    _pushTimePicker.frame = CGRectMake(0, superViewFrame.size.height, superViewFrame.size.width, 162);
    _pushTimePicker.backgroundColor = [UIColor whiteColor];
    _pushTimePicker.tag = 200;
    _pushTimePicker.showsSelectionIndicator = YES;
    
    [self.view whenTapped:^{
        [self removeAll];
    }];
}

//初始化function
-(void)NewData{
    
    //TODO:判斷要修改
    //相機,錄音判斷
    CameraExists = 1;
    recordNumber = 1;
    recordfileExist = 0;
    playRecordVoice = 1;
    count = 10;
    self.timerCount.progress = 1.0;
    
    //給錄音跟照片預設的String
    _photofilename = _recordfilename = @"";
    
    //隱藏
    [self.timerCount setHidden:YES];
    [self.playRecord setHidden:YES];
    
    self.showImage.image = nil; //讓照片重置
}

#pragma mark - viewWillAppear 會先進入
-(void)viewWillAppear:(BOOL)animated{
    
    //第一次進入才做出始值動作
    if (photoLoad == 0) {
        [self NewData];
    }
    
    [super viewWillAppear:animated];
    [self pickerView:self.pushTimePicker didSelectRow:2 inComponent:0];
    [_pushTimePicker selectRow:2 inComponent:0 animated:NO];
    
    NSString *imageStr = _eventInfoDic[@"stamp_id"];
    if ([[imageStr substringToIndex:1]isEqualToString:@"6"]) {//如果存的是自訂貼圖
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *stampdir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *stamptargetdir = [stampdir stringByAppendingPathComponent:@"customstamp"];
        
        //判斷若不存在的話,則創建一個
        if (![fileManager fileExistsAtPath:stamptargetdir]) {
            [fileManager createDirectoryAtPath:stamptargetdir
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:nil];
        }
        
        NSString* path = [stamptargetdir stringByAppendingPathComponent:
                          imageStr];
        
        [self.stampImage setImage:[UIImage imageWithContentsOfFile:path]];
    }else{
        [self.stampImage setImage:[UIImage imageNamed:imageStr]];
    }
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(IBAction)pushTimeBtnClick:(id)sender {
    
    [self removeAll];
    
    _pushTimePicker.center = CGPointMake([self.view superview].frame.size.width/2,
                                         [self.view superview].frame.size.height+_pushTimePicker.frame.size.height/2);
    
    [[self.view superview] addSubview:_pushTimePicker];
    
    
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
//        datePicker.frame = CGRectMake(0, self.view.frame.size.height-datePicker.frame.size.height, self.view.frame.size.width, height/5);
        _pushTimePicker.center = CGPointMake([self.view superview].frame.size.width/2, [self.view superview].frame.size.height-_pushTimePicker.frame.size.height/2);
        
    } completion:^(BOOL finished) {
        
    }];
}



#pragma mark - save and cancel
-(IBAction)saveBtnClick:(id)sender {
    
    //若錄音中
    if (_voiceRecorder.isRecording == YES) {
        [_voiceRecorder stop];
        self.voiceRecorder = nil;
        [self.recorde setImage:[UIImage imageNamed:@"popover_voice.png"] forState:UIControlStateNormal];
    }

    NSDate *eventStartDate = [_parentVC.datePicker date];
    NSDate *eventEndDate = [_parentVC.datePicker2 date];
    NSString *eventMemoString = _textView.text;
    NSDate *eventAlarmDate;//push時間
    
    //刪除預覽貼圖用的tmpDic
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *str = @"1970-01-01";
    if ([_pushTimePicker selectedRowInComponent:0] == 0) {
        eventAlarmDate = [formatter dateFromString:str];//若是選擇無 則設定推播時間為1970年
    }else{
        //其他的則看選擇哪個ROW去讓他減少時間
        eventAlarmDate = [eventStartDate dateByAddingTimeInterval:[pushDateMinusTimeArray[[_pushTimePicker selectedRowInComponent:0]]intValue]*-1];
    }
    
    //NSTimeInterval eventStartTime = [eventStartDate timeIntervalSince1970];
    
    //NSLog(@"%f",eventStartTime);
    
    //TODO:是否不需要？
    /*
    NSDictionary *eventCommetDic = @{@"id":_eventInfoDic[@"id"]
                                     ,@"date_year":_eventInfoDic[@"date_year"]
                                     ,@"date_month":_eventInfoDic[@"date_month"]
                                     ,@"date_day":_eventInfoDic[@"date_day"]
                                     ,@"position":_eventInfoDic[@"position"]
                                     ,@"stamp_id":_eventInfoDic[@"stamp_id"]
                                     ,@"memo":eventMemoString
                                     ,@"alarm_type":eventAlarmDate
                                     ,@"start_alarm":eventStartDate
                                     ,@"end_alarm":eventEndDate
                                     ,@"photo_id":_photofilename  //TODO:加入PHOTO
                                     ,@"record_id":_recordfilename    //TODO:加入RECORD
                                     };
    
    */
    
    NSMutableDictionary *eventCommetDic = [[NSMutableDictionary alloc]initWithDictionary:self.eventInfoDic];
    
    eventCommetDic[@"alarm_type"] = [NSNumber numberWithInteger:[eventAlarmDate timeIntervalSince1970]];
    eventCommetDic[@"start_alarm"] = [NSNumber numberWithInteger:[eventStartDate timeIntervalSince1970]];
    eventCommetDic[@"end_alarm"] = [NSNumber numberWithInteger:[eventEndDate timeIntervalSince1970]];
    
    if(![eventMemoString isEqualToString:@""] || ![eventMemoString isEqualToString:@"請輸入事項"]){
        //有memo時，存memo
        if (![eventMemoString isEqualToString:@"請輸入事項"]) {
            eventCommetDic[@"memo"] = eventMemoString;
        }
    }
    
    if(![_photofilename isEqualToString:@""]){
        //有照片時，存照片id
        eventCommetDic[@"photo_id"] = _photofilename;
        eventCommetDic[@"photo_url"] = url;
    }
    
    if(![_recordfilename isEqualToString:@""]){
        //有錄音時，存錄音id
        eventCommetDic[@"record_id"] = _recordfilename;
    }
    
    //date_month,date_day,position,stamp_id,memo,alarm_type,start_alarm,end_alarm,photo_id,record_id
    
    
    if ([[myDB sharedInstance].settingDict[@"pushNotification"] isEqualToString:@"YES"]) {//如果push設定有開的話
        if ([eventAlarmDate earlierDate:[NSDate date]] != eventAlarmDate) {//如果push時間較現在時間晚的話
            UILocalNotification *localNotif = [UILocalNotification new];
            localNotif.fireDate = eventAlarmDate;
            localNotif.timeZone = [NSTimeZone defaultTimeZone];
            NSDateFormatter *formatter = [NSDateFormatter new];
            [formatter setDateFormat:@"HH:mm"];//date的格式
            NSString *tmpNowTime = [formatter stringFromDate:eventStartDate];//現在的時間
            NSString *tmpEndTime = [formatter stringFromDate:eventEndDate];
            if ([self.textView.text isEqualToString:@"請輸入事項"]) {
                localNotif.alertBody = [NSString stringWithFormat:@"待辦事項 %@-%@",tmpNowTime,tmpEndTime];
            }else{
                localNotif.alertBody = [NSString stringWithFormat:@"%@ %@-%@",self.textView.text,tmpNowTime,tmpEndTime];
            }
            
            localNotif.soundName = UILocalNotificationDefaultSoundName;
            localNotif.applicationIconBadgeNumber = 0;
            NSDictionary *info = [[NSDictionary alloc]initWithObjectsAndKeys: eventCommetDic[@"id"],@"uid", nil];
            localNotif.userInfo = info;
            [[UIApplication sharedApplication]scheduleLocalNotification:localNotif];//設定推播
            
            UIApplication *app = [UIApplication sharedApplication];
            NSArray *eventArray = [app scheduledLocalNotifications];
            for (int i=0; i<[eventArray count]; i++)
            {
                UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
                NSDictionary *userInfoCurrent = oneEvent.userInfo;
                NSString *uid=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:@"uid"]];
            }
        }
    }
    
    photoLoad = 0;
    [self NewData]; //初始化
    
    //新增事件資訊
    [self.parentVC SaveEventWithFullDic:eventCommetDic];
}

-(IBAction)cancelBtnClick:(id)sender {
    
    //若錄音中
    if (_voiceRecorder.isRecording == YES) {
        [_voiceRecorder stop];
        self.voiceRecorder = nil;
        [self.recorde setImage:[UIImage imageNamed:@"popover_voice.png"]
                      forState:UIControlStateNormal];
    }
    
    //刪除錄音檔案
    if (![newRecordName isEqualToString:@""]) {
        
        [self LoadPath];
        NSString *recordfilePathName = [recordegetdir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",newRecordName]];
        NSFileManager *recordfileManager = [NSFileManager defaultManager];
        
        [recordfileManager removeItemAtPath:recordfilePathName error:nil];
    }
    
    //刪除照片檔案
    if (![_photofilename isEqualToString:@""]) {
        
        NSString *photopath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *photogetdir = [photopath stringByAppendingPathComponent:@"photo"];   //資料夾
        NSString *imgPath = [photogetdir stringByAppendingPathComponent:self.photofilename];
        NSFileManager *photofileManager = [NSFileManager defaultManager];
        
        [photofileManager removeItemAtPath:imgPath error:nil];
    }
    
    photoLoad = 0;
    [self NewData]; //初始化
    
    [self.parentVC SaveEventWithFullDic:_eventInfoDic];
}


-(IBAction)dateBtnClick:(id)sender {
    [self removeAll];
    _parentVC.datePicker.center = CGPointMake([self.view superview].frame.size.width/2,
                                              [self.view superview].frame.size.height+_parentVC.datePicker.frame.size.height/2);
    _parentVC.datePicker2.center = CGPointMake([self.view superview].frame.size.width/2,
                                               [self.view superview].frame.size.height+_parentVC.datePicker.frame.size.height/2);
    [[self.view superview] addSubview:_parentVC.datePicker];
    [[self.view superview] addSubview:_parentVC.datePicker2];
    [UIView transitionWithView:_parentVC.datePicker duration:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
        //            datePicker.frame = CGRectMake(0, self.view.frame.size.height-datePicker.frame.size.height, self.view.frame.size.width, height/5);
        _parentVC.datePicker.center = CGPointMake([self.view superview].frame.size.width/4,
                                                  [self.view superview].frame.size.height-_parentVC.datePicker.frame.size.height/2);
        _parentVC.datePicker2.center = CGPointMake(3*[self.view superview].frame.size.width/4,
                                                   [self.view superview].frame.size.height-_parentVC.datePicker.frame.size.height/2);
        
    } completion:^(BOOL finished) {
        
    }];
}


#pragma mark - 錄音跟拍照
//讀取錄音路徑
-(void)LoadPath{
    
    recordepath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    recordegetdir = [recordepath stringByAppendingPathComponent:@"recorde"];   //資料夾
}

//錄音
-(IBAction)recordBtnAction:(id)sender {
    
    //判斷如果在播放錄音的同時點擊了錄音的話 要做什麼動作
    if (self.voicePlayer.isPlaying) {
        [self.voicePlayer stop];
        [self.playRecord setImage:[UIImage imageNamed:@"popover_voice_play.png"]
                         forState:UIControlStateNormal];
        
        playRecordVoice = 1;
    }
    
    if (recordNumber == 1) {
        
        //若該檔案存在的話,則要跳出alert
        if (recordfileExist == 1) {
            
            count = 10;
            self.timerCount.progress = 1.0;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您已有錄音\n請問是否要覆蓋？"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"覆蓋", nil];
            [alert show];
        }else{
            
            [self prepareRecording];
            [self.timerCount setHidden:NO];
            recordeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                            target:self
                                                          selector:@selector(timerEvent:)
                                                          userInfo:nil
                                                           repeats:YES];
            [self.voiceRecorder recordForDuration:10];  //錄音限制10秒
            
            [self.recorde setImage:[UIImage imageNamed:@"popover_voice_stop.png"] forState:UIControlStateNormal];
            recordNumber = 0;
        }
        
    }else if(recordNumber == 0){
        
        [self.timerCount setHidden:YES];
        
        [recordeTimer invalidate];
        recordeTimer = nil;
        
        [self.voiceRecorder stop];
        self.voiceRecorder = nil;
        [self.recorde setImage:[UIImage imageNamed:@"popover_voice.png"] forState:UIControlStateNormal];
        
        if (self.playRecord.isHidden == YES) {
            [self.playRecord setHidden:NO];
        }
        
        recordNumber = 1;
    }
}

//Timer
-(void)timerEvent:(NSTimer *)sender{
    
    if (count != 0) {
        count = count - 1;
        self.timerCount.progress = self.timerCount.progress - 0.1;
        
    }else if(count == 0){
        
        [self.timerCount setHidden:YES];
        
        [recordeTimer invalidate];
        recordeTimer = nil;
        
        [self.voiceRecorder stop];
        self.voiceRecorder = nil;
        [self.recorde setImage:[UIImage imageNamed:@"popover_voice.png"]
                      forState:UIControlStateNormal];
        
        if (self.playRecord.isHidden == YES) {
            [self.playRecord setHidden:NO];
        }
        
        recordNumber = 1;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        
        [self.timerCount setHidden:NO];
        recordeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                        target:self
                                                      selector:@selector(timerEvent:)
                                                      userInfo:nil
                                                       repeats:YES];
        
        oldRecordName = newRecordName;  //把最新的檔名變成舊檔名
        [self prepareRecording];
        [self.voiceRecorder recordForDuration:10];  //錄音限制10秒
        [self.recorde setImage:[UIImage imageNamed:@"popover_voice_stop.png"] forState:UIControlStateNormal];
        
        recordNumber = 0;
        
        //刪除舊檔案
        [self LoadPath];    //讀取路徑
        NSString *recordfilePathName = [recordegetdir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",oldRecordName]];
        NSFileManager *recordfileManager = [NSFileManager defaultManager];
        
        [recordfileManager removeItemAtPath:recordfilePathName error:nil];

    }
}

//播放錄音
-(IBAction)recordplayBtnAction:(id)sender {
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    if (self.voiceRecorder.isRecording == NO) {
        //讀取路徑播放
        [self LoadPath];
        NSString *recordfilePathName = [recordegetdir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",newRecordName]];
        
        if (playRecordVoice == 1) {
            
            self.voicePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:recordfilePathName]
                                                                  error:nil];
            self.voicePlayer.numberOfLoops = 0;
            [self.voicePlayer prepareToPlay];
            [self.voicePlayer play];
            self.voicePlayer.delegate = self;
            [self.playRecord setImage:[UIImage imageNamed:@"popover_voice_stop.png"]
                             forState:UIControlStateNormal];
            
            playRecordVoice = 0;
            
        }else if(playRecordVoice == 0){
        
            [self.voicePlayer stop];
            [self.playRecord setImage:[UIImage imageNamed:@"popover_voice_play.png"]
                             forState:UIControlStateNormal];
            
            playRecordVoice = 1;
        }
    }
}

// 拍照
- (IBAction)photoBtnAction:(id)sender
{
    [self checkUseAlbumOrCamera];
}

- (void)checkUseAlbumOrCamera
{
    UIAlertController *albumOrCameraAlert = [[UIAlertController alloc] init];
    
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"相簿" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //
        [self setPhotoType:PhotoType_Album];
    }];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"相機" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //
        [self setPhotoType:PhotoType_Camera];
    }];
    
    if (CameraExists == 1)
    {
        [albumOrCameraAlert addAction:cameraAction];
    }
    [albumOrCameraAlert addAction:albumAction];    
    
    [self presentViewController:albumOrCameraAlert animated:YES completion:nil];
}

-(void)setPhotoType:(PhotoType)type{
    
    //AlbumOrCamera 0為相簿 1為相機
    self.photo = [[UIImagePickerController alloc] init];
    
    if (type == PhotoType_Album)
    {
        self.photo.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.photo.delegate = self;
        
        [self presentViewController:self.photo
                           animated:YES
                         completion:nil];
        
        photoLoad = 1;
        
    }
    else if (type == PhotoType_Camera)
    {
        //判斷是否有支援相機 不支援的話就跳出Alert
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO){
            
            UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:nil
                                                              message:@"抱歉!您的手機並不支援相機喔!"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [alertView show];
            
            CameraExists = 0;
            
            return;
        }
        else
        {
            self.photo.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.photo.cameraDevice = UIImagePickerControllerCameraDeviceRear;  //選擇後置鏡頭
            self.photo.mediaTypes = [NSArray arrayWithObjects:@"public.image", nil];
            self.photo.allowsEditing = YES;
            
            //建立拍照畫面
            self.photo.delegate = self;
            self.ImagePicker = self.photo;
            
            [self presentViewController:self.photo
                               animated:YES
                             completion:nil];
            
            photoLoad = 1;
        }
    }
}

//相簿開啟或拍照開啟會呼叫此方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    //取得剛剛開好的照片
    UIImage *photo = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if( [picker sourceType] == UIImagePickerControllerSourceTypeCamera){
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.saveBtn.enabled = NO;
        [library writeImageToSavedPhotosAlbum:image.CGImage
                                  orientation:(ALAssetOrientation)image.imageOrientation
                              completionBlock:^(NSURL *assetURL, NSError *error ){
            
                                  self.saveBtn.enabled = YES;
                                  //NSLog(@"IMAGE SAVED TO PHOTO ALBUM");
                                  [library assetForURL:assetURL
                                           resultBlock:^(ALAsset *asset ){
                                               NSLog(@"we have our ALAsset!");
                                               NSLog(@"%@", assetURL);
                                               url = [NSString stringWithFormat:@"%@",assetURL];
                                               NSLog(@"%@",url);
                                           }
                                          failureBlock:^(NSError *error ){
                                          }];
                            }];
    }else{
        url = [info valueForKey:UIImagePickerControllerReferenceURL];
    }
    
    //關閉拍照程式
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    
    self.photo = nil;

    //show photo
    self.showImage.image = photo;
    
    NSDateFormatter *today = [NSDateFormatter new];
    NSString *Date;
    [today setDateFormat:@"yyyyMMddHHmmss"];
    Date = [today stringFromDate:[NSDate date]];
    self.photofilename =[NSString stringWithFormat:@"%@",Date];
    
    //做縮圖的動作 並 寫入至Document的photo資料夾下
    NSData *photoData = UIImageJPEGRepresentation(photo, 0.3);
    
    NSString *photopath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *photogetdir = [photopath stringByAppendingPathComponent:@"photo"];   //資料夾
    NSString *imgPath = [photogetdir stringByAppendingPathComponent:self.photofilename];
    NSFileManager *photofileManager = [NSFileManager defaultManager];
    
    //判斷資料夾若不存在的話,則創建一個
    if (![photofileManager fileExistsAtPath:photogetdir]) {
        [photofileManager createDirectoryAtPath:photogetdir
                      withIntermediateDirectories:YES
                                       attributes:nil
                                            error:nil];
    }
    
    [photoData writeToFile:imgPath atomically:YES];
    
    photoLoad = 1;
}

//若Camera點選Cancel會呼叫此方法
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    //關閉程式
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    self.photo = nil;
    
    photoLoad = 1;
}



#pragma mark - Avaudioplayerdelegate
//播放錄音結束時會做的動作
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    [self.playRecord setImage:[UIImage imageNamed:@"popover_voice_play.png"] forState:UIControlStateNormal];
    playRecordVoice = 1;
}

//存錄音檔
-(void)prepareRecording{
    
    //@()->包裝成NSNumber的動作 Ex:[NSNumber numberWithDouble:22050.0] = @(22050.0) = @22050.0 數字可以不用()
    NSDictionary *setting = @{AVFormatIDKey:@(kAudioFormatAppleIMA4),
                              AVSampleRateKey:@(22050.0),/*目前所用的品質是CD音質的4分之一*/
                              AVNumberOfChannelsKey:@(1),/*表示單聲道*/
                              AVLinearPCMBitDepthKey:@(16),/*16bit */
                              /*以下為PC相關*/
                              AVLinearPCMIsBigEndianKey:@(NO),
                              AVLinearPCMIsFloatKey:@(NO)};
    
    //Prepare File Path
    [self LoadPath];
    NSFileManager *recordefileManager = [NSFileManager defaultManager];
    
    /*stringByAppendingPathComponent -> 會有一個完整的路徑檔名*/
    //caf包含任何編碼 所以副檔名不能亂取
    NSDateFormatter *today = [NSDateFormatter new];
    NSString *Date;
    [today setDateFormat:@"yyyyMMddHHmmss"];
    Date = [today stringFromDate:[NSDate date]];
    self.recordfilename =[NSString stringWithFormat:@"%@",Date];
    newRecordName = self.recordfilename;    //將檔名給newRecordName暫存
    
    NSString *recordePathName = [recordegetdir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",self.recordfilename]];
    
    //判斷資料夾若不存在的話,則創建一個
    if (![recordefileManager fileExistsAtPath:recordegetdir]) {
        [recordefileManager createDirectoryAtPath:recordegetdir
                      withIntermediateDirectories:YES
                                       attributes:nil
                                            error:nil];
    }
    
    //轉成URL給它包進去
    //fileURLWithPath -> 才能將路徑包進去
    self.voiceRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:recordePathName]
                                                     settings:setting
                                                        error:nil];
    [self.voiceRecorder prepareToRecord];
    
    //TODO: Change Audio Session 一定要做!!
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord
                                           error:nil];
    //確定檔案已存在
    recordfileExist = 1;
    
//    NSLog(@"record:%@, photo: %@",self.recordfilename,self.photofilename);
}



#pragma mark - PickerView Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return pushDateArray.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return _parentVC.view.frame.size.width;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return pushDateArray[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [_pushTimeBtn setTitle:[NSString stringWithFormat:@"提醒時間：%@",pushDateArray[row]] forState:UIControlStateNormal];
}

-(void)removeAll{
    [_textView resignFirstResponder];
    [_parentVC.datePicker removeFromSuperview];
    [_parentVC.datePicker2 removeFromSuperview];
    [_pushTimePicker removeFromSuperview];
}
@end
