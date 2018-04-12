#import "IMInstagramUserInfoManager.h"

#import "IMAlertManager.h"
#import "NSDate+IMHelpers.h"
#import <CoreLocation/CoreLocation.h>
#import <IOS-Offline-GeoCoder/reverseGeoCoder.h>
#import <Parse/Parse.h>
#import <SimpleAuth/SimpleAuth.h>

NSString * const kInstagramUserMediaKey = @"kInstagramUserMediaKey";

@interface IMInstagramUserInfoManager ()

@property (nonatomic) InstagramEngine *engine;
@property (nonatomic) reverseGeoCoder *geocoder;

@end

@implementation IMInstagramUserInfoManager

#pragma mark Initialization

+ (instancetype)sharedInstance {
    static IMInstagramUserInfoManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [IMInstagramUserInfoManager new];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    self.engine = [InstagramEngine sharedEngine];
    self.geocoder = [reverseGeoCoder new];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kInstagramUserMediaKey]) {
        _media = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kInstagramUserMediaKey]];
    }
    return self;
}

#pragma mark Public

- (void)getCurrentInstagramUser:(void (^)(IMInstagramUser *instagramUser, NSError *error))completionBlock {
    if (!completionBlock) return;
    if (self.instagramUser) { 
        [self.instagramUser fetchIfNeededInBackgroundWithBlock:^(PFObject *instagramUserObject, NSError *instagramUserError) {
            if (!instagramUserError) {
                completionBlock(self.instagramUser, nil);
            } else {
                completionBlock(nil, instagramUserError);
            }
        }];
    } else if ([PFUser currentUser]) {
        [[PFUser currentUser] fetchIfNeededInBackgroundWithBlock:^(PFObject *userObject, NSError *userError) {
            if (!userError) {
                [userObject[@"instagramUser"] fetchIfNeededInBackgroundWithBlock:^(PFObject *instagramUserObject, NSError *instagramUserError) {
                    if (!instagramUserError) {
                        self.instagramUser = (IMInstagramUser *)instagramUserObject;
                        self.engine.accessToken = self.instagramUser.accessToken;
                        completionBlock(self.instagramUser, nil);
                    } else {
                        completionBlock(nil, instagramUserError);
                    }
                }];
            } else {
                completionBlock(nil, userError);
            }
        }];
    } else {
        completionBlock(nil, [NSError new]);
    }
}

- (void)authorizeWithBlock:(void (^)(IMInstagramUser *instagramUser, NSError *error))completionBlock {
    if (!completionBlock) return;
    SimpleAuth.configuration[@"instagram"] = @{
        @"client_id" : [[NSBundle mainBundle] objectForInfoDictionaryKey:@"InstagramAppClientId"],
        SimpleAuthRedirectURIKey : [[NSBundle mainBundle] objectForInfoDictionaryKey:@"InstagramAppRedirectURL"]
    };
    [SimpleAuth authorize:@"instagram" completion:^(id responseObject, NSError *authorizationError) {
        if (!authorizationError) {
            self.engine.accessToken = responseObject[@"credentials"][@"token"];
            NSDictionary *instagramInfo = responseObject[@"extra"][@"raw_info"][@"data"];
            [PFCloud callFunctionInBackground:@"saveInstagramUser" withParameters:@{
              @"accessToken": responseObject[@"credentials"][@"token"],
              @"instagramId": instagramInfo[@"id"],
              @"username": instagramInfo[@"username"],
              @"name": instagramInfo[@"full_name"],
              @"picture": instagramInfo[@"profile_picture"],
              @"followers": instagramInfo[@"counts"][@"followed_by"],
              @"following": instagramInfo[@"counts"][@"follows"],
              @"media": instagramInfo[@"counts"][@"media"]
            } block:completionBlock];
        } else {
            [[IMAlertManager sharedInstance] showErrorNotificationWithText:NSLocalizedString(@"Something went wrong. Please try again", nil)];
            completionBlock(nil, authorizationError);
        }
    }];
}

