//
//  ASValuePopUpView.h
//  ValueTrackingSlider
//
//  Created by Mac on 2019/7/13.
//  Copyright © 2019 Mac. All rights reserved.
//

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// This UIView subclass is used internally by ASValueTrackingSlider
// The public API is declared in ASValueTrackingSlider.h
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ASValuePopUpViewDelegate <NSObject>

- (CGFloat)currentValueOffset; //expects value in the range 0.0 - 1.0
- (void)animationDidStart;

@end

@interface ASValuePopUpView : UIView

@property (nonatomic, weak) id <ASValuePopUpViewDelegate> delegate;

- (UIColor *)color;
- (void)setColor:(UIColor *)color;
- (UIColor *)opaqueColor;

- (void)setTextColor:(UIColor *)textColor;
- (void)setFont:(UIFont *)font;
- (void)setString:(NSString *)string;

- (void)setAnimatedColors:(NSArray *)animatedColors;

- (void)setAnimationOffset:(CGFloat)offset;
- (void)setArrowCenterOffset:(CGFloat)offset;

- (CGSize)popUpSizeForString:(NSString *)string;

- (void)show;
- (void)hide;


@end

NS_ASSUME_NONNULL_END
