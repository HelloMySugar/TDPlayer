//
//  TDPlayerBottomBar.m
//  TDPlayer
//
//  Created by TangYanQiong on 15/1/20.
//  Copyright (c) 2015年 TangYanQiong. All rights reserved.
//

#import "TDPlayerBottomBar.h"
#import "TDPlayerConfig.h"
#import <MediaPlayer/MediaPlayer.h>

#define LEFT_PADDING  13.f

@interface TDPlayerBottomBar () <UIGestureRecognizerDelegate>
{
    UIButton *nextBtn;
    UIButton *playOrPauseBtn;
    UIButton *previousBtn;
    
    UISlider *videoSlider;
    UIProgressView *videoProgress;
    
    UILabel *currentTimeLabel;
    UILabel *totalTimeLabel;
    CGFloat currentPlayTime;
    CGFloat totalTime;
    
    NSTimer *longPressTimer;
    CGFloat seekToTime;//前进或后退到某个时间
    
    UIButton *voiceButton;
    UIImageView *voiceBgImageView;
    UISlider *voiceSlider;
    
    NSInteger nowVideoIndex;
}
@end

@implementation TDPlayerBottomBar
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:0.f/255.f alpha:0.6f];
        
        CGFloat buttonY = LEFT_PADDING;
        for (int i = 0; i < 3; i ++)
        {
            UIImage *btnImage = nil;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            switch (i) {
                case 0:
                    btnImage = [UIImage imageNamed:@"PlayerImages.bundle/rewind"];
                    previousBtn = button;
                    //[button addTarget:self action:@selector(forwardOrRewindVideo:) forControlEvents:UIControlEventTouchUpInside];//以前是快退按钮
                    [button addTarget:self action:@selector(preOrNextVideo:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 1:
                    btnImage = [UIImage imageNamed:@"PlayerImages.bundle/player_play"];
                    [button setImage:[UIImage imageNamed:@"PlayerImages.bundle/player_pause"] forState:UIControlStateSelected];
                    [button addTarget:self action:@selector(videoPlayOrPause) forControlEvents:UIControlEventTouchUpInside];
                    playOrPauseBtn = button;
                    break;
                case 2:
                    btnImage = [UIImage imageNamed:@"PlayerImages.bundle/forward"];
                    nextBtn = button;
                    //[button addTarget:self action:@selector(forwardOrRewindVideo:) forControlEvents:UIControlEventTouchUpInside];//以前是快进按钮
                    [button addTarget:self action:@selector(preOrNextVideo:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                default:
                    break;
            }
            [button setImage:btnImage forState:UIControlStateNormal];
            button.frame = CGRectMake(buttonY, (self.frame.size.height-btnImage.size.height)/2, btnImage.size.width, btnImage.size.height);
            [self addSubview:button];
            
            buttonY = button.frame.origin.x+button.frame.size.width+5;
            
            /* 长按快进
             if (button != playOrPauseBtn) {
             UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
             [longPressRecognizer setMinimumPressDuration:1.f];
             [longPressRecognizer setDelegate:self];
             [button addGestureRecognizer:longPressRecognizer];
             }
             */
        }
        
        currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(nextBtn.frame.origin.x+nextBtn.frame.size.width, 0, 60, self.frame.size.height)];
        currentTimeLabel.backgroundColor = [UIColor clearColor];
        currentTimeLabel.text = @"00:00:00";
        currentTimeLabel.font = [UIFont systemFontOfSize:14];
        currentTimeLabel.textColor = [UIColor whiteColor];
        currentTimeLabel.textAlignment = NSTextAlignmentRight;
        currentTimeLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:currentTimeLabel];
        
        UIImage *voiceImage = [UIImage imageNamed:@"PlayerImages.bundle/volume"];
        voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        voiceButton.frame = CGRectMake(self.frame.size.width-voiceImage.size.width-12, (self.frame.size.height-voiceImage.size.height)/2, voiceImage.size.width, voiceImage.size.height);
        [voiceButton setImage:voiceImage forState:UIControlStateNormal];
        [voiceButton setImage:[UIImage imageNamed:@"PlayerImages.bundle/volume_on"] forState:UIControlStateSelected];
        [voiceButton addTarget:self action:@selector(showOrHiddenVoiceSlider:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:voiceButton];
        
        totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(voiceButton.frame.origin.x-currentTimeLabel.frame.size.width-4, 0, currentTimeLabel.frame.size.width, currentTimeLabel.frame.size.height)];
        totalTimeLabel.backgroundColor = [UIColor clearColor];
        totalTimeLabel.text = @"00:00:00";
        totalTimeLabel.textAlignment = NSTextAlignmentLeft;
        totalTimeLabel.font = currentTimeLabel.font;
        totalTimeLabel.textColor = currentTimeLabel.textColor;
        [self addSubview:totalTimeLabel];
        
        videoProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(currentTimeLabel.frame.origin.x+currentTimeLabel.frame.size.width+5.f, 0, totalTimeLabel.frame.origin.x-(currentTimeLabel.frame.origin.x+currentTimeLabel.frame.size.width)-10.f, 10)];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.f)
            videoProgress.transform = CGAffineTransformMakeScale(1, 0.2);
        videoProgress.center = CGPointMake(videoProgress.center.x, self.frame.size.height/2);
        videoProgress.progressViewStyle = UIProgressViewStyleBar;
        videoProgress.progressTintColor = [UIColor grayColor];
        [self addSubview:videoProgress];
        
        videoSlider = [[UISlider alloc] initWithFrame:CGRectMake(videoProgress.frame.origin.x-2.f, 0, videoProgress.frame.size.width+4.f, 40)];
        videoSlider.center = CGPointMake(videoSlider.center.x, self.frame.size.height/2);
        videoSlider.continuous = YES;
        [videoSlider setMinimumTrackImage:[UIImage imageNamed:@"PlayerImages.bundle/slider_left_bg"] forState:UIControlStateNormal];
        [videoSlider setMaximumTrackImage:[UIImage imageNamed:@"PlayerImages.bundle/slider_right_bg"] forState:UIControlStateNormal];
        [videoSlider setThumbImage:[UIImage imageNamed:@"PlayerImages.bundle/slider_point"] forState:UIControlStateNormal];
        [videoSlider setThumbImage:[UIImage imageNamed:@"PlayerImages.bundle/slider_point"] forState:UIControlStateSelected];
        [videoSlider setThumbImage:[UIImage imageNamed:@"PlayerImages.bundle/slider_point"] forState:UIControlStateHighlighted];
        [videoSlider addTarget:self action:@selector(videoValueChangeBegin) forControlEvents:UIControlEventTouchDown];
        [videoSlider addTarget:self action:@selector(videoValueChanging) forControlEvents:UIControlEventValueChanged];
        [videoSlider addTarget:self action:@selector(videoValueChangedEnd) forControlEvents:UIControlEventTouchUpInside];
        [videoSlider addTarget:self action:@selector(videoValueChangedEnd) forControlEvents:UIControlEventTouchUpOutside];
        [self addSubview:videoSlider];
    }
    return self;
}

