//
//  TYGQRCode.m
//  TYGQRCode
//
//  Created by tanyugang on 15/8/6.
//  Copyright (c) 2015年 tanyugang. All rights reserved.
//

#import "TYGQRCode.h"

@implementation TYGQRCode{
    NSString *qrLevelStr;
    
    TYGQRCode *actionQRCode;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

- (void)initData{
    
    self.backgroundColor = [UIColor whiteColor];
    self.qrString = @"";
    self.qrLevel = TYGQRLevelM;
    self.qrColor = [UIColor blackColor];
    self.qrBackGroundColor = [UIColor whiteColor];
    self.qrWidth = 200;
    
    self.filterGradientColor0 = [UIColor orangeColor];//梯度
    self.filterGradientColor1 = [UIColor redColor];
}

- (UIImage *)createQRCodeImage{
    //创建一个二维码的滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    
    //设置内容和纠错级别
    NSData *data = [self.qrString dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:qrLevelStr forKey:@"inputCorrectionLevel"];
    CIImage *outputImage0 = [filter outputImage];
    
    //滤镜
    CIImage *filterOutputImage;//其它滤镜得出的结果
    switch (self.filterGradient) {
        case FilterGradientNone: {
            //无
            break;
        }
        case FilterGradientLinear: {
            //线性梯度
            CIFilter *radialFilter = [self filterLinearGradient];
            filterOutputImage = [radialFilter outputImage];

            break;
        }
        case FilterGradientSmoothLinear:{
            //线性梯度2
            CIFilter *radialFilter = [self filterSmoothLinearGradient];
            filterOutputImage = [radialFilter outputImage];
            break;
        }
        case FilterGradientRadial: {
            //半径梯度
            CIFilter *radialFilter = [self filterRadialGradient];
            filterOutputImage = [radialFilter outputImage];
            break;
        }
        case FilterGradientRectWithGaussian: {
            CIFilter *radialFilter = [self filterRectWithGaussianGradient];
            filterOutputImage = [radialFilter outputImage];
            //高斯梯度
            break;
        }
        default: {
            break;
        }
    }
    
    //创建一个颜色滤镜
    CIFilter *colorFilter = [self filterColorWithCIImage:outputImage0];
    CIImage *colorOutputImage = [colorFilter outputImage];
    
    CIImage *outputImage;
    if (filterOutputImage) {
        //混合滤镜，CILightenBlendMode,CIMaximumCompositing,CIScreenBlendMode

        CIFilter *lastFilter = [CIFilter filterWithName:@"CIMaximumCompositing"];//CISourceAtopCompositing
        [lastFilter setDefaults];
        [lastFilter setValue:filterOutputImage forKey:@"inputImage"];
        [lastFilter setValue:colorOutputImage forKey:@"inputBackgroundImage"];
        
        outputImage = [lastFilter outputImage];
    }
    else{
        outputImage = colorOutputImage;
    }
    
    //返回二维码image
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[colorOutputImage extent]];
    
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationUp];

    //不失真的放大
    UIImage *resized = [self resizeImage:image
                             withQuality:kCGInterpolationNone
                                    rate:5.0];
    // 缩放到固定的宽度(高度与宽度一致)
    _QRCodeImage = [self scaleWithFixedWidth:self.qrWidth image:resized];
    
    CGImageRelease(cgImage);
    
    return _QRCodeImage;
}

- (void)setQrLevel:(TYGQRLevelEnum)qrLevel{
    _qrLevel = qrLevel;
    switch (_qrLevel) {
        case TYGQRLevelM:{
            qrLevelStr = @"M";
            break;
        }
        case TYGQRLevelH:{
            qrLevelStr = @"H";
            break;
        }
        case TYGQRLevelL:{
            qrLevelStr = @"L";
            break;
        }
        case TYGQRLevelQ:{
            qrLevelStr = @"Q";
            break;
        }
        default:
            break;
    }
}

#pragma mark - tools
/**
 *  缩放到固定的宽度(高度与宽度一致)
 *  @param width 宽度
 *  @param image 要缩放的图片
 *  @return 缩放后的图片
 */
- (UIImage *)scaleWithFixedWidth:(CGFloat)width image:(UIImage *)image{
    float newHeight = image.size.height * (width / image.size.width);
    CGSize size = CGSizeMake(width, newHeight);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
    
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageOut;
}

/**
 *  不失真放大图片
 *  @param image   要放大的图片
 *  @param quality
 *  @param rate    放大比例
 *  @return 放大后的图片
 */
- (UIImage *)resizeImage:(UIImage *)image
             withQuality:(CGInterpolationQuality)quality
                    rate:(CGFloat)rate{
    UIImage *resized = nil;
    CGFloat width = image.size.width * rate;
    CGFloat height = image.size.height * rate;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, quality);//背景内置颜色质量等级
    [image drawInRect:CGRectMake(0, 0, width, height)];
    resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resized;
}

