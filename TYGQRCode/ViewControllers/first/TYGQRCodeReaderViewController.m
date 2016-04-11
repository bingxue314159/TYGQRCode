//
//  TYGQRCodeReaderViewController.m
//  TYGQRCode
//
//  Created by tanyugang on 15/8/6.
//  Copyright (c) 2015年 tanyugang. All rights reserved.
//

#import "TYGQRCodeReaderViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "TYGQRCodeReader.h"

@interface TYGQRCodeReaderViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>{
    
    TYGQRCodeReader *reader;
    CGRect scanFrame;//imageView.frame
    
    UIView *anView;
    NSInteger anViewStatus;//-2:向上扫描，-1：向上暂停，1：向下暂停，2：向下扫描

    void(^_successReadQRCode)(NSString *codeString);

}

@end

@implementation TYGQRCodeReaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat screenW = [[UIScreen mainScreen] bounds].size.width;
    scanFrame = CGRectMake((screenW - 220)/2.0, 64, 220, 220);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self starScan];
    [self drawPath];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [reader stopReader];
}

- (void)successReadQRCode:(void(^)(NSString *codeString))successReadQRCode{
    _successReadQRCode = successReadQRCode;
}

- (void)starScan{
    
    reader = [TYGQRCodeReader sharedReader];
    
    [self.imageView updateConstraints];
    [self.imageView layoutIfNeeded];
    
    NSLog(@"imageView.frame = %@",NSStringFromCGRect(self.imageView.frame));
    reader.scanFrame = scanFrame;
    [self starAnimation];
    [reader startReaderOnView:self.view callBack:^(AVMetadataMachineReadableCodeObject *qrCode, NSError *error) {
        
        [reader stopReader];
        [self stopAnimation];
        
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.domain message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
        else{
            if (_successReadQRCode) {
                _successReadQRCode(qrCode.stringValue);
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:qrCode.stringValue message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
        
        
    }];
}

//按钮点击事件
- (IBAction)cancalButton:(id)sender {
    [reader stopReader];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

//绘制遮盖层
- (void)drawPath{
    
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRect:self.view.frame];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:scanFrame];
    
    [clipPath appendPath:maskPath];
    clipPath.usesEvenOddFillRule = YES;
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    maskLayer.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7].CGColor;
    maskLayer.path = [clipPath CGPath];
    
    [self.view.layer addSublayer:maskLayer];
}

//开始动画
- (void)starAnimation{
    
    if (nil == anView) {
        anView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220, 2)];
        anView.backgroundColor = [UIColor redColor];
        [self.imageView addSubview:anView];
        anViewStatus = 2;
    }
    
    if (anViewStatus == 1) {
        anViewStatus = 2;
    }
    else if (anViewStatus == -1){
        anViewStatus = -2;
    }

    [self runAnimation];
}

- (void)runAnimation{
    
    if (anViewStatus == 2 || anViewStatus == -2) {
        
        CGRect newFrame = anView.frame;
        CGFloat maxH = 220;
        
        if (anViewStatus == 2) {
            //向下游动
            CGFloat maxY = CGRectGetMaxY(newFrame);
            if (maxY < maxH) {
                newFrame.origin.y = maxY;
            }
            else{
                anViewStatus = -2;
            }
        }
        else{
            //向上游动
            CGFloat minY = CGRectGetMinY(newFrame);
            if (minY > 0) {
                newFrame.origin.y = minY - 2;
            }
            else{
                anViewStatus = 2;
            }
        }
        
        [UIView animateWithDuration:0.01f animations:^{
            anView.frame = newFrame;
        } completion:^(BOOL finished) {
            [self runAnimation];
        }];
    }
}

//停止动画
- (void)stopAnimation{

    if (anViewStatus == 2) {
        anViewStatus = 1;
    }
    else if (anViewStatus == -2){
        anViewStatus = -1;
    }
}

@end
