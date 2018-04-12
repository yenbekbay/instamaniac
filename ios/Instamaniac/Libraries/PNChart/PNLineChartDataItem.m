//
//  Copyright (c) 2013年 kevinzhow.
//

#import "PNLineChartDataItem.h"

@interface PNLineChartDataItem ()

- (instancetype)initWithY:(CGFloat)y;

@property (readwrite) CGFloat y; // should be within the y range

@end

@implementation PNLineChartDataItem

+ (PNLineChartDataItem *)dataItemWithY:(CGFloat)y {
    return [[PNLineChartDataItem alloc] initWithY:y];
}

- (instancetype)initWithY:(CGFloat)y {
    self = [super init];
    if (!self) return nil;
    
    self.y = y;
    return self;
}

@end
