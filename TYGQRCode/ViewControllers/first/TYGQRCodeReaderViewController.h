//
//  TYGQRCodeReaderViewController.h
//  TYGQRCode
//
//  Created by tanyugang on 15/8/6.
//  Copyright (c) 2015年 tanyugang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYGQRCodeReaderViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;


- (void)successReadQRCode:(void(^)(NSString *codeString))successReadQRCode;

@end
