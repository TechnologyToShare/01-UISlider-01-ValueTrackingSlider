//
//  ViewController.m
//  ValueTrackingSlider
//
//  Created by Mac on 2019/7/13.
//  Copyright © 2019 Mac. All rights reserved.
//

#import "ViewController.h"
#import "ASValueTrackingSlider.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet ASValueTrackingSlider *slider1;
@property (weak, nonatomic) IBOutlet ASValueTrackingSlider *slider2;
@property (weak, nonatomic) IBOutlet ASValueTrackingSlider *slider3;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setup];
}

- (void)setup {
    
    // customize slider 1
    self.slider1.maximumValue = 2.0;
    
    // customize slider 2
    self.slider2.maximumValue = 255.0;
    [self.slider2 setMaxFractionDigitsDisplayed:0];
    self.slider2.popUpViewColor = [UIColor colorWithHue:0.55 saturation:0.8 brightness:0.9 alpha:0.7];
    self.slider2.font = [UIFont fontWithName:@"Menlo-Bold" size:22];
    self.slider2.textColor = [UIColor colorWithHue:0.55 saturation:1.0 brightness:0.5 alpha:1];
    
    // customize slider 3
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterPercentStyle];
    [self.slider3 setNumberFormatter:formatter];
    self.slider3.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:26];
    self.slider3.popUpViewAnimatedColors = @[[UIColor purpleColor], [UIColor redColor], [UIColor orangeColor]];
}


@end