- (void)setAlpha:(CGFloat)alpha
{
    [super setAlpha:alpha];
    if (!alpha && voiceSlider.alpha)
        [self showOrHiddenVoiceSlider:voiceButton];
}

- (void)videoPlayOrPause
{
    playOrPauseBtn.selected = !playOrPauseBtn.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickBtnToPlayOrPauseVideoBy:)])
        [self.delegate clickBtnToPlayOrPauseVideoBy:playOrPauseBtn.selected];
}

- (void)preOrNextVideo:(UIButton *)button
{
    if (button == previousBtn)
        nowVideoIndex -= 1;
    else if (button == nextBtn)
        nowVideoIndex += 1;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickPreOrNextBtnWithVideoIndex:)])
        [self.delegate clickPreOrNextBtnWithVideoIndex:nowVideoIndex];
}

#pragma mark - Device Voice Methods -

- (void)showOrHiddenVoiceSlider:(UIButton *)button
{
    button.selected = !button.selected;
    
    if (!voiceSlider)
    {
        UIImage *volumeBgImage = [UIImage imageNamed:@"PlayerImages.bundle/volume_bg"];
        voiceBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(voiceButton.frame.origin.x+voiceButton.frame.size.width/2-10, [self superview].frame.size.height-volumeBgImage.size.height-BOTTOM_BAR_HEIGHT-1, volumeBgImage.size.width, volumeBgImage.size.height)];
        voiceBgImageView.image = volumeBgImage;
        voiceBgImageView.userInteractionEnabled = YES;
        [self.superview addSubview:voiceBgImageView];
        
        [[MPMusicPlayerController applicationMusicPlayer] beginGeneratingPlaybackNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(trackDeviceVolume)
                                                     name:MPMusicPlayerControllerVolumeDidChangeNotification
                                                   object:nil];
        
        voiceSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        voiceSlider.layer.transform = CATransform3DMakeRotation(-M_PI/2, 0, 0, 1);
        voiceSlider.center = voiceBgImageView.center;
        voiceSlider.value = [MPMusicPlayerController applicationMusicPlayer].volume;
        [voiceSlider setMinimumTrackImage:[UIImage imageNamed:@"PlayerImages.bundle/slider_left_bg"] forState:UIControlStateNormal];
        [voiceSlider setMaximumTrackImage:[UIImage imageNamed:@"PlayerImages.bundle/slider_right_bg"] forState:UIControlStateNormal];
        [voiceSlider setThumbImage:[UIImage imageNamed:@"PlayerImages.bundle/slider_point"] forState:UIControlStateNormal];
        [voiceSlider setThumbImage:[UIImage imageNamed:@"PlayerImages.bundle/slider_point"] forState:UIControlStateSelected];
        [voiceSlider setThumbImage:[UIImage imageNamed:@"PlayerImages.bundle/slider_point"] forState:UIControlStateHighlighted];
        [voiceSlider addTarget:self action:@selector(voiceValueChangeBegin) forControlEvents:UIControlEventTouchDown];
        [voiceSlider addTarget:self action:@selector(voiceValueChanging) forControlEvents:UIControlEventValueChanged];
        [voiceSlider addTarget:self action:@selector(voiceValueChangeEnd) forControlEvents:UIControlEventTouchUpInside];
        [voiceSlider addTarget:self action:@selector(voiceValueChangeEnd) forControlEvents:UIControlEventTouchUpOutside];
        [self.superview addSubview:voiceSlider];
    }else
    {
        voiceSlider.alpha = button.selected;
        voiceBgImageView.alpha = button.selected;
    }
}

