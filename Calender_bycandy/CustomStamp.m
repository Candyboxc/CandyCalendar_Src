//
//  CustomStamp.m
//  Calender_bycandy
//
//  Created by candy on 2015/6/7.
//  Copyright (c) 2015年 candy. All rights reserved.
//

#import "CustomStamp.h"
#import "myDB.h"
#import "JMWhenTapped.h"

@interface CustomStamp ()<UITextViewDelegate>{
    
    UIImageView *imageview; //最底層的view
    
    UIButton *stampimage1, *stampimage2, *stampimage3, *stampimage4,*stampimage5, *stampimage6;    //圖樣
    UIButton *stampimage_under1, *stampimage_under2, *stampimage_under3, *stampimage_under4, *stampimage_under5, *stampimage_under6; //圖樣框
    
    /*底,貼圖,框*/
    UIImageView *stampunderview,*stampimageview,*stamptopview;  //成品的imageview
    /*底,貼圖(一開始先給空的),框*/
    UIImage *stampunder,*stampimage,*stamptop;  //成品的底圖跟框
    
    UITextView *customTextView;
    UILabel *Text1,*Text2,*Text3,*Text4;    //成品的文字
    NSArray *TextArray; //建立放Text的Array
    
    UIButton *color1, *color2, *color3, *color4, *color5, *color6, *color7, *color8; //文字顏色button
    
    float width, height;
    
    NSMutableArray *imageDataArray,*loadImage;
    int page;
    int maxPage;
    
}

@end

