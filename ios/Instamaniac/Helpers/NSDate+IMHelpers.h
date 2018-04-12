#import <Foundation/Foundation.h>

@interface NSDate (IMHelpers)

+ (NSArray *)lastMonths:(NSInteger)numberOfMonths;
- (NSDateComponents *)monthComponents;

@end
