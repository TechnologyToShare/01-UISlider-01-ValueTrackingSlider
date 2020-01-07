//
//  ASValueTrackingSlider.m
//  ValueTrackingSlider
//
//  Created by Mac on 2019/7/13.
//  Copyright © 2019 Mac. All rights reserved.
//

#import "ASValueTrackingSlider.h"
#import "ASValuePopUpView.h"

@interface ASValueTrackingSlider ()<ASValuePopUpViewDelegate>

@property (nonatomic, strong) NSNumberFormatter * numberFormatter;
@property (nonatomic, strong) ASValuePopUpView * popUpView;

@end

@implementation ASValueTrackingSlider
{
    CGSize _popUpViewSize;
    UIColor *_popUpViewColor;
}

#pragma mark- initialization

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark- public

- (void)setAutoAdjustTrackColor:(BOOL)autoAdjustTrackColor {
    
    if (_autoAdjustTrackColor == autoAdjustTrackColor) return;
    
    _autoAdjustTrackColor = autoAdjustTrackColor;
    // setMinimumTrackTintColor has been overridden to also set autoAdjustTrackColor to NO
    // therefore super's implementation must be called to set minimumTrackTintColor
    if (autoAdjustTrackColor == NO) {
        super.minimumTrackTintColor = nil; //  sets track to default blue color
    } else {
        super.minimumTrackTintColor = [self.popUpView opaqueColor];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    
    _textColor = textColor;
    [self.popUpView setTextColor:textColor];
}

- (void)setFont:(UIFont *)font {
    
    _font = font;
    [self.popUpView setFont:font];
    
    [self calculatePopUpViewSize];
}

// return the currently displayed color if possible, otherwise return _popUpViewColor
// if animated colors are set, the color will change each time the slider value changes
- (UIColor *)popUpViewColor {
    
    return [self.popUpView color] ?: _popUpViewColor;
}

- (void)setPopUpViewColor:(UIColor *)popUpViewColor {
    
    _popUpViewColor = popUpViewColor;
    _popUpViewAnimatedColors = nil; // animated colors should be discarded
    [self.popUpView setColor:popUpViewColor];
    
    if (_autoAdjustTrackColor) {
        super.minimumTrackTintColor = [self.popUpView opaqueColor];
    }
}

// if only 1 color is present then call 'setPopUpViewColor:'
// if arg is nil then restore previous _popUpViewColor
// otherwise, set animated colors
- (void)setPopUpViewAnimatedColors:(NSArray *)popUpViewAnimatedColors {
    
    _popUpViewAnimatedColors = popUpViewAnimatedColors;
    
    if ([popUpViewAnimatedColors count] >= 2) {
        [self.popUpView setAnimatedColors:popUpViewAnimatedColors];
//        [self.popUpView setAnimatedColors:popUpViewAnimatedColors withOffset:[self currentValueOffset]];
    }else{
        [self setPopUpViewColor:[popUpViewAnimatedColors lastObject] ?: _popUpViewColor];
    }
}

// when either the min/max value or number formatter changes, recalculate the popUpView width
- (void)setMaximumValue:(float)maximumValue {
    
    [super setMaximumValue:maximumValue];
    [self calculatePopUpViewSize];
}

- (void)setMinimumValue:(float)minimumValue {
    
    [super setMinimumValue:minimumValue];
    [self calculatePopUpViewSize];
}

// set max and min digits to same value to keep string length consistent
- (void)setMaxFractionDigitsDisplayed:(NSUInteger)maxDigits {
    
    [self.numberFormatter setMaximumFractionDigits:maxDigits];
    [self.numberFormatter setMinimumFractionDigits:maxDigits];
    [self calculatePopUpViewSize];
}

- (void)setNumberFormatter:(NSNumberFormatter *)numberFormatter {
    
    _numberFormatter = numberFormatter;
    [self calculatePopUpViewSize];
}

#pragma mark- AVValuePopUpViewDelegate

- (void)animationDidStart {
    
    [self autoColorTrack];
}

// returns the current offset of UISlider value in the range 0.0 – 1.0
- (CGFloat)currentValueOffset {
    
    CGFloat valueRange = self.maximumValue - self.minimumValue;
    return (self.value + ABS(self.minimumValue)) / valueRange;
}

#pragma mark- private

- (void)setup {
    
    _autoAdjustTrackColor = YES;
    
    // ensure animation restarts if app is closed then becomes active again
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        if (weakSelf.popUpViewAnimatedColors) {
            [weakSelf.popUpView setAnimatedColors:weakSelf.popUpViewAnimatedColors];
        }
    }];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    [formatter setMaximumFractionDigits:2];
    [formatter setMinimumFractionDigits:2];
    _numberFormatter = formatter;
    
    self.popUpView = [[ASValuePopUpView alloc] initWithFrame:CGRectZero];
    self.popUpViewColor = [UIColor colorWithHue:0.6 saturation:0.6 brightness:0.5 alpha:0.65];
    
    self.popUpView.alpha = 0.0;
    self.popUpView.delegate = self;
    [self addSubview:self.popUpView];
    
    self.textColor = [UIColor whiteColor];
    self.font = [UIFont boldSystemFontOfSize:22.0f];
}

