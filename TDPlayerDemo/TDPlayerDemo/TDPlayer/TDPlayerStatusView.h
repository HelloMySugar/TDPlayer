//
//  TDPlayerStatusView.h
//  GoldenFruit
//
//  Created by TangYanQiong on 15/1/23.
//  Copyright (c) 2015年 TangYanQiong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _TDPlayerStautsType
{
    TDPlayerStautsTypeNone = 0,
    TDPlayerStautsTypeLoading = 1,
    TDPlayerStautsTypeNormal = 2,
    TDPlayerStautsTypeEnd = 3,
    TDPlayerStautsTypeFailed = 4,
    TDPlayerStautsTypeError = 5
} TDPlayerStautsType;

@protocol TDPlayerStatusViewDelegate <NSObject>
@required
- (void)backButtonIsClicked;//返回按钮被点击了
- (void)replay;//重新播放
- (void)requestToPlay;//请求数据以播放
@end

@interface TDPlayerStatusView : UIView

@property (nonatomic, assign) id <TDPlayerStatusViewDelegate> delegate;

- (void)setStatusBy:(TDPlayerStautsType)statusType withWordString:(NSString *)wordStr;

@end
