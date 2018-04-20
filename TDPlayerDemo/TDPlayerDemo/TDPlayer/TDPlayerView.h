//
//  TDPlayerView.h
//  TDPlayer
//
//  Created by TangYanQiong on 15/1/20.
//  Copyright (c) 2015年 TangYanQiong. All rights reserved.
//


/*
    1.说明文档－阐述外部接口与交互关系
    2.隔离变化
    3.外部接口说明
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TDPlayerStatusView.h"

@protocol TDPlayerViewDelegate <NSObject>
@optional
- (void)back;//返回
- (void)rightBtnClicked;//右上角按钮被点击
- (void)bottomBarPreOrNextBtnIsClickWithVideoIndex:(NSInteger)videoIndex;//bottomBar上一集或下一集按钮被点击
- (void)requestToReload;//重新请求播放
- (void)videoPlayEnd;//视频播放完成
- (void)videoPlayError;//视频播放错误
- (void)videoReadyToPlay;//视频可以播放了
@end

@interface TDPlayerView : UIView
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, assign) id <TDPlayerViewDelegate> delegate;

- (void)startLoadingWithTitleStr:(NSString *)titleStr;
- (void)playVideoByUrl:(NSString *)urlStr;
- (void)showPlayerRightBtnByString:(NSString *)rightStr;
- (void)playError;
- (void)setPlayedTimeBy:(CGFloat)playedTime;
- (void)showOrHiddenTopAndBottomBar;
- (void)refreshBottomBarUIByNowVideoIndex:(NSInteger)nowVideoIndex
                         andAllVideoCount:(NSInteger)allVideoCount;

//为了回看特意加的两个方法
- (void)setBottomBarPreviousBtnEnabledBy:(BOOL)enabled;

- (void)setBottomBarNextBtnEnabledBy:(BOOL)enabled;

@end
