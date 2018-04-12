#import "IMUserStatsViewController.h"

#import "AYMacros.h"
#import "IMAlertManager.h"
#import "IMAuthorizationViewController.h"
#import "IMConstants.h"
#import "IMFirstPhotoView.h"
#import "IMFollowingRankingView.h"
#import "IMGlobalRankingView.h"
#import "IMInstagramUserInfoManager.h"
#import "IMLeaderboardRankingView.h"
#import "IMLineChartView.h"
#import "IMMapStatsView.h"
#import "IMStatsView.h"
#import "NSDate+IMHelpers.h"
#import "UIColor+IMTints.h"
#import "UIImage+AYHelpers.h"
#import "UIImage+ImageEffects.h"
#import "UIView+AYUtils.h"
#import <Analytics.h>
#import <ChameleonFramework/Chameleon.h>
#import <FSOpenInInstagram.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <InstagramKit/InstagramKit.h>
#import <JGProgressHUD/JGProgressHUD.h>
#import <pop/POP.h>
#import <SDWebImage/SDWebImageManager.h>

CGFloat const kBackgroundBlurRadius = 14;
CGFloat const kBackgroundBlurDarkeningRatio = 0.5f;
CGFloat const kBackgroundBlurSaturationDeltaFactor = 1.4f;
CGFloat const kSnapshotWatermarkWidth = 100;
CGFloat const kBannerHeight = 50;
CGSize const kSmallSnapshotViewSize = {320, 320};
CGSize const kBigSnapshotViewSize = {400, 400};

@interface IMUserStatsViewController () <UIDocumentInteractionControllerDelegate>

@property (nonatomic, getter=isAnimationInProgress) BOOL animationInProgress;
@property (nonatomic, getter=shouldShowAds) BOOL showAds;
@property (nonatomic) FSOpenInInstagram *instagrammer;
@property (nonatomic) GADBannerView *bannerView;
@property (nonatomic) IMFirstPhotoView *firstPhotoView;
@property (nonatomic) IMFollowingRankingView *followingRankingView;
@property (nonatomic) IMGlobalRankingView *globalRankingView;
@property (nonatomic) IMInstagramUserInfoManager *manager;
@property (nonatomic) IMLeaderboardRankingView *leaderboardRankingView;
@property (nonatomic) IMLineChartView *lineChartView;
@property (nonatomic) IMMapStatsView *mapStatsView;
@property (nonatomic) JGProgressHUD *HUD;
@property (nonatomic) NSArray *backgroundPhotos;
@property (nonatomic) NSUInteger currentBackgroundPhotoIndex;
@property (nonatomic) UIImage *nextBackgroundImage;
@property (nonatomic) UIImageView *backgroundView;
@property (nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *currentSnapshotView;
@property (weak, nonatomic) IMStatsView *bottomLeftView;
@property (weak, nonatomic) IMStatsView *bottomRightView;
@property (weak, nonatomic) IMStatsView *spotlightView;
@property (weak, nonatomic) IMStatsView *topLeftView;
@property (weak, nonatomic) IMStatsView *topRightView;

@end

@implementation IMUserStatsViewController

#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor im_primaryColor];
    
    UIBarButtonItem *logOutButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log out" style:UIBarButtonItemStylePlain target:self action:@selector(logOut)];
    [self.navigationItem setLeftBarButtonItem:logOutButtonItem];
    
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [shareButton setImage:[[[UIImage imageNamed:@"ShareIcon"] scaledToSize:CGSizeMake(14, 22)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    shareButton.tintColor = [UIColor whiteColor];
    [shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    [self.navigationItem setRightBarButtonItem:shareButtonItem];
    
    self.navigationItem.hidesBackButton = YES;
    self.manager = [IMInstagramUserInfoManager sharedInstance];
    self.instagrammer = [FSOpenInInstagram new];
    [self setUpViews];
}

- (void)viewWillLayoutSubviews {
    [self updateViews];
}

#pragma mark Private

- (void)setUpViews {
    self.backgroundView = [UIImageView new];
    [self.view addSubview:self.backgroundView];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, CGRectGetHeight([UIScreen mainScreen].bounds))];
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    [self.manager getRecentPhotos:^(NSArray *photos, NSError *photosError) {
        DDLogVerbose(@"Fetched %@ photos", @(photos.count));
        if (!photosError && [photos count] > 0) {
            self.backgroundPhotos = photos;
            self.currentBackgroundPhotoIndex = 0;
            [self getNextBackgroundImage:YES];
        }
    }];
    
    self.globalRankingView = [[IMGlobalRankingView alloc] initWithFrame:CGRectMake(0, 0, self.view.width - kStatsViewPadding.left - kStatsViewPadding.right, 200)];
    UITapGestureRecognizer *globalRankingViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewToSpotlight:)];
    [self.globalRankingView addGestureRecognizer:globalRankingViewTapGestureRecognizer];
    [self.scrollView addSubview:self.globalRankingView];
    
    self.followingRankingView = [[IMFollowingRankingView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 200)];
    UITapGestureRecognizer *followingRankingViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewToSpotlight:)];
    [self.followingRankingView addGestureRecognizer:followingRankingViewTapGestureRecognizer];
    [self.scrollView addSubview:self.followingRankingView];
    
    self.leaderboardRankingView = [[IMLeaderboardRankingView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 200)];
    UITapGestureRecognizer *leaderboardRankingViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewToSpotlight:)];
    [self.leaderboardRankingView addGestureRecognizer:leaderboardRankingViewTapGestureRecognizer];
    [self.scrollView addSubview:self.leaderboardRankingView];
    
    self.firstPhotoView = [[IMFirstPhotoView alloc] initWithFrame:CGRectMake(0, 0, self.view.width - kStatsViewPadding.left - kStatsViewPadding.right, 200)];
    UITapGestureRecognizer *firstMediaViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewToSpotlight:)];
    [self.firstPhotoView addGestureRecognizer:firstMediaViewTapGestureRecognizer];
    [self.scrollView addSubview:self.firstPhotoView];
    
