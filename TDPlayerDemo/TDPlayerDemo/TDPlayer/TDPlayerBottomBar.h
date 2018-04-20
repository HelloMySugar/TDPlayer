//
//  TDPlayerBottomBar.h
//  TDPlayer
//
//  Created by TangYanQiong on 15/1/20.
//  Copyright (c) 2015年 TangYanQiong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TDPlayerBottomBarDelegate <NSObject>
@required
- (void)clickBtnToPlayOrPauseVideoBy:(BOOL)isPlay;//手动播放或暂停视频
- (void)setVideoPlayTimeBy:(CGFloat)seekTime;//设置播放时间点
- (void)codePauseVideo;//代码暂停播放
- (void)startOrStopTheHiddenTimerBy:(BOOL)isStart;//开始或停止隐藏视图的timer
- (void)clickPreOrNextBtnWithVideoIndex:(NSInteger)videoIndex;//点击上一集或下一集按钮传出videoIndex
@end

@interface TDPlayerBottomBar : UIView

@property (nonatomic, assign) id <TDPlayerBottomBarDelegate> delegate;

- (void)setVideoTotalTime:(CGFloat)totalTime;
- (void)playOrPauseVideoBy:(BOOL)isPlay;
- (void)setPlayTimeAndUpdateSliderBy:(CGFloat)currentTime;
- (void)updateProgressBy:(CGFloat)progress;
- (void)refreshUIByNowVideoIndex:(NSInteger)_nowVideoIndex andAllVideoCount:(NSInteger)allVideoCount;

//为了回看特意加的两个方法
- (void)setPreviousBtnEnabledBy:(BOOL)enabled;
- (void)setNextBtnEnabledBy:(BOOL)enabled;

@end
