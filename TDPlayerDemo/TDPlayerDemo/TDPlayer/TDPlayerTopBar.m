//
//  TDPlayerTopBar.m
//  TDPlayer
//
//  Created by TangYanQiong on 15/1/20.
//  Copyright (c) 2015年 TangYanQiong. All rights reserved.
//

#import "TDPlayerTopBar.h"
#import "TDPlayerConfig.h"

@interface TDPlayerTopBar ()
{
    UILabel *titleLabel;
    UIButton *rightBtn;
}
@end

@implementation TDPlayerTopBar

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:0.f/255.f alpha:0.6f];
        
        CGFloat btnWidth = TOP_BAR_HEIGHT;
        CGFloat btnHeight = TOP_BAR_HEIGHT;
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, (frame.size.height-btnHeight)/2+8.f, btnWidth, btnHeight);
        [backButton setImage:[UIImage imageNamed:@"PlayerImages.bundle/player_back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(playerViewBack) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backButton];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(backButton.frame.origin.x+backButton.frame.size.width, backButton.frame.origin.y, self.frame.size.width-2*btnWidth, btnHeight)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:titleLabel];
        
        rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(self.frame.size.width-btnWidth-8.f, titleLabel.frame.origin.y, btnWidth, btnHeight);
        [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [rightBtn addTarget:self action:@selector(playerRightBtnIsClicked) forControlEvents:UIControlEventTouchUpInside];
        rightBtn.hidden = YES;
        [self addSubview:rightBtn];
    }
    return self;
}

- (void)setTitle:(NSString *)titleStr
{
    titleLabel.text = titleStr;
}

- (void)setRightBtnTitleBy:(NSString *)rightStr
{
    rightBtn.hidden = rightStr.length > 0 ? NO : YES;
    if (rightStr.length > 0)
        [rightBtn setTitle:rightStr forState:UIControlStateNormal];
}

- (void)playerViewBack
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(backButtonIsClicked)])
        [self.delegate backButtonIsClicked];
}

- (void)playerRightBtnIsClicked
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(rightButtonIsClicked)])
        [self.delegate rightButtonIsClicked];
}

@end
