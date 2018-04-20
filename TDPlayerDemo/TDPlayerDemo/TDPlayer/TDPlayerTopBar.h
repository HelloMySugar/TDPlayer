//
//  TDPlayerTopBar.h
//  TDPlayer
//
//  Created by TangYanQiong on 15/1/20.
//  Copyright (c) 2015年 TangYanQiong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TDPlayerTopBarDelegate <NSObject>
@required
- (void)backButtonIsClicked;//返回按钮被点中
@optional
- (void)rightButtonIsClicked;//右边按钮被点中
@end

@interface TDPlayerTopBar : UIView
@property (nonatomic, assign) id <TDPlayerTopBarDelegate> delegate;
- (void)setTitle:(NSString *)titleStr;
- (void)setRightBtnTitleBy:(NSString *)rightStr;
@end