//    self.mapStatsView = [[IMMapStatsView alloc] initWithFrame:CGRectMake(0, 0, self.view.width - kStatsViewPadding.left - kStatsViewPadding.right, 200)];
//    UITapGestureRecognizer *mapStatsViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewToSpotlight:)];
//    [self.mapStatsView addGestureRecognizer:mapStatsViewTapGestureRecognizer];
//    [self.scrollView addSubview:self.mapStatsView];
    
    if (!IS_IPHONE_4_OR_LESS) {
        self.lineChartView = [[IMLineChartView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 200)];
        UITapGestureRecognizer *lineChartViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewToSpotlight:)];
        [self.lineChartView addGestureRecognizer:lineChartViewTapGestureRecognizer];
        [self.scrollView addSubview:self.lineChartView];
    }
    
    self.spotlightView = self.globalRankingView;
    self.topLeftView = self.followingRankingView;
    self.topRightView = self.leaderboardRankingView;
    self.bottomLeftView = self.firstPhotoView;
    //self.bottomRightView = self.mapStatsView;
    if (!IS_IPHONE_4_OR_LESS) {
        self.bottomRightView = self.lineChartView;
    }
    
    for (IMStatsView *statsView in @[self.topLeftView, self.topRightView, self.bottomLeftView]) {
        statsView.scale = 0.5f;
    }
    if (!IS_IPHONE_4_OR_LESS) {
        self.bottomRightView.scale = 0.5f;
    }
    
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnSpotlightView:)];
    [self.spotlightView addGestureRecognizer:self.longPressGestureRecognizer];
    
    [self.manager getCurrentInstagramUser:^(IMInstagramUser *instagramUser, NSError *error) {
        DDLogVerbose(@"Got current instagram user: %@", instagramUser);
        if (!error) {
            self.title = instagramUser.username;
            self.globalRankingView.userCount = [instagramUser.instagramId integerValue];
            [self.manager getTotalUserCount:^(NSNumber *totalUserCount, NSError *totalUserCountError) {
                if (!totalUserCountError) {
                    DDLogVerbose(@"Got total user count: %@", totalUserCount);
                    self.globalRankingView.totalCount = [totalUserCount integerValue];
                    [self updateViewsAnimated:YES];
                    
                    [self.globalRankingView show];
                } else {
                    DDLogError(@"Error while getting total user count: %@", totalUserCountError);
                }
            }];
            [self.manager getNumberOfFollowingWhoSignedUpLater:^(NSInteger number, NSError *numberOfFollowingError) {
                if (!numberOfFollowingError) {
                    DDLogVerbose(@"Got number of following who signed up later: %@", @(number));
                    NSInteger userPercent = number*100/[instagramUser.following integerValue];
                    self.followingRankingView.userPercent = userPercent;
                    [self updateViewsAnimated:YES];
                    [self.followingRankingView show];
                } else {
                    DDLogError(@"Error while getting number of following who signed up later: %@", numberOfFollowingError);
                }
            }];
            [self.manager getSortedFollowingPlusCurrentUser:^(NSArray *users, NSError *sortedFollowingPlusCurrentUserError) {
                if (!sortedFollowingPlusCurrentUserError) {
                    DDLogVerbose(@"Got %@ following users", @(users.count));
                    self.leaderboardRankingView.users = users;
                    [self updateViewsAnimated:YES];
                    [self.leaderboardRankingView performSelector:@selector(show) withObject:nil afterDelay:0.4f];
                } else {
                    DDLogError(@"Error while getting following users: %@", sortedFollowingPlusCurrentUserError);
                }
            }];
            [self.manager getFirstPhoto:^(IMGettingMediaStage stage, NSUInteger currentIndex, NSUInteger totalIndex) {
                //self.HUD.progress = (float)currentIndex/(float)totalIndex;
                //self.HUD.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ photo %@ of %@", nil), stage == IMGettingMediaStageLoading ? NSLocalizedString(@"Loading", nil) : NSLocalizedString(@"Parsing", nil), @(currentIndex), @(totalIndex)];
            } completionBlock:^(InstagramMedia *photo, NSError *firstPhotoError) {
                if (!firstPhotoError) {
                    DDLogVerbose(@"Got first photo: %@", photo);
                    self.firstPhotoView.photo = photo;
                    [self updateViewsAnimated:YES];
                    [self.firstPhotoView show];
                    
                    if (!IS_IPHONE_4_OR_LESS) {
                        [self.manager getLikesAndCommentsForTheLastYear:^(NSArray *dates, NSArray *likes, NSArray *comments, NSError *likesAndCommentsError) {
                            if (!likesAndCommentsError) {
                                DDLogVerbose(@"Got likes and comments for dates: %@\nlikes:%@\ncomments:%@", dates, likes, comments);
                                [self.lineChartView setDates:dates likes:likes comments:comments];
                                [self updateViewsAnimated:YES];
                                [self.lineChartView show];
                            } else {
                                DDLogError(@"Error while getting likes and comments: %@", likesAndCommentsError);
                            }
                        }];
                    }
                } else {
                    DDLogError(@"Error while getting first photo: %@", firstPhotoError);
                }
            }];
//            [self.manager getAllMediaCountries:^(IMGettingMediaStage stage, NSUInteger currentIndex, NSUInteger totalIndex) {
//                self.HUD.progress = (float)currentIndex/(float)totalIndex;
//                self.HUD.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ photo %@ of %@", nil), stage == IMGettingMediaStageLoading ? NSLocalizedString(@"Loading", nil) : NSLocalizedString(@"Parsing", nil), @(currentIndex), @(totalIndex)];
//            } completionBlock:^(NSArray *countries, NSError *allMediaCountriesError) {
//                if (!allMediaCountriesError) {
//                    self.mapStatsView.countries = countries;
//                    [self.mapStatsView updateScale:0.5f];
//                    [self.mapStatsView show];
//                }
//            }];
        }
    }];
    
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        self.showAds = [config[@"showAds"] boolValue];
        if (self.shouldShowAds) {
            self.bannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeFullWidthPortraitWithHeight(kBannerHeight)];
            self.bannerView.adUnitID = @"ca-app-pub-8391106572655126/6916417291";
            self.bannerView.rootViewController = self;
            [self.bannerView loadRequest:[GADRequest request]];
            [self.view addSubview:self.bannerView];
            [self updateViews];
        }
    }];
}

