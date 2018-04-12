//
//  Copyright (c) 2013年 kevinzhow.
//

#import "PNChartLabel.h"

@implementation PNChartLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    self.font                      = [UIFont boldSystemFontOfSize:11];
    self.backgroundColor           = [UIColor clearColor];
    self.textAlignment             = NSTextAlignmentCenter;
    self.userInteractionEnabled    = YES;
    self.adjustsFontSizeToFitWidth = YES;
    self.numberOfLines             = 0;
    /* if you want to see ... in large labels un-comment this line
    self.minimumScaleFactor        = 0.8;
    */

    return self;
}

@end