- (void)positionAndUpdatePopUpView {
    
    [self adjustPopUpViewFrame];
    [self.popUpView setString:[_numberFormatter stringFromNumber:@(self.value)]];
    [self.popUpView setAnimationOffset:[self currentValueOffset]];
    
    [self autoColorTrack];
}

- (void)adjustPopUpViewFrame {
    
    CGRect thumbRect = [self thumRect];
    CGFloat thumbW = thumbRect.size.width;
    CGFloat thumbH = thumbRect.size.height;
    
    CGRect popUpRect = CGRectInset(thumbRect, (thumbW - _popUpViewSize.width)/2, (thumbH - _popUpViewSize.height)/2);
    popUpRect.origin.y = thumbRect.origin.y - _popUpViewSize.height;
    
    // determine if popUpRect extends beyond the frame of the UISlider
    // if so adjust frame and set the center offset of the PopUpView's arrow
    CGFloat minOffsetX = CGRectGetMinX(popUpRect);
    CGFloat maxOffsetX = CGRectGetMaxX(popUpRect) - self.bounds.size.width;
    
    CGFloat offset = minOffsetX < 0.0 ? minOffsetX : (maxOffsetX > 0.0 ? maxOffsetX : 0.0);
    popUpRect.origin.x -= offset;
    [self.popUpView setArrowCenterOffset:offset];
    
    self.popUpView.frame = popUpRect;
}

- (void)autoColorTrack {
    
    if (_autoAdjustTrackColor == NO || !_popUpViewAnimatedColors) return;
    
    super.minimumTrackTintColor = [self.popUpView opaqueColor];
}

- (void)calculatePopUpViewSize {
    
    // if the abs of minimumValue is the same or larger than maximumValue, use it to calculate size
    CGFloat value = ABS(self.minimumValue) >= self.maximumValue ? self.minimumValue : self.maximumValue;
    _popUpViewSize = [self.popUpView popUpSizeForString:[_numberFormatter stringFromNumber:@(value)]];
}

- (CGRect)thumRect {
    
    return [self thumbRectForBounds:self.bounds trackRect:[self trackRectForBounds:self.bounds] value:self.value];
}

#pragma mark- subclassed

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
    
    self.autoAdjustTrackColor = NO; // if a custom value is set then prevent auto coloring
    [super setMinimumTrackTintColor:minimumTrackTintColor];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    BOOL begin = [super beginTrackingWithTouch:touch withEvent:event];
    if (begin) {
        [self positionAndUpdatePopUpView];
        [self.popUpView show];
    }
    return begin;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    BOOL continueTrack = [super continueTrackingWithTouch:touch withEvent:event];
    if (continueTrack) [self positionAndUpdatePopUpView];
    return continueTrack;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    
    [super cancelTrackingWithEvent:event];
    [self.popUpView hide];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    [super endTrackingWithTouch:touch withEvent:event];
    [self positionAndUpdatePopUpView];
    [self.popUpView hide];
}

@end
