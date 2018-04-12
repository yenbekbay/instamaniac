#import "IMLeaderboardRankingView.h"

#import "IMInstagramUserInfoManager.h"
#import "IMLeaderboardRankingViewCellTableViewCell.h"
#import "UIColor+IMTints.h"
#import "UIFont+IMSizes.h"
#import "UIFont+OpenSans.h"
#import "UILabel+AYHelpers.h"
#import "UIView+AYUtils.h"
#import <InstagramKit/InstagramUser.h>
#import <SDWebImage/UIImageView+WebCache.h>

NSString * const kLeaderboardRankingViewCellReuseIdentifier = @"leaderboardRankingViewCell";
CGFloat const kLeaderboardRankingViewCellHeight = 40;
CGFloat const kLeaderboardRankingViewSeparatorHeight = 20;
CGFloat const kLeaderboardRankingViewSeparatorHorizontalPadding = 10;
CGFloat const kLeaderboardRankingViewTableViewTopMargin = 20;
CGSize const kLeaderboardRankingSnapshotViewSize = {400, 400};

@interface IMLeaderboardRankingView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UILabel *prefaceLabel;
@property (nonatomic) UITableView *tableView;

@property (nonatomic) NSMutableArray *topUsers;
@property (nonatomic) NSMutableArray *topPhotos;
@property (nonatomic) NSMutableArray *bottomUsers;
@property (nonatomic) NSMutableArray *bottomPhotos;

@end

@implementation IMLeaderboardRankingView

#pragma mark Setters

- (void)setUsers:(NSArray *)users {
    _users = users;
    
    self.loaded = YES;
    self.topUsers = [NSMutableArray new];
    self.topPhotos = [NSMutableArray new];
    self.bottomUsers = [NSMutableArray new];
    self.bottomPhotos = [NSMutableArray new];
    for (NSUInteger i = 0; i < 3; i++) {
        if (i >= [users count]) break;
        [self.topUsers addObject:users[i]];
        if (self.photos) {
            [self.topPhotos addObject:self.photos[i]];
        }
    }
    NSUInteger indexOfCurrentUser = [self indexOfCurrentUser];
    if (indexOfCurrentUser > 2) {
        NSUInteger startingIndex = indexOfCurrentUser - 1;
        if (startingIndex < 3) {
            startingIndex = indexOfCurrentUser - indexOfCurrentUser%3;
        }
        NSUInteger endingIndex = startingIndex + 2;
        for (NSUInteger i = startingIndex; i < endingIndex + 1; i++) {
            if (i >= [users count]) break;
            [self.bottomUsers addObject:users[i]];
            if (self.photos) {
                [self.bottomPhotos addObject:self.photos[i]];
            }
        }
    }
    self.prefaceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 0)];
    self.prefaceLabel.font = [UIFont openSansLightFontOfSize:self.isForSharing ? [UIFont mediumSnapshotFontSize] : [UIFont mediumTextFontSize]];
    self.prefaceLabel.textColor = [UIColor colorWithWhite:1 alpha:0.75f];
    self.prefaceLabel.textAlignment = NSTextAlignmentCenter;
    self.prefaceLabel.text = NSLocalizedString(@"The earliest users at the Instagram party", nil);
    [self.prefaceLabel setFrameToFitWithHeightLimit:0];
    [self.contentView addSubview:self.prefaceLabel];
    
    self.tableView = [UITableView new];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[IMLeaderboardRankingViewCellTableViewCell class] forCellReuseIdentifier:kLeaderboardRankingViewCellReuseIdentifier];
    self.tableView.allowsSelection = NO;
    self.tableView.bounces = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contentView addSubview:self.tableView];
    
    CGFloat height = self.prefaceLabel.height + kLeaderboardRankingViewTableViewTopMargin + kLeaderboardRankingViewCellHeight * ([self.topUsers count] + [self.bottomUsers count]);
    if ([self.bottomUsers count] > 0) {
        height += kLeaderboardRankingViewSeparatorHeight;
    }
    self.height = height * self.scale;
    self.tableView.frame = CGRectMake(0, self.prefaceLabel.height + kLeaderboardRankingViewTableViewTopMargin, self.contentView.width, height - kLeaderboardRankingViewTableViewTopMargin - self.prefaceLabel.height);
    if (!self.photos) {
        self.photos = [NSMutableArray new];
        for (NSUInteger i = 0; i < [users count]; i++) {
            [self.photos addObject:[NSNull null]];
        }
    }
    [self.tableView reloadData];
}

