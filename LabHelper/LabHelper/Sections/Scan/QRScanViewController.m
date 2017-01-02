//
//  QRScanViewController.m
//  LabHelper
//
//  Created by ljc on 2016/11/19.
//  Copyright © 2016年 meitu. All rights reserved.
//

#import "QRScanViewController.h"
#import "QRScanView.h"
#import "HomeViewController.h"
#import "ClientModel.h"
#import "ClientInfoModel.h"

#define kScanViewWith         200.f
#define kScanViewHeight       200.f


@import AVFoundation;

@interface QRScanViewController () <AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) CGRect scanRect;
@property (nonatomic, assign) BOOL isQRCodeCaptured;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) ClientInfoModel *infoModel;

@end

@implementation QRScanViewController

#pragma mark -lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Actions

- (IBAction)pickAction:(UIBarButtonItem *)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - Setup

- (void)setup {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authorizationStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler: ^(BOOL granted) {
                if (granted) {
                    [self setupCapture];
                } else {
                    NSLog(@"%@", @"访问受限");
                }
            }];
            break;
        }
            
        case AVAuthorizationStatusAuthorized: {
            [self setupCapture];
            break;
        }
            
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied: {
            NSLog(@"%@", @"访问受限");
            break;
        }
            
        default: {
            break;
        }
    }
    
    self.scanRect = CGRectMake((kScreenWidth - kScanViewWith)/2, (kScreenHeight - kScanViewHeight)/2, kScanViewWith, kScanViewHeight);
}

- (void)showHUDWithMessage:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = message;
}

- (void)setupCapture {
    [self showHUDWithMessage:@"相机准备中..."];
    dispatch_async(dispatch_get_main_queue(), ^{
        AVCaptureSession *session = [[AVCaptureSession alloc] init];
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error;
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (deviceInput) {
            [session addInput:deviceInput];
            
            AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
            [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
            [session addOutput:metadataOutput];
            metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
            
            AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            previewLayer.frame = self.view.frame;
            [self.view.layer insertSublayer:previewLayer atIndex:0];
            
            __weak typeof(self) weakSelf = self;
            [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification
                                                              object:nil
                                                               queue:[NSOperationQueue currentQueue]
                                                          usingBlock: ^(NSNotification *_Nonnull note) {
                                                              metadataOutput.rectOfInterest = [previewLayer metadataOutputRectOfInterestForRect:weakSelf.scanRect];                                                           }];
            
            QRScanView *scanView = [[QRScanView alloc] initWithScanRect:self.scanRect];
            [self.view addSubview:scanView];
            
            [session startRunning];
            [self.hud hideAnimated:YES];
        } else {
            NSLog(@"%@", error);
        }
    });
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
    if ([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode] && !self.isQRCodeCaptured) {
        [self showAlertViewWithMessage:metadataObject.stringValue];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy:CIDetectorAccuracyHigh }];
    CIImage *image = [[CIImage alloc] initWithImage:originalImage];
    NSArray *features = [detector featuresInImage:image];
    CIQRCodeFeature *feature = [features firstObject];
    if (feature) {
        [self showAlertViewWithMessage:feature.messageString];
        [picker dismissViewControllerAnimated:YES completion:nil];
    } else {
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.isQRCodeCaptured = NO;
}

#pragma mark - Private Methods

- (void)jumpToGuestDetailVCWithCiid:(NSString *)ciid {
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[HomeViewController class]]) {
            [self.navigationController popToViewController:vc animated:NO];
            HomeViewController *homeVC = (HomeViewController *)vc;
            [homeVC refreshData];
            ClientModel *model = [[ClientModel alloc] initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:ciid,@"CiId",self.infoModel.ciname,@"CiName", nil]];
            self.isQRCodeCaptured = YES;
            [homeVC performSegueWithIdentifier:@"showCustomDetail" sender:model];
            return ;
        }
    }
}
- (void)showAlertViewControllerWithCiid:(NSString *)ciid {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"新用户你好！" message:@"输入用户名和手机号" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"请输入用户名";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"请输入手机号";
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *nameTF = alertController.textFields.firstObject;
        UITextField *phoneNumberTF = alertController.textFields.lastObject;
        if (nameTF.text != nil  && phoneNumberTF.text != nil) {
            [self uploadName:nameTF.text phoneNumber:phoneNumberTF.text ciid:ciid];
        }
    }];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.isQRCodeCaptured = NO;
    }];
    [alertController addAction:okAction];
    [alertController addAction:cancle];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)uploadName:(NSString *)clientName phoneNumber:(NSString *)number ciid:(NSString *)ciid {
    NSUserDefaults *uts = [NSUserDefaults standardUserDefaults];
    NSDictionary *paramDic = [NSDictionary dictionaryWithObjectsAndKeys:[uts objectForKey:KUserID], @"userid", [uts objectForKey:KToken], @"token", ciid, @"ciid",clientName,@"ciname",number,@"ciphone",nil];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:KUploadGuestInfo parameters:paramDic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"上传成功");
        [self jumpToGuestDetailVCWithCiid:ciid];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"上传失败");
    }];
}

- (void)showAlertViewWithMessage:(NSString *)ciid {
    self.isQRCodeCaptured = YES;
    NSUserDefaults *uts = [NSUserDefaults standardUserDefaults];
    NSDictionary *paramDic = [NSDictionary dictionaryWithObjectsAndKeys:[uts objectForKey:KUserID], @"userid", [uts objectForKey:KToken], @"token", ciid, @"ciid", nil];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSLog(@"请求请求请求================");
    [manager GET:KGetGuestInfoAddress parameters:paramDic progress:^(NSProgress * _Nonnull downloadProgress) {
        
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = responseObject;
        self.infoModel = [[ClientInfoModel alloc] initWithDictionary:dic];
        NSLog(@"进入进入进入");
        switch (self.infoModel.isNewClient) {
            case 0://无此用户
                  {
                      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"无此用户" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                      alertView.delegate = self;
                     
                      [alertView show];
                  }
                break;
            case 1://新用户
                [self showAlertViewControllerWithCiid:ciid];
                [self jumpToGuestDetailVCWithCiid:ciid];
                break;
            case 2://老用户
                 [self jumpToGuestDetailVCWithCiid:ciid];
            default:
                break;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}
@end