- (void)getTotalUserCount:(void (^)(NSNumber *totalUserCount, NSError *error))completionBlock {
    if (!completionBlock) return;
    [PFCloud callFunctionInBackground:@"getTotalUserCount" withParameters:nil block:completionBlock];
}

- (void)getRecentPhotos:(void (^)(NSArray *photos, NSError *error))completionBlock {
    if (!completionBlock) return;
    [self getCurrentInstagramUser:^(IMInstagramUser *instagramUser, NSError *instagramUserError) {
        if (!instagramUserError) {
            [self.engine getSelfRecentMediaWithSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
                NSArray *photoMedia = [media filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    return ![evaluatedObject isVideo];
                }]];
                NSArray *photos = [photoMedia valueForKey:@"standardResolutionImageURL"];
                completionBlock(photos, nil);
            } failure:^(NSError *error, NSInteger serverStatusCode) {
                completionBlock(nil, error);
            }];
        } else {
            completionBlock(nil, instagramUserError);
        }
    }];
}

- (void)getLikesAndCommentsForTheLastYear:(void (^)(NSArray *dates, NSArray *likes, NSArray *comments, NSError *error))completionBlock {
    if (!completionBlock) return;
    NSArray *dates = [NSDate lastMonths:12];
#ifdef SNAPSHOT
    NSArray *likes = @[@50, @40, @30, @25, @70, @60, @100, @35, @40, @20, @45, @50];
    NSArray *comments = @[@5, @3, @2, @0, @1, @3, @4, @6, @10, @4, @2, @0];
    completionBlock(dates, likes, comments, nil);
#else
    NSMutableArray *mediaForDates = [NSMutableArray new];
    for (NSDate *date in dates) {
        [mediaForDates addObject:[self mediaForDate:date]];
    }
    NSMutableArray *likes = [NSMutableArray new];
    NSMutableArray *comments = [NSMutableArray new];
    for (NSArray *media in mediaForDates) {
        NSInteger likesForMediaObject = 0;
        NSInteger commentsForMediaObject = 0;
        for (InstagramMedia *mediaObject in media) {
            likesForMediaObject += mediaObject.likesCount;
            commentsForMediaObject += mediaObject.commentCount;
        }
        [likes addObject:@(likesForMediaObject)];
        [comments addObject:@(commentsForMediaObject)];
    }
    completionBlock(dates, likes, comments, nil);
#endif
}

- (NSArray *)mediaForDate:(NSDate *)date {
    return [self.media filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *createdDateComponents = [[evaluatedObject createdDate] monthComponents];
        NSDate *createdDate = [calendar dateFromComponents:createdDateComponents];
        return date == createdDate;
    }]];
}

- (void)getAllMedia:(void (^)(IMGettingMediaStage stage, NSUInteger currentIndex, NSUInteger totalIndex))progressBlock completionBlock:(void (^)(NSArray *media, NSError *error))completionBlock {
    if (!completionBlock) return;
    if (self.media) {
        completionBlock(self.media, nil);
    } else {
        [self getCurrentInstagramUser:^(IMInstagramUser *instagramUser, NSError *instagramUserError) {
            if (!instagramUserError) {
                [self.engine getSelfRecentMediaWithSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
                    NSMutableArray *allMedia = [media mutableCopy];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [self getMediaRecursively:allMedia paginationInfo:paginationInfo progressBlock:progressBlock completionBlock:completionBlock];
                    });
                } failure:^(NSError *error, NSInteger serverStatusCode) {
                    completionBlock(nil, error);
                }];
            } else {
                completionBlock(nil, instagramUserError);
            }
        }];
    }
}

