#import "IMAlertManager.h"

#import "UIFont+OpenSans.h"
#import "UIFont+IMSizes.h"
#import <ChameleonFramework/Chameleon.h>
#import <CRToast/CRToast.h>

@implementation IMAlertManager

#pragma mark Initialization

+ (instancetype)sharedInstance {
    static IMAlertManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [IMAlertManager new];
    });
    return _sharedInstance;
}

#pragma mark Public

- (void)showErrorNotificationWithText:(NSString *)text {
    [self showNotificationWithText:text color:[UIColor flatRedColor]];
}

- (void)showNotificationWithText:(NSString *)text color:(UIColor *)color {
    [self showNotificationWithText:text color:color statusBar:NO];
}

- (void)showNotificationWithText:(NSString *)text color:(UIColor *)color statusBar:(BOOL)statusBar {
    NSDictionary *options = @{ kCRToastNotificationTypeKey : statusBar ? @(CRToastTypeStatusBar) : @(CRToastTypeNavigationBar),
                               kCRToastTextKey : text,
                               kCRToastFontKey : [UIFont openSansFontOfSize:[UIFont mediumTextFontSize]],
                               kCRToastBackgroundColorKey : color,
                               kCRToastAnimationInTypeKey : @(CRToastAnimationTypeSpring),
                               kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeSpring),
                               kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                               kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionBottom) };
    [CRToastManager showNotificationWithOptions:options completionBlock:nil];
}

@end
