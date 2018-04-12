//
//  Copyright (c) 2013年 kevinzhow.
//

#import "PNColor.h"
#import <UICountingLabel/UICountingLabel.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, PNChartFormatType) {
    PNChartFormatTypePercent,
    PNChartFormatTypeDollar,
    PNChartFormatTypeNone
};

#define DEGREES_TO_RADIANS(angle) ((angle) / 180 * M_PI)

@interface PNCircleChart : UIView

- (void)strokeChart;
- (void)growChartByAmount:(NSNumber *)growAmount;
- (void)updateChartByCurrent:(NSNumber *)current;
- (void)updateChartByCurrent:(NSNumber *)current byTotal:(NSNumber *)total;
- (instancetype)initWithFrame:(CGRect)frame
              total:(NSNumber *)total
            current:(NSNumber *)current
          clockwise:(BOOL)clockwise;

- (instancetype)initWithFrame:(CGRect)frame
              total:(NSNumber *)total
            current:(NSNumber *)current
          clockwise:(BOOL)clockwise
             shadow:(BOOL)hasBackgroundShadow
        shadowColor:(UIColor *)backgroundShadowColor;

- (instancetype)initWithFrame:(CGRect)frame
              total:(NSNumber *)total
            current:(NSNumber *)current
          clockwise:(BOOL)clockwise
             shadow:(BOOL)hasBackgroundShadow
        shadowColor:(UIColor *)backgroundShadowColor
displayCountingLabel:(BOOL)displayCountingLabel;

- (instancetype)initWithFrame:(CGRect)frame
              total:(NSNumber *)total
            current:(NSNumber *)current
          clockwise:(BOOL)clockwise
             shadow:(BOOL)hasBackgroundShadow
        shadowColor:(UIColor *)backgroundShadowColor
displayCountingLabel:(BOOL)displayCountingLabel
  overrideLineWidth:(NSNumber *)overrideLineWidth;

@property (strong, nonatomic) UICountingLabel *countingLabel;
@property (nonatomic) UIColor *strokeColor;
@property (nonatomic) UIColor *strokeColorGradientStart;
@property (nonatomic) NSNumber *total;
@property (nonatomic) NSNumber *current;
@property (nonatomic) NSNumber *lineWidth;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) PNChartFormatType chartType;

@property (nonatomic) CAShapeLayer *circle;
@property (nonatomic) CAShapeLayer *gradientMask;
@property (nonatomic) CAShapeLayer *circleBackground;

@property (nonatomic) BOOL displayCountingLabel;

@end
