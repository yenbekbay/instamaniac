#import "NSDate+IMHelpers.h"

@implementation NSDate (IMHelpers)

+ (NSArray *)lastMonths:(NSInteger)numberOfMonths {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [date monthComponents];
    NSMutableArray *months = [NSMutableArray new];
    for (NSInteger i = 0; i < numberOfMonths; i++) {
        NSDateComponents *newComponents = [components copy];
        newComponents.month = components.month - i;
        [months addObject:[calendar dateFromComponents:newComponents]];
    }
    return [[months reverseObjectEnumerator] allObjects];
}

- (NSDateComponents *)monthComponents {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth);
    return [calendar components:preservedComponents fromDate:self];
}

@end
