//
//  TYGQRCodeReaderViewController.m
//  TYGQRCode
//
//  Created by tanyugang on 15/8/6.
//  Copyright (c) 2015年 tanyugang. All rights reserved.
//

#import "TYGQRCodeReaderViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface TYGQRCodeReaderViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>{
    AVCaptureSession * session;//输入输出的中间桥梁
    AVCaptureVideoPreviewLayer *previewLayer;
    
    void(^_successReadQRCode)(NSString *codeString);
}

@end

@implementation TYGQRCodeReaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    BOOL flag = [self startReading];
    if (!flag) {
        //摄像设备不能用
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"找不到可用的摄像设备" message:@"" delegate:self cancelButtonTitle:@"确定并退出" otherButtonTitles: nil];
        alert.tag = 0;
        [alert show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self stopReading];
}

- (BOOL)startReading{
    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        return NO;
    }
    
    //创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    //设置条形码扫描区域
    output.rectOfInterest=[self imageRectSale];//它的四个值的范围都是0-1，表示比例
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
//    // Create a new serial dispatch queue.
//    dispatch_queue_t dispatchQueue;
//    dispatchQueue = dispatch_queue_create("myQueue", NULL);
//    [output setMetadataObjectsDelegate:self queue:dispatchQueue];
    
    //初始化链接对象
    session = [[AVCaptureSession alloc] init];
    //高质量采集率
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    [session addInput:input];
    [session addOutput:output];
    
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code];
    
    previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = [[UIScreen mainScreen] bounds];
    [self.view.layer insertSublayer:previewLayer atIndex:0];
    
    //开始捕获
    [session startRunning];
    
    return YES;
}

-(void)stopReading{
    if (session) {
        [session stopRunning];
        session = nil;
    }
    
    if (previewLayer) {
        [previewLayer removeFromSuperlayer];
    }
    
}

- (IBAction)cancalButton:(id)sender {
    [self stopReading];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - tool
- (CGRect)imageRectSale{
    CGFloat screenW = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenH = [[UIScreen mainScreen] bounds].size.height;
    
    CGFloat imageW = 220;
    CGFloat imageH = imageW;
    CGFloat imageY = 64;
    CGFloat imageX = (screenW - imageW)/2.0;
    
    CGFloat saleX = imageY/screenH;
    CGFloat saleY = imageX/screenW;
    CGFloat saleW = imageH/screenH;
    CGFloat saleH = imageW/screenW;
    
    return CGRectMake(saleX, saleY, saleW, saleH);
    
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects != nil && metadataObjects.count > 0) {
        [session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        //输出扫描字符串
        if (_successReadQRCode) {
            _successReadQRCode(metadataObject.stringValue);
        }

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:metadataObject.stringValue delegate:self cancelButtonTitle:@"继续扫描" otherButtonTitles:@"确定并退出", nil];
        alert.tag = 1;
        [alert show];
        
    }
}

- (void)successReadQRCode:(void (^)(NSString *))successReadQRCode{
    _successReadQRCode = successReadQRCode;
}

#pragma mark -
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    switch (alertView.tag) {
        case 0:{

            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
            break;
        }
        case 1:{
            switch (buttonIndex) {
                case 0:{
                    [session startRunning];
                    break;
                }
                case 1:{
                    [self stopReading];
                    
                    [self dismissViewControllerAnimated:YES completion:^{
                        
                    }];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    
    
}


@end
