//
//  Copyright (c) 2013年 kevinzhow.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PNLineChartDataItem : NSObject

+ (PNLineChartDataItem *)dataItemWithY:(CGFloat)y;

@property (readonly) CGFloat y; // should be within the y range

@end