#pragma mark - 滤镜
/**
 *  设置二维码颜色及背景色
 */
- (CIFilter *)filterColorWithCIImage:(CIImage *)image{
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"];
    [colorFilter setDefaults];
    [colorFilter setValue:image forKey:@"inputImage"];
    
    CIColor *color0 = [CIColor colorWithCGColor:self.qrColor.CGColor];
    CIColor *color1 = [CIColor colorWithCGColor:self.qrBackGroundColor.CGColor];
    [colorFilter setValue:color0 forKey:@"inputColor0"];
    [colorFilter setValue:color1 forKey:@"inputColor1"];
    
    return colorFilter;
}

#pragma mark - 渐变滤镜
/**
 *  线性梯度
 */
-(CIFilter *)filterLinearGradient{
    
    /*
     [Linear Gradient] CILinearGradient
     inputPoint1 : {
     CIAttributeClass = CIVector;
     CIAttributeDefault = "[200 200]";
     CIAttributeType = CIAttributeTypePosition;
     }
     
     inputPoint0 : {
     CIAttributeClass = CIVector;
     CIAttributeDefault = "[0 0]";
     CIAttributeType = CIAttributeTypePosition;
     }
     
     inputColor1 : {
     CIAttributeClass = CIColor;
     CIAttributeDefault = "(0 0 0 1)";
     }
     
     inputColor0 : {
     CIAttributeClass = CIColor;
     CIAttributeDefault = "(1 1 1 1)";
     }
     */
    
//   还有 CISmoothLinearGradient
    CIFilter *grand = [CIFilter filterWithName:@"CILinearGradient"];
    [grand setDefaults];
    [grand setValue:[CIVector vectorWithCGPoint:CGPointMake(0, 0)] forKey:@"inputPoint0"];
    [grand setValue:[CIVector vectorWithCGPoint:CGPointMake(self.qrWidth, self.qrWidth)] forKey:@"inputPoint1"];
    
    CIColor *color0 = [CIColor colorWithCGColor:self.filterGradientColor0.CGColor];
    CIColor *color1 = [CIColor colorWithCGColor:self.filterGradientColor1.CGColor];
    [grand setValue:color0 forKey:@"inputColor0"];
    [grand setValue:color1 forKey:@"inputColor1"];
    
    return grand;
}

/**
 *  线性梯度2
 */
-(CIFilter *)filterSmoothLinearGradient{
    
    /*
     [Linear Gradient] CILinearGradient
     inputPoint1 : {
     CIAttributeClass = CIVector;
     CIAttributeDefault = "[200 200]";
     CIAttributeType = CIAttributeTypePosition;
     }
     
     inputPoint0 : {
     CIAttributeClass = CIVector;
     CIAttributeDefault = "[0 0]";
     CIAttributeType = CIAttributeTypePosition;
     }
     
     inputColor1 : {
     CIAttributeClass = CIColor;
     CIAttributeDefault = "(0 0 0 1)";
     }
     
     inputColor0 : {
     CIAttributeClass = CIColor;
     CIAttributeDefault = "(1 1 1 1)";
     }
     */
    
    //   还有 CISmoothLinearGradient
    CIFilter *grand = [CIFilter filterWithName:@"CISmoothLinearGradient"];
    [grand setDefaults];
    [grand setValue:[CIVector vectorWithCGPoint:CGPointMake(0, 0)] forKey:@"inputPoint0"];
    [grand setValue:[CIVector vectorWithCGPoint:CGPointMake(self.qrWidth, self.qrWidth)] forKey:@"inputPoint1"];
    
    CIColor *color0 = [CIColor colorWithCGColor:self.filterGradientColor0.CGColor];
    CIColor *color1 = [CIColor colorWithCGColor:self.filterGradientColor1.CGColor];
    [grand setValue:color0 forKey:@"inputColor0"];
    [grand setValue:color1 forKey:@"inputColor1"];
    
    return grand;
}

/**
 *  半径梯度
 */
