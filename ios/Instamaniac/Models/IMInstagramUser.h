#import <Parse/Parse.h>

@interface IMInstagramUser : PFObject <PFSubclassing>

@property (nonatomic) NSString *instagramId;
@property (nonatomic) NSString *username;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *picture;
@property (nonatomic) NSNumber *followers;
@property (nonatomic) NSNumber *following;
@property (nonatomic) NSNumber *media;
@property (nonatomic) NSString *accessToken;

@end