- (void)getFirstPhoto:(void (^)(IMGettingMediaStage stage, NSUInteger currentIndex, NSUInteger totalIndex))progressBlock completionBlock:(void (^)(InstagramMedia *photo, NSError *error))completionBlock {
    if (!completionBlock) return;
    if (self.media) {
        InstagramMedia *firstPhoto = [self firstPhotoFromMedia:self.media];
        if (firstPhoto) {
            completionBlock(firstPhoto, nil);
        } else {
            completionBlock(nil, [NSError new]);
        }
    } else {
        [self getAllMedia:progressBlock completionBlock:^(NSArray *media, NSError *error) {
            if (!error) {
                self.media = media;
                InstagramMedia *firstPhoto = [self firstPhotoFromMedia:media];
                if (firstPhoto) {
                    completionBlock(firstPhoto, nil);
                } else {
                    completionBlock(nil, [NSError new]);
                }
            } else {
                completionBlock(nil, error);
            }
        }];
    }
}

- (InstagramMedia *)firstPhotoFromMedia:(NSArray *)media {
    NSArray *photos = [media filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return ![evaluatedObject isVideo];
    }]];
    if ([photos count] > 0) {
        return [photos lastObject];
    } else {
        return nil;
    }
}

- (void)getAllMediaCountries:(void (^)(IMGettingMediaStage stage, NSUInteger currentIndex, NSUInteger totalIndex))progressBlock completionBlock:(void (^)(NSArray *countries, NSError *error))completionBlock {
    if (!completionBlock) return;
    [self getAllMedia:(void (^)(IMGettingMediaStage stage, NSUInteger currentIndex, NSUInteger totalIndex))progressBlock completionBlock:^(NSArray *media, NSError *error) {
        if (!error) {
            self.media = media;
            NSMutableArray *visitedCountries = [NSMutableArray new];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self getCountriesRecursively:visitedCountries forMedia:media atIndex:0 progressBlock:progressBlock completionBlock:^(NSArray *countries) {
                    NSSet *countriesSet = [NSSet setWithArray:countries];
                    completionBlock([countriesSet allObjects], nil);
                }];
            });
        } else {
            completionBlock(nil, error);
        }
    }];
}

- (void)getCountriesRecursively:(NSMutableArray *)countries forMedia:(NSArray *)media atIndex:(NSUInteger)index progressBlock:(void (^)(IMGettingMediaStage stage, NSUInteger currentIndex, NSUInteger totalIndex))progressBlock completionBlock:(void (^)(NSArray *countries))completionBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        progressBlock(IMGettingMediaStageParsing, index + 1, [media count]);
    });
    [self getCountryForMedia:media atIndex:index completionBlock:^(BOOL succeeded, NSString *country, NSUInteger nextIndex) {
        if (succeeded) {
            [countries addObject:country];
        }
        if (nextIndex < [media count]) {
            [self getCountriesRecursively:countries forMedia:media atIndex:nextIndex progressBlock:progressBlock completionBlock:completionBlock];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(countries);
            });
        }
    }];
}

- (void)getCountryForMedia:(NSArray *)media atIndex:(NSUInteger)index completionBlock:(void (^)(BOOL succeeded, NSString *country, NSUInteger nextIndex))completionBlock {
    InstagramMedia *object = media[index];
    index++;
    if (CLLocationCoordinate2DIsValid(object.location) && object.locationName) {
        NSString *country  = [self.geocoder getCountryDetailWithKey:KeyISO2A withLocation:[[CLLocation alloc] initWithLatitude:object.location.latitude longitude:object.location.longitude]];
        completionBlock(YES, country, index);
    } else {
        completionBlock(NO, nil, index);
    }
}

- (void)getNumberOfFollowingWhoSignedUpLater:(void (^)(NSInteger number, NSError *error))completionBlock {
    if (!completionBlock) return;
    [self getFollowing:^(NSArray *following, NSError *followingError) {
        if (!followingError) {
            NSArray *usersWhoSignedUpLater = [following filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                return [[evaluatedObject Id] integerValue] > [self.instagramUser.instagramId integerValue];
            }]];
            completionBlock((NSInteger)[usersWhoSignedUpLater count], nil);
        } else {
            completionBlock(-1, followingError);
        }
    }];
}

