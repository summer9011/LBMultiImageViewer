//
//  LBDetailScrollView.h
//  MultiImageViewer
//
//  Created by 赵立波 on 2017/10/11.
//

#import <UIKit/UIKit.h>
#import "LBDetailImageView.h"

#define LBImageScrollLargeImageP 4
#define LBImageScrollOffset 20.f

@class LBDetailScrollView;
@class LBImageModel;

@protocol LBDetailScrollViewDelegate <NSObject>

@required

- (LBImageModel *)LBDetailScrollGetImageModelWithIndex:(NSUInteger)index;

@optional

- (void)LBDetailScrollReloadImage:(LBDetailScrollView *)scrollView;

- (void)LBDetailScrollSingleTapOnImage:(LBDetailScrollView *)scrollView;

- (void)LBDetailScrollDoubleTapOnImage:(LBDetailScrollView *)scrollView zoomUp:(BOOL)zoomUp;

- (void)LBDetailScrollLongPressOnImage:(LBDetailScrollView *)scrollView;

- (void)LBDetailScrollBeginLoad:(LBDetailScrollView *)scrollView;

- (void)LBDetailScrollLoadSuccess:(LBDetailScrollView *)scrollView;

@end

@interface LBDetailScrollView : UIScrollView

@property (nonatomic, weak) id<LBDetailScrollViewDelegate> detailDelegate;

@property (nonatomic, weak) LBDetailImageView *imageView;
@property (nonatomic, weak) UIActivityIndicatorView *activityView;
@property (nonatomic, weak) UIButton *reloadBtn;

- (void)setImageContentWithIndex:(NSUInteger)index;

- (void)clearImage;

@end