- (void)trackDeviceVolume
{
    voiceSlider.value = [MPMusicPlayerController applicationMusicPlayer].volume;
}

- (void)voiceValueChangeBegin
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(startOrStopTheHiddenTimerBy:)])
        [self.delegate startOrStopTheHiddenTimerBy:NO];
}

- (void)voiceValueChanging
{
    [[MPMusicPlayerController applicationMusicPlayer] setVolume:voiceSlider.value];
}

- (void)voiceValueChangeEnd
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(startOrStopTheHiddenTimerBy:)])
        [self.delegate startOrStopTheHiddenTimerBy:YES];
}

/*
 #pragma mark - Forward And Back Methods -
 
 - (void)forwardOrRewindVideo:(UIButton *)button
 {
 button.userInteractionEnabled = NO;
 
 if (self.delegate && [self.delegate respondsToSelector:@selector(codePauseVideo)])
 [self.delegate codePauseVideo];
 
 CGFloat theTime = currentPlayTime + ((button == nextBtn) ? FORWARD_OR_BACK_SECOND : -FORWARD_OR_BACK_SECOND);
 if (self.delegate && [self.delegate respondsToSelector:@selector(setVideoPlayTimeBy:)])
 [self.delegate setVideoPlayTimeBy:theTime];
 
 button.userInteractionEnabled = YES;
 }
 
 - (void)handleLongPress:(UILongPressGestureRecognizer *)longPressRecognizer
 {
 if (longPressRecognizer.state == UIGestureRecognizerStateBegan)
 {
 if (self.delegate && [self.delegate respondsToSelector:@selector(codePauseVideo)])
 [self.delegate codePauseVideo];
 if (self.delegate && [self.delegate respondsToSelector:@selector(startOrStopTheHiddenTimerBy:)])
 [self.delegate startOrStopTheHiddenTimerBy:NO];
 
 seekToTime = currentPlayTime;
 
 if ([longPressTimer isValid]) {
 [longPressTimer invalidate];
 longPressTimer = nil;
 }
 
 longPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
 target:self
 selector:@selector(longPress:)
 userInfo:longPressRecognizer
 repeats:YES];
 }else if (longPressRecognizer.state == UIGestureRecognizerStateEnded)
 {
 if ([longPressTimer isValid]) {
 [longPressTimer invalidate];
 longPressTimer = nil;
 }
 
 if (self.delegate && [self.delegate respondsToSelector:@selector(setVideoPlayTimeBy:)])
 [self.delegate setVideoPlayTimeBy:seekToTime];
 if (self.delegate && [self.delegate respondsToSelector:@selector(startOrStopTheHiddenTimerBy:)])
 [self.delegate startOrStopTheHiddenTimerBy:YES];
 }
 }
 
 - (void)longPress:(NSTimer *)timer
 {
 UILongPressGestureRecognizer *longPressRecognize = [longPressTimer userInfo];
 if ([longPressRecognize.view isEqual:nextBtn])
 seekToTime += FORWARD_OR_BACK_SECOND;
 else if ([longPressRecognize.view isEqual:previousBtn])
 seekToTime -= FORWARD_OR_BACK_SECOND;
 
 currentTimeLabel.text = [self convertTime:seekToTime];
 [videoSlider setValue:seekToTime/totalTime animated:YES];
 }
 */

