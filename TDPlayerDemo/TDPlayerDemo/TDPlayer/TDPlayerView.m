//
//  TDPlayerView.m
//  TDPlayer
//
//  Created by TangYanQiong on 15/1/20.
//  Copyright (c) 2015年 TangYanQiong. All rights reserved.
//

#import "TDPlayerView.h"
#import "TDPlayerConfig.h"
#import "TDPlayerTopBar.h"
#import "TDPlayerBottomBar.h"
#import "TDPlayerStatusView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Reachability.h"
#import "TDPlayerLoadingView.h"

#define PlayerItemStatus             @"status"
#define PlayerItemLoadedTimeRanges   @"loadedTimeRanges"

@interface TDPlayerView () <TDPlayerStatusViewDelegate, TDPlayerTopBarDelegate, TDPlayerBottomBarDelegate>
{
    UIStatusBarStyle beforeStatusBarStyle;
    BOOL beforeStatusBarStatus;
    
    AVPlayerItem *playerItem;
    id playbackTimeObserver;
    
    TDPlayerStatusView *playerStatusView;
    TDPlayerTopBar *topBar;
    TDPlayerBottomBar *bottomBar;
    
    TDPlayerLoadingView *playerLoadingView;
    NSInteger cacheArrayCount;
    CGFloat beforeCacheSize;
    NSTimer *networkTimer;
    
    BOOL nowIsPlayStatus;//记录现在的播放状态：播放是YES，暂停是NO
    
    NSTimer *hiddenTimer;//隐藏状态栏和底部栏Timer
    
    BOOL isBack;//返回到上一层
    
    CGFloat networkBreakPlayedTime;//网络链接断了的时候的播放时间
}
@property (nonatomic) NSInteger nowPlayedTime;//当前播放时间，为NSIntger类型是因为有时候不到一秒也会回调播放函数
@property (nonatomic) BOOL isLive;//是否是直播
@property (nonatomic) NSInteger liveShowTime;//直播时默认时间不是从0开始，所以要手动去增加时间
@end

@implementation TDPlayerView
@synthesize player;
@synthesize delegate;

#pragma mark - AVPlayer只能添加至AVPlayerLayer中，改变一下layerClass -

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayer *)player
{
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)_player
{
    [(AVPlayerLayer *)[self layer] setPlayer:_player];
}

#pragma mark - 

//0 无网络，1 WIFI，2 移动数据
- (NSInteger)checkNetWorkType
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    if([reachability currentReachabilityStatus] == NotReachable) return 0;
    if([reachability currentReachabilityStatus] == ReachableViaWiFi) return 1;
    if([reachability currentReachabilityStatus] == ReachableViaWWAN) return 2;
    return 0;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        beforeStatusBarStatus = [UIApplication sharedApplication].statusBarHidden;
        beforeStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        self.backgroundColor = [UIColor blackColor];
        
        topBar = [[TDPlayerTopBar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, TOP_BAR_HEIGHT)];
        topBar.delegate = self;
        [self addSubview:topBar];
        
        bottomBar = [[TDPlayerBottomBar alloc] initWithFrame:CGRectMake(0, self.frame.size.height-BOTTOM_BAR_HEIGHT, frame.size.width, BOTTOM_BAR_HEIGHT)];
        bottomBar.delegate = self;
        [self addSubview:bottomBar];
        
        playerLoadingView = [[TDPlayerLoadingView alloc] initWithFrame:CGRectMake(0, (self.frame.size.height-100)/2, self.frame.size.width, 100)];
        [self addSubview:playerLoadingView];
        
        UIView *middleView = [[UIView alloc] initWithFrame:CGRectMake(0, topBar.frame.origin.y+topBar.frame.size.height, self.frame.size.width, self.frame.size.height-topBar.frame.size.height-bottomBar.frame.size.height)];
        [self addSubview:middleView];
        
        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showOrHiddenTopAndBottomBar)];
        [singleTapGestureRecognizer setNumberOfTapsRequired:1];
        [middleView addGestureRecognizer:singleTapGestureRecognizer];
        
        playerStatusView = [[TDPlayerStatusView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        playerStatusView.delegate = self;
        [self addSubview:playerStatusView];
        
        nowIsPlayStatus = YES;//刚开始默认可以播放，所以为YES
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(gotoBackground)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fromBackground)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - UIApplication Delegate -

- (void)gotoBackground
{
    if (self.player.rate)
        [self codePauseVideo];
}

- (void)fromBackground
{
    if (nowIsPlayStatus)
    {
        [self.player play];
    }else
    {
        [self.player play];
        [self.player pause];
    }
}

#pragma mark -

- (void)hiddenTopAndBottomBar
{
    [UIView animateWithDuration:0.4f animations:^{
        topBar.alpha = 0.f;
        bottomBar.alpha = 0.f;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }];
}

- (void)addOrRemoveNotification:(BOOL)isAdd
{
    if (isAdd)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayStalled:)
                                                     name:AVPlayerItemPlaybackStalledNotification
                                                   object:playerItem];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayDidEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:playerItem];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayError:)
                                                     name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                   object:playerItem];
        
        [playerItem addObserver:self
                     forKeyPath:PlayerItemStatus
                        options:NSKeyValueObservingOptionNew
                        context:nil];//监听playerItem status属性
        [playerItem addObserver:self
                     forKeyPath:PlayerItemLoadedTimeRanges
                        options:NSKeyValueObservingOptionNew
                        context:nil];//监听playerItem loadedTimeRanges属性
    }else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:playerItem];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:playerItem];
        
        [playerItem removeObserver:self forKeyPath:PlayerItemStatus context:nil];
        [playerItem removeObserver:self forKeyPath:PlayerItemLoadedTimeRanges context:nil];
    }
}

