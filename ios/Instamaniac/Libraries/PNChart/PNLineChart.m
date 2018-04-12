//
//  Copyright (c) 2013年 kevinzhow.
//

#import "PNLineChart.h"
#import "PNColor.h"
#import "PNChartLabel.h"
#import "PNLineChartData.h"
#import "PNLineChartDataItem.h"
#import <CoreText/CoreText.h>

@interface PNLineChart ()

@property (nonatomic) NSMutableArray *chartLineArray;  // Array[CAShapeLayer]
@property (nonatomic) NSMutableArray *chartPointArray; // Array[CAShapeLayer] save the point layer

@property (nonatomic) NSMutableArray *chartPath;       // Array of line path, one for each line.
@property (nonatomic) NSMutableArray *pointPath;       // Array of point path, one for each line
@property (nonatomic) NSMutableArray *endPointsOfPath;      // Array of start and end points of each line path, one for each line

// display grade
@property (nonatomic) NSMutableArray *gradeStringPaths;

@end

@implementation PNLineChart

#pragma mark initialization

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (!self) return nil;
    
    [self setupDefaultValues];

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    [self setupDefaultValues];
    
    return self;
}

#pragma mark instance methods

- (void)setYLabels {
    CGFloat yStep = (_yValueMax - _yValueMin) / _yLabelNum;
    CGFloat yStepHeight = _chartCavanHeight / _yLabelNum;

    if (_yChartLabels) {
        for (PNChartLabel * label in _yChartLabels) {
            [label removeFromSuperview];
        }
    } else {
        _yChartLabels = [NSMutableArray new];
    }

    if (yStep == 0) {
        PNChartLabel *minLabel = [[PNChartLabel alloc] initWithFrame:CGRectMake(0, (NSInteger)_chartCavanHeight, (NSInteger)_chartMargin, (NSInteger)_yLabelHeight)];
        minLabel.text = [self formatYLabel:0];
        [self setCustomStyleForYLabel:minLabel];
        [self addSubview:minLabel];
        [_yChartLabels addObject:minLabel];

        PNChartLabel *midLabel = [[PNChartLabel alloc] initWithFrame:CGRectMake(0, (NSInteger)(_chartCavanHeight / 2), (NSInteger)_chartMargin, (NSInteger)_yLabelHeight)];
        midLabel.text = [self formatYLabel:_yValueMax];
        [self setCustomStyleForYLabel:midLabel];
        [self addSubview:midLabel];
        [_yChartLabels addObject:midLabel];

        PNChartLabel *maxLabel = [[PNChartLabel alloc] initWithFrame:CGRectMake(0, 0, (NSInteger)_chartMargin, (NSInteger)_yLabelHeight)];
        maxLabel.text = [self formatYLabel:_yValueMax * 2];
        [self setCustomStyleForYLabel:maxLabel];
        [self addSubview:maxLabel];
        [_yChartLabels addObject:maxLabel];
    } else {
        NSInteger index = 0;
        NSInteger num = _yLabelNum + 1;

        while (num > 0) {
            PNChartLabel *label = [[PNChartLabel alloc] initWithFrame:CGRectMake(0, (NSInteger)(_chartCavanHeight - index * yStepHeight), (NSInteger)_chartMargin, (NSInteger)_yLabelHeight)];
            [label setTextAlignment:NSTextAlignmentRight];
            label.text = [self formatYLabel:_yValueMin + (yStep * index)];
            [self setCustomStyleForYLabel:label];
            [self addSubview:label];
            [_yChartLabels addObject:label];
            index += 1;
            num -= 1;
        }
    }
}

- (void)setYLabels:(NSArray *)yLabels {
    _showGenYLabels = NO;
    _yLabelNum = (NSInteger)(yLabels.count - 1);
    
    CGFloat yLabelHeight;
    if (_showLabel) {
        yLabelHeight = _chartCavanHeight / [yLabels count];
    } else {
        yLabelHeight = (self.frame.size.height) / [yLabels count];
    }
    
    return [self setYLabels:yLabels withHeight:yLabelHeight];
}

- (void)setYLabels:(NSArray *)yLabels withHeight:(CGFloat)height {
    _yLabels = yLabels;
    _yLabelHeight = height;
    if (_yChartLabels) {
        for (PNChartLabel * label in _yChartLabels) {
            [label removeFromSuperview];
        }
    } else {
        _yChartLabels = [NSMutableArray new];
    }
    
    NSString *labelText;
    
    if (_showLabel) {
        CGFloat yStepHeight = _chartCavanHeight / _yLabelNum;
        
        for (NSUInteger index = 0; index < yLabels.count; index++) {
            labelText = yLabels[index];
            
            NSInteger y = (NSInteger)(_chartCavanHeight - index * yStepHeight);
            
            PNChartLabel *label = [[PNChartLabel alloc] initWithFrame:CGRectMake(0, y, (NSInteger)_chartMargin, (NSInteger)_yLabelHeight)];
            [label setTextAlignment:NSTextAlignmentRight];
            label.text = labelText;
            [self setCustomStyleForYLabel:label];
            [self addSubview:label];
            [_yChartLabels addObject:label];
        }
    }
}

