#import "IMGlobalRankingView.h"

#import "IMConstants.h"
#import "UIFont+IMSizes.h"
#import "UIFont+OpenSans.h"
#import "UILabel+AYHelpers.h"
#import "UIView+AYUtils.h"

CGFloat const kGlobalRankingViewSpacing = 10;
CGSize const kGlobalRankingSnapshotViewSize = {320, 320};

@interface IMGlobalRankingView ()

@property (nonatomic) UILabel *prefaceLabel;
@property (nonatomic) UIView *percentageView;
@property (nonatomic) UILabel *percentageLabel;
@property (nonatomic) UILabel *usersLabel;
@property (nonatomic) UILabel *alternativeLabel;

@end

@implementation IMGlobalRankingView

#pragma mark Setters

- (void)setTotalCount:(NSInteger)totalCount {
    _totalCount = totalCount;
    self.loaded = YES;
    
    self.prefaceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 0)];
    self.prefaceLabel.font = [UIFont openSansLightFontOfSize:self.isForSharing ? [UIFont mediumSnapshotFontSize] : [UIFont mediumTextFontSize]];
    self.prefaceLabel.text = self.isForSharing ? NSLocalizedString(@"I am among the first", nil) : NSLocalizedString(@"You are among the first", nil);
    [self.prefaceLabel setFrameToFitWithHeightLimit:0];
    [self.contentView addSubview:self.prefaceLabel];
    
    self.percentageView = [[UIView alloc] initWithFrame:CGRectMake(0, self.prefaceLabel.bottom + kGlobalRankingViewSpacing, self.contentView.width, 0)];
    self.percentageView.layer.cornerRadius = 10;
    self.percentageView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.75f].CGColor;
    self.percentageView.layer.borderWidth = 1/[UIScreen mainScreen].scale;
    
    self.percentageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.percentageView.width, 0)];
    self.percentageLabel.font = [UIFont openSansFontOfSize:self.isForSharing ? [UIFont mediumSnapshotFontSize] : [UIFont mediumTextFontSize]];
    CGFloat percentage = (CGFloat)self.userCount/(CGFloat)self.totalCount*100;
    NSMutableAttributedString *percentageText = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.04f", percentage] attributes:@{ NSFontAttributeName: [UIFont openSansFontOfSize:self.isForSharing ? [UIFont extraLargeSnapshotFontSize] : [UIFont extraLargeTextFontSize]] }] mutableCopy];
    [percentageText appendAttributedString:[[NSAttributedString alloc] initWithString:@"%" attributes:@{ NSFontAttributeName: [UIFont openSansLightFontOfSize:self.isForSharing ? [UIFont largeSnapshotFontSize] : [UIFont largeTextFontSize]] }]];
    self.percentageLabel.attributedText = percentageText;
    [self.percentageLabel setFrameToFitWithHeightLimit:0];
    [self.percentageView addSubview:self.percentageLabel];
    
    self.usersLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.percentageLabel.bottom, self.percentageView.width, 0)];
    self.usersLabel.font = [UIFont openSansLightFontOfSize:self.isForSharing ? [UIFont smallSnapshotFontSize] : [UIFont smallTextFontSize]];
    self.usersLabel.text = NSLocalizedString(@"of users", nil);
    CGRect usersLabelFrame = [self.usersLabel frameToFitWithHeightLimit:0];
    usersLabelFrame.origin.y -= CGRectGetHeight(usersLabelFrame)/2;
    self.usersLabel.frame = usersLabelFrame;
    [self.percentageView addSubview:self.usersLabel];
    
    self.percentageView.height = self.usersLabel.bottom + self.usersLabel.height;
    [self.contentView addSubview:self.percentageView];
    
    self.alternativeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.percentageView.bottom + kGlobalRankingViewSpacing, self.contentView.width, 0)];
    self.alternativeLabel.font = [UIFont openSansLightFontOfSize:self.isForSharing ? [UIFont mediumSnapshotFontSize] : [UIFont mediumTextFontSize]];
    
    NSString *usersString;
    BOOL isEarlyAdopter = NO;
    if (self.userCount <= 500*1000) {
        usersString = [NSString stringWithFormat:@"%@", @(self.userCount)];
        isEarlyAdopter = YES;
    } else if (self.userCount + 500*1000 < 2*1000*1000) {
        usersString = @"about a million";
        isEarlyAdopter = YES;
    } else if (self.userCount < 1000*1000*1000) {
        CGFloat roundedMillionUserCount = roundf(self.userCount/1000.f/1000.f+0.5f);
        usersString = [NSString stringWithFormat:@"about %@ million", @(roundedMillionUserCount)];
        if (roundedMillionUserCount < 100) {
            isEarlyAdopter = YES;
        }
    } else {
        CGFloat billionUserCount = self.userCount/1000.f/1000.f/1000.f;
        usersString = [NSString stringWithFormat:@"about %.02f billion", billionUserCount];
    }
    NSMutableAttributedString *alternativeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:self.isForSharing ? NSLocalizedString(@"I joined Instagram when it %@ had ", nil) : NSLocalizedString(@"You joined Instagram when it %@ had ", nil), isEarlyAdopter ? @"only" : @"already"]];
    [alternativeString appendAttributedString:[[NSAttributedString alloc] initWithString:usersString attributes:@{ NSFontAttributeName: [UIFont openSansFontOfSize:self.isForSharing ? [UIFont mediumSnapshotFontSize] : [UIFont mediumTextFontSize]] }]];
    [alternativeString appendAttributedString:[[NSAttributedString alloc] initWithString:@" users."]];
    self.alternativeLabel.attributedText = alternativeString;
    self.alternativeLabel.numberOfLines = 0;
    [self.alternativeLabel setFrameToFitWithHeightLimit:0];
    [self.contentView addSubview:self.alternativeLabel];
    
    self.height = self.alternativeLabel.bottom * self.scale;
    for (UILabel *label in @[self.prefaceLabel, self.percentageLabel, self.usersLabel, self.alternativeLabel]) {
        label.textColor = [UIColor colorWithWhite:1 alpha:0.75f];
        label.textAlignment = NSTextAlignmentCenter;
    }
}

#pragma mark Public

- (void)generateSharingView {
    IMGlobalRankingView *sharingView = [[IMGlobalRankingView alloc] initWithFrame:CGRectMake(0, 0, kGlobalRankingSnapshotViewSize.width - kStatsViewPadding.left - kStatsViewPadding.right, kGlobalRankingSnapshotViewSize.height) animated:NO];
    sharingView.forSharing = YES;
    sharingView.userCount = self.userCount;
    sharingView.totalCount = self.totalCount;
    self.sharingView = sharingView;
}

@end