- (void)getSortedFollowingPlusCurrentUser:(void (^)(NSArray *users, NSError *error))completionBlock {
    if (!completionBlock) return;
    [self getFollowing:^(NSArray *following, NSError *followingError) {
        if (!followingError) {
            NSMutableArray *followingPlusCurrentUser = [following mutableCopy];
            [self.engine getSelfUserDetailsWithSuccess:^(InstagramUser *user) {
                [followingPlusCurrentUser addObject:user];
                NSArray *usersSortedById = [followingPlusCurrentUser sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    if ([obj1 Id] == [obj2 Id] ) return NSOrderedSame;
                    return [[obj1 Id] integerValue] < [[obj2 Id] integerValue] ? NSOrderedAscending : NSOrderedDescending;
                }];
                completionBlock(usersSortedById, nil);
            } failure:^(NSError *error, NSInteger serverStatusCode) {
                completionBlock(nil, error);
            }];
        } else {
            completionBlock(nil, followingError);
        }
    }];
}

- (void)getFollowing:(void (^)(NSArray *following, NSError *error))completionBlock {
    if (!completionBlock) return;
    [self getCurrentInstagramUser:^(IMInstagramUser *instagramUser, NSError *instagramUserError) {
        if (!instagramUserError) {
            [self.engine getUsersFollowedByUser:instagramUser.instagramId withSuccess:^(NSArray *users, InstagramPaginationInfo *paginationInfo) {
                NSMutableArray *following = [users mutableCopy];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self getUsersRecursively:following paginationInfo:paginationInfo completionBlock:completionBlock];
                });
            } failure:^(NSError *error, NSInteger serverStatusCode) {
                completionBlock(nil, error);
            }];
        } else {
            completionBlock(nil, instagramUserError);
        }
    }];
}

- (void)getUsersRecursively:(NSMutableArray *)users paginationInfo:(InstagramPaginationInfo *)paginationInfo completionBlock:(void (^)(NSArray *users, NSError *error))completionBlock {
    if (!paginationInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(users, nil);
        });
    }
    [self.engine getPaginatedItemsForInfo:paginationInfo withSuccess:^(NSArray *objects, InstagramPaginationInfo *otherPaginationInfo) {
        [users addObjectsFromArray:objects];
        if (!otherPaginationInfo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(users, nil);
            });
        } else {
            [self getUsersRecursively:users paginationInfo:otherPaginationInfo completionBlock:completionBlock];
        }
    } failure:^(NSError *error, NSInteger serverStatusCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(nil, error);
        });
    }];
}

- (void)getMediaRecursively:(NSMutableArray *)media paginationInfo:(InstagramPaginationInfo *)paginationInfo progressBlock:(void (^)(IMGettingMediaStage stage, NSUInteger currentIndex, NSUInteger totalIndex))progressBlock completionBlock:(void (^)(NSArray *media, NSError *error))completionBlock {
    if (!paginationInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(media, nil);
        });
    }
    [self.engine getPaginatedItemsForInfo:paginationInfo withSuccess:^(NSArray *objects, InstagramPaginationInfo *otherPaginationInfo) {
        [media addObjectsFromArray:objects];
        dispatch_async(dispatch_get_main_queue(), ^{
            progressBlock(IMGettingMediaStageLoading, [media count], (NSUInteger)[self.instagramUser.media integerValue]);
        });
        if (!otherPaginationInfo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(media, nil);
            });
        } else {
            [self getMediaRecursively:media paginationInfo:otherPaginationInfo progressBlock:progressBlock completionBlock:completionBlock];
        }
    } failure:^(NSError *error, NSInteger serverStatusCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(nil, error);
        });
    }];
}

- (void)setMedia:(NSArray *)media {
    _media = media;
    NSData *mediaData = [NSKeyedArchiver archivedDataWithRootObject:media];
    [[NSUserDefaults standardUserDefaults] setObject:mediaData forKey:kInstagramUserMediaKey];
}

- (void)reset {
    self.instagramUser = nil;
    self.media = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kInstagramUserMediaKey];
}

@end
