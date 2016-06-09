//
//  OtherTableViewController.m
//  Calender_bycandy
//
//  Created by Man Man Yang on 2015/6/11.
//  Copyright (c) 2015年 candy. All rights reserved.
//

#import "OtherTableViewController.h"
#import <StoreKit/StoreKit.h>


@interface OtherTableViewController () <SKStoreProductViewControllerDelegate,UIScrollViewDelegate>

@property (strong, nonatomic) UIActivityIndicatorView *ClickedIndicator;
@property (strong, nonatomic) UIActivityIndicatorView *LoadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *myVersionShowLabel;
@property (strong, nonatomic) UIPageControl *pageControl;

@end

@implementation OtherTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.myVersionShowLabel.text = [NSString stringWithFormat:@"%@", version];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIView *originView = [[[[[[[[[self.tableView superview] superview] superview] superview] superview] superview] superview] superview] superview];
    float width = originView.frame.size.width;
    float height = originView.frame.size.height;
    //TODO: 有幾頁 塞圖到array;
    int page = 5;
    NSArray *scrollImageArray = [[NSArray alloc]initWithObjects:@"TeachSample1.png",@"TeachSample2.png",@"TeachSample3.png",@"TeachSample4.png",@"TeachSample5.png", nil];
    //
    if (indexPath.row == 0) {
        self.pageControl = [UIPageControl new];
        self.pageControl.frame = CGRectMake(0, 0, 100, 50);
        self.pageControl.center = CGPointMake(width/2, height-50);
        self.pageControl.currentPage = 0;
        self.pageControl.numberOfPages = 5;
        self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
        self.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];

        
        UIScrollView *scrollview = [UIScrollView new];
        scrollview.userInteractionEnabled = YES;
        scrollview.pagingEnabled = YES;
        scrollview.contentSize = CGSizeMake(width*(page+1), height);
        scrollview.frame = CGRectMake(0, 0, width, height);
        scrollview.delegate = self;
        scrollview.showsHorizontalScrollIndicator = NO;
        scrollview.showsVerticalScrollIndicator = NO;
        for (int i = 0; i<page; i++) {
            UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(width*i, 0, width, height)];
            image.image = [UIImage imageNamed:scrollImageArray[i]];
            [scrollview addSubview:image];
        }
        
        [originView addSubview:scrollview];
        [originView addSubview:self.pageControl];
    }
    
    
    switch (indexPath.row)
    {
        
        case 2:
            // TODO: Fix that if iphone have installed FB App, It can't go to the right page.
            //NSLog(@"點選 第 %ld 個 Cell", (long)indexPath.row);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/pages/SCC_Sweet-Candy-Calendar/578289098979530?ref=bookmarks"]];
            break;
            
        case 3:
        {
            // TODO: Fix Tag's bug.
            // TODO: Fix Indicator's constraints.
            
            //NSLog(@"點選 第 %ld 個 Cell", (long)indexPath.row);
            
            // 設定 ClickedIndicator 轉圈實體
            self.ClickedIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [self.ClickedIndicator startAnimating];
            self.ClickedIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
            [self.view addSubview:self.ClickedIndicator];
            
            // ClickedIndicator 開始轉圈
            [self.LoadingIndicator startAnimating];
            
            NSString *bAppleID = @"1009756655";
            
            //判斷當前SDK有無SKStoreProductViewController
            if ([SKStoreProductViewController class] != nil) {  //有的話即App內開啟App Store
                
                SKStoreProductViewController *skpvc = [[SKStoreProductViewController alloc] init];
                skpvc.delegate = self;
                NSDictionary *dict = [NSDictionary dictionaryWithObject:bAppleID forKey: SKStoreProductParameterITunesItemIdentifier];
                [skpvc loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {
                    
                    if (error)
                    {
//                        NSLog(@"error : %@, UserInfo : %@",error,[error userInfo]);
                    }
                    else
                    {
                        // ClickedIndicator 停止轉圈
                        [self.ClickedIndicator stopAnimating];
                        
                        //設定 LoadingIndicator 轉圈
                        self.LoadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                        self.LoadingIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
                        [skpvc.view addSubview:self.LoadingIndicator];
                        
                        // LoadingIndicator 開始轉圈
                        [self.LoadingIndicator startAnimating];
                        
                        //推出頁面顯示app位置
                        [self.navigationController presentViewController:skpvc animated:YES completion:^{
                            
                            //頁面顯示完成後，LoadingIndicator 停止轉圈
                            [self.LoadingIndicator stopAnimating];
                        }];
                    }
                }];
            }
            else    // 否則就在App外，用Safari開啟App Store
            {
                static NSString *const iOS7AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%@";
                static NSString *const iOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@";
                NSString *url = [[NSString alloc] initWithFormat: ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0f) ? iOS7AppStoreURLFormat : iOSAppStoreURLFormat, bAppleID];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
        }
            break;
            
        default:
            break;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //設定Setting項目row高度
    CGSize SettingRowSize = CGSizeMake(self.tableView.frame.size.width, (self.tableView.frame.size.height+2)/4);
    return SettingRowSize.height;
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated: YES completion: nil];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat width = scrollView.frame.size.width;
    NSInteger currentPage = ((scrollView.contentOffset.x - width / 2) / width) + 1;
    if (currentPage==5) {
        [scrollView setHidden:YES];
        [self.pageControl setHidden:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [scrollView removeFromSuperview];
            [self.pageControl removeFromSuperview];
        });
    }else{
        [self.pageControl setCurrentPage:currentPage];

    }
}



@end
