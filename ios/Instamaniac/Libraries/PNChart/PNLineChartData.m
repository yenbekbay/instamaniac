//
//  Copyright (c) 2013年 kevinzhow.
//

#import "PNLineChartData.h"

@implementation PNLineChartData

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupDefaultValues];
    }
    
    return self;
}

- (void)setupDefaultValues {
    _inflexionPointStyle = PNLineChartPointStyleNone;
    _inflexionPointWidth = 6.f;
    _lineWidth = 2.f;
    _alpha = 1.f;
}

@end