@implementation CustomStamp

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    width = view.frame.size.width;
    height = view.frame.size.height;
    //NSLog(@"Height:%f, Width:%f",height,width);
    
    imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];   //最底的view
    UIImageView *underimageview = [[UIImageView alloc] initWithFrame:CGRectMake(width/42.4, height/2.05, width/1.07, height/2.56)];  //貼圖的view
    underimageview.center = CGPointMake(width/2, height/1.45);
    
    
    if (([[UIScreen mainScreen] bounds].size.width == 320 && [[UIScreen mainScreen] bounds].size.height == 480)||([[UIScreen mainScreen] bounds].size.width == 768 && [[UIScreen mainScreen] bounds].size.height == 1024) ) {
        stampunderview = [[UIImageView alloc] initWithFrame:CGRectMake(width/2.41, height/7.5, width/2.2, width/2.2)];//上方成品貼圖的最底層的view
        stampimageview = [[UIImageView alloc] initWithFrame:CGRectMake(width/2.34, height/7.15, width/2.3, width/2.3)];//上方成品貼圖的view
        stamptopview = [[UIImageView alloc] init];//上方成品貼圖的最上面的view
        stamptopview.frame = CGRectMake(0, 0, width/2.1, width/2.1);
        stamptopview.center = stampimageview.center;
        //至中
        stampunderview.center = stampimageview.center = stamptopview.center = CGPointMake(width/2, height/5.5);
    }else{
        stampunderview = [[UIImageView alloc] initWithFrame:CGRectMake(width/2.41, height/7.5, width/1.97, height/3.5)];//上方成品貼圖的最底層的view
        stampimageview = [[UIImageView alloc] initWithFrame:CGRectMake(width/2.34, height/7.15, width/2.1, height/3.68)];//上方成品貼圖的view
        stamptopview = [[UIImageView alloc] init];//上方成品貼圖的最上面的view
        stamptopview.frame = CGRectMake(0, 0, width/1.9, width/1.9);
        stamptopview.center = stampimageview.center;
        //至中
        stampunderview.center = stampimageview.center = stamptopview.center = CGPointMake(width/2, height/5.5);
    }
    
    
    UIImage *image = [UIImage imageNamed:[myDB sharedInstance].typeDic[@"background"]];; //成品的圖
    stampunder = [UIImage imageNamed:@"customstampview_under.png"];
    stamptop = [UIImage imageNamed:@"customstamp_stampfram.png"];
    
    UIButton *underbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, height,width)];    //設定最底的button
    [underbutton addTarget:self action:@selector(underclick) forControlEvents:UIControlEventTouchUpInside];
    UIImage *underimage = [UIImage imageNamed:[myDB sharedInstance].typeDic[@"stampunder"]];
    
    UIButton *customcancelbutton = [[UIButton alloc] initWithFrame:CGRectMake( width/13.8, height/1.12, width/5.2, height/14.72)];
    UIButton *customsavebutton = [[UIButton alloc]initWithFrame:CGRectMake( width/1.35, height/1.12, width/5.2, height/14.72)];
    customTextView = [[UITextView alloc] initWithFrame:CGRectMake( width/5.38 , height/2.47, width/4.5, height/24.5)];
    
    CGAffineTransform bigtextview = CGAffineTransformMakeScale(2, 2);   //讓TextView變大
    [customTextView setTransform:bigtextview];
    [customTextView setReturnKeyType:UIReturnKeyDone];
    customTextView.layer.borderWidth = 1.0;
    customTextView.layer.borderColor = [[UIColor blackColor] CGColor];
    UILabel *noticelabel = [[UILabel alloc] initWithFrame:CGRectMake(width/13.8, height/3.03, width/1.16, height/24.5)];
    
    //成品的文字
    float stampwidth = stampimageview.frame.size.width/2;
    
    Text1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, stampwidth, stampwidth)];
    CGPoint tmp1 = Text1.center;
    Text1.bounds = CGRectMake(0, 0, stampwidth*2, stampwidth);
    Text1.center=tmp1;
    Text2 = [[UILabel alloc] initWithFrame:CGRectMake(stampwidth, 0, stampwidth, stampwidth)];
    CGPoint tmp2 = Text2.center;
    Text2.bounds = CGRectMake(0, 0, stampwidth*2, stampwidth);
    Text2.center=tmp2;
    Text3 = [[UILabel alloc] initWithFrame:CGRectMake(0, stampwidth, stampwidth, stampwidth)];
    CGPoint tmp3 = Text3.center;
    Text3.bounds = CGRectMake(0, 0, stampwidth*2, stampwidth);
    Text3.center=tmp3;
    Text4 = [[UILabel alloc] initWithFrame:CGRectMake(stampwidth, stampwidth, stampwidth, stampwidth)];
    CGPoint tmp4 = Text4.center;
    Text4.bounds = CGRectMake(0, 0, stampwidth*2, stampwidth);
    Text4.center=tmp4;
    
    TextArray =[[NSArray alloc] initWithObjects:Text1,Text2,Text3,Text4,nil];
  
    CGRect mainScreen = [[UIScreen mainScreen] bounds];
    if (mainScreen.size.width == 375 && mainScreen.size.height > 600) {
//        NSLog(@"width%.f / height%.f",self.view.frame.size.width,self.view.frame.size.height);
        for (UILabel *L in TextArray) {
            [L setTextAlignment:NSTextAlignmentCenter];
            [L setFont:[UIFont fontWithName:@"DFPErW4-B5" size:105]];
            L.userInteractionEnabled = NO;
        }
//        NSLog(@"YES");
        
    }else if (mainScreen.size.width == 414 && mainScreen.size.height > 700) {
//        NSLog(@"width%.f / height%.f",self.view.frame.size.width,self.view.frame.size.height);
        for (UILabel *L in TextArray) {
            [L setTextAlignment:NSTextAlignmentCenter];
            [L setFont:[UIFont fontWithName:@"DFPErW4-B5" size:115]];
        }
    }else if (mainScreen.size.width == 320 && mainScreen.size.height > 500) {
//        NSLog(@"width%.f / height%.f",self.view.frame.size.width,self.view.frame.size.height);
        for (UILabel *L in TextArray) {
            [L setTextAlignment:NSTextAlignmentCenter];
            [L setFont:[UIFont fontWithName:@"DFPErW4-B5" size:93]];
        }
    }else if (mainScreen.size.width == 320 && mainScreen.size.height > 440) {
//        NSLog(@"width%.f / height%.f",self.view.frame.size.width,self.view.frame.size.height);
        for (UILabel *L in TextArray) {
            [L setTextAlignment:NSTextAlignmentCenter];
            [L setFont:[UIFont fontWithName:@"DFPErW4-B5" size:85]];
        }
    }else {
//        NSLog(@"width%.f / height%.f",self.view.frame.size.width,self.view.frame.size.height);
        for (UILabel *L in TextArray) {
            [L setTextAlignment:NSTextAlignmentCenter];
            [L setFont:[UIFont fontWithName:@"DFPErW4-B5" size:185]];
            L.userInteractionEnabled = NO;
        }
    }
    
    //文字顏色button
    color1 = [[UIButton alloc] initWithFrame:CGRectMake(width/1.68, height/2.65, width/16.56, height/29.44)];
    color2 = [[UIButton alloc] initWithFrame:CGRectMake(width/1.45, height/2.65, width/16.56, height/29.44)];
    color3 = [[UIButton alloc] initWithFrame:CGRectMake(width/1.27, height/2.65, width/16.56, height/29.44)];
    color4 = [[UIButton alloc] initWithFrame:CGRectMake(width/1.13, height/2.65, width/16.56, height/29.44)];
    color5 = [[UIButton alloc] initWithFrame:CGRectMake(width/1.68, height/2.3, width/16.56, height/29.44)];
    color6 = [[UIButton alloc] initWithFrame:CGRectMake(width/1.45, height/2.3, width/16.56, height/29.44)];
    color7 = [[UIButton alloc] initWithFrame:CGRectMake(width/1.27, height/2.3, width/16.56, height/29.44)];
    color8 = [[UIButton alloc] initWithFrame:CGRectMake(width/1.13, height/2.3, width/16.56, height/29.44)];
    
    [color5 setBounds:CGRectMake(0, 0, 40, 40)];    //設定預設文字顏色放大
    
    [color1 setBackgroundColor:[UIColor colorWithCGColor:[self getColorFromRed:63 Green:152 Blue:255 Alpha:100]]];
    [color2 setBackgroundColor:[UIColor colorWithCGColor:[self getColorFromRed:252 Green:66 Blue:65 Alpha:100]]];
    [color3 setBackgroundColor:[UIColor colorWithCGColor:[self getColorFromRed:112 Green:66 Blue:14 Alpha:100]]];
    [color4 setBackgroundColor:[UIColor colorWithCGColor:[self getColorFromRed:124 Green:68 Blue:232 Alpha:100]]];
    [color5 setBackgroundColor:[UIColor blackColor]];
    [color6 setBackgroundColor:[UIColor colorWithCGColor:[self getColorFromRed:0 Green:56 Blue:255 Alpha:100]]];
    [color7 setBackgroundColor:[UIColor colorWithCGColor:[self getColorFromRed:242 Green:82 Blue:103 Alpha:100]]];
    [color8 setBackgroundColor:[UIColor colorWithCGColor:[self getColorFromRed:0 Green:232 Blue:108 Alpha:100]]];
    
    [color1 addTarget:self action:@selector(colorbutton:) forControlEvents:UIControlEventTouchUpInside];
    [color2 addTarget:self action:@selector(colorbutton:) forControlEvents:UIControlEventTouchUpInside];
    [color3 addTarget:self action:@selector(colorbutton:) forControlEvents:UIControlEventTouchUpInside];
    [color4 addTarget:self action:@selector(colorbutton:) forControlEvents:UIControlEventTouchUpInside];
    [color5 addTarget:self action:@selector(colorbutton:) forControlEvents:UIControlEventTouchUpInside];
    [color6 addTarget:self action:@selector(colorbutton:) forControlEvents:UIControlEventTouchUpInside];
    [color7 addTarget:self action:@selector(colorbutton:) forControlEvents:UIControlEventTouchUpInside];
    [color8 addTarget:self action:@selector(colorbutton:) forControlEvents:UIControlEventTouchUpInside];
    
    //預設文字顏色
    for (UILabel *L in TextArray) {
        [L setTextColor:[UIColor blackColor]];
    }
    
    //取消    UIControlEventTouchUpInside表示為點擊時會做什麼事情
    [customcancelbutton setImage:[UIImage imageNamed:@"popover_cancel.png"] forState:UIControlStateNormal];
    [customcancelbutton addTarget:self action:@selector(backbutton) forControlEvents:UIControlEventTouchUpInside];
    
    //儲存
    [customsavebutton setImage:[UIImage imageNamed:@"popover_save.png"] forState:UIControlStateNormal];
    [customsavebutton addTarget:self action:@selector(savebutton) forControlEvents:UIControlEventTouchUpInside];
    
    //文字
    if ([[UIScreen mainScreen]bounds].size.height == 480) {
        [customTextView setFont:[UIFont fontWithName:@"DFPErW4-B5" size:10]];
    }else{
        [customTextView setFont:[UIFont fontWithName:@"DFPErW4-B5" size:15]];
    }
    
    [customTextView setScrollEnabled:NO];
    customTextView.text = @"";
    customTextView.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];
    
    //Label
    [noticelabel setFont:[UIFont fontWithName:@"DFPErW4-B5" size:18]];
    noticelabel.text = @"請輸入自訂文字(請勿超過四個字)";
    UIScrollView *stampBackScrollView = [UIScrollView new];
    stampBackScrollView.frame = CGRectMake(200, 300, underimageview.frame.size.width*0.75, underimageview.frame.size.height*0.65);
    stampBackScrollView.center = underimageview.center;
    float cellWidth = stampBackScrollView.frame.size.width/3;
    float cellHeight = stampBackScrollView.frame.size.height/2;
