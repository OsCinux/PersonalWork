//
//  LoginInViewController.m
//  LabHelper
//
//  Created by ljc on 2016/11/5.
//  Copyright © 2016年 meitu. All rights reserved.
//

#import "LoginInViewController.h"
#import <AFNetworking.h>


typedef NS_ENUM(NSInteger,NSLoginState) {
         NSLoginStateSuccess      = 0,
         NSLoginStateFailed       = 1,
         NSLoginStateNetworkError = 2
};

typedef void(^loginCompleteHandler)(BOOL reslut,NSString *description);

@interface LoginInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passWordTextField;

@end

@implementation LoginInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Acions
- (IBAction)ActionLogin:(id)sender {
    
    [self loginWithUserName:self.userNameTextField.text Password:self.passWordTextField.text complete:^(BOOL reslut,NSString *description) {
        
        NSLog(@"%@",description);
    }];
    
}

- (void)loginWithUserName:(NSString*)userName Password:(NSString *)password complete:(loginCompleteHandler)completeHandle {
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@"https://202.115.207.95:8080/appService.ashx?password=123&username=cyd"];
    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@",error);
        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    [task resume];

    
//    NSDictionary *paramDic = [NSDictionary dictionaryWithObjectsAndKeys:userName,@"username",password,@"password", nil];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//        [manager GET:KLoginAddres parameters:paramDic progress:^(NSProgress * _Nonnull downloadProgress) {
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSDictionary *dic = responseObject;
//        completeHandle(dic[@"Result"],dic[@"Remark"]);
//        NSLog(@"数据返回成功");
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"%@",error);
//    }];
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
