#import "IMFirstPhotoView.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "IMConstants.h"
#import "UIFont+IMSizes.h"
#import "UIFont+OpenSans.h"
#import "UILabel+AYHelpers.h"
#import "UIView+AYUtils.h"

CGFloat const kFirstPhotoImageViewVerticalMargin = 10;
CGSize const kFirstPhotoSnapshotViewSize = {320, 320};

@interface IMFirstPhotoView ()

@property (nonatomic) UILabel *prefaceLabel;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UILabel *dateLabel;

@end

@implementation IMFirstPhotoView

#pragma mark Setters

- (void)setPhoto:(InstagramMedia *)photo {
    _photo = photo;
    
    self.loaded = YES;
    self.prefaceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 0)];
    self.prefaceLabel.font = [UIFont openSansLightFontOfSize:self.isForSharing ? [UIFont mediumSnapshotFontSize] : [UIFont mediumTextFontSize]];
    self.prefaceLabel.text = self.isForSharing ? NSLocalizedString(@"My first photo on Instagram", nil) : NSLocalizedString(@"Your first photo on Instagram", nil);
    [self.prefaceLabel setFrameToFitWithHeightLimit:0];
    [self.contentView addSubview:self.prefaceLabel];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.prefaceLabel.bottom + kFirstPhotoImageViewVerticalMargin, self.contentView.width, self.contentView.width)];
    if (self.image) {
        self.imageView.image = self.image;
    } else {
        [self.imageView sd_setImageWithURL:self.photo.standardResolutionImageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            self.image = image;
        }];
    }
    [self.contentView addSubview:self.imageView];
    
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.imageView.bottom + kFirstPhotoImageViewVerticalMargin, self.contentView.width, 0)];
    self.dateLabel.font = [UIFont openSansLightFontOfSize:self.isForSharing ? [UIFont mediumSnapshotFontSize] : [UIFont mediumTextFontSize]];
    self.dateLabel.text = [NSDateFormatter localizedStringFromDate:self.photo.createdDate
                                                         dateStyle:NSDateFormatterMediumStyle
                                                         timeStyle:NSDateFormatterNoStyle];
    [self.dateLabel setFrameToFitWithHeightLimit:0];
    [self.contentView addSubview:self.dateLabel];
    
    self.height = self.dateLabel.bottom * self.scale;
    for (UILabel *label in @[self.prefaceLabel, self.dateLabel]) {
        label.textColor = [UIColor colorWithWhite:1 alpha:0.75f];
        label.textAlignment = NSTextAlignmentCenter;
    }
}

#pragma mark Public

- (void)generateSharingView {
    IMFirstPhotoView *sharingView = [[IMFirstPhotoView alloc] initWithFrame:CGRectMake(0, 0, kFirstPhotoSnapshotViewSize.width - kStatsViewPadding.left*2 - kStatsViewPadding.right*2, kFirstPhotoSnapshotViewSize.height) animated:NO];
    sharingView.forSharing = YES;
    sharingView.image = self.image;
    sharingView.photo = self.photo;
    self.sharingView = sharingView;
}

@end
