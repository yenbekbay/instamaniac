#import "IMLineChartView.h"

#import "IMConstants.h"
#import "PNChart.h"
#import "UIFont+IMSizes.h"
#import "UIFont+OpenSans.h"
#import "UIImage+AYHelpers.h"
#import "UILabel+AYHelpers.h"
#import "UIView+AYUtils.h"
#import <ChameleonFramework/Chameleon.h>

CGFloat const kLineChartViewLineChartTopMargin = 10;
CGSize const kLineChartSnapshotViewSize = {400, 400};

@interface IMLineChartView ()

@property (nonatomic) UILabel *prefaceLabel;
@property (nonatomic) PNLineChart *lineChart;
@property (nonatomic) UIView *legend;

@end

@implementation IMLineChartView

#pragma mark Setters

- (void)setDates:(NSArray *)dates likes:(NSArray *)likes comments:(NSArray *)comments {
    _dates = dates;
    _likes = likes;
    _comments = comments;
    
    self.loaded = YES;
    self.prefaceLabel = [self generatePrefaceLabelWithWidth:self.contentView.width];
    [self.contentView addSubview:self.prefaceLabel];
    
    self.lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, self.prefaceLabel.bottom + kLineChartViewLineChartTopMargin, self.contentView.width, self.contentView.width * 0.65f)];
    self.lineChart.opaque = NO;
    self.lineChart.backgroundColor = [UIColor clearColor];
    self.lineChart.showCoordinateAxis = YES;
    self.lineChart.axisColor = [UIColor colorWithWhite:1 alpha:0.75f];
    self.lineChart.axisWidth = 1/[UIScreen mainScreen].scale;
    self.lineChart.xLabelFont = [UIFont openSansLightFontOfSize:[UIFont extraSmallSnapshotFontSize]];
    self.lineChart.xLabelColor = [UIColor colorWithWhite:1 alpha:0.75f];
    self.lineChart.yLabelFont = [UIFont openSansLightFontOfSize:[UIFont smallSnapshotFontSize]];
    self.lineChart.yLabelColor = [UIColor colorWithWhite:1 alpha:0.75f];
   
    NSMutableArray *xLabels = [NSMutableArray new];
    for (NSDate *date in dates) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"MMM"];
        [xLabels addObject:[formatter stringFromDate:date]];
    }
    self.lineChart.xLabels = xLabels;
    
    PNLineChartData *likesData = [PNLineChartData new];
    likesData.color = [UIColor flatRedColor];
    likesData.itemCount = [xLabels count];
    likesData.dataTitle = NSLocalizedString(@"Likes", nil);
    likesData.inflexionPointStyle = PNLineChartPointStyleCircle;
    likesData.getData = ^(NSUInteger index) {
        return [PNLineChartDataItem dataItemWithY:[likes[index] floatValue]];
    };
    PNLineChartData *commentsData = [PNLineChartData new];
    commentsData.color = [UIColor flatGreenColor];
    commentsData.itemCount = [xLabels count];
    commentsData.dataTitle = NSLocalizedString(@"Comments", nil);
    commentsData.inflexionPointStyle = PNLineChartPointStyleTriangle;
    commentsData.getData = ^(NSUInteger index) {
        return [PNLineChartDataItem dataItemWithY:[comments[index] floatValue]];
    };
    self.lineChart.chartData = @[likesData, commentsData];
    
    if (self.isForSharing) {
        self.lineChart.duration = 0;
    }
    [self.lineChart strokeChart];
    [self.contentView addSubview:self.lineChart];
    
    self.lineChart.legendStyle = PNLegendItemStyleStacked;
    self.lineChart.legendFont = [UIFont openSansLightFontOfSize:[UIFont smallSnapshotFontSize]];
    
    self.legend = [self.lineChart getLegendWithMaxWidth:self.contentView.width];
    self.legend.opaque = NO;
    for (UIView *view in [self.legend subviews]) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            label.textColor = [UIColor colorWithWhite:1 alpha:0.75f];
        }
    }
    [self.contentView addSubview:self.legend];
    self.legend.top = self.lineChart.bottom + kLineChartViewLineChartTopMargin;
    self.legend.centerX = self.centerX;
    
    self.height = self.legend.bottom * self.scale;
}

#pragma mark Public

- (void)generateSharingView {
    IMLineChartView *sharingView = [[IMLineChartView alloc] initWithFrame:CGRectMake(0, 0, kLineChartSnapshotViewSize.width - kStatsViewPadding.left*2 - kStatsViewPadding.right*2, kLineChartSnapshotViewSize.height) animated:NO];
    sharingView.forSharing = YES;
    UILabel *prefaceLabel = [self generatePrefaceLabelWithWidth:sharingView.width];
    [sharingView addSubview:prefaceLabel];
    
    UIImage *lineChartSnapshot = [UIImage convertViewToImage:self.lineChart];
    CGFloat lineChartSnapshotHeightRatio = lineChartSnapshot.size.height/lineChartSnapshot.size.width;
    UIImageView *lineChartView = [[UIImageView alloc] initWithFrame:CGRectMake(0, prefaceLabel.bottom + kLineChartViewLineChartTopMargin, sharingView.width, sharingView.width*lineChartSnapshotHeightRatio)];
    lineChartView.image = lineChartSnapshot;
    [sharingView addSubview:lineChartView];
    
    UIImage *legendSnapshot = [UIImage convertViewToImage:self.legend];
    CGFloat legendSnapshotHeightRatio = legendSnapshot.size.height/legendSnapshot.size.width;
    UIImageView *legendView = [[UIImageView alloc] initWithFrame:CGRectMake(0, lineChartView.bottom + kLineChartViewLineChartTopMargin, sharingView.width, sharingView.width*legendSnapshotHeightRatio)];
    legendView.image = legendSnapshot;
    [sharingView addSubview:legendView];
    
    sharingView.height = legendView.bottom;
    
    self.sharingView = sharingView;
}

#pragma mark Helpers

- (UILabel *)generatePrefaceLabelWithWidth:(CGFloat)width {
    UILabel *prefaceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    prefaceLabel.font = [UIFont openSansLightFontOfSize:self.isForSharing ? [UIFont mediumSnapshotFontSize] : [UIFont mediumTextFontSize]];
    prefaceLabel.textColor = [UIColor colorWithWhite:1 alpha:0.75f];
    prefaceLabel.textAlignment = NSTextAlignmentCenter;
    prefaceLabel.numberOfLines = 0;
    prefaceLabel.text = self.isForSharing ? NSLocalizedString(@"My likes and comments for the last year", nil) : NSLocalizedString(@"Your likes and comments for the last year", nil);
    [prefaceLabel setFrameToFitWithHeightLimit:0];
    return prefaceLabel;
}

@end
