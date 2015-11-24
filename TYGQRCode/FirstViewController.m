//
//  FirstViewController.m
//  TYGQRCode
//
//  Created by tanyugang on 15/8/6.
//  Copyright (c) 2015年 tanyugang. All rights reserved.
//

#import "FirstViewController.h"
#import "TYGQRCodeCreate.h"
#import "TYGQRCodeReaderViewController.h"

@interface FirstViewController (){
    UIColor *qrColor;//二维码颜色(默认:黑色)
    UIColor *qrBackGroundColor;//二维码背景颜色(默认:白色)
}

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    qrColor = [UIColor blackColor];
    qrBackGroundColor = [UIColor whiteColor];
    
    [self createQRCodeWithString:self.textView.text];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (IBAction)createButton:(id)sender {
    
    [self createQRCodeWithString:self.textView.text];
    
}

//扫描二维码
- (IBAction)readButton:(id)sender {
    
    TYGQRCodeReaderViewController *read = [[TYGQRCodeReaderViewController alloc] init];

    [read successReadQRCode:^(NSString *codeString) {
        self.textView.text = codeString;
        [self createQRCodeWithString:codeString];
        
    }];

    [self presentViewController:read animated:YES completion:^{

    }];
}

//颜色变化按钮点击事件
- (IBAction)viewClick:(UITapGestureRecognizer *)sender {
    
    UIView *view = sender.view;
    switch (view.tag) {
        case 0:{
            qrBackGroundColor = [self randomColor];
            view.backgroundColor = qrBackGroundColor;
            break;
        }
        case 1:{
            qrColor = [self randomColor];
            view.backgroundColor = qrColor;
            break;
        }
        default:
            break;
    }
    
    NSString *string = [self.textView text];
    [self createQRCodeWithString:string];
}

//QRCode容错级别
- (IBAction)levelSegValueChanged:(id)sender {
    
    NSString *string = [self.textView text];
    [self createQRCodeWithString:string];
}

//创建QRCode
- (void)createQRCodeWithString:(NSString *)codeString{
    NSString *string = [self.textView text];
    /*
    //方法一：
    TYGQRCodeCreate *tygQRCode2 = [[TYGQRCodeCreate alloc] initWithQRCodeString:string width:250];
    self.imageView.image = tygQRCode2.QRCodeImage;
     */
    
    //方法二：
    TYGQRCodeCreate *tygQRCode = [[TYGQRCodeCreate alloc] init];
    tygQRCode.qrString = string;
    tygQRCode.qrWidth = 250;
    tygQRCode.qrLevel = self.levelSeg.selectedSegmentIndex;
    tygQRCode.qrColor = qrColor;
    tygQRCode.qrBackGroundColor = qrBackGroundColor;
    self.imageView.image = [tygQRCode createQRCodeImage];
     
}


#pragma mark - tool
/**
 *  获取随机颜色
 *  @return 随机颜色
 */
-(UIColor *)randomColor{
    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
    
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}


@end
