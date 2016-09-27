//
//  ViewController.m
//  WS_TouchID_Demo
//
//  Created by warron on 16/9/27.
//  Copyright © 2016年 warron. All rights reserved.
//

#import "ViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "SuccessVC.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
}
- (IBAction)btnTouch:(UIButton *)sender {
  
    //创建LAContext
    LAContext *context = [LAContext new];
    
    //这个属性是设置指纹输入失败之后的弹出框的选项
    context.localizedFallbackTitle = @"没有输入密码";
    
    //这个属性是设置右边取消按钮文字
    context.localizedCancelTitle = @"取消录入";
    
    if ([[UIDevice currentDevice].systemVersion floatValue]<8.0) {
        //设备版本在8.0一下不支持指纹解锁
        return;
    }
    
    NSError *error = nil;
    
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        NSLog(@"支持指纹识别");
        
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"请触摸home键指纹解锁" reply:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    SuccessVC *successVC = [sb instantiateViewControllerWithIdentifier:@"SuccessVC"];
                    [self presentViewController:successVC animated:YES completion:nil];
                }];
            }
            else{
             // 失败
            // 获取到相应的错误信息····做相应的操作
                NSString * domain = [error domain];//获取错误域
                NSString * userInfo = [error userInfo];//错误详细信息
                NSInteger code = [error code];// 获取Code值  一般domin 和 code 一起就是一个错误信息
                NSLog(@"%@",error.localizedDescription);

                [self representErrorMessage:code];
            }
            
            
        }];
    }
    else{
        NSLog(@"不支持指纹识别");
        switch (error.code) {
            case LAErrorTouchIDNotEnrolled:
                NSLog(@"TouchID is not enrolled");

                break;
            case LAErrorPasscodeNotSet:
                NSLog(@"A passcode has not been set");
                break;
            default:
                 NSLog(@"TouchID not available");
                break;
        }
        
        NSLog(@"%@",error.localizedDescription);

    }
}
-(void)representErrorMessage:(NSInteger) code{
    switch (code) {
        case LAErrorSystemCancel:
            NSLog(@"系统取消授权，如其他APP切入");
            break;
        case LAErrorUserCancel:
            NSLog(@"用户取消验证Touch ID");
            break;
        case LAErrorAuthenticationFailed:
            NSLog(@"授权失败");
            break;
        case LAErrorPasscodeNotSet:
            NSLog(@"系统未设置密码");
            break;
        case LAErrorTouchIDNotAvailable:
            NSLog(@"设备Touch ID不可用，例如未打开，请尝试打开Touch ID(设置 -> Touch ID 与 密码 -> 打开密码)");
            break;
        case LAErrorTouchIDNotEnrolled:
            NSLog(@"设备Touch ID不可用，用户未录入");
            break;
        case LAErrorUserFallback:
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"用户选择输入密码，切换主线程处理");
            }];
            break;
       
        default:
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"其他情况，切换主线程处理");
            }];
            break;
            break;
    }

}

@end
