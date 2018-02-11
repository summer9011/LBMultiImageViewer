//
//  LBImageScrollView.h
//  MultiImageViewer
//
//  Created by 赵立波 on 2017/9/7.
//
//

#import <UIKit/UIKit.h>
#import "LBImageModel.h"

@protocol LBImageScrollDelegate <NSObject>

@required

- (NSUInteger)numberOfItems;

- (LBImageModel *)imageModelForIndex:(NSUInteger)index;

@optional

- (void)didSingleTapImageWithIndex:(NSUInteger)index;

- (void)didDoubleTapImageWithIndex:(NSUInteger)index zoomUp:(BOOL)isZoomUp;

- (void)didLongPressImageWithIndex:(NSUInteger)index;

- (void)didChangeImageView:(NSUInteger)index;

- (void)didReloadImageScroll;

- (void)imageViewBeginLoad;

- (void)imageViewLoadSuccess;

@end

@interface LBImageScrollView : UIView

@property (nonatomic, weak) id<LBImageScrollDelegate> imageScrollDelegate;

- (instancetype)initWithFrame:(CGRect)frame imageIndex:(NSUInteger)index;

- (void)showInView:(UIView *)parentView;

- (void)reloadData;

- (void)setScrollViewContentSizeByImageCount:(NSUInteger)imageCount;

@property (nonatomic, assign, readonly) NSUInteger currentImageIndex;

- (UIImage *)currentImage;

@end
