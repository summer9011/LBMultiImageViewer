//
//  LBImageScrollView.m
//  MultiImageViewer
//
//  Created by 赵立波 on 2017/9/7.
//
//

#import "LBImageScrollView.h"
#import "LBDetailScrollView.h"

@interface LBImageScrollView () <UIScrollViewDelegate, LBDetailScrollViewDelegate>

@property (nonatomic, assign) CGFloat oldOffsetX;

@property (nonatomic, weak) UIScrollView *contentScrollView;

@property (nonatomic, strong) LBConfigModel *config;

@end

@implementation LBImageScrollView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    LBConfigModel *config = [[LBConfigModel alloc] init];
    config.retryTitle = @"Retry";
    config.playTitle = @"Play";
    return [self initWithFrame:frame imageIndex:0 config:config];
}

- (instancetype)initWithFrame:(CGRect)frame imageIndex:(NSUInteger)index config:(LBConfigModel *)config {
    self = [super initWithFrame:frame];
    
    if (self) {
        _currentImageIndex = index;
        _config = config;
        [self initSelfView];
    }
    
    return self;
}

#pragma mark - Setup

- (void)initSelfView {
    CGRect bounds = [UIScreen mainScreen].bounds;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(bounds) + LBImageScrollOffset, CGRectGetHeight(bounds))];
    scrollView.backgroundColor = [UIColor colorWithRed:61/255.f green:60/255.f blue:63/255.f alpha:1.f];
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self addSubview:scrollView];
    
    self.contentScrollView = scrollView;
}

#pragma mark - Public Method

- (void)showInView:(UIView *)parentView {
    [parentView addSubview:self];
}

- (void)reloadData {
    [self setContents];
    [self loadImageView];
    
    if ([self.imageScrollDelegate respondsToSelector:@selector(didReloadImageScroll)]) {
        [self.imageScrollDelegate didReloadImageScroll];
    }
}

- (void)setScrollViewContentSizeByImageCount:(NSUInteger)imageCount {
    CGRect bounds = [UIScreen mainScreen].bounds;
    self.contentScrollView.contentSize = CGSizeMake(CGRectGetWidth(bounds) * imageCount, CGRectGetHeight(bounds));
}

- (UIImage *)currentImage {
    LBDetailScrollView *detailScroll = self.contentScrollView.subviews[self.currentImageIndex];
    return detailScroll.imageView.image;
}

#pragma mark - Private Method