- (NSTimeInterval)availableDuration
{
    NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];//获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    if (isnan(startSeconds)) {
        if (!playerLoadingView.isLoading) {
            [self showNetworkLoadingView];
        }
    }
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;//计算缓冲总进度
    return result;
}

- (void)showNetworkLoadingView
{
    //暂停时不显示视频加载速度
    if (!nowIsPlayStatus)
        return;
    
    [playerLoadingView keepLastLoading];
    
    if ([networkTimer isValid]) {
        [networkTimer invalidate];
        networkTimer = nil;
    }
    
    networkTimer = [NSTimer scheduledTimerWithTimeInterval:1.f
                                                    target:self
                                                  selector:@selector(showNetworkSpeed)
                                                  userInfo:nil
                                                   repeats:YES];
    [networkTimer fire];
}

- (void)hiddenLoadingView
{
    [playerLoadingView stopLoading];
    
    if ([networkTimer isValid]) {
        [networkTimer invalidate];
        networkTimer = nil;
    }
}

- (void)showNetworkSpeed
{
    if (cacheArrayCount != self.player.currentItem.accessLog.events.count)
    {
        beforeCacheSize = 0.f;
        cacheArrayCount = self.player.currentItem.accessLog.events.count;
    }
    
    NSArray *events = self.player.currentItem.accessLog.events;
    NSInteger count = events.count;
    for (int i = 0; i < count; i++)
    {
        if (i == count - 1) {
            AVPlayerItemAccessLogEvent *currentEvent = [events objectAtIndex:i];
            long long byte = currentEvent.numberOfBytesTransferred;
            
            CGFloat changedByte = (CGFloat)byte;
            if (beforeCacheSize >= 0 && changedByte > beforeCacheSize) {
                [playerLoadingView loadingWithNetworkSpeed:changedByte-beforeCacheSize];
            }
            beforeCacheSize = changedByte;
        }
    }
}

#pragma mark - Notification -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    AVPlayerItem *_playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:PlayerItemStatus])
    {
        if ([_playerItem status] == AVPlayerStatusReadyToPlay)
        {
            if (networkBreakPlayedTime > 0) {
                [self setPlayedTimeBy:networkBreakPlayedTime];
                networkBreakPlayedTime = 0;
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(videoReadyToPlay)])
                [self.delegate videoReadyToPlay];
            
            self.liveShowTime = 0;
            if (isnan(CMTimeGetSeconds(_playerItem.duration)) || CMTimeGetSeconds(_playerItem.duration) <= 0)
                self.isLive = YES;
            else
                self.isLive = NO;
            
            [playerStatusView setStatusBy:TDPlayerStautsTypeNormal withWordString:nil];
            [bottomBar setVideoTotalTime:CMTimeGetSeconds(_playerItem.duration)];
            [self monitoringPlayback:_playerItem];//监听播放状态
            
            if (topBar.alpha)
            {
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
                
                if ([hiddenTimer isValid]) {
                    [hiddenTimer invalidate];
                    hiddenTimer = nil;
                }
                hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:TOP_BOTTOM_HIDDEN_TIME
                                                               target:self
                                                             selector:@selector(hiddenTopAndBottomBar)
                                                             userInfo:nil
                                                              repeats:NO];
            }
        }else if ([_playerItem status] == AVPlayerStatusFailed)
        {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            [playerStatusView setStatusBy:TDPlayerStautsTypeFailed withWordString:@"播放失败,请点击重试"];
            NSLog(@"AVPlayerStatusFailed");
        }else
        {
            [self playError];
            if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayError)])
                [self.delegate videoPlayError];
        }
    }else if ([keyPath isEqualToString:PlayerItemLoadedTimeRanges])
    {
        NSTimeInterval timeInterval = [self availableDuration];//计算缓冲进度

        if (!isnan(timeInterval)) {
            CGFloat totalDuration = CMTimeGetSeconds(_playerItem.duration);
            [bottomBar updateProgressBy:timeInterval/totalDuration];
        }
    }
}

