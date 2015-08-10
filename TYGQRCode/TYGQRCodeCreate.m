//
//  TYGQRCodeCreate.m
//  TYGQRCode
//
//  Created by tanyugang on 15/8/6.
//  Copyright (c) 2015年 tanyugang. All rights reserved.
//

#import "TYGQRCodeCreate.h"

@implementation TYGQRCodeCreate

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}


- (instancetype)initWithQRCodeString:(NSString *)string width:(CGFloat)width{
    
    self = [super init];
    if (self) {
        [self initData];
        
        self.qrString = string;
        self.qrWidth = width;
        
        [self createQRCodeImage];
    }
    return self;
}

- (void)initData{
    self.qrString = @"";
    self.qrLevel = @"M";
    self.qrColor = [UIColor blackColor];
    self.qrBackGroundColor = [UIColor whiteColor];
    self.qrWidth = 200;
    
    self.color0 = [UIColor orangeColor];
    self.color1 = [UIColor yellowColor];
}

- (UIImage *)createQRCodeImage{
    //创建一个二维码的滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    
    //设置内容和纠错级别
    NSData *data = [self.qrString dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:self.qrLevel forKey:@"inputCorrectionLevel"];
    CIImage *outputImage0 = [filter outputImage];
    
    //创建一个颜色滤镜,黑白色
    CIFilter *colorFilter = [self filterColorWithCIImage:outputImage0];
//    CIImage *outputImage1 = [colorFilter outputImage];
//    
//    //渐变
//    CIFilter *radialFilter = [self filterRadialGradient];
//    CIImage *outputImage2 = [radialFilter outputImage];
//    
//    //混合滤镜
//    CIFilter *lastFilter = [CIFilter filterWithName:@"CISourceAtopCompositing"];
//    [lastFilter setValue:outputImage2 forKey:kCIInputImageKey];
//    [lastFilter setValue:outputImage1 forKey:kCIInputBackgroundImageKey];
    
    CIImage *outputImage = [colorFilter outputImage];
    
    //返回二维码image
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
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
    
    CIFilter *grand = [CIFilter filterWithName:@"CILinearGradient"];
    [grand setDefaults];
    [grand setValue:[CIVector vectorWithCGPoint:CGPointMake(0, 0)] forKey:@"inputPoint0"];
    [grand setValue:[CIVector vectorWithCGPoint:CGPointMake(self.qrWidth, self.qrWidth)] forKey:@"inputPoint1"];
    
    CIColor *color0 = [CIColor colorWithCGColor:self.color0.CGColor];
    CIColor *color1 = [CIColor colorWithCGColor:self.color1.CGColor];
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
    [grand setValue:[NSNumber numberWithFloat:5] forKey:@"inputRadius0"];
    [grand setValue:[NSNumber numberWithFloat:self.qrWidth/2.0] forKey:@"inputRadius1"];
    [grand setValue:[CIVector vectorWithCGPoint:CGPointMake(self.qrWidth/2.0, self.qrWidth/2.0)] forKey:@"inputCenter"];
    
    CIColor *color0 = [CIColor colorWithCGColor:self.color0.CGColor];
    CIColor *color1 = [CIColor colorWithCGColor:self.color1.CGColor];
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
    
    CIColor *color0 = [CIColor colorWithCGColor:self.color0.CGColor];
    CIColor *color1 = [CIColor colorWithCGColor:self.color1.CGColor];
    [grand setValue:color0 forKey:@"inputColor0"];
    [grand setValue:color1 forKey:@"inputColor1"];
    
    return grand;
}


@end
