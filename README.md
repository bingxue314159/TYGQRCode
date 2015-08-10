# TYGQRCode
##功能说明
iOS自带的二维码生成与扫描！可自定义二维码色块颜色及背景色！

##SDK
至少为iOS7

##截图
生成二维码  
![demo](https://github.com/bingxue314159/TYGQRCode/raw/master/TYGQRCode.gif "生成二维码")  


##代码
###生成二维码
```objc
NSString *string = [self.textView text];
//方法一：
TYGQRCodeCreate *tygQRCode2 = [[TYGQRCodeCreate alloc] initWithQRCodeString:string width:250];
self.imageView.image = tygQRCode2.QRCodeImage;
//方法二：
TYGQRCodeCreate *tygQRCode = [[TYGQRCodeCreate alloc] init];
tygQRCode.qrString = string;
tygQRCode.qrWidth = 250;
tygQRCode.qrLevel = [self.levelSeg titleForSegmentAtIndex:self.levelSeg.selectedSegmentIndex];
tygQRCode.qrColor = qrColor;
tygQRCode.qrBackGroundColor = qrBackGroundColor;
self.imageView.image = [tygQRCode createQRCodeImage];
```

###扫描二维码
```objc
TYGQRCodeReaderViewController *read = [[TYGQRCodeReaderViewController alloc] init];
[read successReadQRCode:^(NSString *codeString) {
    NSLog(@"123:::%@",codeString);
}];
[self presentViewController:read animated:YES completion:^{
}];
```


##问题反馈
如果你在使用过程中发现了BUG，你可以这样联系到我：  
Email:bingxue314159#163.com(把#换成@)