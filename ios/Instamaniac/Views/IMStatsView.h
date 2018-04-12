#import <UIKit/UIKit.h>

@interface IMStatsView : UIView

#pragma mark Properties

@property (nonatomic) CGFloat scale;
@property (nonatomic) BOOL loaded;
@property (nonatomic,getter=isForSharing) BOOL forSharing;
@property (nonatomic) IMStatsView *sharingView;
@property (nonatomic) UIView *contentView;

#pragma mark Methods

- (instancetype)initWithFrame:(CGRect)frame animated:(BOOL)animated;
- (void)show;
- (void)generateSharingView;

@end
