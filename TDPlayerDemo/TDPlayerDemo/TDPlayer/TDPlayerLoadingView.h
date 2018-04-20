//
//  TDPlayerLoadingView.h
//  TDPlayerDemo
//
//  Created by TangYanQiong on 15/4/7.
//  Copyright (c) 2015年 TangYanQiong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDPlayerLoadingView : UIView

@property (nonatomic) BOOL isLoading;

- (void)startLoading;
- (void)keepLastLoading;
- (void)loadingWithNetworkSpeed:(CGFloat)networkSpeed;
- (void)stopLoading;

@end
