#import "IMStatsView.h"

@interface IMLineChartView : IMStatsView

#pragma mark Properties

@property (nonatomic) NSArray *dates;
@property (nonatomic) NSArray *likes;
@property (nonatomic) NSArray *comments;

#pragma mark Methods

- (void)setDates:(NSArray *)dates likes:(NSArray *)likes comments:(NSArray *)comments;

@end
