#import "IMLeaderboardRankingViewCellTableViewCell.h"

#import "UIColor+IMTints.h"
#import "UIFont+IMSizes.h"
#import "UIFont+OpenSans.h"
#import "UIView+AYUtils.h"

CGFloat const kLeaderboardRankingViewCellNumberLabelWidth = 30;
CGFloat const kLeaderboardRankingViewCellSpacing = 5;
CGFloat const kLeaderboardRankingViewCellCountLabelWidth = 100;

@implementation IMLeaderboardRankingViewCellTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;
    
    self.numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLeaderboardRankingViewCellSpacing, 0, kLeaderboardRankingViewCellNumberLabelWidth, 0)];
    self.numberLabel.font = [UIFont openSansLightFontOfSize:[UIFont smallTextFontSize]];
    self.numberLabel.adjustsFontSizeToFitWidth = YES;
    self.numberLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.numberLabel];
    
    self.avatarImageView = [UIImageView new];
    self.avatarImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.avatarImageView];
    
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kLeaderboardRankingViewCellCountLabelWidth, 0)];
    self.countLabel.font = [UIFont openSansLightFontOfSize:[UIFont smallTextFontSize]];
    self.countLabel.adjustsFontSizeToFitWidth = YES;
    self.countLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.countLabel];
    
    self.usernameLabel = [UILabel new];
    self.usernameLabel.font = [UIFont openSansLightFontOfSize:[UIFont smallTextFontSize]];
    [self.contentView addSubview:self.usernameLabel];
    
    for (UILabel *label in @[self.numberLabel, self.usernameLabel, self.countLabel]) {
        label.textColor = [UIColor colorWithWhite:1 alpha:0.75f];
    }
    
    return self;
}

- (void)setForSharing:(BOOL)forSharing {
    _forSharing = forSharing;
    if (forSharing) {
        self.numberLabel.font = [UIFont openSansLightFontOfSize:[UIFont smallSnapshotFontSize]];
        self.countLabel.font = [UIFont openSansLightFontOfSize:[UIFont smallSnapshotFontSize]];
        self.usernameLabel.font = [UIFont openSansLightFontOfSize:[UIFont smallSnapshotFontSize]];
    }
}

- (void)layoutSubviews {
    self.numberLabel.height = self.contentView.height;
    self.avatarImageView.left = self.numberLabel.right + kLeaderboardRankingViewCellSpacing;
    self.avatarImageView.width = self.contentView.height;
    self.avatarImageView.height = self.contentView.height;
    self.avatarImageView.layer.cornerRadius = self.contentView.height/2;
    self.countLabel.left = self.contentView.right - kLeaderboardRankingViewCellCountLabelWidth - kLeaderboardRankingViewCellSpacing;
    self.countLabel.height = self.contentView.height;
    self.usernameLabel.left = self.avatarImageView.right + kLeaderboardRankingViewCellSpacing;
    self.usernameLabel.width = self.countLabel.left - kLeaderboardRankingViewCellSpacing - self.usernameLabel.left;
    self.usernameLabel.height = self.contentView.height;
}

- (void)prepareForReuse {
    self.numberLabel.text = nil;
    self.avatarImageView.image = nil;
    self.countLabel.text = nil;
    self.usernameLabel.text = nil;
}

@end
