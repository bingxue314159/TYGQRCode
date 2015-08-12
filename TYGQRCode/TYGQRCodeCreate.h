//
//  TYGQRCodeCreate.h
//  TYGQRCode
//
//  Created by tanyugang on 15/8/6.
//  Copyright (c) 2015年 tanyugang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, QRLevelEnum) {
    QRLevelL,
    QRLevelM,
    QRLevelQ,
    QRLevelH
};

@interface TYGQRCodeCreate : UIView

@property (nonatomic, strong) NSString *qrString;/**< 内容 */
@property (nonatomic, strong) UIColor *qrColor;/**< 二维码颜色(默认:黑色) */
@property (nonatomic, strong) UIColor *qrBackGroundColor;/**< 二维码背景颜色(默认:白色) */
@property (nonatomic, assign) QRLevelEnum qrLevel;/**< 纠错级别(默认:M),L: 7%,M: 15%,Q: 25%,H: 30% */
@property (nonatomic, assign) CGFloat qrWidth;/**< 宽度(默认:200) */

@property (nonatomic, strong) UIColor *color0;/**< 渐变颜色(默认:无) */
@property (nonatomic, strong) UIColor *color1;/**< 渐变颜色(默认:无) */

@property (nonatomic, strong, readwrite) UIImage *filterImage;
@property (nonatomic, strong, readwrite) UIImage *QRCodeImage;/**< 二维码图片 */

/**
 *  创建二维码图片
 *  @param string 内容
 *  @param width  图片宽度
 *  @return 二维码图片
 */
- (instancetype)initWithQRCodeString:(NSString *)string width:(CGFloat)width;

/**
 *  创建二维码图片
 *  @return 二维码图片
 */
- (UIImage *)createQRCodeImage;

@end
