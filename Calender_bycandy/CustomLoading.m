//
//  CustomLoading.m
//  Calender_bycandy
//
//  Created by candy on 2015/6/29.
//  Copyright (c) 2015年 candy. All rights reserved.
//

#import "CustomLoading.h"
#import "myDB.h"
#import "JMWhenTapped.h"

@interface CustomLoading ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    
    NSArray *headArray,*faceArray,*dressArray,*weaponArray;
    
    UICollectionViewCell *selectCell;
    
    NSMutableArray *cellArray;
    NSMutableDictionary *equipDic;
    
    /*判斷頁籤,經驗值,等級*/
    int partOfNumber,progressImageNumber,levelOfNumber;
    
    /* 新的服裝 / 舊的服裝 */
//    NSMutableDictionary *NewDic,*OldDic;
}

@property (weak, nonatomic) IBOutlet UICollectionView *mycollectionview;

//Image
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UIImageView *faceImage;
@property (weak, nonatomic) IBOutlet UIImageView *dressImage;
@property (weak, nonatomic) IBOutlet UIImageView *weaponImage;

//頁籤button
@property (weak, nonatomic) IBOutlet UIButton *headBtn;
@property (weak, nonatomic) IBOutlet UIButton *faceBtn;
@property (weak, nonatomic) IBOutlet UIButton *dressBtn;
@property (weak, nonatomic) IBOutlet UIButton *weaponBtn;

//經驗值
@property (weak, nonatomic) IBOutlet UIView *topview;
@property (weak, nonatomic) IBOutlet UIProgressView *progressview;

//經驗值 等級
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressviewLabel;

@end

@implementation CustomLoading

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //讀取圖片
    _faceImage.image = [UIImage imageNamed:[myDB sharedInstance].scoreDict[@"face"]];
    _dressImage.image = [UIImage imageNamed:[myDB sharedInstance].scoreDict[@"cloth1"]];
    _headImage.image = [UIImage imageNamed:[myDB sharedInstance].scoreDict[@"head"]];
    _weaponImage.image = [UIImage imageNamed:[myDB sharedInstance].scoreDict[@"equipment"]];
    equipDic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[myDB sharedInstance].scoreDict[@"face"],@"face",
                                                                  [myDB sharedInstance].scoreDict[@"cloth1"],@"cloth1",
                                                                  [myDB sharedInstance].scoreDict[@"cloth2"],@"cloth2",
                                                                  [myDB sharedInstance].scoreDict[@"head"],@"head",
                                                                  [myDB sharedInstance].scoreDict[@"equipment"],@"equipment", nil];
    