- (CGFloat)computeEqualWidthForXLabels:(NSArray *)xLabels {
    CGFloat xLabelWidth;

    if (_showLabel) {
        xLabelWidth = _chartCavanWidth / [xLabels count];
    } else {
        xLabelWidth = (self.frame.size.width) / [xLabels count];
    }

    return xLabelWidth;
}


- (void)setXLabels:(NSArray *)xLabels {
    CGFloat xLabelWidth;

    if (_showLabel) {
        xLabelWidth = _chartCavanWidth / [xLabels count];
    } else {
        xLabelWidth = (self.frame.size.width) / [xLabels count];
    }

    return [self setXLabels:xLabels withWidth:xLabelWidth];
}

- (void)setXLabels:(NSArray *)xLabels withWidth:(CGFloat)width {
    _xLabels = xLabels;
    _xLabelWidth = width;
    if (_xChartLabels) {
        for (PNChartLabel * label in _xChartLabels) {
            [label removeFromSuperview];
        }
    } else {
        _xChartLabels = [NSMutableArray new];
    }
    
    NSString *labelText;

    if (_showLabel) {
        for (NSUInteger index = 0; index < xLabels.count; index++) {
            labelText = xLabels[index];

            NSInteger x = (NSInteger)(2 * _chartMargin +  (index * _xLabelWidth) - (_xLabelWidth / 2));
            NSInteger y = (NSInteger)(_chartMargin + _chartCavanHeight);

            PNChartLabel *label = [[PNChartLabel alloc] initWithFrame:CGRectMake(x, y, (NSInteger)_xLabelWidth, (NSInteger)_chartMargin)];
            [label setTextAlignment:NSTextAlignmentCenter];
            label.text = labelText;
            [self setCustomStyleForXLabel:label];
            [self addSubview:label];
            [_xChartLabels addObject:label];
        }
    }
}

- (void)setCustomStyleForXLabel:(UILabel *)label {
    if (_xLabelFont) {
        label.font = _xLabelFont;
    }

    if (_xLabelColor) {
        label.textColor = _xLabelColor;
    }
}

- (void)setCustomStyleForYLabel:(UILabel *)label {
    if (_yLabelFont) {
        label.font = _yLabelFont;
    }

    if (_yLabelColor) {
        label.textColor = _yLabelColor;
    }
}

#pragma mark - Touch at point

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchPoint:touches withEvent:event];
    [self touchKeyPoint:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchPoint:touches withEvent:event];
    [self touchKeyPoint:touches withEvent:event];
}

- (void)touchPoint:(NSSet *)touches withEvent:(UIEvent *)event {
    // Get the point user touched
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];

    for (NSInteger p = (NSInteger)(_pathPoints.count - 1); p >= 0; p--) {
        NSArray *linePointsArray = _endPointsOfPath[(NSUInteger)p];

        for (NSUInteger i = 0; i < linePointsArray.count - 1; i += 2) {
            CGPoint p1 = [linePointsArray[i] CGPointValue];
            CGPoint p2 = [linePointsArray[i + 1] CGPointValue];

            // Closest distance from point to line
            CGFloat distance = (CGFloat)fabs((double)(((p2.x - p1.x) * (touchPoint.y - p1.y)) - ((p1.x - touchPoint.x) * (p1.y - p2.y))));
            distance /= hypot((double)(p2.x - p1.x), (CGFloat)(p1.y - p2.y));

            if (distance <= 5) {
                // Conform to delegate parameters, figure out what bezier path this CGPoint belongs to.
                for (UIBezierPath *path in _chartPath) {
                    BOOL pointContainsPath = CGPathContainsPoint(path.CGPath, NULL, p1, NO);

                    if (pointContainsPath) {
                        [_delegate userClickedOnLinePoint:touchPoint lineIndex:(NSInteger)[_chartPath indexOfObject:path]];

                        return;
                    }
                }
            }
        }
    }
}

- (void)touchKeyPoint:(NSSet *)touches withEvent:(UIEvent *)event {
    // Get the point user touched
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];

    for (NSInteger p = (NSInteger)(_pathPoints.count - 1); p >= 0; p--) {
        NSArray *linePointsArray = _pathPoints[(NSUInteger)p];

        for (NSUInteger i = 0; i < linePointsArray.count - 1; i += 1) {
            CGPoint p1 = [linePointsArray[i] CGPointValue];
            CGPoint p2 = [linePointsArray[i + 1] CGPointValue];

            CGFloat distanceToP1 = (CGFloat)fabs(hypot((double)(touchPoint.x - p1.x), (CGFloat)(touchPoint.y - p1.y)));
            CGFloat distanceToP2 = (CGFloat)hypot((double)(touchPoint.x - p2.x), (double)(touchPoint.y - p2.y));

            CGFloat distance = MIN(distanceToP1, distanceToP2);

            if (distance <= 10) {
                [_delegate userClickedOnLineKeyPoint:touchPoint
                                           lineIndex:p
                                          pointIndex:(distance == distanceToP2 ? (NSInteger)(i + 1) :(NSInteger)i)];
                return;
            }
        }
    }
}

