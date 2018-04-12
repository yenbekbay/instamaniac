#import "IMInstagramUser.h"

@implementation IMInstagramUser

@dynamic instagramId;
@dynamic username;
@dynamic name;
@dynamic picture;
@dynamic followers;
@dynamic following;
@dynamic media;
@dynamic accessToken;

#pragma mark PFSubclassing

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"InstagramUser";
}

@end