#pragma mark Private

- (NSUInteger)indexOfCurrentUser {
    NSString *currentUserId = [IMInstagramUserInfoManager sharedInstance].instagramUser.instagramId;
    NSUInteger index = 0;
    if (currentUserId.length > 0) {
        for (InstagramUser *instagramUser in self.users) {
            if ([[instagramUser Id] integerValue] == [currentUserId integerValue]) {
                index = [self.users indexOfObject:instagramUser];
                break;
            }
        }
    }
    return index;
}

#pragma mark UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kLeaderboardRankingViewCellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return (NSInteger)[self.topUsers count];
    } else {
        return (NSInteger)[self.bottomUsers count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IMLeaderboardRankingViewCellTableViewCell *cell = (IMLeaderboardRankingViewCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kLeaderboardRankingViewCellReuseIdentifier forIndexPath:indexPath];
    if (self.forSharing) {
        cell.forSharing = YES;
    }
    InstagramUser *instagramUser;
    UIImage *photo;
    if (indexPath.section == 0) {
        instagramUser = self.topUsers[(NSUInteger)indexPath.row];
        if ([self.topPhotos count] > (NSUInteger)indexPath.row) {
            photo = self.topPhotos[(NSUInteger)indexPath.row];
        }
    } else {
        instagramUser = self.bottomUsers[(NSUInteger)indexPath.row];
        if ([self.bottomPhotos count] > (NSUInteger)indexPath.row) {
            photo = self.bottomPhotos[(NSUInteger)indexPath.row];
        }
    }
    if (instagramUser == self.users[[self indexOfCurrentUser]]) {
        cell.backgroundColor = [[UIColor im_accentColor] colorWithAlphaComponent:0.75f];
    } else {
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.numberLabel.text = [NSString stringWithFormat:@"%@", @([self.users indexOfObject:instagramUser]+1)];
    if (!photo) {
        [cell.avatarImageView sd_setImageWithURL:instagramUser.profilePictureURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [self.photos insertObject:image atIndex:[self.users indexOfObject:instagramUser]];
        }];
    } else {
        cell.avatarImageView.image = photo;
    }
    cell.usernameLabel.text = instagramUser.username;
    cell.countLabel.text = [NSString localizedStringWithFormat:@"#%@", @([instagramUser.Id integerValue])];
    [cell layoutSubviews];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0 && [self.bottomUsers count] > 0) {
        UIView *separatorWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, kLeaderboardRankingViewSeparatorHeight)];
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(kLeaderboardRankingViewSeparatorHorizontalPadding, 0, self.tableView.width - kLeaderboardRankingViewSeparatorHorizontalPadding*2, 1/[UIScreen mainScreen].scale)];
        separator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.75f];
        separator.center = separatorWrapper.center;
        [separatorWrapper addSubview:separator];
        return separatorWrapper;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0 && [self.bottomUsers count] > 0) {
        return kLeaderboardRankingViewSeparatorHeight;
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark Public

- (void)generateSharingView {
    IMLeaderboardRankingView *sharingView = [[IMLeaderboardRankingView alloc] initWithFrame:CGRectMake(0, 0, kLeaderboardRankingSnapshotViewSize.width, kLeaderboardRankingSnapshotViewSize.height) animated:NO];
    sharingView.forSharing = YES;
    sharingView.photos = self.photos;
    sharingView.users = self.users;
    self.sharingView = sharingView;
}

@end
