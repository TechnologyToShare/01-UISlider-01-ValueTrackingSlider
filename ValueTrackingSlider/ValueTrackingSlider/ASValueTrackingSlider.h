//
//  ASValueTrackingSlider.h
//  ValueTrackingSlider
//
//  Created by Mac on 2019/7/13.
//  Copyright © 2019 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASValueTrackingSlider : UISlider

@property (nonatomic, strong) UIColor * textColor;
@property (nonatomic, strong) UIFont * font;

// setting the value of 'popUpViewColor' overrides 'popUpViewAnimatedColors' and vice versa
// the return value of 'popUpViewColor' is the currently displayed value
// this will vary if 'popUpViewAnimatedColors' is set (see below)
@property (nonatomic, strong) UIColor * popUpViewColor;

// pass an array of  2 or more UIColors to animate the color change as the slider moves
@property (nonatomic, strong) NSArray * popUpViewAnimatedColors;

// default is YES
// changes the left handside of the UISlider track to match current popUpView color
// the track color alpha is always set to 1.0, even if popUpView color is less than 1.0
@property (nonatomic) BOOL autoAdjustTrackColor;

// when setting max FractionDigits the min value is automatically set to the same value
// this ensures that the PopUpView frame maintains a consistent width
- (void)setMaxFractionDigitsDisplayed:(NSUInteger)maxDigits;

// take full control of the format dispayed with a custom NSNumberFormatter
- (void)setNumberFormatter:(NSNumberFormatter *)numberFormatter;


@end

NS_ASSUME_NONNULL_END