//    NSLog(@"%.f",cellWidth);
    stampBackScrollView.contentSize = CGSizeMake(cellWidth*3, cellHeight*2);
    stampBackScrollView.userInteractionEnabled = YES;
    
    
    
    imageDataArray = [NSMutableArray new];
    for (int i = 1 ; i<= 12; i++) {
        [imageDataArray addObject:[NSString stringWithFormat:@"customstamp_stamp%i.png",i]];
    }//總共幾張
    
    
    //Create背景圖樣
    stampimage1 = [[UIButton alloc] initWithFrame:CGRectMake(0 , 0, cellWidth*0.7, cellWidth*0.7)];
    stampimage_under1 = [[UIButton alloc] initWithFrame:CGRectMake(0 , 0, cellWidth*0.8, cellWidth*0.8)];
    stampimage1.center = CGPointMake(cellWidth/2, cellHeight/2);
    stampimage_under1.center = stampimage1.center;
    
    stampimage2 = [[UIButton alloc] initWithFrame:CGRectMake(0 , 0, cellWidth*0.7, cellWidth*0.7)];
    stampimage_under2 = [[UIButton alloc] initWithFrame:CGRectMake(0 , 0, cellWidth*0.8, cellWidth*0.8)];
    stampimage2.center = CGPointMake(cellWidth/2+cellWidth, cellHeight/2);
    stampimage_under2.center = stampimage2.center;
    
    stampimage3 = [[UIButton alloc] initWithFrame:CGRectMake(0 , 0, cellWidth*0.7, cellWidth*0.7)];
    stampimage_under3 = [[UIButton alloc] initWithFrame:CGRectMake(0 , 0, cellWidth*0.8, cellWidth*0.8)];
    stampimage3.center = CGPointMake(cellWidth/2+cellWidth*2, cellHeight/2);
    stampimage_under3.center = stampimage3.center;
    
    stampimage4 = [[UIButton alloc] initWithFrame:CGRectMake(0 , 0, cellWidth*0.7, cellWidth*0.7)];
    stampimage_under4 = [[UIButton alloc] initWithFrame:CGRectMake(0 , 0, cellWidth*0.8, cellWidth*0.8)];
    stampimage4.center = CGPointMake(cellWidth/2, cellHeight/2+cellHeight);
    stampimage_under4.center = stampimage4.center;
    
    stampimage5 = [[UIButton alloc] initWithFrame:CGRectMake(0 , 0, cellWidth*0.7, cellWidth*0.7)];
    stampimage_under5 = [[UIButton alloc] initWithFrame:CGRectMake(0 , 0, cellWidth*0.8, cellWidth*0.8)];
    stampimage5.center = CGPointMake(cellWidth/2+cellWidth, cellHeight/2+cellHeight);
    stampimage_under5.center = stampimage5.center;
    
    stampimage6 = [[UIButton alloc] initWithFrame:CGRectMake(0 , 0, cellWidth*0.7, cellWidth*0.7)];
    stampimage_under6 = [[UIButton alloc] initWithFrame:CGRectMake(0 , 0, cellWidth*0.8, cellWidth*0.8)];
    stampimage6.center = CGPointMake(cellWidth/2+cellWidth*2, cellHeight/2+cellHeight);
    stampimage_under6.center = stampimage6.center;
    
    page=0;
    maxPage = imageDataArray.count/6;
    if (imageDataArray.count%6>0) {
        maxPage++;
    }
    [self changeLoadImage];
    UIButton *leftButton = [UIButton new];
    leftButton.frame = CGRectMake(0, 0, underimageview.frame.size.width*0.125 , underimageview.frame.size.height*0.8);
    leftButton.center = CGPointMake(stampBackScrollView.frame.origin.x-underimageview.frame.size.width*0.035, underimageview.center.y);
    [leftButton setImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
    UIButton *rightButton = [UIButton new];
    rightButton.frame = CGRectMake(0, 0, underimageview.frame.size.width*0.125 , underimageview.frame.size.height*0.8);
    rightButton.center = CGPointMake(stampBackScrollView.frame.origin.x + stampBackScrollView.frame.size.width + underimageview.frame.size.width*0.035, underimageview.center.y);
    [rightButton setImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];

    [leftButton whenTapped:^{
        //
        page--;
        if (page<0) {
            page = maxPage-1;
        }else if(page>=maxPage){
            page = 0;
        }
        [self changeLoadImage];
    }];
    [rightButton whenTapped:^{
        //
        page--;
        if (page<0) {
            page = maxPage-1;
        }else if(page>=maxPage){
            page = 0;
        }
        [self changeLoadImage];
    }];

    
    
    
    [stampimage1 addTarget:self action:@selector(buttonclick:) forControlEvents:UIControlEventTouchUpInside];
    [stampimage2 addTarget:self action:@selector(buttonclick:) forControlEvents:UIControlEventTouchUpInside];
    [stampimage3 addTarget:self action:@selector(buttonclick:) forControlEvents:UIControlEventTouchUpInside];
    [stampimage4 addTarget:self action:@selector(buttonclick:) forControlEvents:UIControlEventTouchUpInside];
    [stampimage5 addTarget:self action:@selector(buttonclick:) forControlEvents:UIControlEventTouchUpInside];
    [stampimage6 addTarget:self action:@selector(buttonclick:) forControlEvents:UIControlEventTouchUpInside];

    
    
    view.tag = imageview.tag = underimageview.tag = stampimageview.tag = stamptopview.tag = stampunderview.tag = 1;
    customcancelbutton.tag = customsavebutton.tag = underbutton.tag = 1;
    customTextView.tag = 1;
    noticelabel.tag = 1;
    Text1.tag = Text2.tag = Text3.tag = Text4.tag =  1;
    stampimage1.tag = stampimage_under1.tag = color1.tag = 11;
    stampimage2.tag = stampimage_under2.tag = color2.tag = 12;
    stampimage3.tag = stampimage_under3.tag = color3.tag = 13;
    stampimage4.tag = stampimage_under4.tag = color4.tag = 14;
    stampimage5.tag = stampimage_under5.tag = color5.tag = 15;
    stampimage6.tag = stampimage_under6.tag = color6.tag = 16;
    color7.tag = 17;
    color8.tag = 18;
    
    imageview.image = image;
    imageview.userInteractionEnabled = YES;   //讓button可以點擊
    underimageview.image = underimage;
    underimageview.userInteractionEnabled = YES;
    [underimageview whenTapped:^{
        //
        [customTextView resignFirstResponder];
    }];
    stampunderview.image = stampunder;
    stampimageview.image = stampimage;
    stamptopview.image = stamptop;
    
    [self.view addSubview:view];
    [self.view addSubview:imageview];
    
    
    [imageview addSubview:underbutton];
    [imageview addSubview:underimageview];
    [imageview addSubview:customcancelbutton];
    [imageview addSubview:customsavebutton];
    [imageview addSubview:customTextView];
    [imageview addSubview:noticelabel];
    [imageview addSubview:color1];
    [imageview addSubview:color2];
    [imageview addSubview:color3];
    [imageview addSubview:color4];
    [imageview addSubview:color5];
    [imageview addSubview:color6];
    [imageview addSubview:color7];
    [imageview addSubview:color8];
    
    [imageview addSubview:stampunderview];
    [imageview addSubview:stamptopview];
    [imageview addSubview:stampimageview];
    [stampimageview addSubview:Text1];
    [stampimageview addSubview:Text2];
    [stampimageview addSubview:Text3];
    [stampimageview addSubview:Text4];
    [self.view addSubview:leftButton];
    [self.view addSubview:rightButton];
    
    [stampBackScrollView addSubview:stampimage_under1];
    [stampBackScrollView addSubview:stampimage_under2];
    [stampBackScrollView addSubview:stampimage_under3];
    [stampBackScrollView addSubview:stampimage_under4];
    [stampBackScrollView addSubview:stampimage_under5];
    [stampBackScrollView addSubview:stampimage_under6];
    [stampBackScrollView addSubview:stampimage1];
    [stampBackScrollView addSubview:stampimage2];
    [stampBackScrollView addSubview:stampimage3];
    [stampBackScrollView addSubview:stampimage4];
    [stampBackScrollView addSubview:stampimage5];
    [stampBackScrollView addSubview:stampimage6];
    [self.view addSubview:stampBackScrollView];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//取消按鈕
-(void) backbutton {
    
    [self back];
}

//儲存按鈕
-(void) savebutton {
    
    //做判斷是否為空
    if (![customTextView.text isEqualToString:@""]) {
        
        UIGraphicsBeginImageContext(CGSizeMake(stampimageview.frame.size.width, stampimageview.frame.size.height));
        CGContextRef context = UIGraphicsGetCurrentContext();
        [stampimageview.layer renderInContext:context];
        UIImage *Screenofstamp = UIGraphicsGetImageFromCurrentImageContext();
        Screenofstamp = [CustomStamp imageWithImage:Screenofstamp scaledToSize:CGSizeMake(70, 70)]; //做70*70的圖
        UIGraphicsGetImageFromCurrentImageContext();
        
        
        //存檔名至plist
        NSString *dbPath = [self GetDBPath];
//        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //存至Document下
        NSString *stampdir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *stamptargetdir = [stampdir stringByAppendingPathComponent:@"customstamp"];   //資料夾
        NSFileManager *stampfilemanager = [NSFileManager defaultManager];
        
        //判斷若不存在的話,則創建一個
        if (![stampfilemanager fileExistsAtPath:stamptargetdir]) {
            [stampfilemanager createDirectoryAtPath:stamptargetdir
                        withIntermediateDirectories:YES
                                         attributes:nil
                                              error:nil];
        }
        
        if ([myDB sharedInstance].customStampArray.count== 0) {
            //如果第一次使用自訂貼圖會給他6000.png
            [[myDB sharedInstance].customStampArray addObject:@"6000.png"];
            [[myDB sharedInstance].customStampArray writeToFile:dbPath atomically:YES];
            
            //存png
            NSData *imageData = UIImagePNGRepresentation(Screenofstamp);
            NSString *imageName = [NSString stringWithFormat:@"6000.png"];
            [imageData writeToFile:[stamptargetdir stringByAppendingPathComponent:imageName] atomically:YES];
            
        }else{
            //讀取plist資料
            //取出原本的plist資料
            NSString *lastName = [myDB sharedInstance].customStampArray[0];
//            NSLog(@"%@", lastName);
            int NewName = [[lastName substringToIndex:4] intValue];
            NewName = NewName + 1;
            
            //插入新的圖片檔名
            NSString *imageName = [NSString stringWithFormat:@"%i.png",NewName];
            [[myDB sharedInstance].customStampArray insertObject:imageName atIndex:0];
            [[myDB sharedInstance].customStampArray writeToFile:dbPath atomically:YES];
            
            //存png
            NSData *imageData = UIImagePNGRepresentation(Screenofstamp);
            [imageData writeToFile:[stamptargetdir stringByAppendingPathComponent:imageName] atomically:YES];
        }
        
        [self back];
        
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"請輸入文字!"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"我知道了"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

//讀取plist路徑
-(NSString *)GetDBPath {
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask,YES);
    NSString *documentPath = [path firstObject];
    NSString *dbPath = [documentPath stringByAppendingPathComponent:@"customstamp.plist"];
    return dbPath;
    
}

-(void)back{
    [self dismissViewControllerAnimated:NO
                             completion:nil];
    
}

//文字顏色判斷
-(void)colorbutton:(UIButton *)color{
    
    NSArray *colorArr = @[color1,color2,color3,color4,color5,color6,color7,color8];
    
    //預設每個colorbutton都一樣
    for (UIButton *B in colorArr) {
        [B setBounds:CGRectMake(0, 0, width/16.56, height/29.44)];
    }
    
    switch (color.tag) {
        case 11:
            for (UILabel *L in TextArray) {
                [L setTextColor:[UIColor colorWithCGColor:[self getColorFromRed:63 Green:152 Blue:255 Alpha:100]]];
            }
            
            [color1 setBounds:CGRectMake(0, 0, width/10.35, height/18.4)];
            break;
            
        case 12:
            for (UILabel *L in TextArray) {
                [L setTextColor:[UIColor colorWithCGColor:[self getColorFromRed:252 Green:66 Blue:65 Alpha:100]]];
            }
            
            [color2 setBounds:CGRectMake(0, 0, width/10.35, height/18.4)];
            break;
            
        case 13:
            for (UILabel *L in TextArray) {
                [L setTextColor:[UIColor colorWithCGColor:[self getColorFromRed:112 Green:66 Blue:14 Alpha:100]]];
            }
            [color3 setBounds:CGRectMake(0, 0, width/10.35, height/18.4)];
            break;
            
        case 14:
            for (UILabel *L in TextArray) {
                [L setTextColor:[UIColor colorWithCGColor:[self getColorFromRed:124 Green:68 Blue:232 Alpha:100]]];
            }
            [color4 setBounds:CGRectMake(0, 0, width/10.35, height/18.4)];
            break;
            
        case 15:
            for (UILabel *L in TextArray) {
                [L setTextColor:[UIColor blackColor]];
            }
            [color5 setBounds:CGRectMake(0, 0, width/10.35, height/18.4)];
            break;
            
        case 16:
            for (UILabel *L in TextArray) {
                [L setTextColor:[UIColor colorWithCGColor:[self getColorFromRed:0 Green:56 Blue:255 Alpha:100]]];
            }
            [color6 setBounds:CGRectMake(0, 0, width/10.35, height/18.4)];
            break;
            
        case 17:
            for (UILabel *L in TextArray) {
                [L setTextColor:[UIColor colorWithCGColor:[self getColorFromRed:242 Green:82 Blue:103 Alpha:100]]];
            }
            [color7 setBounds:CGRectMake(0, 0, width/10.35, height/18.4)];
            break;
            
        case 18:
            for (UILabel *L in TextArray) {
                [L setTextColor:[UIColor colorWithCGColor:[self getColorFromRed:0 Green:232 Blue:108 Alpha:100]]];
            }
            [color8 setBounds:CGRectMake(0, 0, width/10.35, height/18.4)];
            break;
            
        default:
            break;
    }
}

//做字數判斷
-(void)textDidChange:(id)sender{
    
    NSString *temp = customTextView.text;
    NSString *String1,*String2,*String3,*String4;
    
    switch (temp.length) {
        case 1:
            temp = [NSString stringWithFormat:@"%@   ",temp];
            break;
        case 2:
            temp = [NSString stringWithFormat:@"%@  ",temp];
            break;
        case 3:
            temp = [NSString stringWithFormat:@"%@ ",temp];
            break;
        case 4:
            temp = temp;
            break;
            
        default:
            if (temp.length <= 0) {
                temp = @"    ";
            }else{
                temp = temp;
            }
            break;
    }
    
    String1 = [temp substringWithRange:NSMakeRange(0, 1)];
    String2 = [temp substringWithRange:NSMakeRange(1, 1)];
    String3 = [temp substringWithRange:NSMakeRange(2, 1)];
    String4 = [temp substringWithRange:NSMakeRange(3, 1)];
    
    if (customTextView.text.length == 2) {
        [Text1 setText:String1];
        [Text2 setText:@""];
        [Text3 setText:@""];
        [Text4 setText:String2];
    }else{
        [Text1 setText:String1];
        [Text2 setText:String2];
        [Text3 setText:String3];
        [Text4 setText:String4];
        
    }
}

//收鍵盤
-(void)underclick{
    [customTextView resignFirstResponder];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString: @"\n"]) {
        [textView resignFirstResponder];
    }
    if (range.location >= 6) {
//        NSLog(@"no");
        return NO;
    }else{
        return YES;
    }
}

