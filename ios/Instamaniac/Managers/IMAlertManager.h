#import <Foundation/Foundation.h>

@interface IMAlertManager : NSObject

+ (instancetype)sharedInstance;
- (void)showErrorNotificationWithText:(NSString *)text;
- (void)showNotificationWithText:(NSString *)text color:(UIColor *)color;
- (void)showNotificationWithText:(NSString *)text color:(UIColor *)color statusBar:(BOOL)statusBar;

@end
