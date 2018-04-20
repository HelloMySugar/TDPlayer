//
//  ShowTextForTestViewController.m
//  TDPlayerDemo
//
//  Created by TangYanQiong on 15/3/26.
//  Copyright (c) 2015年 TangYanQiong. All rights reserved.
//

#import "ShowTextForTestViewController.h"
#import "TDPlayerViewController.h"

@interface ShowTextForTestViewController () <UITextFieldDelegate>
{
    UITextField *enterText;
}
@end

@implementation ShowTextForTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    CGFloat selfWidth = self.view.frame.size.width;
    if (self.view.frame.size.width < self.view.frame.size.height)
        selfWidth = self.view.frame.size.height;
    
    enterText = [[UITextField alloc] initWithFrame:CGRectMake(10, 80, selfWidth-20, 40.f)];
    enterText.backgroundColor = [UIColor grayColor];
    enterText.returnKeyType = UIReturnKeyGo;
    enterText.delegate = self;
    enterText.textColor = [UIColor whiteColor];
    [self.view addSubview:enterText];
    
    UIButton *fireBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    fireBtn.frame = CGRectMake(0, 0, 80, 40);
    fireBtn.center = CGPointMake(enterText.center.x, enterText.center.y+40);
    [fireBtn setTitle:@"去看看" forState:UIControlStateNormal];
    [fireBtn addTarget:self action:@selector(goToShowVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fireBtn];
}

- (void)goToShowVideo
{
    TDPlayerViewController *tdPlayerVC = [[TDPlayerViewController alloc] init];
    tdPlayerVC.playUrl = enterText.text;
    [self presentViewController:tdPlayerVC animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [enterText becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    TDPlayerViewController *tdPlayerVC = [[TDPlayerViewController alloc] init];
    tdPlayerVC.playUrl = textField.text;
    [self presentViewController:tdPlayerVC animated:YES completion:nil];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
