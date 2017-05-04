//
//  TYGQRCodeReader.m
//  TYGQRCode
//
//  Created by 谈宇刚 on 16/1/26.
//  Copyright © 2016年 tanyugang. All rights reserved.
//

#import "TYGQRCodeReader.h"
@import AVFoundation;

@interface TYGQRCodeReader ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureMetadataOutput *captureMetadataOutput;
@property (nonatomic, strong) AVCaptureSession *captureSession;

@property (nonatomic, strong) void(^callBack)(AVMetadataMachineReadableCodeObject *qrCode,NSError *error);


@end

@implementation TYGQRCodeReader

+ (instancetype)sharedReader {
    
    static id instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

// =============================================================================
#pragma mark - Private


// =============================================================================
#pragma mark - Public

- (void)startReaderOnView:(UIView *)view callBack:(void (^)(AVMetadataMachineReadableCodeObject *, NSError *))callBack{
    
    _callBack = callBack;
    
    //获取摄像设备
    AVCaptureDevice *captureDevice;
    for (AVCaptureDevice *aCaptureDevice in [AVCaptureDevice devices]) {
        if (aCaptureDevice.position == AVCaptureDevicePositionBack) {
            captureDevice = aCaptureDevice;
        }
    }
    if (!captureDevice) {
        callBack(nil,[NSError errorWithDomain:@"找不到后置摄像头." code:0 userInfo:nil]);
        return;
    }
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusDenied){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"相机权限受限" message:@"请在iPhone的\"设置->隐私->相机\"选项中,允许\"APP\"访问您的相机." delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    //创建输入流
    NSError *error;
    AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (error) {
        callBack(nil,error);
        return;
    }
    
    //初始化链接对象
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;//高质量采集率AVCaptureSessionPreset1920x1080
    //AVCaptureSessionPresetHigh
    if ([self.captureSession canAddInput:captureDeviceInput]) {
        [self.captureSession addInput:captureDeviceInput];
    }
    
    //创建输出流
    self.captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];//设置代理 在主线程里刷新
    
    if ([self.captureSession canAddOutput:self.captureMetadataOutput]) {
        [self.captureSession addOutput:self.captureMetadataOutput];
    }
    
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    self.captureMetadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code];
    
    // Setup preview layer
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;// AVLayerVideoGravityResizeAspect is default.
    captureVideoPreviewLayer.frame = view.bounds;
    
    //[view.layer insertSublayer:captureVideoPreviewLayer atIndex:0];
    [view.layer addSublayer:captureVideoPreviewLayer];
    
    //设置rectOfInterest
    if (!CGRectEqualToRect(CGRectZero, self.scanFrame)) {
        
        /**
         * NG - 此处设置会失效，不建议使用
        CGRect viewBounds = view.bounds;//[UIScreen mainScreen].bounds
        self.captureMetadataOutput.rectOfInterest = [self imageRectSale:self.scanFrame readerViewBounds:viewBounds];//设置条形码扫描区域，它的四个值的范围都是0-1，表示比例
        */
        __weak typeof(self) weakSelf = self;
        [[NSNotificationCenter defaultCenter]addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            
            __strong __typeof(self) strongSelf = weakSelf;
//            AVCaptureMetadataOutput *output = strongSelf.captureSession.outputs.firstObject;
//            output.rectOfInterest = [captureVideoPreviewLayer metadataOutputRectOfInterestForRect:strongSelf.scanFrame];
            
            strongSelf.captureMetadataOutput.rectOfInterest = [captureVideoPreviewLayer metadataOutputRectOfInterestForRect:strongSelf.scanFrame];
        }];
    }
    else{
        callBack(nil,[NSError errorWithDomain:@"未设置扫描区域" code:0 userInfo:nil]);
        return;
    }
    
    

    //开始捕获
    [self.captureSession startRunning];
}

//停止扫描
- (void)stopReader {
    
    if (self.captureSession) {
        [self.captureSession stopRunning];
    }
}

#pragma mark - tool
/**
 计算扫描框尺寸(扫描区域的比例关系)

 @param viewFrame 扫描区域frame
 @param readerViewBounds 所在图层bounds
 @return CGRect
 */
- (CGRect)imageRectSale:(CGRect)viewFrame readerViewBounds:(CGRect)readerViewBounds{
    //原理见http://www.cocoachina.com/ios/20141225/10763.html
    CGFloat screenW = CGRectGetWidth(readerViewBounds);
    CGFloat screenH = CGRectGetHeight(readerViewBounds);
    
    CGFloat imageW = CGRectGetWidth(viewFrame);
    CGFloat imageH = CGRectGetHeight(viewFrame);
    CGFloat imageY = CGRectGetMinY(viewFrame);
    CGFloat imageX = CGRectGetMinX(viewFrame);
    
    CGFloat saleX = imageY/screenH;
    CGFloat saleY = imageX/screenW;
    CGFloat saleW = imageH/screenH;
    CGFloat saleH = imageW/screenW;
    
    CGRect lastRect = CGRectMake(saleX, saleY, saleW, saleH);

    
    return lastRect;
}

// =============================================================================
#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection{
    
    for (AVMetadataObject *metadataObject in metadataObjects) {
        
        if (![metadataObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            continue;
        }
        
        AVMetadataMachineReadableCodeObject *machineReadableCode = (AVMetadataMachineReadableCodeObject *)metadataObject;
        
        if (_callBack) {
            _callBack(machineReadableCode,nil);
        }
    }
    
}

/**
 *  从照片中直接识别二维码
 *  @param qrCodeImage 带二维码的图片
 *  @param myQRCode    回调
 */
+ (void)readQRCodeFromImage:(UIImage *)qrCodeImage myQRCode:(void(^)(CIQRCodeFeature *qrCode,NSError *error))myQRCode NS_AVAILABLE_IOS(8_0){
    
    UIImage * srcImage = qrCodeImage;
    if (nil == srcImage) {
        myQRCode(nil,[NSError errorWithDomain:@"未传入图片" code:0 userInfo:nil]);
        return;
    }
    
    CIContext *context = [CIContext contextWithOptions:nil];
    //初始化一个监测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    //识别
    CIImage *image = [CIImage imageWithCGImage:srcImage.CGImage];
    NSArray *features = [detector featuresInImage:image];
    if (features.count > 0) {
        CIQRCodeFeature *feature = [features firstObject];
        
        myQRCode(feature,nil);
    }
    else{
        myQRCode(nil,[NSError errorWithDomain:@"未能识别出二维码" code:0 userInfo:nil]);
        return;
    }
    
}

@end
