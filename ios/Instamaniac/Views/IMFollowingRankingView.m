#import "IMFollowingRankingView.h"

#import "IMConstants.h"
#import "PNChart.h"
#import "UIFont+IMSizes.h"
#import "UIFont+OpenSans.h"
#import "UIColor+IMTints.h"
#import "UILabel+AYHelpers.h"
#import "UIView+AYUtils.h"

CGFloat kFollowingRankingViewCircleChartHeight = 150;
CGFloat kFollowingRankingViewCircleChartLineWidth = 30;
CGFloat kFollowingRankingViewSpacing = 10;
CGSize const kFollowingRankingSnapshotViewSize = {320, 320};

@interface IMFollowingRankingView ()

@property (nonatomic) UILabel *prefaceLabel;
@property (nonatomic) PNCircleChart *circleChart;
@property (nonatomic) UILabel *specifyingLabel;

@end

@implementation IMFollowingRankingView

#pragma mark Setters

- (void)setUserPercent:(NSInteger)userPercent {
    _userPercent = userPercent;
    self.loaded = YES;
    
    self.prefaceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 0)];
    self.prefaceLabel.font = [UIFont openSansLightFontOfSize:self.isForSharing ? [UIFont mediumSnapshotFontSize] : [UIFont mediumTextFontSize]];
    self.prefaceLabel.text = self.isForSharing ? NSLocalizedString(@"I signed up earlier than", nil) : NSLocalizedString(@"You signed up earlier than", nil);
    [self.prefaceLabel setFrameToFitWithHeightLimit:0];
    [self.contentView addSubview:self.prefaceLabel];
    
    self.circleChart = [[PNCircleChart alloc] initWithFrame:CGRectMake(0, self.prefaceLabel.bottom + kFollowingRankingViewSpacing, self.contentView.width, kFollowingRankingViewCircleChartHeight) total:@100  current:@(userPercent) clockwise:NO shadow:NO shadowColor:nil displayCountingLabel:YES overrideLineWidth:@(kFollowingRankingViewCircleChartLineWidth)];
    self.circleChart.countingLabel.font = [UIFont openSansLightFontOfSize:self.isForSharing ? [UIFont largeSnapshotFontSize] : [UIFont largeTextFontSize]];
    self.circleChart.strokeColor = [UIColor im_accentColor];
    if (self.isForSharing) {
        self.circleChart.duration = 0;
    }
    [self.circleChart strokeChart];
    [self.contentView addSubview:self.circleChart];
    
    self.specifyingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.circleChart.bottom + kFollowingRankingViewSpacing, self.contentView.width, 0)];
    self.specifyingLabel.font = [UIFont openSansLightFontOfSize:self.isForSharing ? [UIFont mediumSnapshotFontSize] : [UIFont mediumTextFontSize]];
    self.specifyingLabel.text = self.isForSharing ? NSLocalizedString(@"of the users I follow", nil) : NSLocalizedString(@"of the users you follow", nil);
    [self.specifyingLabel setFrameToFitWithHeightLimit:0];
    [self.contentView addSubview:self.specifyingLabel];
    
    self.height = self.specifyingLabel.bottom * self.scale;
    for (UILabel *label in @[self.prefaceLabel, self.circleChart.countingLabel, self.specifyingLabel]) {
        label.textColor = [UIColor colorWithWhite:1 alpha:0.75f];
        label.textAlignment = NSTextAlignmentCenter;
    }
}

#pragma mark Public

- (void)generateSharingView {
    IMFollowingRankingView *sharingView = [[IMFollowingRankingView alloc] initWithFrame:CGRectMake(0, 0, kFollowingRankingSnapshotViewSize.width - kStatsViewPadding.left - kStatsViewPadding.right, kFollowingRankingSnapshotViewSize.height) animated:NO];
    sharingView.forSharing = YES;
    sharingView.userPercent = self.userPercent;
    self.sharingView = sharingView;
}

@end