- (void)updateViewsAnimated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.2f animations:^{
            [self updateViews];
        }];
    } else {
        [self updateViews];
    }
}

- (void)updateViews {
    self.spotlightView.top = self.topLayoutGuide.length + kStatsViewPadding.top;
    self.spotlightView.centerX = self.scrollView.centerX;
    self.topLeftView.top = self.spotlightView.bottom + kStatsViewPadding.bottom + kStatsViewPadding.top;
    self.topLeftView.centerX = self.scrollView.centerX/2;
    self.topRightView.top = self.topLeftView.top;
    self.topRightView.centerX = self.scrollView.centerX*1.5f;
    self.bottomLeftView.top = (self.topLeftView.bottom > self.topRightView.bottom ? self.topLeftView.bottom : self.topRightView.bottom) + kStatsViewPadding.bottom;
    self.bottomLeftView.centerX = self.topLeftView.centerX;
    self.bottomRightView.top = self.bottomLeftView.top;
    self.bottomRightView.centerX = self.topRightView.centerX;
    self.scrollView.height = CGRectGetHeight([UIScreen mainScreen].bounds) - (self.shouldShowAds ? kBannerHeight : 0);
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, 0, 0);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width, (self.bottomLeftView.bottom > self.bottomRightView.bottom ? self.bottomLeftView.bottom : self.bottomRightView.bottom) + kStatsViewPadding.bottom);
    if (self.bannerView) {
        self.bannerView.bottom = self.view.bottom;
    }
}