//    //把資料放入新&&舊的Dic
//    OldDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",[myDB sharedInstance].scoreDict[@"head"]],@"head",
//                                                                 [NSString stringWithFormat:@"%@",[myDB sharedInstance].scoreDict[@"face"]],@"face",
//                                                                 [NSString stringWithFormat:@"%@",[myDB sharedInstance].scoreDict[@"cloth1"]],@"cloth1",
//                                                                 [NSString stringWithFormat:@"%@",[myDB sharedInstance].scoreDict[@"equipment"]],@"equipment", nil];
//    
//    NewDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",[myDB sharedInstance].scoreDict[@"head"]],@"head",
//                                                                 [NSString stringWithFormat:@"%@",[myDB sharedInstance].scoreDict[@"face"]],@"face",
//                                                                 [NSString stringWithFormat:@"%@",[myDB sharedInstance].scoreDict[@"cloth1"]],@"cloth1",
//                                                                 [NSString stringWithFormat:@"%@",[myDB sharedInstance].scoreDict[@"equipment"]],@"equipment", nil];
    
    
    _mycollectionview.delegate = self;
    _mycollectionview.dataSource = self;
    
    //一開始的頁籤放大
    [_headBtn setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
    
    //先給頁籤數字
    partOfNumber = 1;
    
    //更新DB
    [[myDB sharedInstance] checkAvatarTable];
    
    //抓取plist的分數
    progressImageNumber = [[myDB sharedInstance] score];
    _scoreLabel.text = [NSString stringWithFormat:@"%d",progressImageNumber];
    levelOfNumber = (progressImageNumber / 10)+1;
    _levelLabel.text = [NSString stringWithFormat:@"%d",levelOfNumber];
    int number = progressImageNumber % 10;  //取餘數
    [_progressview setProgress:number*0.1];
    
    [_progressview setTransform:CGAffineTransformMakeScale(1.0, 2.0)];
    _progressviewLabel.text = [NSString stringWithFormat:@"%d / %d",progressImageNumber,levelOfNumber*10];
    
    
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
    bannerView_.adUnitID = @"ca-app-pub-7172905197509417/4036443485";
    
    // 通知執行階段，將使用者帶往廣告到達網頁後，該恢復哪一個 UIViewController，
    // 並將其加入檢視階層中。
    bannerView_.rootViewController = self;
    
    
    // 啟動一般請求，隨著廣告一起載入。
    [bannerView_ loadRequest:[GADRequest request]];   //實際
    //[bannerView_ loadRequest:[self createTestRequest]];  //測試
    
    //NSLog(@"height: %f",self.view.frame.size.height);
    //4s:480   //5:568    //6:736
    [self.view addSubview:bannerView_];
    
    
    
    //NSArray *allArray = [[myDB sharedInstance]queryAvatar];
    headArray = [[myDB sharedInstance]queryAvatarWithPart:@"1"];
    faceArray = [[myDB sharedInstance]queryAvatarWithPart:@"2"];
    dressArray = [[myDB sharedInstance]queryAvatarWithPart:@"3"];
    weaponArray = [[myDB sharedInstance]queryAvatarWithPart:@"4"];
    
    //    for (int i=0; i<headArray.count; i++) {
    //        NSLog(@"head %@",[NSString stringWithFormat:@"%@",headArray[i][@"name"]]);
    //    }
    //
    //    for (int i=0; i<faceArray.count; i++) {
    //        NSLog(@"face %@",[NSString stringWithFormat:@"%@",faceArray[i][@"name"]]);
    //    }
    //
    //    for (int i=0; i<dressArray.count; i++) {
    //        NSLog(@"dress %@",[NSString stringWithFormat:@"%@",dressArray[i][@"name"]]);
    //    }
    //
    //    for (int i=0; i<weaponArray.count; i++) {
    //       NSLog(@"weapon %@",[NSString stringWithFormat:@"%@",weaponArray[i][@"name"]]);
    //    }
    
    cellArray = [[NSMutableArray alloc] initWithArray:headArray];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([myDB sharedInstance].lastScore < [myDB sharedInstance].score) {
        //
        NSMutableString *titleStr =[NSMutableString stringWithFormat:@"您的分數新增了:%i分",[myDB sharedInstance].score - [myDB sharedInstance].lastScore];
        if ([[myDB sharedInstance].firstOpenAppBonus isEqualToString:@"YES"]) {
            [titleStr appendString:@"\n每日登入獎勵1分"];
            
        }
        [titleStr appendString:[NSString stringWithFormat:@"\n目前分數是:%li分",(long)[myDB sharedInstance].score]];
        if([myDB sharedInstance].lastScore/10 < [myDB sharedInstance].score/10){//升級
            [titleStr insertString:[NSString stringWithFormat:@"恭喜您升級囉\n等級 %i -> %i\n快去看看有哪些新解鎖的衣服吧\n\n",levelOfNumber-1,levelOfNumber] atIndex:0];
        }
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:titleStr message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [myDB sharedInstance].firstOpenAppBonus = @"NO";
        [alert show];
    }
    [myDB sharedInstance].lastScore = [myDB sharedInstance].score;
}

#pragma mark - back and save
- (IBAction)BackBtn:(id)sender {
    
    NSString *dbScorePath = [self GetDBScorePath];
    

    [[myDB sharedInstance].scoreDict setObject:equipDic[@"head"] forKey:@"head"];
    [[myDB sharedInstance].scoreDict setObject:equipDic[@"face"] forKey:@"face"];
    [[myDB sharedInstance].scoreDict setObject:equipDic[@"cloth1"] forKey:@"cloth1"];
    [[myDB sharedInstance].scoreDict setObject:equipDic[@"cloth2"] forKey:@"cloth2"];
    [[myDB sharedInstance].scoreDict setObject:equipDic[@"equipment"] forKey:@"equipment"];
    
    [[myDB sharedInstance].scoreDict writeToFile:dbScorePath atomically:YES];
    
    [self dismissViewControllerAnimated:NO
                             completion:nil];
    
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - collectionview delegate

//建立Section數量
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

//每個section的item數量
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return cellArray.count;
    
}

