//
//  LoginInViewController.m
//  LabHelper
//
//  Created by ljc on 2016/11/5.
//  Copyright © 2016年 meitu. All rights reserved.
//
#import "LoginInViewController.h"
#import "NSString+MD5Encrypt.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>

typedef NS_ENUM(NSInteger,NSLoginState) {
         NSLoginStateSuccess      = 0,
         NSLoginStateFailed       = 1,
         NSLoginStateNetworkError = 2
};

typedef void(^loginCompleteHandler)(BOOL reslut,NSString *description);

@interface LoginInViewController ()
@property (nonatomic, weak) IBOutlet UITextField *userNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *passWordTextField;
@property (nonatomic, strong)  MBProgressHUD *hud;

@end

@implementation LoginInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark -Acions

- (IBAction)actionLogin:(id)sender {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self showHUDWithMessage:@"登录中..."];
        [self loginWithUserName:self.userNameTextField.text Password:self.passWordTextField.text complete:^(BOOL reslut,NSString *description) {
            if (reslut) {
                [self showHUDWithMessage:@"登录成功"];
                [self performSegueWithIdentifier:@"pushToHome" sender:nil];
                
                
            }else {
                [self showHUDWithMessage:description];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.hud hideAnimated:YES];
            });
            
        }];
}

/**
 拿到密码生成进行两次md5,并与返回的token2拼接，在进行md5

 @param password 用户输入的密码
 @param token2 请求回来的token2
 @return 认证的token
 */
- (NSString *)generateMD5tokenWithPassword:(NSString*)password Token2:(NSString *)token2 {
    NSString *doubleTimesMD5WithPasswordString = [NSString md5StringForString:[NSString md5StringForString:password]];
    NSString *newToken = [NSString stringWithFormat:@"%@%@",doubleTimesMD5WithPasswordString,token2];
    return  [NSString md5StringForString:newToken];
}

/**
 登录

 @param userID 用户id
 @param password 用户密码
 @param completeHandle 登录回调
 */
- (void)loginWithUserName:(NSString*)userID Password:(NSString *)password complete:(loginCompleteHandler)completeHandle {
    NSDictionary *paramDic = [NSDictionary dictionaryWithObjectsAndKeys:userID,@"userid",KLoginCode,@"sp", nil];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:KGetSecondPasswordAddress parameters:paramDic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = responseObject;
        NSString *newToken = [self generateMD5tokenWithPassword:password Token2:dic[@"Token"]];
        NSDictionary *paramDic = [NSDictionary dictionaryWithObjectsAndKeys:userID,@"userid",newToken,@"token", nil];
      [manager GET:KLoginAddress parameters:paramDic progress:^(NSProgress * _Nonnull downloadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *dic = responseObject;
            NSUserDefaults *uts = [NSUserDefaults standardUserDefaults];
            [uts setObject:userID forKey:KUserID];
            [uts setObject:[self generateMD5tokenWithPassword:password
                                                       Token2:dic[@"NewToken"]]
                                                       forKey:KToken];
            BOOL result = [dic[@"Result"] isEqualToString:@"false"] ? NO : YES;
            completeHandle(result,dic[@"Remark"]);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self showHUDWithMessage:@"登录网络错误"];
            sleep(5);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.hud hideAnimated:YES];
            });

            NSLog(@"登录网络错误%@",error);
        }];
        }
      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [self showHUDWithMessage:@"获取密码2网络错误"];
          sleep(5);

          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
              [self.hud hideAnimated:YES];
          });

        NSLog(@"获取密码2网络错误:%@",error);
    }];
}

- (void)showHUDWithMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = message;
    });
}

- (BOOL)isNetWorkReachable
{
    
   __block BOOL isReachable = YES;
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
                
            case AFNetworkReachabilityStatusNotReachable:{
                
                isReachable = NO;
                NSLog(@"无网络");
                
                break;
                
            }
                
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                
                NSLog(@"WiFi网络");
                
                break;
                
            }
                
            case AFNetworkReachabilityStatusReachableViaWWAN:{
                
                NSLog(@"3G网络");
                
                break;
                
            }
                
            default:
                
                break;
                
        }
        
    }];
    return isReachable;
    
}

#pragma mark - Private
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.userNameTextField.isFirstResponder) {
        [self.userNameTextField resignFirstResponder];
    }
    if (self.passWordTextField.isFirstResponder) {
        [self.passWordTextField resignFirstResponder];
    }

}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}


@end