- (void)monitoringPlayback:(AVPlayerItem *)_playerItem
{
    if (playbackTimeObserver)
        [self.player removeTimeObserver:playbackTimeObserver];
    
    __weak __typeof(self)weakSelf = self;
    TDPlayerBottomBar *_bottomBar = bottomBar;
    TDPlayerLoadingView *_playerLoadingView = playerLoadingView;
    playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1)
                                                                     queue:NULL
                                                                usingBlock:^(CMTime time)
                            {
                                NSInteger currentTime = (NSInteger)CMTimeGetSeconds(_playerItem.currentTime);
                                if (weakSelf.nowPlayedTime != currentTime) {
                                    weakSelf.nowPlayedTime = currentTime;
                                    
                                    NSInteger currentSecond = 0;
                                    if (weakSelf.isLive)
                                    {
                                        /*为了直播时不显示当前播放时间注释了
                                        currentSecond = weakSelf.liveShowTime;
                                        weakSelf.liveShowTime++;
                                        */
                                    }else
                                        currentSecond = currentTime;//计算当前在第几秒
                                    
                                    [_bottomBar setPlayTimeAndUpdateSliderBy:currentSecond];
                                    
                                    if (_playerLoadingView.isLoading)
                                        [weakSelf hiddenLoadingView];
                                }
                            }];
}

- (void)moviePlayStalled:(NSNotification *)notifcation
{
    if (!playerLoadingView.isLoading)
        [self showNetworkLoadingView];
    
    //断网络时
    if (![self checkNetWorkType])
    {
        networkBreakPlayedTime = (CGFloat)CMTimeGetSeconds(self.player.currentItem.currentTime);
        
        [self.player pause];
        [playerItem.asset cancelLoading];
        [self.player replaceCurrentItemWithPlayerItem:nil];
        
        [self hiddenLoadingView];
        
        [self playError];
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayError)])
            [self.delegate videoPlayError];
    }
    
    NSLog(@"播放卡顿");
}

- (void)moviePlayDidEnd:(NSNotification *)notifcation
{
    [playerStatusView setStatusBy:TDPlayerStautsTypeEnd withWordString:@"播放完成,点击重新播放"];
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayEnd)])
        [self.delegate videoPlayEnd];
}

- (void)moviePlayError:(NSNotification *)notifcation
{
    [self playError];
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayError)])
        [self.delegate videoPlayError];
}

#pragma mark - TDPlayerBottomBar Delegate -

- (void)setVideoPlayTimeBy:(CGFloat)seekTime
{
    [self setPlayedTimeBy:seekTime];
}

- (void)clickBtnToPlayOrPauseVideoBy:(BOOL)isPlay
{
    nowIsPlayStatus = isPlay;
    isPlay ? [self.player play] : [self.player pause];
    
    if (playerLoadingView.isLoading)
        [self hiddenLoadingView];
}

- (void)codePauseVideo
{
    [self.player pause];
}

- (void)startOrStopTheHiddenTimerBy:(BOOL)isStart
{
    if ([hiddenTimer isValid]) {
        [hiddenTimer invalidate];
        hiddenTimer = nil;
    }
    
    if (isStart) {
        hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:TOP_BOTTOM_HIDDEN_TIME
                                                       target:self
                                                     selector:@selector(hiddenTopAndBottomBar)
                                                     userInfo:nil
                                                      repeats:NO];
    }
}

- (void)clickPreOrNextBtnWithVideoIndex:(NSInteger)videoIndex
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomBarPreOrNextBtnIsClickWithVideoIndex:)])
        [self.delegate bottomBarPreOrNextBtnIsClickWithVideoIndex:videoIndex];
}

#pragma mark - TDPlayerStatusView Delegate -

- (void)replay
{
    [playerStatusView setStatusBy:TDPlayerStautsTypeNormal withWordString:nil];
    
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            [playerLoadingView startLoading];
            [self.player play];
        }else
        {
            [self playError];
            if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayError)])
                [self.delegate videoPlayError];
        }
    }];
}

- (void)requestToPlay
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestToReload)])
        [self.delegate requestToReload];
}

#pragma mark - TDPlayerStatusView And TDPlayerTopBar Delegate -

- (void)backButtonIsClicked
{
    [[UIApplication sharedApplication] setStatusBarHidden:beforeStatusBarStatus];
    [[UIApplication sharedApplication] setStatusBarStyle:beforeStatusBarStyle];
    
    isBack = YES;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(back)])
        [self.delegate back];
    
    [self.player pause];
    [playerItem.asset cancelLoading];
    [self.player replaceCurrentItemWithPlayerItem:nil];//一定要放在back方法后面
    
    //important
    if ([hiddenTimer isValid]) {
        [hiddenTimer invalidate];
        hiddenTimer = nil;
    }
    
    if ([networkTimer isValid]) {
        [networkTimer invalidate];
        networkTimer = nil;
    }
}

