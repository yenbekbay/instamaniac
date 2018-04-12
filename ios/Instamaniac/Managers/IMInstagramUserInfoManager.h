#import "IMInstagramUser.h"
#import <Foundation/Foundation.h>
#import <InstagramKit/InstagramKit.h>

typedef NS_ENUM(NSInteger, IMGettingMediaStage) {
    IMGettingMediaStageLoading = 0,
    IMGettingMediaStageParsing = 1
};

@interface IMInstagramUserInfoManager : NSObject

#pragma mark Properties

@property (nonatomic) IMInstagramUser *instagramUser;
@property (nonatomic) NSArray *media;

#pragma mark Methods

+ (instancetype)sharedInstance;
- (void)authorizeWithBlock:(void (^)(IMInstagramUser *instagramUser, NSError *error))completionBlock;
- (void)getCurrentInstagramUser:(void (^)(IMInstagramUser *instagramUser, NSError *error))completionBlock;
- (void)getTotalUserCount:(void (^)(NSNumber *totalUserCount, NSError *error))completionBlock;
- (void)getRecentPhotos:(void (^)(NSArray *photos, NSError *error))completionBlock;
- (void)getNumberOfFollowingWhoSignedUpLater:(void (^)(NSInteger number, NSError *error))completionBlock;
- (void)getSortedFollowingPlusCurrentUser:(void (^)(NSArray *users, NSError *error))completionBlock;
- (void)getAllMediaCountries:(void (^)(IMGettingMediaStage stage, NSUInteger currentIndex, NSUInteger totalIndex))progressBlock completionBlock:(void (^)(NSArray *countries, NSError *error))completionBlock;
- (void)getFirstPhoto:(void (^)(IMGettingMediaStage stage, NSUInteger currentIndex, NSUInteger totalIndex))progressBlock completionBlock:(void (^)(InstagramMedia *photo, NSError *error))completionBlock;
- (void)getLikesAndCommentsForTheLastYear:(void (^)(NSArray *dates, NSArray *likes, NSArray *comments, NSError *error))completionBlock;
- (void)reset;

@end