-(CIFilter *)filterRadialGradient{
    /*
     [Radial Gradient] CIRadialGradient
     
     inputRadius0 : {
     CIAttributeClass = NSNumber;
     CIAttributeDefault = 5;
     CIAttributeMin = 0;
     CIAttributeSliderMax = 800;
     CIAttributeSliderMin = 0;
     CIAttributeType = CIAttributeTypeDistance;
     }
     
     inputRadius1 : {
     CIAttributeClass = NSNumber;
     CIAttributeDefault = 100;
     CIAttributeMin = 0;
     CIAttributeSliderMax = 800;
     CIAttributeSliderMin = 0;
     CIAttributeType = CIAttributeTypeDistance;
     }
     
     inputColor1 : {
     CIAttributeClass = CIColor;
     CIAttributeDefault = "(0 0 0 1)";
     }
     
     inputCenter : {
     CIAttributeClass = CIVector;
     CIAttributeDefault = "[150 150]";
     CIAttributeType = CIAttributeTypePosition;
     }
     
     inputColor0 : {
     CIAttributeClass = CIColor;
     CIAttributeDefault = "(1 1 1 1)";
     }
     

     */
    
    CIFilter *grand = [CIFilter filterWithName:@"CIRadialGradient"];
    [grand setDefaults];
    [grand setValue:[NSNumber numberWithFloat:5.0] forKey:@"inputRadius0"];
    [grand setValue:[NSNumber numberWithFloat:self.qrWidth/2.0] forKey:@"inputRadius1"];
    [grand setValue:[CIVector vectorWithCGPoint:CGPointMake(self.qrWidth/2.0, self.qrWidth/2.0)] forKey:@"inputCenter"];
    
    CIColor *color0 = [CIColor colorWithCGColor:self.filterGradientColor0.CGColor];
    CIColor *color1 = [CIColor colorWithCGColor:self.filterGradientColor1.CGColor];
    [grand setValue:color0 forKey:@"inputColor0"];
    [grand setValue:color1 forKey:@"inputColor1"];
    
    return grand;
}

/**
 *  高斯梯度
 */
-(CIFilter *)filterRectWithGaussianGradient{
    /*
     [Gaussian Gradient] CIGaussianGradient
     
     inputRadius : {
     CIAttributeClass = NSNumber;
     CIAttributeDefault = 300;
     CIAttributeMin = 0;
     CIAttributeSliderMax = 800;
     CIAttributeSliderMin = 0;
     CIAttributeType = CIAttributeTypeDistance;
     }
     
     inputColor1 : {
     CIAttributeClass = CIColor;
     CIAttributeDefault = "(0 0 0 0)";
     }
     
     inputCenter : {
     CIAttributeClass = CIVector;
     CIAttributeDefault = "[150 150]";
     CIAttributeType = CIAttributeTypePosition;
     }
     
     inputColor0 : {
     CIAttributeClass = CIColor;
     CIAttributeDefault = "(1 1 1 1)";
     }
     
     */
    
    CIFilter *grand = [CIFilter filterWithName:@"CIGaussianGradient"];
    [grand setDefaults];

    [grand setValue:[NSNumber numberWithFloat:self.qrWidth/2.0] forKey:@"inputRadius"];
    [grand setValue:[CIVector vectorWithCGPoint:CGPointMake(self.qrWidth/2.0, self.qrWidth/2.0)] forKey:@"inputCenter"];
    
    CIColor *color0 = [CIColor colorWithCGColor:self.filterGradientColor0.CGColor];
    CIColor *color1 = [CIColor colorWithCGColor:self.filterGradientColor1.CGColor];
    [grand setValue:color0 forKey:@"inputColor0"];
    [grand setValue:color1 forKey:@"inputColor1"];
    
    return grand;
}


#pragma mark - 对外开发的方法
/**
 *  创建二维码
 *  @param qrCodeStr 二维码内容
 *  @param myQRCode  回调
 */
+ (void)createQRCodeWithString:(NSString *)qrCodeStr myQRCode:(void(^)(TYGQRCode *myQRCode,NSError *error))myQRCode NS_AVAILABLE_IOS(7_0){
    
    TYGQRCode *qrCode = [[TYGQRCode alloc] init];
    qrCode.qrString = qrCodeStr;
    
    if (qrCode.qrString.length == 0) {
        myQRCode(qrCode,[NSError errorWithDomain:@"内容为空" code:0 userInfo:nil]);
        return;
    }
    
    [qrCode createQRCodeImage];
    
    myQRCode(qrCode,nil);
}

/**
 *  创建二维码
 *  @param tygQRCode   参数对象
 *  @param QRCode      生成的二维码对象
 */
+ (void)createQRCode:(TYGQRCode *)tygQRCode myQRCode:(void(^)(TYGQRCode *myQRCode,NSError *error))myQRCode{
    if (nil == tygQRCode) {
        myQRCode(tygQRCode,[NSError errorWithDomain:@"参数为空" code:0 userInfo:nil]);
        return;
    }
    else if (tygQRCode.qrString.length == 0) {
        myQRCode(tygQRCode,[NSError errorWithDomain:@"内容为空" code:0 userInfo:nil]);
        return;
    }
    
    [tygQRCode createQRCodeImage];
    
    myQRCode(tygQRCode,nil);
}

@end