- (void)rightButtonIsClicked
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(rightBtnClicked)])
        [self.delegate rightBtnClicked];
}

#pragma mark - 外部调用接口 -

- (void)startLoadingWithTitleStr:(NSString *)titleStr
{
    [self.player pause];
    [playerItem.asset cancelLoading];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    
    [topBar setTitle:titleStr];
    [playerStatusView setStatusBy:TDPlayerStautsTypeLoading
                   withWordString:titleStr.length > 0 ? [NSString stringWithFormat:@"即将播放: %@", titleStr] : titleStr];
    
    //主要是为了隐藏状态栏
    if (topBar.alpha)
        [self hiddenTopAndBottomBar];
}

- (void)playVideoByUrl:(NSString *)urlStr
{
    if (playerItem)
        [self addOrRemoveNotification:NO];
    
    urlStr = [urlStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (urlStr.length > 0)
    {
        playerItem = [[AVPlayerItem alloc] initWithAsset:[AVAsset assetWithURL:[NSURL URLWithString:urlStr]]];
        if (!self.player)
            self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        else
            [self.player replaceCurrentItemWithPlayerItem:playerItem];
        
        [self addOrRemoveNotification:YES];
        
        [bottomBar playOrPauseVideoBy:YES];
        [playerLoadingView startLoading];
    }else
    {
        playerItem = nil;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [playerStatusView setStatusBy:TDPlayerStautsTypeFailed withWordString:@"播放失败,请点击重试"];
    }
}

- (void)showPlayerRightBtnByString:(NSString *)rightStr
{
    [topBar setRightBtnTitleBy:rightStr];
}

- (void)playError
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [playerStatusView setStatusBy:TDPlayerStautsTypeError withWordString:@"播放错误,请点击重试"];
}

- (void)setPlayedTimeBy:(CGFloat)playedTime
{
    //页面已经退出，不需要再设置
    if (isBack)
        return;

    //断网络时
    if (![self checkNetWorkType])
    {
        networkBreakPlayedTime = (CGFloat)CMTimeGetSeconds(self.player.currentItem.currentTime);
        
        [self.player pause];
        [playerItem.asset cancelLoading];
        [self.player replaceCurrentItemWithPlayerItem:nil];
        
        [self hiddenLoadingView];
        
        [self playError];
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayError)])
            [self.delegate videoPlayError];
        
        return;
    }
    
    if (playedTime < 0)
        playedTime = 0;
    if (playedTime >= CMTimeGetSeconds(playerItem.duration))
        playedTime = CMTimeGetSeconds(playerItem.duration)-10.f;
    
    CMTime changedTime = CMTimeMakeWithSeconds(playedTime, 1);
    [self.player seekToTime:changedTime completionHandler:^(BOOL finished) {
        nowIsPlayStatus ? [self.player play] : [self.player pause];
        
        if (!playerLoadingView.isLoading)
            [self showNetworkLoadingView];
    }];
}

- (void)showOrHiddenTopAndBottomBar
{
    [UIView animateWithDuration:0.4f animations:^{
        topBar.alpha = !topBar.alpha;
        bottomBar.alpha = !bottomBar.alpha;
        [[UIApplication sharedApplication] setStatusBarHidden:!topBar.alpha withAnimation:UIStatusBarAnimationFade];
    } completion:^(BOOL finished) {
        if ([hiddenTimer isValid]) {
            [hiddenTimer invalidate];
            hiddenTimer = nil;
        }
        
        if (topBar.alpha) {
            hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:TOP_BOTTOM_HIDDEN_TIME
                                                           target:self
                                                         selector:@selector(hiddenTopAndBottomBar)
                                                         userInfo:nil
                                                          repeats:NO];
        }
    }];
}

- (void)refreshBottomBarUIByNowVideoIndex:(NSInteger)nowVideoIndex
                         andAllVideoCount:(NSInteger)allVideoCount
{
    [bottomBar refreshUIByNowVideoIndex:nowVideoIndex andAllVideoCount:allVideoCount];
}

//为了回看特意加的两个方法
- (void)setBottomBarPreviousBtnEnabledBy:(BOOL)enabled
{
    [bottomBar setPreviousBtnEnabledBy:enabled];
}

- (void)setBottomBarNextBtnEnabledBy:(BOOL)enabled
{
    [bottomBar setNextBtnEnabledBy:enabled];
}
//

#pragma mark - dealloc -

- (void)dealloc
{
    if (playerItem)
        [self addOrRemoveNotification:NO];
    [self.player removeTimeObserver:playbackTimeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

@end
