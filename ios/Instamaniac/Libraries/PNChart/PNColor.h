//
//  Copyright (c) 2013年 kevinzhow.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
 *  System Versioning Preprocessor Macros
 */

#define SCREEN_WIDTH    ([UIScreen mainScreen].bounds.size.width)

#define PNGrey          [UIColor colorWithRed:246 / 255 green:246 / 255 blue:246 / 255 alpha:1]
#define PNLightBlue     [UIColor colorWithRed:94 / 255 green:147 / 255 blue:196 / 255 alpha:1]
#define PNGreen         [UIColor colorWithRed:77 / 255 green:186 / 255 blue:122 / 255 alpha:1]
#define PNTitleColor    [UIColor colorWithRed:0 / 255 green:189 / 255 blue:113 / 255 alpha:1]
#define PNButtonGrey    [UIColor colorWithRed:141 / 255 green:141 / 255 blue:141 / 255 alpha:1]
#define PNLightGreen    [UIColor colorWithRed:77 / 255 green:216 / 255 blue:122 / 255 alpha:1]
#define PNFreshGreen    [UIColor colorWithRed:77 / 255 green:196 / 255 blue:122 / 255 alpha:1]
#define PNDeepGreen     [UIColor colorWithRed:77 / 255 green:176 / 255 blue:122 / 255 alpha:1]
#define PNRed           [UIColor colorWithRed:245 / 255 green:94 / 255 blue:78 / 255 alpha:1]
#define PNMauve         [UIColor colorWithRed:88 / 255 green:75 / 255 blue:103 / 255 alpha:1]
#define PNBrown         [UIColor colorWithRed:119 / 255 green:107 / 255 blue:95 / 255 alpha:1]
#define PNBlue          [UIColor colorWithRed:82 / 255 green:116 / 255 blue:188 / 255 alpha:1]
#define PNDarkBlue      [UIColor colorWithRed:121 / 255 green:134 / 255 blue:142 / 255 alpha:1]
#define PNYellow        [UIColor colorWithRed:242 / 255 green:197 / 255 blue:117 / 255 alpha:1]
#define PNWhite         [UIColor colorWithRed:255 / 255 green:255 / 255 blue:255 / 255 alpha:1]
#define PNDeepGrey      [UIColor colorWithRed:99 / 255 green:99 / 255 blue:99 / 255 alpha:1]
#define PNPinkGrey      [UIColor colorWithRed:200 / 255 green:193 / 255 blue:193 / 255 alpha:1]
#define PNHealYellow    [UIColor colorWithRed:245 / 255 green:242 / 255 blue:238 / 255 alpha:1]
#define PNLightGrey     [UIColor colorWithRed:225 / 255 green:225 / 255 blue:225 / 255 alpha:1]
#define PNCleanGrey     [UIColor colorWithRed:251 / 255 green:251 / 255 blue:251 / 255 alpha:1]
#define PNLightYellow   [UIColor colorWithRed:241 / 255 green:240 / 255 blue:240 / 255 alpha:1]
#define PNDarkYellow    [UIColor colorWithRed:152 / 255 green:150 / 255 blue:159 / 255 alpha:1]
#define PNPinkDark      [UIColor colorWithRed:170 / 255 green:165 / 255 blue:165 / 255 alpha:1]
#define PNCloudWhite    [UIColor colorWithRed:244 / 255 green:244 / 255 blue:244 / 255 alpha:1]
#define PNBlack         [UIColor colorWithRed:45 / 255 green:45 / 255 blue:45 / 255 alpha:1]
#define PNStarYellow    [UIColor colorWithRed:252 / 255 green:223 / 255 blue:101 / 255 alpha:1]
#define PNTwitterColor  [UIColor colorWithRed:0 / 255 green:171 / 255 blue:243 / 255 alpha:1]
#define PNWeiboColor    [UIColor colorWithRed:250 / 255 green:0 / 255 blue:33 / 255 alpha:1]
#define PNiOSGreenColor [UIColor colorWithRed:98 / 255 green:247 / 255 blue:77 / 255 alpha:1]


@interface PNColor : NSObject

- (UIImage *)imageFromColor:(UIColor *)color;

@end