- (void)moveViewToSpotlight:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (self.isAnimationInProgress) return;

    IMStatsView *view = (IMStatsView *)tapGestureRecognizer.view;
    if (view == self.spotlightView) return;
    CGPoint currentViewCenter = view.center;
    CGPoint spotlightViewCenter = self.spotlightView.center;
    
    POPSpringAnimation *currentViewScaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    currentViewScaleAnimation.fromValue = [NSValue valueWithCGSize:CGSizeMake(view.scale, view.scale)];
    currentViewScaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
    currentViewScaleAnimation.springBounciness = 10;
    [view.layer pop_addAnimation:currentViewScaleAnimation forKey:@"layerScaleAnimation"];
    
    POPSpringAnimation *spotlightViewScaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    spotlightViewScaleAnimation.fromValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
    spotlightViewScaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(view.scale, view.scale)];
    spotlightViewScaleAnimation.springBounciness = 10;
    [self.spotlightView.layer pop_addAnimation:spotlightViewScaleAnimation forKey:@"layerScaleAnimation"];
    
    [UIView animateWithDuration:0.4f animations:^{
        view.center = spotlightViewCenter;
        self.spotlightView.center = currentViewCenter;
    } completion:^(BOOL finishedFirstAnimation) {
        view.scale = 1.f;
        self.spotlightView.scale = 0.5f;
        if (view == self.topLeftView) {
            self.topLeftView = self.spotlightView;
        } else if (view == self.topRightView) {
            self.topRightView = self.spotlightView;
        } else if (view == self.bottomLeftView) {
            self.bottomLeftView = self.spotlightView;
        } else if (view == self.bottomRightView) {
            self.bottomRightView = self.spotlightView;
        }
        [self.spotlightView removeGestureRecognizer:self.longPressGestureRecognizer];
        self.spotlightView = view;
        [self.spotlightView addGestureRecognizer:self.longPressGestureRecognizer];
        [UIView animateWithDuration:0.4f animations:^{
            [self updateViews];
        } completion:^(BOOL finishedSecondAnimation) {
            self.animationInProgress = NO;
        }];
    }];
    
    self.animationInProgress = YES;
}

- (void)getNextBackgroundImage:(BOOL)update {
    self.nextBackgroundImage = nil;
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:self.backgroundPhotos[self.currentBackgroundPhotoIndex] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (!error) {
            self.nextBackgroundImage = image;
            if (update) {
                [self updateBackgroundImage];
            }
        }
    }];
}

- (void)updateBackgroundImage {
    if (self.nextBackgroundImage) {
        [UIView transitionWithView:self.backgroundView duration:0.4f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.backgroundView.image = [self.nextBackgroundImage applyBlurWithRadius:kBackgroundBlurRadius tintColor:[UIColor colorWithWhite:0 alpha:kBackgroundBlurDarkeningRatio] saturationDeltaFactor:kBackgroundBlurSaturationDeltaFactor maskImage:nil];
        } completion:nil];
        self.backgroundView.frame = CGRectMake(0, 0, CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
        self.backgroundView.centerX = self.view.centerX + 20;
        [self startBackgroundAnimation];
    } else {
        [self getNextBackgroundImage:YES];
    }
}

- (void)startBackgroundAnimation {
    [UIView animateWithDuration:10 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.backgroundView.centerX = self.view.centerX - 20;
    } completion:nil];
    [self performSelector:@selector(updateBackgroundImage) withObject:self afterDelay:9.6f];
    self.currentBackgroundPhotoIndex++;
    if (self.currentBackgroundPhotoIndex >= [self.backgroundPhotos count]) {
        self.currentBackgroundPhotoIndex = 0;
    }
    [self getNextBackgroundImage:NO];
}

