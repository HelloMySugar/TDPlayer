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
    
    self.playUrl = @"http://172.18.22.8:5000/nn_live/nn_x64/aWQ9aG53cyZ1cmxfYzE9MjAwMCZudHRsPTQmbnBpcHM9MTcyLjE4LjIyLjg6NTEwMCZuY21zaWQ9MTAwMDAzJm5ncz01NWRmYzRlZjAwMGM2YzFhNzY3NzA2MDBiMzdiOTg2YSZubl9jcD1zdXBlcm5ldCZubl91c2VyX2lkPUlQSE9ORUQ5NzZBMkZGQkIwNzQ0MEE4OUIwOERGMzgzJm5uX2RheT0yMDE1MDgyOCZubl9iZWdpbj0wMzQwMDAmbm5fdGltZV9sZW49MzU0MCZuZHY9MS4wLjAuMC4yLlNDLVZEUy1JUEhPTkUuMC4wX1JlbGVhc2U,/hnws.ts";
//    self.playUrl = @"http://219.232.84.70:30001/nn_live.ts?id=radio_gxxwzh";
//    self.playUrl = @"http://219.232.84.70:30003/ts1500";//广播流
//    self.playUrl = @"http://125.64.99.42:6000/nl.m3u8?id=livehntv";//test url
//    self.playUrl = @"http://cache.m.iqiyi.com/dc/dt/mobile/20150330/51/af/f84dae7e4eedee5210f48ee0cbd860c9.m3u8?qypid=357774800_33&qd_src=5be6a2fdfe4f4a1a8c7b08ee46a18887&qd_tm=1428566179000&qd_ip=182.138.101.47&qd_sc=63eda4fc0b97d90644c5921017966966";
//    self.playUrl = @"http://182.138.101.48:5001/nn_vod/nn_x64/aWQ9NWZlOTljZWYwY2Q0Mzk3ZGRlNjI1MDExMTE0OGFlNjMmdXJsX2MxPTZkNmY2OTc2NjU3MzJmMzA2MjYzMzQzODMzNjUzMDY1MzIzMTYzNjYzMTMzMzAzMzYyMzUzNzM3MzkzMjY1NjE2MTM0Mzg2NjY2NjQzMzJlNzQ3MzIwMDAmbm5fYWs9MDFkZTU0YTczNjYxOWZiODdlMzU1NjgxZjEzZGNhYzc4ZCZudHRsPTMmbnBpcHM9MTgyLjEzOC4xMDEuNDg6NTEwMSZuY21zaWQ9MTAwMDAxJm5ncz01NTFlMDQxYTAwMGI5NWYxNWVjZjc1NTg2MDYyMTZiOCZubl91c2VyX2lkPVlZSEQwMDAwMDc3OSZuZHY9MS4wLjAuMC4yLlNDLUpHUy1JUEhPTkUuMC4wX1JlbGVhc2UmbmVhPSZuZXM9/5fe99cef0cd4397dde6250111148ae63.ts";
    
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
