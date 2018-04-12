#import "IMMapStatsView.h"

#import "IMConstants.h"
#import "FSInteractiveMapView.h"
#import "UIColor+IMTints.h"
#import "UIFont+IMSizes.h"
#import "UIFont+OpenSans.h"
#import "UILabel+AYHelpers.h"
#import "UIView+AYUtils.h"

CGFloat const kMapStatsViewMapTopMargin = 20;
CGSize const kMapStatsSnapshotViewSize = {320, 320};

@interface IMMapStatsView ()

@property (nonatomic) UILabel *prefaceLabel;
@property (nonatomic) UILabel *noDataLabel;
@property (nonatomic) FSInteractiveMapView *mapView;

@end

@implementation IMMapStatsView

#pragma mark Setters

- (void)setCountries:(NSArray *)countries {
    if ([countries count] <= 0) countries = nil;
    _countries = countries;
    
    self.loaded = YES;
    self.prefaceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 0)];
    self.prefaceLabel.text = self.isForSharing ? NSLocalizedString(@"The countries I've taken pictures in", nil) : NSLocalizedString(@"The countries you've taken pictures in", nil);
    [self.contentView addSubview:self.prefaceLabel];
    
    self.noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 0)];
    self.noDataLabel.text = NSLocalizedString(@"No data available", nil);
    if (!countries) [self.contentView addSubview:self.noDataLabel];
    
    for (UILabel *label in @[self.prefaceLabel, self.noDataLabel]) {
        label.font = [UIFont openSansLightFontOfSize:self.isForSharing ? [UIFont mediumSnapshotFontSize] : [UIFont mediumTextFontSize]];
        label.textColor = [UIColor colorWithWhite:1 alpha:0.75f];
        label.textAlignment = NSTextAlignmentCenter;
    }
    
    [self.prefaceLabel setFrameToFitWithHeightLimit:0];
    [self.noDataLabel setFrameToFitWithHeightLimit:0];
    
    self.mapView = [[FSInteractiveMapView alloc] initWithFrame:CGRectMake(0, self.prefaceLabel.bottom + kMapStatsViewMapTopMargin, self.contentView.width, self.contentView.width*0.65f)];
    NSMutableDictionary *colors = [NSMutableDictionary new];
    for (NSString *country in countries) {
        [colors setObject:[UIColor im_accentColor] forKey:country];
    }
    [self.mapView loadMap:@"world-low" withColors:colors];
    [self.contentView addSubview:self.mapView];
    if (!countries) self.mapView.alpha = 0.15f;
    
    self.height = self.mapView.bottom * self.scale;
    self.noDataLabel.center = self.mapView.center;
}

#pragma mark Public

- (void)generateSharingView {
    IMMapStatsView *sharingView = [[IMMapStatsView alloc] initWithFrame:CGRectMake(0, 0, kMapStatsSnapshotViewSize.width - kStatsViewPadding.left - kStatsViewPadding.right, kMapStatsSnapshotViewSize.height) animated:NO];
    sharingView.forSharing = YES;
    sharingView.countries = self.countries;
    self.sharingView = sharingView;
}

@end
