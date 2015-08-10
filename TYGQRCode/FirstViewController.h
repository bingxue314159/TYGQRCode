//
//  FirstViewController.h
//  TYGQRCode
//
//  Created by tanyugang on 15/8/6.
//  Copyright (c) 2015年 tanyugang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *levelSeg;

- (IBAction)levelSegValueChanged:(id)sender;//容错级别
- (IBAction)createButton:(id)sender;
- (IBAction)readButton:(id)sender;


- (IBAction)viewClick:(UITapGestureRecognizer *)sender;

@end

