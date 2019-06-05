//
//  TDPlayerViewController.m
//  TDPlayerDemo
//
//  Created by TangYanQiong on 15/3/26.
//  Copyright (c) 2015年 TangYanQiong. All rights reserved.
//

#import "TDPlayerViewController.h"
#import "TDPlayerView.h"

@interface TDPlayerViewController () <TDPlayerViewDelegate>
{
    TDPlayerView *tdPlayerView;
}
@end

@implementation TDPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat selfWidth = self.view.frame.size.width;
    CGFloat selfHeight = self.view.frame.size.height;
    if (self.view.frame.size.width < self.view.frame.size.height)
    {
        selfWidth = self.view.frame.size.height;
        selfHeight = self.view.frame.size.width;
    }
    
    tdPlayerView = [[TDPlayerView alloc] initWithFrame:CGRectMake(0, 0, selfWidth, selfHeight)];
    tdPlayerView.delegate = self;
    [self.view addSubview:tdPlayerView];
    
    [tdPlayerView startLoadingWithTitleStr:@"测试视频"];
    
    self.playUrl = @"http://182.138.101.48:5001/nn_vod/nn_x64/aWQ9NWZlOTljZWYwY2Q0Mzk3ZGRlNjI1MDExMTE0OGFlNjMmdXJsX2MxPTZkNmY2OTc2NjU3MzJmMzA2MjYzMzQzODMzNjUzMDY1MzIzMTYzNjYzMTMzMzAzMzYyMzUzNzM3MzkzMjY1NjE2MTM0Mzg2NjY2NjQzMzJlNzQ3MzIwMDAmbm5fYWs9MDFkZTU0YTczNjYxOWZiODdlMzU1NjgxZjEzZGNhYzc4ZCZudHRsPTMmbnBpcHM9MTgyLjEzOC4xMDEuNDg6NTEwMSZuY21zaWQ9MTAwMDAxJm5ncz01NTFlMDQxYTAwMGI5NWYxNWVjZjc1NTg2MDYyMTZiOCZubl91c2VyX2lkPVlZSEQwMDAwMDc3OSZuZHY9MS4wLjAuMC4yLlNDLUpHUy1JUEhPTkUuMC4wX1JlbGVhc2UmbmVhPSZuZXM9/5fe99cef0cd4397dde6250111148ae63.ts";
    //    self.playUrl = @"http://219.232.84.70:30003/ts1500";//广播流
    
    if ([self.playUrl rangeOfString:@".ts"].location != NSNotFound)
        self.playUrl = [self.playUrl stringByReplacingOccurrencesOfString:@".ts" withString:@".m3u8"];
    [tdPlayerView playVideoByUrl:self.playUrl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TDPlayerViewDelegate -

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)requestToReload
{
    [tdPlayerView startLoadingWithTitleStr:@"测试视频"];
    
    if ([self.playUrl rangeOfString:@".ts"].location != NSNotFound)
        self.playUrl = [self.playUrl stringByReplacingOccurrencesOfString:@".ts" withString:@".m3u8"];
    [tdPlayerView playVideoByUrl:self.playUrl];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
