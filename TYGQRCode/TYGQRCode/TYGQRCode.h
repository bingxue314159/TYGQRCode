//
//  TYGQRCode.h
//  TYGQRCode
//
//  Created by tanyugang on 15/8/6.
//  Copyright (c) 2015年 tanyugang. All rights reserved.
//

#import <UIKit/UIKit.h>

//纠错级别
typedef NS_ENUM(NSUInteger, TYGQRLevelEnum) {
    TYGQRLevelL,
    TYGQRLevelM,
    TYGQRLevelQ,
    TYGQRLevelH
};

//渐变滤镜
typedef NS_ENUM(NSUInteger, FilterGradientEnum) {
    FilterGradientNone, //无
    FilterGradientLinear,   //线性渐变梯度
    FilterGradientSmoothLinear, //线性渐变梯度
    FilterGradientRadial,   //辐射渐变梯度
    FilterGradientRectWithGaussian, //高斯渐变梯度
};

@interface TYGQRCode : UIView

@property (nonatomic, strong) NSString *qrString;/**< 内容 */
@property (nonatomic, strong) UIColor *qrColor;/**< 二维码颜色(默认:黑色) */
@property (nonatomic, strong) UIColor *qrBackGroundColor;/**< 二维码背景颜色(默认:白色) */
@property (nonatomic, assign) TYGQRLevelEnum qrLevel;/**< 纠错级别(默认:M),L: 7%,M: 15%,Q: 25%,H: 30% */
@property (nonatomic, assign) NSUInteger qrWidth;/**< 宽度(默认:200) */

@property (nonatomic, assign) FilterGradientEnum filterGradient;/**< 渐变梯度 */
@property (nonatomic, strong) UIColor *filterGradientColor0;/**< 渐变颜色(默认:无) */
@property (nonatomic, strong) UIColor *filterGradientColor1;/**< 渐变颜色(默认:无) */

@property (nonatomic, strong, readonly) UIImage *QRCodeImage;/**< 二维码图片 */


/**
 *  以默认值创建二维码
 *  @param qrCodeStr 二维码内容
 *  @param myQRCode  回调
 */
+ (void)createQRCodeWithString:(NSString *)qrCodeStr myQRCode:(void(^)(TYGQRCode *myQRCode,NSError *error))myQRCode NS_AVAILABLE_IOS(7_0);

/**
 *  创建二维码
 *  @param tygQRCode   参数对象
 *  @param myQRCode  回调
 */
+ (void)createQRCode:(TYGQRCode *)tygQRCode myQRCode:(void(^)(TYGQRCode *myQRCode,NSError *error))myQRCode NS_AVAILABLE_IOS(7_0);

@end
