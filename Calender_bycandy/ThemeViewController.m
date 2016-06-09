//
//  ThemeViewController.m
//  Calender_bycandy
//
//  Created by Dong on 2015/6/17.
//  Copyright (c) 2015年 candy. All rights reserved.
//

#import "ThemeViewController.h"
#import "myDB.h"
@interface ThemeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *basicBtn;
@property (weak, nonatomic) IBOutlet UIButton *lovelyBtn;
@property (weak, nonatomic) IBOutlet UIButton *wonderfulBtn;
@property (weak, nonatomic) IBOutlet UIButton *mouseBtn;

@end

@implementation ThemeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.backgroundView.image = [UIImage imageNamed:[myDB sharedInstance].typeDic[@"background"]];
    
    [self checkTheTheme];
    UIBarButtonItem *bacnBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(back:)];
    bacnBtn.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = bacnBtn;
    
}

-(void)back:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)basicBtn:(id)sender {
    [[myDB sharedInstance]changeThemeType:@"basicType"];
    self.backgroundView.image = [UIImage imageNamed:[myDB sharedInstance].typeDic[@"background"]];
    [[myDB sharedInstance].settingDict setObject:@"basicType" forKey:@"themeType"];
    [self valueChange];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"CHANGETHEME" object:nil];
    
    [self checkTheTheme];
}
- (IBAction)lovelyBtn:(id)sender {
    [[myDB sharedInstance]changeThemeType:@"LOVELY"];
    self.backgroundView.image = [UIImage imageNamed:[myDB sharedInstance].typeDic[@"background"]];
    [[myDB sharedInstance].settingDict setObject:@"LOVELY" forKey:@"themeType"];
    [self valueChange];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"CHANGETHEME" object:nil];
    
    [self checkTheTheme];
}
- (IBAction)wonderfulBtn:(id)sender {
    [[myDB sharedInstance]changeThemeType:@"WONDERFUL"];
    self.backgroundView.image = [UIImage imageNamed:[myDB sharedInstance].typeDic[@"background"]];
    [[myDB sharedInstance].settingDict setObject:@"WONDERFUL" forKey:@"themeType"];
    [self valueChange];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"CHANGETHEME" object:nil];
    
    [self checkTheTheme];
}
- (IBAction)mouseBtn:(id)sender {
    
    [[myDB sharedInstance]changeThemeType:@"Mouse"];
    self.backgroundView.image = [UIImage imageNamed:[myDB sharedInstance].typeDic[@"background"]];
    [[myDB sharedInstance].settingDict setObject:@"Mouse" forKey:@"themeType"];
    [self valueChange];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"CHANGETHEME" object:nil];
    
    [self checkTheTheme];
}

- (void)checkTheTheme {
    if ([self.backgroundView.image isEqual:[UIImage imageNamed:@"customstamp_under.png"]])
    {
        [self.basicBtn setTitle:@"✓" forState:UIControlStateNormal];
        [self.lovelyBtn setTitle:@"" forState:UIControlStateNormal];
        [self.wonderfulBtn setTitle:@"" forState:UIControlStateNormal];
        [self.mouseBtn setTitle:@"" forState:UIControlStateNormal];
    }
    else if ([self.backgroundView.image isEqual:[UIImage imageNamed:@"LOVELY_background.png"]])
    {
        [self.basicBtn setTitle:@"" forState:UIControlStateNormal];
        [self.lovelyBtn setTitle:@"✓" forState:UIControlStateNormal];
        [self.wonderfulBtn setTitle:@"" forState:UIControlStateNormal];
        [self.mouseBtn setTitle:@"" forState:UIControlStateNormal];
    }
    else if ([self.backgroundView.image isEqual:[UIImage imageNamed:@"WONDERFUL_background.png"]])
    {
        [self.basicBtn setTitle:@"" forState:UIControlStateNormal];
        [self.lovelyBtn setTitle:@"" forState:UIControlStateNormal];
        [self.wonderfulBtn setTitle:@"✓" forState:UIControlStateNormal];
        [self.mouseBtn setTitle:@"" forState:UIControlStateNormal];
    }
    else if ([self.backgroundView.image isEqual:[UIImage imageNamed:@"Mouse_background.png"]])
    {
        [self.basicBtn setTitle:@"" forState:UIControlStateNormal];
        [self.lovelyBtn setTitle:@"" forState:UIControlStateNormal];
        [self.wonderfulBtn setTitle:@"" forState:UIControlStateNormal];
        [self.mouseBtn setTitle:@"✓" forState:UIControlStateNormal];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)valueChange{//存檔
    NSString *dbPath = [self GetDBPath];
    [[myDB sharedInstance].settingDict writeToFile:dbPath atomically:YES];
}

-(NSString *)GetDBPath{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask, YES);
    NSString *documentPath = [paths firstObject];
    NSString *dbPath = [documentPath stringByAppendingPathComponent:@"setting.plist"];
//    NSLog(@"dbPath=%@",dbPath);
    return dbPath;
}
@end
