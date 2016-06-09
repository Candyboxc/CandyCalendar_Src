//
//  DownloadTableViewController.m
//  Calender_bycandy
//
//  Created by Man Man Yang on 2015/6/11.
//  Copyright (c) 2015年 candy. All rights reserved.
//

#import "DownloadTableViewController.h"

@interface DownloadTableViewController ()

@end

@implementation DownloadTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    float width = [[[[[self.tableView superview] superview] superview] superview] superview].frame.size.width;
    float height = [[[[[self.tableView superview] superview] superview] superview] superview].frame.size.height;
    UIView *originView = [[[[[[[[[self.tableView superview] superview] superview] superview] superview] superview] superview] superview] superview];
    //得到畫面大小
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0.3;
    backgroundView.userInteractionEnabled = YES;
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    indicator.center = CGPointMake(width/2, height/2-25);
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [indicator startAnimating];
    [originView addSubview:backgroundView];
    [originView addSubview:indicator];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row==0) {
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [backgroundView removeFromSuperview];
            [indicator removeFromSuperview];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"目前沒有可下載的貼圖喔" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                //
                
                [alert dismissViewControllerAnimated:YES completion:nil];
                
            }];
            
            
            [alert addAction:ok];
            
            [self presentViewController:alert animated:YES completion:nil];
        });

        
        
    }else if (indexPath.row==1){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [backgroundView removeFromSuperview];
            [indicator removeFromSuperview];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"目前沒有可下載的主題喔" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                //
                
                [alert dismissViewControllerAnimated:YES completion:nil];
                
            }];
            
            
            [alert addAction:ok];
            
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //設定Setting項目row高度
    CGSize SettingRowSize = CGSizeMake(self.tableView.frame.size.width, (self.tableView.frame.size.height+2)/2);
    return SettingRowSize.height;
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
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

@end