//點擊圖樣之後要做什麼事情
-(void)buttonclick:(UIButton *)button{
    
    CGAffineTransform originframe = CGAffineTransformMakeScale(1, 1);
    CGAffineTransform bigframe = CGAffineTransformMakeScale(1.2, 1.2);
    
    NSArray *stampimageArr = @[stampimage1,stampimage2,stampimage3,stampimage4,stampimage5,stampimage6];
    NSArray *stampunderArr = @[stampimage_under1,stampimage_under2,stampimage_under3,stampimage_under4,stampimage_under5,stampimage_under6];
    
    for (UIButton *B in stampimageArr) {
        [B setTransform:originframe];
    }
    
    for (UIButton *B in stampunderArr) {
        [B setTransform:originframe];
    }
    [stampimageview setImage:button.currentImage];
    switch (button.tag) {
        case 11:
            [stampimage1 setTransform:bigframe];
            [stampimage_under1 setTransform:bigframe];
            break;
            
        case 12:
            [stampimage2 setTransform:bigframe];
            [stampimage_under2 setTransform:bigframe];
            break;
            
        case 13:
            [stampimage3 setTransform:bigframe];
            [stampimage_under3 setTransform:bigframe];
            break;
            
        case 14:
            [stampimage4 setTransform:bigframe];
            [stampimage_under4 setTransform:bigframe];
            break;
            
        case 15:
            [stampimage5 setTransform:bigframe];
            [stampimage_under5 setTransform:bigframe];
            break;
            
        case 16:
            [stampimage6 setTransform:bigframe];
            [stampimage_under6 setTransform:bigframe];
            break;

            
        default:
            break;
    }
}


//縮圖
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//取得RGB顏色
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

-(void)changeLoadImage{
    loadImage = [NSMutableArray new];
    for (int i = 6*page; i< 6*(page+1); i++) {
        if (imageDataArray[i] != nil) {
            [loadImage addObject:imageDataArray[i]];
        }
        
    }
    NSArray *imageunderArr = @[stampimage_under1,stampimage_under2,stampimage_under3,stampimage_under4,stampimage_under5,stampimage_under6];
    NSArray *imageArr = @[stampimage1,stampimage2,stampimage3,stampimage4,stampimage5,stampimage6];
    
    for (int i =0 ; i<imageArr.count; i++) {
        if (loadImage[i] != nil) {
            [imageArr[i] setImage:[UIImage imageNamed:loadImage[i]] forState:UIControlStateNormal];
            [imageunderArr[i] setImage:[UIImage imageNamed:@"customstamp_stampfram.png"] forState:UIControlStateNormal];
        }else{
            [imageunderArr[i] setImage:nil forState:UIControlStateNormal];
        }
    }
}

@end
