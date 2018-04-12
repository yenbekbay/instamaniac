#import <UIKit/UIKit.h>

@interface IMLeaderboardRankingViewCellTableViewCell : UITableViewCell

@property (nonatomic) UILabel *numberLabel;
@property (nonatomic) UIImageView *avatarImageView;
@property (nonatomic) UILabel *usernameLabel;
@property (nonatomic) UILabel *countLabel;
@property (nonatomic,getter=isForSharing) BOOL forSharing;

@end