//製作cell內容
-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UIButton *ImageButton;
    UILabel *LevelLabel;
    
    //Identifier名稱要取cell
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    //[cell setTransform:CGAffineTransformMakeScale(1, 1)];
    
    //設定圓角
    cell.layer.cornerRadius = 10;
    ImageButton  = (UIButton *)[cell viewWithTag:101];
    LevelLabel = (UILabel *)[cell viewWithTag:102];
    
    
    //先設為nil
    [ImageButton setImage:nil forState:UIControlStateNormal];
    
    [ImageButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",cellArray[indexPath.row][@"name"]]] forState:UIControlStateNormal];
    
    //圖片enable
    if ([cellArray[indexPath.row][@"point"] intValue] <= levelOfNumber) {
        [ImageButton setEnabled:YES];
        [LevelLabel setHidden:YES];
    }else{
        [ImageButton setEnabled:NO];
        [LevelLabel setHidden:NO];
        LevelLabel.text = [NSString stringWithFormat:@"Lv.%@",cellArray[indexPath.row][@"point"]];
    }
    
    
    //裝備圖片放大
    switch (partOfNumber) {
        case 1:
            if ([equipDic[@"head"] isEqualToString:[NSString stringWithFormat:@"%@", cellArray[indexPath.row][@"name"]]]) {
//                [selectCell setTransform:CGAffineTransformMakeScale(1, 1)];
                [cell setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
                selectCell = cell;
            }else{
//                selectCell = nil;
                [cell setTransform:CGAffineTransformMakeScale(1, 1)];
            }
            break;
            
        case 2:
            if ([equipDic[@"face"] isEqualToString:[NSString stringWithFormat:@"%@", cellArray[indexPath.row][@"name"]]]) {
//                [selectCell setTransform:CGAffineTransformMakeScale(1, 1)];
                [cell setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
                selectCell = cell;
            }else{
//                selectCell = nil;
                [cell setTransform:CGAffineTransformMakeScale(1, 1)];
            }
            break;
            
        case 3:
            if ([equipDic[@"cloth1"] isEqualToString:[NSString stringWithFormat:@"%@", cellArray[indexPath.row][@"name"]]]) {
//                [selectCell setTransform:CGAffineTransformMakeScale(1, 1)];
                [cell setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
                selectCell = cell;
            }else{
//                selectCell = nil;
                [cell setTransform:CGAffineTransformMakeScale(1, 1)];
            }
            break;
            
        case 4:
            if ([equipDic[@"equipment"] isEqualToString:[NSString stringWithFormat:@"%@", cellArray[indexPath.row][@"name"]]]) {
//                [selectCell setTransform:CGAffineTransformMakeScale(1, 1)];
                [cell setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
                selectCell = cell;
            }else{
//                selectCell = nil;
                [cell setTransform:CGAffineTransformMakeScale(1, 1)];
            }
            break;
            
        default:
            break;
    }

    
    [ImageButton setBackgroundColor:[UIColor colorWithRed:255 green:168 blue:65 alpha:0.5]];
    
    [ImageButton whenTapped:^{
        
        NSLog(@"YES");
        
        
        if (selectCell == cell) {
            
            selectCell = nil;
            [cell setTransform:CGAffineTransformMakeScale(1, 1)];
            
            switch (partOfNumber) {
                case 1:
                    [_headImage setImage:[UIImage imageNamed:@""]];
                    [equipDic setObject:@" " forKey:@"head"];
                    break;
                    
                case 2:
                    [_faceImage setImage:[UIImage imageNamed:@""]];
                    [equipDic setObject:@" " forKey:@"face"];
                    break;
                    
                case 3:
                    [_dressImage setImage:[UIImage imageNamed:@""]];
                    [equipDic setObject:@" " forKey:@"cloth1"];
                    [equipDic setObject:@" " forKey:@"cloth2"];
                    break;
                    
                case 4:
                    [_weaponImage setImage:[UIImage imageNamed:@""]];
                    [equipDic setObject:@" " forKey:@"equipment"];
                    break;
                    
                default:
                    break;
            }
        }else{
            
            [selectCell setTransform:CGAffineTransformMakeScale(1, 1)];
            [cell setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
            
            switch (partOfNumber) {
                case 1:
                    [_headImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",cellArray[indexPath.row][@"name"]]]];
                    [equipDic setObject:[NSString stringWithFormat:@"%@",cellArray[indexPath.row][@"name"]] forKey:@"head"];
                    
//                    [NewDic removeObjectForKey:@"head"];
//                    [NewDic setObject:[NSString stringWithFormat:@"%@",cellArray[indexPath.row][@"name"]] forKey:@"head"];

                    break;
                    
                case 2:
                    NSLog(@"faceArray");
                    [_faceImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",cellArray[indexPath.row][@"name"]]]];
                    [equipDic setObject:[NSString stringWithFormat:@"%@",cellArray[indexPath.row][@"name"]] forKey:@"face"];
                    
//                    [NewDic removeObjectForKey:@"face"];
//                    [NewDic setObject:[NSString stringWithFormat:@"%@",cellArray[indexPath.row][@"name"]] forKey:@"face"];
                    
                    break;
                    
                case 3:
                    NSLog(@"dressArray");
                    [_dressImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",cellArray[indexPath.row][@"name"]]]];
                    [equipDic setObject:[NSString stringWithFormat:@"%@",cellArray[indexPath.row][@"name"]] forKey:@"cloth1"];
                    [equipDic setObject:[NSString stringWithFormat:@"%@_1",cellArray[indexPath.row][@"name"]] forKey:@"cloth2"];
                    
//                    [NewDic removeObjectForKey:@"cloth1"];
//                    [NewDic setObject:[NSString stringWithFormat:@"%@",cellArray[indexPath.row][@"name"]] forKey:@"cloth1"];
                    
                    break;
                    
                case 4:
                    NSLog(@"weaponArray");
                    [_weaponImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",cellArray[indexPath.row][@"name"]]]];
                    [equipDic setObject:[NSString stringWithFormat:@"%@",cellArray[indexPath.row][@"name"]] forKey:@"equipment"];
                    
//                    [NewDic removeObjectForKey:@"equipment"];
//                    [NewDic setObject:[NSString stringWithFormat:@"%@",cellArray[indexPath.row][@"name"]] forKey:@"equipment"];
                    
                    break;
                    
                default:
                    break;
            }
            
            selectCell = cell;
        }
    }];
    
    return cell;
}

//Cell Size 大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGRect mainScreen = [UIScreen mainScreen].bounds;
    
    //6
    if (mainScreen.size.width == 375 && mainScreen.size.height > 600) {
        return CGSizeMake(70, 70);
        
        //6+
    }else if (mainScreen.size.width == 414 && mainScreen.size.height > 700) {
        return CGSizeMake(80, 80);
        
        //5
    }else if (mainScreen.size.width == 320 && mainScreen.size.height > 500) {
        return CGSizeMake(60, 60);
        
        //4
    }else if (mainScreen.size.width == 320 && mainScreen.size.height > 440) {
        return CGSizeMake(50, 50);
        
        //ipad
    }else {
        return CGSizeMake(100, 100);
    }
}

//頭部
- (IBAction)HeadBtnClicked:(id)sender {
    partOfNumber = 1;
    
    cellArray = [[NSMutableArray alloc] initWithArray:headArray];
    [self allclear];
    [_headBtn setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
    [self buttonclicke];
}

//臉部
- (IBAction)FaceBtnClicked:(id)sender {
    partOfNumber = 2;
    
    cellArray = [[NSMutableArray alloc] initWithArray:faceArray];
    [self allclear];
    [_faceBtn setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
    [self buttonclicke];
}

//服裝
- (IBAction)DressBtnClicked:(id)sender {
    partOfNumber = 3;
    
    cellArray = [[NSMutableArray alloc] initWithArray:dressArray];
    [self allclear];
    [_dressBtn setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
    [self buttonclicke];
}

//飾品
- (IBAction)WeaponBtnClicked:(id)sender {
    partOfNumber = 4;
    
    cellArray = [[NSMutableArray alloc] initWithArray:weaponArray];
    [self allclear];
    [_weaponBtn setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
    [self buttonclicke];
    
}

#pragma mark - 共用的fuction

//共用的fuction
-(void)buttonclicke{
    selectCell = nil;
    [_mycollectionview reloadData];
}

-(void)allclear{    //把所有button恢復原狀
    
    [_headBtn setTransform:CGAffineTransformMakeScale(1, 1)];
    [_faceBtn setTransform:CGAffineTransformMakeScale(1, 1)];
    [_dressBtn setTransform:CGAffineTransformMakeScale(1, 1)];
    [_weaponBtn setTransform:CGAffineTransformMakeScale(1, 1)];
}


#pragma mark - get color
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
}//得到RGB顏色

-(NSString *)GetDBScorePath {
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask,YES);
    NSString *documentPath = [path firstObject];
    NSString *dbPath = [documentPath stringByAppendingPathComponent:@"Score.plist"];
    return dbPath;
    
}

@end
