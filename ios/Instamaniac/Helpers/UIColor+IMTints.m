#import "UIColor+IMTints.h"

@implementation UIColor (IMTints)

#define AGEColorImplement(COLOR_NAME,RED,GREEN,BLUE)    \
+ (UIColor *)COLOR_NAME{    \
static UIColor* COLOR_NAME##_color;    \
static dispatch_once_t COLOR_NAME##_onceToken;   \
dispatch_once(&COLOR_NAME##_onceToken, ^{    \
COLOR_NAME##_color = [UIColor colorWithRed:RED green:GREEN blue:BLUE alpha:1.0];  \
}); \
return COLOR_NAME##_color;  \
}

AGEColorImplement(im_primaryColor, 0.20f, 0.25f, 0.33f)
AGEColorImplement(im_accentColor, 0.91f, 0.74f, 0.38f)

@end