#pragma mark - Draw Chart

- (void)strokeChart {
    _chartPath = [NSMutableArray new];
    _pointPath = [NSMutableArray new];
    _gradeStringPaths = [NSMutableArray array];

    [self calculateChartPath:_chartPath andPointsPath:_pointPath andPathKeyPoints:_pathPoints andPathStartEndPoints:_endPointsOfPath];
    // Draw each line
    for (NSUInteger lineIndex = 0; lineIndex < self.chartData.count; lineIndex++) {
        PNLineChartData *chartData = self.chartData[lineIndex];
        CAShapeLayer *chartLine = (CAShapeLayer *)self.chartLineArray[lineIndex];
        CAShapeLayer *pointLayer = (CAShapeLayer *)self.chartPointArray[lineIndex];
        UIGraphicsBeginImageContext(self.frame.size);
        // setup the color of the chart line
        if (chartData.color) {
            chartLine.strokeColor = [[chartData.color colorWithAlphaComponent:chartData.alpha]CGColor];
        } else {
            chartLine.strokeColor = [PNGreen CGColor];
            pointLayer.strokeColor = [PNGreen CGColor];
        }
        
        UIBezierPath *progressline = [_chartPath objectAtIndex:lineIndex];
        UIBezierPath *pointPath = [_pointPath objectAtIndex:lineIndex];

        chartLine.path = progressline.CGPath;
        pointLayer.path = pointPath.CGPath;

        [CATransaction begin];
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = self.duration;
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        pathAnimation.fromValue = @0;
        pathAnimation.toValue = @1;
        if (self.duration > 0) {
            [chartLine addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
        }
        chartLine.strokeEnd = 1;

        // if you want cancel the point animation, conment this code, the point will show immediately
        if (chartData.inflexionPointStyle != PNLineChartPointStyleNone && self.duration > 0) {
            [pointLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
        }
        pointLayer.strokeEnd = 1;

        [CATransaction commit];
        
        NSMutableArray *textLayerArray = [self.gradeStringPaths objectAtIndex:lineIndex];
        for (CATextLayer *textLayer in textLayerArray) {
            CABasicAnimation *fadeAnimation = [self fadeAnimation];
            if (self.duration > 0) {
                [textLayer addAnimation:fadeAnimation forKey:nil];
            }
        }

        UIGraphicsEndImageContext();
    }
}


- (void)calculateChartPath:(NSMutableArray *)chartPath andPointsPath:(NSMutableArray *)pointsPath andPathKeyPoints:(NSMutableArray *)pathPoints andPathStartEndPoints:(NSMutableArray *)pointsOfPath {
    // Draw each line
    for (NSUInteger lineIndex = 0; lineIndex < self.chartData.count; lineIndex++) {
        PNLineChartData *chartData = self.chartData[lineIndex];
        
        CGFloat yValue;
        CGFloat innerGrade;
        
        UIBezierPath *progressline = [UIBezierPath bezierPath];
        
        UIBezierPath *pointPath = [UIBezierPath bezierPath];
        
        [chartPath insertObject:progressline atIndex:lineIndex];
        [pointsPath insertObject:pointPath atIndex:lineIndex];
        
        NSMutableArray* gradePathArray = [NSMutableArray array];
        [self.gradeStringPaths addObject:gradePathArray];
        
        if (!_showLabel) {
            _chartCavanHeight = self.frame.size.height - 2 * _yLabelHeight;
            _chartCavanWidth = self.frame.size.width;
            _chartMargin = chartData.inflexionPointWidth;
            _xLabelWidth = (_chartCavanWidth / ([_xLabels count] - 1));
        }
        
        NSMutableArray *linePointsArray = [[NSMutableArray alloc] init];
        NSMutableArray *lineStartEndPointsArray = [[NSMutableArray alloc] init];
        NSInteger last_x = 0;
        NSInteger last_y = 0;
        CGFloat inflexionWidth = chartData.inflexionPointWidth;
        
        for (NSUInteger i = 0; i < chartData.itemCount; i++) {
            
            yValue = chartData.getData(i).y;
            
            if (!(BOOL)(_yValueMax - _yValueMin)) {
                innerGrade = 0.5f;
            } else {
                innerGrade = (yValue - _yValueMin) / (_yValueMax - _yValueMin);
            }
            
            CGFloat offSetX = (_chartCavanWidth) / (chartData.itemCount);

            NSInteger x = (NSInteger)(2 * _chartMargin +  (i * offSetX));
            NSInteger y = (NSInteger)(_chartCavanHeight - (innerGrade * _chartCavanHeight) + (_yLabelHeight / 2));
            
            // Circular point
            if (chartData.inflexionPointStyle == PNLineChartPointStyleCircle) {
                
                CGRect circleRect = CGRectMake(x - inflexionWidth / 2, y - inflexionWidth / 2, inflexionWidth, inflexionWidth);
                CGPoint circleCenter = CGPointMake(circleRect.origin.x + (circleRect.size.width / 2), circleRect.origin.y + (circleRect.size.height / 2));
                
                [pointPath moveToPoint:CGPointMake(circleCenter.x + (inflexionWidth / 2), circleCenter.y)];
                [pointPath addArcWithCenter:circleCenter radius:inflexionWidth / 2 startAngle:0 endAngle:(CGFloat)(2 * M_PI) clockwise:YES];
                
                //jet text display text
//                CATextLayer* textLayer = [self createTextLayer];
//                [self setGradeFrame:textLayer grade:yValue pointCenter:circleCenter width:inflexionWidth];
//                [gradePathArray addObject:textLayer];
                
                if ( i != 0 ) {
                    
                    // calculate the point for line
                    CGFloat distance = sqrtf(powf(x - last_x, 2) + powf(y - last_y, 2) );
                    CGFloat last_x1 = last_x + (inflexionWidth / 2) / distance * (x - last_x);
                    CGFloat last_y1 = last_y + (inflexionWidth / 2) / distance * (y - last_y);
                    CGFloat x1 = x - (inflexionWidth / 2) / distance * (x - last_x);
                    CGFloat y1 = y - (inflexionWidth / 2) / distance * (y - last_y);
                    
                    [progressline moveToPoint:CGPointMake(last_x1, last_y1)];
                    [progressline addLineToPoint:CGPointMake(x1, y1)];
                    
                    [lineStartEndPointsArray addObject:[NSValue valueWithCGPoint:CGPointMake(last_x1, last_y1)]];
                    [lineStartEndPointsArray addObject:[NSValue valueWithCGPoint:CGPointMake(x1, y1)]];
                }
                
                last_x = x;
                last_y = y;
            }
            // Square point
            else if (chartData.inflexionPointStyle == PNLineChartPointStyleSquare) {
                
                CGRect squareRect = CGRectMake(x - inflexionWidth / 2, y - inflexionWidth / 2, inflexionWidth, inflexionWidth);
                CGPoint squareCenter = CGPointMake(squareRect.origin.x + (squareRect.size.width / 2), squareRect.origin.y + (squareRect.size.height / 2));
                
                [pointPath moveToPoint:CGPointMake(squareCenter.x - (inflexionWidth / 2), squareCenter.y - (inflexionWidth / 2))];
                [pointPath addLineToPoint:CGPointMake(squareCenter.x + (inflexionWidth / 2), squareCenter.y - (inflexionWidth / 2))];
                [pointPath addLineToPoint:CGPointMake(squareCenter.x + (inflexionWidth / 2), squareCenter.y + (inflexionWidth / 2))];
                [pointPath addLineToPoint:CGPointMake(squareCenter.x - (inflexionWidth / 2), squareCenter.y + (inflexionWidth / 2))];
                [pointPath closePath];
                
                // text display text
//                CATextLayer* textLayer = [self createTextLayer];
//                [self setGradeFrame:textLayer grade:yValue pointCenter:squareCenter width:inflexionWidth];
//                [gradePathArray addObject:textLayer];

                if ( i != 0 ) {
                    
                    // calculate the point for line
                    CGFloat distance = sqrtf(powf(x - last_x, 2) + powf(y - last_y, 2) );
                    CGFloat last_x1 = last_x + (inflexionWidth / 2);
                    CGFloat last_y1 = last_y + (inflexionWidth / 2) / distance * (y - last_y);
                    CGFloat x1 = x - (inflexionWidth / 2);
                    CGFloat y1 = y - (inflexionWidth / 2) / distance * (y - last_y);
                    
                    [progressline moveToPoint:CGPointMake(last_x1, last_y1)];
                    [progressline addLineToPoint:CGPointMake(x1, y1)];
                    
                    [lineStartEndPointsArray addObject:[NSValue valueWithCGPoint:CGPointMake(last_x1, last_y1)]];
                    [lineStartEndPointsArray addObject:[NSValue valueWithCGPoint:CGPointMake(x1, y1)]];
                }
                
                last_x = x;
                last_y = y;
            }
            // Triangle point
            else if (chartData.inflexionPointStyle == PNLineChartPointStyleTriangle) {
                
                CGRect squareRect = CGRectMake(x - inflexionWidth / 2, y - inflexionWidth / 2, inflexionWidth, inflexionWidth);
                
                CGPoint startPoint = CGPointMake(squareRect.origin.x,squareRect.origin.y + squareRect.size.height);
                CGPoint endPoint = CGPointMake(squareRect.origin.x + (squareRect.size.width / 2) , squareRect.origin.y);
                CGPoint middlePoint = CGPointMake(squareRect.origin.x + (squareRect.size.width) , squareRect.origin.y + squareRect.size.height);
                
                [pointPath moveToPoint:startPoint];
                [pointPath addLineToPoint:middlePoint];
                [pointPath addLineToPoint:endPoint];
                [pointPath closePath];
                
                // text display text
//                CATextLayer* textLayer = [self createTextLayer];
//                [self setGradeFrame:textLayer grade:yValue pointCenter:middlePoint width:inflexionWidth];
//                [gradePathArray addObject:textLayer];
                
                if ( i != 0 ) {
                    // calculate the point for triangle
                    CGFloat distance = sqrtf(powf(x - last_x, 2) + powf(y - last_y, 2) ) * 1.4f;
                    CGFloat last_x1 = last_x + (inflexionWidth / 2) / distance * (x - last_x);
                    CGFloat last_y1 = last_y + (inflexionWidth / 2) / distance * (y - last_y);
                    CGFloat x1 = x - (inflexionWidth / 2) / distance * (x - last_x);
                    CGFloat y1 = y - (inflexionWidth / 2) / distance * (y - last_y);
                    
                    [progressline moveToPoint:CGPointMake(last_x1, last_y1)];
                    [progressline addLineToPoint:CGPointMake(x1, y1)];
                    
                    [lineStartEndPointsArray addObject:[NSValue valueWithCGPoint:CGPointMake(last_x1, last_y1)]];
                    [lineStartEndPointsArray addObject:[NSValue valueWithCGPoint:CGPointMake(x1, y1)]];
                }
                
                last_x = x;
                last_y = y;
            } else {
                if ( i != 0 ) {
                    [progressline addLineToPoint:CGPointMake(x, y)];
                    [lineStartEndPointsArray addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                }
                
                [progressline moveToPoint:CGPointMake(x, y)];
                if(i != chartData.itemCount - 1){
                    [lineStartEndPointsArray addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                }
            }
            
            [linePointsArray addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        }
        
        [pathPoints addObject:[linePointsArray copy]];
        [pointsOfPath addObject:[lineStartEndPointsArray copy]];
    }
}

#pragma mark - Set Chart Data

- (void)setChartData:(NSArray *)data {
    if (data != _chartData) {
        // remove all shape layers before adding new ones
        for (CALayer *layer in self.chartLineArray) {
            [layer removeFromSuperlayer];
        }
        for (CALayer *layer in self.chartPointArray) {
            [layer removeFromSuperlayer];
        }

        self.chartLineArray = [NSMutableArray arrayWithCapacity:data.count];
        self.chartPointArray = [NSMutableArray arrayWithCapacity:data.count];

        for (PNLineChartData *chartData in data) {
            // create as many chart line layers as there are data-lines
            CAShapeLayer *chartLine = [CAShapeLayer layer];
            chartLine.lineCap = kCALineCapButt;
            chartLine.lineJoin = kCALineJoinMiter;
            chartLine.fillColor = [[UIColor whiteColor] CGColor];
            chartLine.lineWidth = chartData.lineWidth;
            chartLine.strokeEnd = 0;
            [self.layer addSublayer:chartLine];
            [self.chartLineArray addObject:chartLine];

            // create point
            CAShapeLayer *pointLayer = [CAShapeLayer layer];
            pointLayer.strokeColor = [[chartData.color colorWithAlphaComponent:chartData.alpha]CGColor];
            pointLayer.lineCap = kCALineCapRound;
            pointLayer.lineJoin = kCALineJoinBevel;
            pointLayer.fillColor = nil;
            pointLayer.lineWidth = chartData.lineWidth;
            [self.layer addSublayer:pointLayer];
            [self.chartPointArray addObject:pointLayer];
        }

        _chartData = data;
        
        [self prepareYLabelsWithData:data];

        [self setNeedsDisplay];
    }
}

- (void)prepareYLabelsWithData:(NSArray *)data {
    CGFloat yMax = 0;
    CGFloat yMin = MAXFLOAT;
    NSMutableArray *yLabelsArray = [NSMutableArray new];
    
    for (PNLineChartData *chartData in data) {
        // create as many chart line layers as there are data-lines
        for (NSUInteger i = 0; i < chartData.itemCount; i++) {
            CGFloat yValue = chartData.getData(i).y;
            [yLabelsArray addObject:[NSString stringWithFormat:@"%2f", yValue]];
            yMax = (CGFloat)fmax((double)yMax, (double)yValue);
            yMin = (CGFloat)fmin((double)yMin, (double)yValue);
        }
    }
    
    // Min value for Y label
    if (yMax < 5) {
        yMax = 5;
    }
    
    if (yMin < 0) {
        yMin = 0;
    }
    
    _yValueMin = (_yFixedValueMin > -FLT_MAX) ? _yFixedValueMin : yMin ;
    _yValueMax = (_yFixedValueMax > -FLT_MAX) ? _yFixedValueMax : yMax + yMax / 10;
    
    if (_showGenYLabels) {
        [self setYLabels];
    }
}

#pragma mark - Update Chart Data

- (void)updateChartData:(NSArray *)data {
    _chartData = data;
    
    [self prepareYLabelsWithData:data];
    
    [self calculateChartPath:_chartPath andPointsPath:_pointPath andPathKeyPoints:_pathPoints andPathStartEndPoints:_endPointsOfPath];
    
    for (NSUInteger lineIndex = 0; lineIndex < self.chartData.count; lineIndex++) {
        CAShapeLayer *chartLine = (CAShapeLayer *)self.chartLineArray[lineIndex];
        CAShapeLayer *pointLayer = (CAShapeLayer *)self.chartPointArray[lineIndex];

        UIBezierPath *progressline = [_chartPath objectAtIndex:lineIndex];
        UIBezierPath *pointPath = [_pointPath objectAtIndex:lineIndex];
        
        CABasicAnimation * pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimation.fromValue = (id)chartLine.path;
        pathAnimation.toValue = (id)[progressline CGPath];
        pathAnimation.duration = 0.5f;
        pathAnimation.autoreverses = NO;
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [chartLine addAnimation:pathAnimation forKey:@"animationKey"];
        
        CABasicAnimation * pointPathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        pointPathAnimation.fromValue = (id)pointLayer.path;
        pointPathAnimation.toValue = (id)[pointPath CGPath];
        pointPathAnimation.duration = 0.5f;
        pointPathAnimation.autoreverses = NO;
        pointPathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [pointLayer addAnimation:pointPathAnimation forKey:@"animationKey"];
        
        chartLine.path = progressline.CGPath;
        pointLayer.path = pointPath.CGPath;
    }
}

#define IOS7_OR_LATER [[[UIDevice currentDevice] systemVersion] floatValue] >= 7

- (void)drawRect:(CGRect)rect {
    if (self.isShowCoordinateAxis) {
        CGFloat yAxisOffset = 10.f;

        CGContextRef ctx = UIGraphicsGetCurrentContext();
        UIGraphicsPushContext(ctx);
        CGContextSetLineWidth(ctx, self.axisWidth);
        CGContextSetStrokeColorWithColor(ctx, [self.axisColor CGColor]);

        CGFloat xAxisWidth = CGRectGetWidth(rect) - _chartMargin / 2;
        CGFloat yAxisHeight = _chartMargin + _chartCavanHeight;

        // draw coordinate axis
        CGContextMoveToPoint(ctx, _chartMargin + yAxisOffset, 0);
        CGContextAddLineToPoint(ctx, _chartMargin + yAxisOffset, yAxisHeight);
        CGContextAddLineToPoint(ctx, xAxisWidth, yAxisHeight);
        CGContextStrokePath(ctx);

        // draw y axis arrow
        CGContextMoveToPoint(ctx, _chartMargin + yAxisOffset - 3, 6);
        CGContextAddLineToPoint(ctx, _chartMargin + yAxisOffset, 0);
        CGContextAddLineToPoint(ctx, _chartMargin + yAxisOffset + 3, 6);
        CGContextStrokePath(ctx);

        // draw x axis arrow
        CGContextMoveToPoint(ctx, xAxisWidth - 6, yAxisHeight - 3);
        CGContextAddLineToPoint(ctx, xAxisWidth, yAxisHeight);
        CGContextAddLineToPoint(ctx, xAxisWidth - 6, yAxisHeight + 3);
        CGContextStrokePath(ctx);

        if (self.showLabel) {

            // draw x axis separator
            CGPoint point;
            for (NSUInteger i = 0; i < [self.xLabels count]; i++) {
                point = CGPointMake(2 * _chartMargin +  (i * _xLabelWidth), _chartMargin + _chartCavanHeight);
                CGContextMoveToPoint(ctx, point.x, point.y - 2);
                CGContextAddLineToPoint(ctx, point.x, point.y);
                CGContextStrokePath(ctx);
            }

            // draw y axis separator
            CGFloat yStepHeight = _chartCavanHeight / _yLabelNum;
            for (NSUInteger i = 0; i < [self.xLabels count]; i++) {
                point = CGPointMake(_chartMargin + yAxisOffset, (_chartCavanHeight - i * yStepHeight + _yLabelHeight / 2));
                CGContextMoveToPoint(ctx, point.x, point.y);
                CGContextAddLineToPoint(ctx, point.x + 2, point.y);
                CGContextStrokePath(ctx);
            }
        }

        UIFont *font = [UIFont systemFontOfSize:11];

        // draw y unit
        if ([self.yUnit length]) {
            CGFloat height = [PNLineChart sizeOfString:self.yUnit withWidth:30.f font:font].height;
            CGRect drawRect = CGRectMake(_chartMargin + 10 + 5, 0, 30.f, height);
            [self drawTextInContext:ctx text:self.yUnit inRect:drawRect font:font];
        }

        // draw x unit
        if ([self.xUnit length]) {
            CGFloat height = [PNLineChart sizeOfString:self.xUnit withWidth:30.f font:font].height;
            CGRect drawRect = CGRectMake(CGRectGetWidth(rect) - _chartMargin + 5, _chartMargin + _chartCavanHeight - height / 2, 25.f, height);
            [self drawTextInContext:ctx text:self.xUnit inRect:drawRect font:font];
        }
    }

    [super drawRect:rect];
}

#pragma mark private methods

- (void)setupDefaultValues {
    [super setupDefaultValues];
    // Initialization code
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds   = YES;
    self.chartLineArray  = [NSMutableArray new];
    _showLabel            = YES;
    _showGenYLabels        = YES;
    _pathPoints          = [[NSMutableArray alloc] init];
    _endPointsOfPath     = [[NSMutableArray alloc] init];
    self.userInteractionEnabled = YES;

    _yFixedValueMin = -FLT_MAX;
    _yFixedValueMax = -FLT_MAX;
    _yLabelNum = 5;
    _yLabelHeight = [[[[PNChartLabel alloc] init] font] pointSize];

    _chartMargin = 40;

    _chartCavanWidth = self.frame.size.width - _chartMargin * 2;
    _chartCavanHeight = self.frame.size.height - _chartMargin * 2;

    // Coordinate Axis Default Values
    _showCoordinateAxis = NO;
    _axisColor = [UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.f];
    _axisWidth = 1;
    _duration = 1;
}

#pragma mark - tools

+ (CGSize)sizeOfString:(NSString *)text withWidth:(CGFloat)width font:(UIFont *)font {
    CGSize size = CGSizeMake(width, MAXFLOAT);

    if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSDictionary *tdic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
        size = [text boundingRectWithSize:size
                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                               attributes:tdic
                                  context:nil].size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        size = [text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
#pragma clang diagnostic pop
    }

    return size;
}

- (void)drawTextInContext:(CGContextRef )ctx text:(NSString *)text inRect:(CGRect)rect font:(UIFont *)font {
    if (IOS7_OR_LATER) {
        NSMutableParagraphStyle *priceParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        priceParagraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        priceParagraphStyle.alignment = NSTextAlignmentLeft;

        [text drawInRect:rect
          withAttributes:@{ NSParagraphStyleAttributeName:priceParagraphStyle, NSFontAttributeName:font }];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [text drawInRect:rect
                withFont:font
           lineBreakMode:NSLineBreakByTruncatingTail
               alignment:NSTextAlignmentLeft];
#pragma clang diagnostic pop
    }
}

- (NSString *)formatYLabel:(CGFloat)value{
    if (self.yLabelBlockFormatter) {
        return self.yLabelBlockFormatter(value);
    } else {
        if (!self.thousandsSeparator) {
            NSString *format = self.yLabelFormat ? : @"%1.f";
            return [NSString stringWithFormat:format,value];
        }
        
        NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
        return [numberFormatter stringFromNumber: [NSNumber numberWithDouble:value]];
    }
}

- (UIView *)getLegendWithMaxWidth:(CGFloat)mWidth{
    if ([self.chartData count] < 1) {
        return nil;
    }
    
    /* This is a short line that refers to the chart data */
    CGFloat legendLineWidth = 40;
    
    /* x and y are the coordinates of the starting point of each legend item */
    CGFloat x = 0;
    CGFloat y = 0;
    
    /* accumulated height */
    CGFloat totalHeight = 0;
    CGFloat totalWidth = 0;
    
    NSMutableArray *legendViews = [[NSMutableArray alloc] init];

    /* Determine the max width of each legend item */
    CGFloat maxLabelWidth;
    if (self.legendStyle == PNLegendItemStyleStacked) {
        maxLabelWidth = mWidth - legendLineWidth;
    } else {
        maxLabelWidth = MAXFLOAT;
    }
    
    /* this is used when labels wrap text and the line 
     * should be in the middle of the first row */
    CGFloat singleRowHeight = [PNLineChart sizeOfString:@"Test"
                                              withWidth:MAXFLOAT
                                                   font:self.legendFont ? self.legendFont : [UIFont systemFontOfSize:12]].height;

    NSUInteger counter = 0;
    NSUInteger rowWidth = 0;
    NSUInteger rowMaxHeight = 0;
    
    for (PNLineChartData *pdata in self.chartData) {
        /* Expected label size*/
        CGSize labelsize = [PNLineChart sizeOfString:pdata.dataTitle
                                           withWidth:maxLabelWidth
                                                font:self.legendFont ? self.legendFont : [UIFont systemFontOfSize:12]];
        
        /* draw lines */
        if ((rowWidth + labelsize.width + legendLineWidth > mWidth)&&(self.legendStyle == PNLegendItemStyleSerial)) {
            rowWidth = 0;
            x = 0;
            y += rowMaxHeight;
            rowMaxHeight = 0;
        }
        rowWidth += labelsize.width + legendLineWidth;
        totalWidth = self.legendStyle == PNLegendItemStyleSerial ? (CGFloat)fmax((double)rowWidth, (double)totalWidth) : (CGFloat)fmax((double)totalWidth, (double)(labelsize.width + legendLineWidth));
        
        /* If there is inflection decorator, the line is composed of two lines 
         * and this is the space that separates two lines in order to put inflection
         * decorator */
        
        CGFloat inflexionWidthSpacer = pdata.inflexionPointStyle == PNLineChartPointStyleTriangle ? pdata.inflexionPointWidth / 2 : pdata.inflexionPointWidth;
        
        CGFloat halfLineLength;
        
        if (pdata.inflexionPointStyle != PNLineChartPointStyleNone) {
            halfLineLength = (legendLineWidth * 0.8f - inflexionWidthSpacer)/2;
        } else {
            halfLineLength = legendLineWidth * 0.8f;
        }
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(x + legendLineWidth * 0.1f, y + (singleRowHeight - pdata.lineWidth) / 2, halfLineLength, pdata.lineWidth)];
        
        line.backgroundColor = pdata.color;
        line.alpha = pdata.alpha;
        [legendViews addObject:line];
        
        if (pdata.inflexionPointStyle != PNLineChartPointStyleNone) {
            line = [[UIView alloc] initWithFrame:CGRectMake(x + legendLineWidth * 0.1f + halfLineLength + inflexionWidthSpacer, y + (singleRowHeight - pdata.lineWidth) / 2, halfLineLength, pdata.lineWidth)];
            line.backgroundColor = pdata.color;
            line.alpha = pdata.alpha;
            [legendViews addObject:line];
        }

        // Add inflexion type
        [legendViews addObject:[self drawInflexion:pdata.inflexionPointWidth
                                                center:CGPointMake(x + legendLineWidth / 2, y + singleRowHeight / 2)
                                           strokeWidth:pdata.lineWidth
                                        inflexionStyle:pdata.inflexionPointStyle
                                              andColor:pdata.color
                                              andAlpha:pdata.alpha]];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x + legendLineWidth, y, labelsize.width, labelsize.height)];
        label.text = pdata.dataTitle;
        label.textColor = self.legendFontColor ? self.legendFontColor : [UIColor blackColor];
        label.font = self.legendFont ? self.legendFont : [UIFont systemFontOfSize:12];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;

        rowMaxHeight = (NSUInteger)fmax(rowMaxHeight, labelsize.height);
        x += self.legendStyle == PNLegendItemStyleStacked ? 0 : labelsize.width + legendLineWidth;
        y += self.legendStyle == PNLegendItemStyleStacked ? labelsize.height : 0;
        
        totalHeight = self.legendStyle == PNLegendItemStyleSerial ? (CGFloat)fmax((double)totalHeight, (double)(rowMaxHeight + y)) : totalHeight + labelsize.height;
        
        [legendViews addObject:label];
        counter++;
    }
    
    UIView *legend = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mWidth, totalHeight)];

    for (UIView* v in legendViews) {
        [legend addSubview:v];
    }
    return legend;
}


