//
//  TYGQRCodeReader.h
//  TYGQRCode
//
//  Created by 谈宇刚 on 16/1/26.
//  Copyright © 2016年 tanyugang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class AVMetadataMachineReadableCodeObject;

@interface TYGQRCodeReader : NSObject

@property (nonatomic,assign) CGRect scanFrame;/**< 设置扫描区域 */

/**
 *  单例
 *  @return self
 */
+ (instancetype)sharedReader;

/**
 *  开始扫描
 *  @param view 视频区域(默认为扫描区域)
 */
- (void)startReaderOnView:(UIView *)view callBack:(void(^)(AVMetadataMachineReadableCodeObject *qrCode,NSError *error))callBack;

/**
 *  停止扫描
 */
- (void)stopReader;

@end