#pragma mark - Video Progress Slider Methods -

- (void)videoValueChangeBegin
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(codePauseVideo)])
        [self.delegate codePauseVideo];
    if (self.delegate && [self.delegate respondsToSelector:@selector(startOrStopTheHiddenTimerBy:)])
        [self.delegate startOrStopTheHiddenTimerBy:NO];
}

- (void)videoValueChanging
{
    currentTimeLabel.text = [self convertTime:videoSlider.value*totalTime];
    [videoSlider setValue:videoSlider.value*totalTime/totalTime animated:YES];
}

- (void)videoValueChangedEnd
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(setVideoPlayTimeBy:)])
        [self.delegate setVideoPlayTimeBy:videoSlider.value*totalTime];
    if (self.delegate && [self.delegate respondsToSelector:@selector(startOrStopTheHiddenTimerBy:)])
        [self.delegate startOrStopTheHiddenTimerBy:YES];
}

#pragma mark -

- (NSString *)convertTime:(CGFloat)second
{
    int seconds = (int)second % 60;
    int minutes = ((int)second / 60) % 60;
    int hours = second / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

#pragma mark - 外部调用接口 -

- (void)setVideoTotalTime:(CGFloat)_totalTime
{
    if (isnan(_totalTime) || _totalTime <= 0)
    {
        nextBtn.enabled = NO;
        previousBtn.enabled = NO;
        videoSlider.enabled = NO;
        videoProgress.hidden = YES;
        totalTimeLabel.text = @"00:00:00";
    }else
    {
        videoSlider.enabled = YES;
        videoProgress.hidden = NO;
        totalTime = _totalTime;
        totalTimeLabel.text = [self convertTime:totalTime];
    }
}

- (void)playOrPauseVideoBy:(BOOL)isPlay
{
    playOrPauseBtn.selected = isPlay;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickBtnToPlayOrPauseVideoBy:)])
        [self.delegate clickBtnToPlayOrPauseVideoBy:playOrPauseBtn.selected];
}

- (void)setPlayTimeAndUpdateSliderBy:(CGFloat)currentTime
{
    currentPlayTime = currentTime;
    currentTimeLabel.text = [self convertTime:currentTime];
    if (totalTime > 0 && currentTime <= totalTime)
        [videoSlider setValue:currentTime/totalTime animated:YES];
}

- (void)updateProgressBy:(CGFloat)progress
{
    [videoProgress setProgress:progress animated:YES];
}

- (void)refreshUIByNowVideoIndex:(NSInteger)_nowVideoIndex andAllVideoCount:(NSInteger)allVideoCount
{
    nowVideoIndex = _nowVideoIndex;
    
    if (allVideoCount <= 1 || nowVideoIndex < 0)
    {
        previousBtn.enabled = NO;
        nextBtn.enabled = NO;
    }else
    {
        previousBtn.enabled = ((nowVideoIndex-1) >= 0) ? YES : NO;
        nextBtn.enabled = (nowVideoIndex+1) < allVideoCount ? YES : NO;
    }
}

//为了回看特意加的两个方法
- (void)setPreviousBtnEnabledBy:(BOOL)enabled
{
    previousBtn.enabled = enabled;
}

- (void)setNextBtnEnabledBy:(BOOL)enabled
{
    nextBtn.enabled = enabled;
}
//

#pragma mark -

- (void)dealloc
{
    //    [[MPMusicPlayerController applicationMusicPlayer] endGeneratingPlaybackNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerVolumeDidChangeNotification object:nil];
}

@end
