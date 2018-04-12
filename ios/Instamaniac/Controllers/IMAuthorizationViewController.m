#import "IMAuthorizationViewController.h"

#import "IMInstagramUser.h"
#import "IMInstagramUserInfoManager.h"
#import "IMUserStatsViewController.h"
#import "UIColor+AYHelpers.h"
#import "UIColor+IMTints.h"
#import "UIFont+IMSizes.h"
#import "UIFont+OpenSans.h"
#import "UIImage+AYHelpers.h"
#import "UILabel+AYHelpers.h"
#import "UIView+AYUtils.h"
#import <JGProgressHUD/JGProgressHUD.h>
#import <Parse/Parse.h>

UIEdgeInsets const kLogoMargin = {150, 30, 0, 30};
UIEdgeInsets const kWelcomeTitleLabelMargin = {40, 30, 0, 30};
UIEdgeInsets const kWelcomeBodyLabelMargin = {20, 30, 0, 30};
UIEdgeInsets const kInstagramButtonMargin = {0, 30, 75, 30};
UIEdgeInsets const kInstagramButtonInsets = {10, 10, 10, 10};
CGFloat const kInstagramButtonHeight = 60;
CGFloat const kInstagramButtonCornerRadius = 10;

@interface IMAuthorizationViewController ()

@property (nonatomic) UIImageView *logo;
@property (nonatomic) UILabel *welcomeTitleLabel;
@property (nonatomic) UILabel *welcomeBodyLabel;
@property (nonatomic) UIButton *instagramButton;

@end

@implementation IMAuthorizationViewController

#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor im_primaryColor];
    self.title = NSLocalizedString(@"Welcome", nil);
    self.navigationItem.hidesBackButton = YES;
    self.view.clipsToBounds = YES;
    [self setUpViews];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.logo.top = kLogoMargin.top;
    self.logo.centerX = self.view.centerX;
    self.welcomeTitleLabel.top = self.logo.bottom + kWelcomeTitleLabelMargin.top;
    self.welcomeBodyLabel.top = self.welcomeTitleLabel.bottom + kWelcomeBodyLabelMargin.top;
    self.instagramButton.bottom = self.view.height - kInstagramButtonMargin.bottom;
    self.instagramButton.centerX = self.view.centerX;
}

#pragma mark Private

- (void)setUpViews {
    UIImage *logoImage = [UIImage imageNamed:@"InstamaniacLogo"];
    CGFloat logoImageRatio = logoImage.size.height/logoImage.size.width;
    CGSize logoImageSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - kLogoMargin.left - kLogoMargin.right, (CGRectGetWidth([UIScreen mainScreen].bounds) - kLogoMargin.left - kLogoMargin.right)*logoImageRatio);
    self.logo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, logoImageSize.width, logoImageSize.height)];
    self.logo.image = [[logoImage scaledToSize:logoImageSize] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.logo.tintColor = [UIColor im_accentColor];
    [self.view addSubview:self.logo];
    
    self.welcomeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kWelcomeTitleLabelMargin.left, 0, CGRectGetWidth([UIScreen mainScreen].bounds) - kWelcomeTitleLabelMargin.left - kWelcomeTitleLabelMargin.right, 0)];
    self.welcomeTitleLabel.font = [UIFont openSansLightFontOfSize:[UIFont largeTextFontSize]];
    self.welcomeTitleLabel.textColor = [UIColor im_accentColor];
    self.welcomeTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.welcomeTitleLabel.text = NSLocalizedString(@"Hi there!", nil);
    [self.welcomeTitleLabel setFrameToFitWithHeightLimit:0];
    [self.view addSubview:self.welcomeTitleLabel];
    
    self.welcomeBodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(kWelcomeBodyLabelMargin.left, 0, CGRectGetWidth([UIScreen mainScreen].bounds) - kWelcomeBodyLabelMargin.left - kWelcomeBodyLabelMargin.right, 0)];
    self.welcomeBodyLabel.font = [UIFont openSansFontOfSize:[UIFont mediumTextFontSize]];
    self.welcomeBodyLabel.textColor = [UIColor whiteColor];
    self.welcomeBodyLabel.textAlignment = NSTextAlignmentCenter;
    self.welcomeBodyLabel.numberOfLines = 0;
    self.welcomeBodyLabel.text = NSLocalizedString(@"To get started, please introduce yourself:", nil);
    [self.welcomeBodyLabel setFrameToFitWithHeightLimit:0];
    [self.view addSubview:self.welcomeBodyLabel];
    
    self.instagramButton = [[UIButton alloc] initWithFrame:CGRectMake(kInstagramButtonMargin.left, 0, CGRectGetWidth([UIScreen mainScreen].bounds) - kInstagramButtonMargin.left - kInstagramButtonMargin.right, kInstagramButtonHeight)];
    [self.instagramButton setBackgroundImage:[UIImage imageWithColor:[UIColor im_accentColor]] forState:UIControlStateNormal];
    [self.instagramButton setBackgroundImage:[UIImage imageWithColor:[[UIColor im_accentColor] darkerColor:0.1f]] forState:UIControlStateHighlighted];
    [self.instagramButton setTitle:NSLocalizedString(@"Connect with Instagram", nil) forState:UIControlStateNormal];
    
    CGSize instagramButtonIconSize = CGSizeMake(kInstagramButtonHeight - kInstagramButtonInsets.top - kInstagramButtonInsets.bottom, kInstagramButtonHeight - kInstagramButtonInsets.top - kInstagramButtonInsets.bottom);
    UIImageView *instagramButtonIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kInstagramButtonInsets.left, kInstagramButtonInsets.top, instagramButtonIconSize.width, instagramButtonIconSize.height)];
    instagramButtonIconView.tintColor = [UIColor im_primaryColor];
    instagramButtonIconView.contentMode = UIViewContentModeScaleAspectFit;
    instagramButtonIconView.image = [[[UIImage imageNamed:@"InstagramIcon"] scaledToSize:instagramButtonIconSize] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.instagramButton addSubview:instagramButtonIconView];
    
    self.instagramButton.adjustsImageWhenHighlighted = NO;
    self.instagramButton.titleLabel.font = [UIFont openSansFontOfSize:[UIFont buttonFontSize]];
    self.instagramButton.clipsToBounds = YES;
    self.instagramButton.layer.cornerRadius = kInstagramButtonCornerRadius;
    self.instagramButton.titleEdgeInsets = UIEdgeInsetsMake(0, kInstagramButtonInsets.left + instagramButtonIconSize.width, 0, 0);
    [self.instagramButton setTitleColor:[UIColor im_primaryColor] forState:UIControlStateNormal];
    [self.instagramButton addTarget:self action:@selector(instagramButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.instagramButton];
}

- (void)instagramButtonTapped {
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleLight];
    [HUD showInView:self.view];
    [[IMInstagramUserInfoManager sharedInstance] authorizeWithBlock:^(IMInstagramUser *instagramUser, NSError *authorizationError) {
        if (!authorizationError && instagramUser) {
            [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *userError) {
                [HUD dismiss];
                if (!userError) {
                    user[@"instagramUser"] = instagramUser;
                    [user saveEventually];
                    [self.navigationController pushViewController:[IMUserStatsViewController new] animated:YES];
                }
            }];
        } else {
            [HUD dismiss];
        }
    }];
}

@end