- (void)longPressOnSpotlightView:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self share];
    }
}

- (void)share {
    CGSize snapshotViewSize = self.spotlightView == self.leaderboardRankingView ? kBigSnapshotViewSize : kSmallSnapshotViewSize;
    self.currentSnapshotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, snapshotViewSize.width, snapshotViewSize.height)];
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.currentSnapshotView.bounds];
    if (self.spotlightView == self.firstPhotoView) {
        backgroundView.image = [self.firstPhotoView.image applyBlurWithRadius:kBackgroundBlurRadius tintColor:[UIColor colorWithWhite:0 alpha:kBackgroundBlurDarkeningRatio] saturationDeltaFactor:kBackgroundBlurSaturationDeltaFactor maskImage:nil];
    } else {
        backgroundView.image = self.backgroundView.image;
    }
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    [self.currentSnapshotView addSubview:backgroundView];
    UIImage *watermarkImage = [UIImage imageNamed:@"InstamaniacLogo"];
    CGFloat watermarkImageHeightRatio = watermarkImage.size.height/watermarkImage.size.width;
    UIImageView *watermarkView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSnapshotWatermarkWidth, kSnapshotWatermarkWidth*watermarkImageHeightRatio)];
    watermarkView.image = [[watermarkImage scaledToSize:watermarkView.size] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    watermarkView.tintColor = [UIColor whiteColor];
    [self.currentSnapshotView addSubview:watermarkView];
    watermarkView.right = self.currentSnapshotView.right - 10;
    watermarkView.bottom = self.currentSnapshotView.bottom - 10;
    
    UIImageView *contentView = [[UIImageView alloc] initWithImage:[UIImage convertViewToImage:self.spotlightView.sharingView]];
    [self.currentSnapshotView addSubview:contentView];
    contentView.center = self.currentSnapshotView.center;
    if (self.spotlightView == self.firstPhotoView || self.spotlightView == self.followingRankingView) {
        contentView.top -= 10;
    }
    [self sendSnapshotToInstagram];
}

- (void)sendSnapshotToInstagram {
    UIImage *snapshot = [UIImage convertViewToImage:self.currentSnapshotView];
    if ([FSOpenInInstagram canSendInstagram]) {
        [self.instagrammer postImage:snapshot caption:NSLocalizedString(@"#instamaniac @instamaniacapp", nil) inView:self.view delegate:self];
    } else {
        UIImageWriteToSavedPhotosAlbum(snapshot, nil, nil, nil);
        [[IMAlertManager sharedInstance] showErrorNotificationWithText:NSLocalizedString(@"Please install Instagram", nil)];
    }
}

- (void)logOut {
    self.HUD.indicatorView = [[JGProgressHUDIndeterminateIndicatorView alloc] initWithHUDStyle:JGProgressHUDStyleLight];
    self.HUD.textLabel.text = nil;
    if (!self.HUD.isVisible) {
        [self.HUD showInView:self.view];
    }
    [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
        [self.HUD dismiss];
        if (!error) {
            [[IMInstagramUserInfoManager sharedInstance] reset];
            NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
            [NSURLCache setSharedURLCache:sharedCache];
            for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
            [self.navigationController pushViewController:[IMAuthorizationViewController new] animated:YES];
        } else {
            [[IMAlertManager sharedInstance] showErrorNotificationWithText:NSLocalizedString(@"Something went wrong. Please try again", nil)];
        }
    }];
}

#pragma mark UIDocumentInteractionControllerDelegate

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    NSString *spotlightViewDescription = @"";
    if (self.spotlightView == self.globalRankingView) {
        spotlightViewDescription = @"Global percentile";
    } else if (self.spotlightView == self.followingRankingView) {
        spotlightViewDescription = @"Following circle";
    } else if (self.spotlightView == self.leaderboardRankingView) {
        spotlightViewDescription = @"Following leaderboard";
    } else if (self.spotlightView == self.lineChartView) {
        spotlightViewDescription = @"Likes and comments";
    } else if (self.spotlightView == self.firstPhotoView) {
        spotlightViewDescription = @"First photo";
    }
    [[SEGAnalytics sharedAnalytics] track:@"Shared"
                               properties:@{ @"stat": spotlightViewDescription }];
}

@end
