//
//  TDPlayerLoadingView.m
//  TDPlayerDemo
//
//  Created by TangYanQiong on 15/4/7.
//  Copyright (c) 2015年 TangYanQiong. All rights reserved.
//

#import "TDPlayerLoadingView.h"

@interface TDPlayerLoadingView()
{
    UIActivityIndicatorView *activityIndicatorView;
    UILabel *networkSpeedLabel;
}
@end

@implementation TDPlayerLoadingView
@synthesize isLoading;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicatorView.frame = CGRectMake(0, 0, 40, 40);
        activityIndicatorView.center = CGPointMake(self.frame.size.width/2-35, self.frame.size.height/2);
        activityIndicatorView.hidesWhenStopped = YES;
        [self addSubview:activityIndicatorView];
        
        networkSpeedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        networkSpeedLabel.center = CGPointMake(activityIndicatorView.center.x+60, activityIndicatorView.center.y);
        networkSpeedLabel.textColor = [UIColor whiteColor];
        networkSpeedLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:networkSpeedLabel];
    }
    return self;
}

- (void)startLoading
{
    self.hidden = NO;
    self.isLoading = YES;
    networkSpeedLabel.text = nil;
    [activityIndicatorView startAnimating];
    activityIndicatorView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

- (void)keepLastLoading
{
    self.hidden = NO;
    self.isLoading = YES;
    [activityIndicatorView startAnimating];
}

- (void)loadingWithNetworkSpeed:(CGFloat)networkSpeed
{
    if (self.hidden) {
        self.hidden = NO;
        [activityIndicatorView startAnimating];
    }
    
    if (networkSpeedLabel.text.length == 0) {
        activityIndicatorView.center = CGPointMake(self.frame.size.width/2-35, self.frame.size.height/2);
        networkSpeedLabel.center = CGPointMake(activityIndicatorView.center.x+60, activityIndicatorView.center.y);
    }
    
    if (!self.isLoading) self.isLoading = YES;
    
    NSString *unit = @"KB";
    CGFloat changedSpeed = networkSpeed/1024.0/8.f;
    if (networkSpeed < 1024.f) {
        changedSpeed = networkSpeed/8.f;
        unit = @"B";
    }else
    {
        if (changedSpeed >= 1024.f) {
            changedSpeed = changedSpeed/1024.0;
            unit = @"M";
        }
    }
    networkSpeedLabel.text = [NSString stringWithFormat:@"%.1f %@/s", changedSpeed, unit];
}

- (void)stopLoading
{
    self.hidden = YES;
    [activityIndicatorView stopAnimating];
    self.isLoading = NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
