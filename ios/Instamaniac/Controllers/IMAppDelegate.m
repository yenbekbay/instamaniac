#import "IMAppDelegate.h"

#import "IMAuthorizationViewController.h"
#import "IMUserStatsViewController.h"
#import "UIColor+IMTints.h"
#import "UIColor+IMTints.h"
#import "UIFont+OpenSans.h"
#import <Analytics.h>
#import <Crashlytics/Crashlytics.h>
#import <Fabric/Fabric.h>
#import <Parse/Parse.h>
#import <SDStatusBarManager.h>

@implementation IMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SEGAnalytics setupWithConfiguration:[SEGAnalyticsConfiguration configurationWithWriteKey:kSegmentWriteKey]];
    [Parse setApplicationId:kParseApplicationId
                  clientKey:kParseClientKey];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    self.navigationController = [UINavigationController new];
    [self setUpNavigationBar];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.tintColor = [UIColor im_accentColor];
    self.window.rootViewController = self.navigationController;
    
#ifdef SNAPSHOT
    [[SDStatusBarManager sharedInstance] enableOverrides];
    [PFUser logInWithUsernameInBackground:@"test" password:@"test" block:^(PFUser *user, NSError *error) {
        self.navigationController.viewControllers = @[[IMUserStatsViewController new]];
        [self.window makeKeyAndVisible];
    }];
#else
    if ([PFUser currentUser]) {
        self.navigationController.viewControllers = @[[IMUserStatsViewController new]];
    } else {
        self.navigationController.viewControllers = @[[IMAuthorizationViewController new]];
    }
    [self.window makeKeyAndVisible];
#endif
    
    return YES;
}

#pragma mark Private

- (void)setUpNavigationBar {
    NSDictionary *attributes = @{ NSFontAttributeName: [UIFont openSansFontOfSize:17],
                                  NSForegroundColorAttributeName: [UIColor whiteColor] };
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor im_primaryColor]];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = nil;
    self.navigationController.navigationBar.translucent = YES;
}

@end