- (void)setContents {
    [self.contentScrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    
    NSUInteger imageCount = [self.imageScrollDelegate numberOfItems];
    
    for (int i = 0; i < imageCount; i ++) {
        LBDetailScrollView *scrollView = [[LBDetailScrollView alloc] initWithFrame:CGRectMake((CGRectGetWidth(bounds) + LBImageScrollOffset) * i, 0, CGRectGetWidth(bounds), CGRectGetHeight(bounds)) config:self.config];
        scrollView.detailDelegate = self;
        [self.contentScrollView addSubview:scrollView];
    }
    
    self.contentScrollView.contentSize = CGSizeMake((CGRectGetWidth(bounds) + LBImageScrollOffset) * imageCount, CGRectGetHeight(bounds));
    self.contentScrollView.contentOffset = CGPointMake((CGRectGetWidth(bounds) + LBImageScrollOffset) * self.currentImageIndex, 0);
}

- (void)loadImageView {
    [self setImageContentsWithIndex:self.currentImageIndex];
    
    //Set left image.
    NSInteger leftIndex = self.currentImageIndex - 1;
    if (leftIndex >= 0) {
        [self setImageContentsWithIndex:leftIndex];
    }
    
    //Set right image.
    NSInteger rightIndex = self.currentImageIndex + 1;
    if (rightIndex <= [self.imageScrollDelegate numberOfItems] - 1) {
        [self setImageContentsWithIndex:rightIndex];
    }
}

- (void)setImageContentsWithIndex:(NSUInteger)index {
    NSInteger imageCount = [self.imageScrollDelegate numberOfItems];
    if (imageCount > 0 && index <= imageCount - 1) {
        LBDetailScrollView *imageScroll = self.contentScrollView.subviews[index];
        [imageScroll setImageContentWithIndex:index];
    }
}

- (void)clearUnusedImage {
    NSInteger prevIndex = self.currentImageIndex - 4;
    if (prevIndex >= 0) {
        for (NSInteger i = prevIndex; i >= 0; i --) {
            LBDetailScrollView *imageScroll = self.contentScrollView.subviews[i];
            [imageScroll clearImage];
        }
    }
    
    NSUInteger imageCount = [self.imageScrollDelegate numberOfItems];
    NSInteger nextIndex = self.currentImageIndex + 4;
    if (nextIndex < imageCount) {
        for (NSInteger i = nextIndex; i < imageCount; i ++) {
            LBDetailScrollView *imageScroll = self.contentScrollView.subviews[i];
            [imageScroll clearImage];
        }
    }
}

#pragma mark - LBDetailScrollViewDelegate

- (LBImageModel *)LBDetailScrollGetImageModelWithIndex:(NSUInteger)index {
    return [self.imageScrollDelegate imageModelForIndex:index];
}

- (void)LBDetailScrollReloadImage:(LBDetailScrollView *)scrollView {
    NSUInteger index = [self.contentScrollView.subviews indexOfObject:scrollView];
    [self setImageContentsWithIndex:index];
}

- (void)LBDetailScrollSingleTapOnImage:(LBDetailScrollView *)scrollView {
    if ([self.imageScrollDelegate respondsToSelector:@selector(didSingleTapImageWithIndex:)]) {
        [self.imageScrollDelegate didSingleTapImageWithIndex:self.currentImageIndex];
    }
}

- (void)LBDetailScrollDoubleTapOnImage:(LBDetailScrollView *)scrollView zoomUp:(BOOL)zoomUp {
    if ([self.imageScrollDelegate respondsToSelector:@selector(didDoubleTapImageWithIndex:zoomUp:)]) {
        [self.imageScrollDelegate didDoubleTapImageWithIndex:self.currentImageIndex zoomUp:zoomUp];
    }
}

- (void)LBDetailScrollLongPressOnImage:(LBDetailScrollView *)scrollView {
    if ([self.imageScrollDelegate respondsToSelector:@selector(didLongPressImageWithIndex:)]) {
        [self.imageScrollDelegate didLongPressImageWithIndex:self.currentImageIndex];
    }
}

- (void)LBDetailScrollBeginLoad:(LBDetailScrollView *)scrollView {
    NSUInteger index = [self.contentScrollView.subviews indexOfObject:scrollView];
    if (index == self.currentImageIndex && [self.imageScrollDelegate respondsToSelector:@selector(imageViewBeginLoad)]) {
        [self.imageScrollDelegate imageViewBeginLoad];
    }
}

- (void)LBDetailScrollLoadSuccess:(LBDetailScrollView *)scrollView {
    NSUInteger index = [self.contentScrollView.subviews indexOfObject:scrollView];
    if (index == self.currentImageIndex && [self.imageScrollDelegate respondsToSelector:@selector(imageViewLoadSuccess)]) {
        [self.imageScrollDelegate imageViewLoadSuccess];
    }
}

- (void)LBDetailScrollPlayVideo:(LBDetailScrollView *)scrollView {
    NSUInteger index = [self.contentScrollView.subviews indexOfObject:scrollView];
    if (index == self.currentImageIndex && [self.imageScrollDelegate respondsToSelector:@selector(didPlayVideo:)]) {
        [self.imageScrollDelegate didPlayVideo:index];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect bounds = [UIScreen mainScreen].bounds;
    
    NSUInteger minIndex = ceilf(scrollView.contentOffset.x/((CGRectGetWidth(bounds) + LBImageScrollOffset)));
    NSUInteger maxIndex = floorf(scrollView.contentOffset.x/((CGRectGetWidth(bounds) + LBImageScrollOffset)));
    
    if (scrollView.isDragging) {
        if (scrollView.contentOffset.x > self.oldOffsetX) {
            NSUInteger imageCount = [self.imageScrollDelegate numberOfItems];
            if (self.currentImageIndex != maxIndex && maxIndex <= imageCount - 1) {
                _currentImageIndex = maxIndex;
                [self loadImageView];
            }
        } else {
            if (self.currentImageIndex != minIndex) {
                if (minIndex <= 0) {
                    minIndex = 0;
                }
                _currentImageIndex = minIndex;
                [self loadImageView];
            }
        }
    }
    self.oldOffsetX = scrollView.contentOffset.x;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGRect bounds = [UIScreen mainScreen].bounds;
    NSUInteger index = floorf(scrollView.contentOffset.x/((CGRectGetWidth(bounds) + LBImageScrollOffset)));
    if ([self.imageScrollDelegate respondsToSelector:@selector(didChangeImageView:)]) {
        [self.imageScrollDelegate didChangeImageView:index];
    }
    
    [self clearUnusedImage];
}

#pragma mark - Setter

- (void)setImageScrollDelegate:(id<LBImageScrollDelegate>)imageScrollDelegate {
    _imageScrollDelegate = imageScrollDelegate;
    
    [self reloadData];
}

@end