- (UIImageView *)drawInflexion:(CGFloat)size center:(CGPoint)center strokeWidth:(CGFloat)sw inflexionStyle:(PNLineChartPointStyle)type andColor:(UIColor*)color andAlpha:(CGFloat) alfa {
    //Make the size a little bigger so it includes also border stroke
    CGSize aSize = CGSizeMake(size + sw, size + sw);
    
    UIGraphicsBeginImageContextWithOptions(aSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    if (type == PNLineChartPointStyleCircle) {
        CGContextAddArc(context, (size + sw)/2, (size + sw) / 2, size/2, 0, (CGFloat)(M_PI*2), YES);
    } else if (type == PNLineChartPointStyleSquare){
        CGContextAddRect(context, CGRectMake(sw/2, sw/2, size, size));
    } else if (type == PNLineChartPointStyleTriangle){
        CGContextMoveToPoint(context, sw/2, size + sw/2);
        CGContextAddLineToPoint(context, size + sw/2, size + sw/2);
        CGContextAddLineToPoint(context, size/2 + sw/2, sw/2);
        CGContextAddLineToPoint(context, sw/2, size + sw/2);
        CGContextClosePath(context);
    }
    
    //Set some stroke properties
    CGContextSetLineWidth(context, sw);
    CGContextSetAlpha(context, alfa);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    
    //Finally draw
    CGContextDrawPath(context, kCGPathStroke);

    //now get the image from the context
    UIImage *squareImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    //// Translate origin
    CGFloat originX = center.x - (size + sw) / 2;
    CGFloat originY = center.y - (size + sw) / 2;
    
    UIImageView *squareImageView = [[UIImageView alloc]initWithImage:squareImage];
    [squareImageView setFrame:CGRectMake(originX, originY, size + sw, size + sw)];
    return squareImageView;
}

#pragma mark setter and getter

- (CATextLayer*)createTextLayer {
    CATextLayer * textLayer = [[CATextLayer alloc]init];
    [textLayer setString:@"0"];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    [textLayer setForegroundColor:[[UIColor blackColor] CGColor]];
    return textLayer;
}

- (void)setGradeFrame:(CATextLayer *)textLayer grade:(CGFloat)grade pointCenter:(CGPoint)pointCenter width:(CGFloat)width {
    CGFloat textheigt = width*3;
    CGFloat textWidth = width*8;
    CGFloat textStartPosY;
    
    if (pointCenter.y > textheigt) {
        textStartPosY = pointCenter.y - textheigt;
    } else {
        textStartPosY = pointCenter.y;
    }
    
    [self.layer addSublayer:textLayer];
    [textLayer setFontSize:textheigt/2];
    
    [textLayer setString:[[NSString alloc] initWithFormat:@"%@",@(grade*100)]];
    [textLayer setFrame:CGRectMake(0, 0, textWidth,  textheigt)];
    [textLayer setPosition:CGPointMake(pointCenter.x, textStartPosY)];
    textLayer.contentsScale = [UIScreen mainScreen].scale;

}

- (CABasicAnimation *)fadeAnimation {
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:0];
    fadeAnimation.toValue = [NSNumber numberWithFloat:1];
    fadeAnimation.duration = self.duration;
    
    return fadeAnimation;
}

@end
