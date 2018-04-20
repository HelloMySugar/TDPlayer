//
//  TDPlayerStatusView.m
//  GoldenFruit
//
//  Created by TangYanQiong on 15/1/23.
//  Copyright (c) 2015年 TangYanQiong. All rights reserved.
//

#import "TDPlayerStatusView.h"
#import "TDPlayerConfig.h"

@interface TDPlayerStatusView ()
{
    UILabel *showWordLabel;
    UIActivityIndicatorView *loadingActivityIndicatorView;
    UIButton *replayButton;
    
    TDPlayerStautsType playerStatusType;
}
@end

@implementation TDPlayerStatusView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor blackColor];
        
        CGFloat btnWidth = TOP_BAR_HEIGHT;
        CGFloat btnHeight = TOP_BAR_HEIGHT;
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, 8.f, btnWidth, btnHeight);
        [backButton setImage:[UIImage imageNamed:@"PlayerImages.bundle/player_back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backButton];
        
        showWordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
        showWordLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2-30);
        showWordLabel.textAlignment = NSTextAlignmentCenter;
        showWordLabel.font = [UIFont systemFontOfSize:18];
        showWordLabel.backgroundColor = [UIColor clearColor];
        showWordLabel.textColor = [UIColor whiteColor];
        [self addSubview:showWordLabel];
        
        loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        loadingActivityIndicatorView.center = CGPointMake(showWordLabel.center.x, showWordLabel.center.y+40);
        loadingActivityIndicatorView.hidesWhenStopped = YES;
        [self addSubview:loadingActivityIndicatorView];
        
        UIImage *replayImage = [UIImage imageNamed:@"PlayerImages.bundle/replay"];
        replayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        replayButton.frame = CGRectMake(0, 0, replayImage.size.width, replayImage.size.height);
        replayButton.center = loadingActivityIndicatorView.center;
        [replayButton setImage:replayImage forState:UIControlStateNormal];
        [replayButton addTarget:self action:@selector(replayOrRequestToPlay) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:replayButton];
    }
    return self;
}

- (void)setStatusBy:(TDPlayerStautsType)statusType withWordString:(NSString *)wordStr
{
    playerStatusType = statusType;
    
    self.hidden = NO;
    showWordLabel.text = wordStr;
    loadingActivityIndicatorView.center = CGPointMake(showWordLabel.center.x, showWordLabel.center.y+40);
    
    switch (statusType) {
        case TDPlayerStautsTypeNone:
            self.hidden = YES;
            break;
        case TDPlayerStautsTypeLoading:
            if (wordStr.length == 0)
                loadingActivityIndicatorView.center = CGPointMake(showWordLabel.center.x, self.frame.size.height/2);
            [loadingActivityIndicatorView startAnimating];
            replayButton.hidden = YES;
            break;
        case TDPlayerStautsTypeNormal:
            self.hidden = YES;
            break;
        case TDPlayerStautsTypeEnd: case TDPlayerStautsTypeFailed: case TDPlayerStautsTypeError:
            [loadingActivityIndicatorView stopAnimating];
            replayButton.hidden = NO;
            break;
        default:
            break;
    }
}

- (void)clickBack
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(backButtonIsClicked)])
        [self.delegate backButtonIsClicked];
}

- (void)replayOrRequestToPlay
{
    switch (playerStatusType) {
        case TDPlayerStautsTypeEnd:
            if (self.delegate && [self.delegate respondsToSelector:@selector(replay)])
                [self.delegate replay];
            break;
        case TDPlayerStautsTypeFailed: case TDPlayerStautsTypeError:
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestToPlay)])
                [self.delegate requestToPlay];
            break;
        default:
            break;
    }
}

@end
