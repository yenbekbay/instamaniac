#import "IMStatsView.h"

#import "UIView+AYUtils.h"

@interface IMStatsView ()

@property (nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation IMStatsView

#pragma mark Initializaiton

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame animated:YES];
}

- (instancetype)initWithFrame:(CGRect)frame animated:(BOOL)animated {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    if (animated) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:self.bounds];
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        self.activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.activityIndicatorView];
        [self.activityIndicatorView startAnimating];
    }
    
    self.contentView = [[UIView alloc] initWithFrame:self.bounds];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (animated) {
        self.contentView.hidden = YES;
    }
    [self addSubview:self.contentView];
    _scale = 1;
    
    return self;
}

#pragma mark Public

- (void)show {
    [self.activityIndicatorView stopAnimating];
    [UIView transitionWithView:self duration:0.4f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.contentView.hidden = NO;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(generateSharingView) withObject:nil afterDelay:1];
    }];
}

- (void)generateSharingView { }

#pragma mark Setters

- (void)setScale:(CGFloat)scale {
    if (_scale == scale) return;
    _scale = scale;
    self.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)setSharingView:(IMStatsView *)sharingView {
    _sharingView = sharingView;
    sharingView.opaque = NO;
}

@end
