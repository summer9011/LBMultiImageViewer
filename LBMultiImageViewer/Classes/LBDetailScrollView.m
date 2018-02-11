//
//  LBDetailScrollView.m
//  MultiImageViewer
//
//  Created by 赵立波 on 2017/10/11.
//

#import "LBDetailScrollView.h"
#import "LBImageModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Photos/Photos.h>

@interface LBDetailScrollView () <UIScrollViewDelegate>

@end

@implementation LBDetailScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
        self.backgroundColor = [UIColor colorWithRed:61/255.f green:60/255.f blue:63/255.f alpha:1.f];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        CGRect bounds = [UIScreen mainScreen].bounds;
        
        LBDetailImageView *imageView = [[LBDetailImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(bounds), CGRectGetHeight(bounds))];
        imageView.minScale = 0.f;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = [UIColor clearColor];
        imageView.userInteractionEnabled = YES;
        [self addSubview:imageView];
        
        self.imageView = imageView;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOnImageView:)];
        [imageView addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapOnImageView:)];
        doubleTap.numberOfTapsRequired = 2;
        [imageView addGestureRecognizer:doubleTap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnImageView:)];
        [imageView addGestureRecognizer:longPress];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.tag = 102;
        activityView.hidesWhenStopped = YES;
        activityView.center = imageView.center;
        activityView.hidden = YES;
        [self addSubview:activityView];
        
        self.activityView = activityView;
        
        UIButton *retryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        retryBtn.tag = 103;
        retryBtn.center = imageView.center;
        retryBtn.bounds = CGRectMake(0, 0, 60, 30);
        [retryBtn setTitle:@"Retry" forState:UIControlStateNormal];
        [retryBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [retryBtn addTarget:self action:@selector(doReloadImageAction:) forControlEvents:UIControlEventTouchUpInside];
        retryBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        retryBtn.layer.cornerRadius = 4.f;
        retryBtn.layer.borderWidth = 0.5;
        retryBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        retryBtn.hidden = YES;
        [self addSubview:retryBtn];
        
        self.reloadBtn = retryBtn;
    }
    
    return self;
}

#pragma mark - Public Method

- (void)setImageContentWithIndex:(NSUInteger)index {
    switch (self.imageView.status) {
        case LBDetailImageInit: {
            if (self.detailDelegate && [self.detailDelegate respondsToSelector:@selector(LBDetailScrollBeginLoad:)]) {
                [self.detailDelegate LBDetailScrollBeginLoad:self];
            }
            
            CGRect bounds = [UIScreen mainScreen].bounds;
            
            self.imageView.status = LBDetailImageLoading;
            self.imageView.frame = CGRectMake(0, 0, CGRectGetWidth(bounds), CGRectGetHeight(bounds));
            
            self.activityView.center = self.imageView.center;
            self.activityView.hidden = NO;
            [self.activityView startAnimating];
            
            self.reloadBtn.hidden = YES;
            
            self.minimumZoomScale = 1.f;
            self.maximumZoomScale = 1.f;
            [self setZoomScale:1.f animated:NO];
            
            LBImageModel *model = [self.detailDelegate LBDetailScrollGetImageModelWithIndex:index];
            if (model.imageType == LBImageLocal) {
                [self loadWithLocalImage:model];
            } else {
                [self loadWithRemoteImage:model];
            }
        }
            break;
        case LBDetailImageLoaded: {
            [self setZoomScale:self.minimumZoomScale animated:NO];
            
            if (self.detailDelegate && [self.detailDelegate respondsToSelector:@selector(LBDetailScrollLoadSuccess:)]) {
                [self.detailDelegate LBDetailScrollLoadSuccess:self];
            }
        }
            break;
        default: {
            if (self.detailDelegate && [self.detailDelegate respondsToSelector:@selector(LBDetailScrollBeginLoad:)]) {
                [self.detailDelegate LBDetailScrollBeginLoad:self];
            }
        }
            break;
    }
}

- (void)loadWithLocalImage:(LBImageModel *)imageModel {
    dispatch_queue_t queue = dispatch_queue_create("lb.fetch.image", NULL);
    dispatch_async(queue, ^{
        PHFetchResult *fetchResult = nil;
        if (imageModel.localPHAsset) {
            fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[imageModel.localPHAsset.localIdentifier] options:nil];
        } else {
            fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[imageModel.localAssetURL] options:nil];
        }
        if (fetchResult.count) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
            options.resizeMode = PHImageRequestOptionsResizeModeExact;
            
            PHAsset *asset = fetchResult.firstObject;
            
            __weak LBDetailScrollView *weakSelf = self;
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                __strong LBDetailScrollView *strongSelf = weakSelf;
                
                strongSelf.imageView.status = result?LBDetailImageLoaded:LBDetailImageLoadFailed;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf resetImageScrollWithImage:result];
                    
                    if (strongSelf.detailDelegate && [strongSelf.detailDelegate respondsToSelector:@selector(LBDetailScrollLoadSuccess:)]) {
                        [strongSelf.detailDelegate LBDetailScrollLoadSuccess:strongSelf];
                    }
                });
            }];
        } else {
            self.imageView.status = LBDetailImageLoadFailed;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self resetImageScrollWithImage:nil];
                
                if (self.detailDelegate && [self.detailDelegate respondsToSelector:@selector(LBDetailScrollLoadSuccess:)]) {
                    [self.detailDelegate LBDetailScrollLoadSuccess:self];
                }
            });
        }
    });
}

- (void)loadWithRemoteImage:(LBImageModel *)imageModel {
    NSURL *imageURL = [NSURL URLWithString:imageModel.remoteURLStr];
    
    __weak LBDetailScrollView *weakSelf = self;
    [self.imageView sd_setImageWithURL:imageURL placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        __strong LBDetailScrollView *strongSelf = weakSelf;
        
        strongSelf.imageView.status = image?LBDetailImageLoaded:LBDetailImageLoadFailed;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf resetImageScrollWithImage:image];
        });
    }];
}

- (void)resetImageScrollWithImage:(UIImage *)image {
    self.activityView.hidden = YES;
    [self.activityView stopAnimating];
    
    if (!image) {
        self.reloadBtn.hidden = NO;
        
        self.imageView.minScale = 0.f;
        
        CGRect bounds = [UIScreen mainScreen].bounds;
        
        self.imageView.frame = CGRectMake(0, 0, CGRectGetWidth(bounds), CGRectGetHeight(bounds));
        self.imageView.image = nil;
        
        self.reloadBtn.center = self.imageView.center;
        
        self.minimumZoomScale = 1.f;
        self.maximumZoomScale = 1.f;
        
        if (self.detailDelegate && [self.detailDelegate respondsToSelector:@selector(LBDetailScrollBeginLoad:)]) {
            [self.detailDelegate LBDetailScrollBeginLoad:self];
        }
        
    } else {
        self.reloadBtn.hidden = YES;
        
        self.imageView.minScale = [self minScaleFor:image];
        
        UIEdgeInsets inserts = [self edgeInsetFor:self.imageView.frame.size];
        self.imageView.center = CGPointMake(self.contentSize.width/2.f + inserts.left, self.contentSize.height/2.f + inserts.top);
        self.imageView.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
        
        self.imageView.image = image;
        
        self.minimumZoomScale = self.imageView.minScale;
        self.maximumZoomScale = self.minimumZoomScale * 2;
        
        if (self.detailDelegate && [self.detailDelegate respondsToSelector:@selector(LBDetailScrollLoadSuccess:)]) {
            [self.detailDelegate LBDetailScrollLoadSuccess:self];
        }
    }
    
    [self.imageView sizeToFit];
    
    [self setZoomScale:self.minimumZoomScale animated:NO];
}

- (void)clearImage {
    if (self.imageView.image) {
        self.imageView.status = LBDetailImageInit;
        self.imageView.minScale = 0.f;
        
        CGRect bounds = [UIScreen mainScreen].bounds;
        
        self.imageView.frame = CGRectMake(0, 0, CGRectGetWidth(bounds), CGRectGetHeight(bounds));
        self.imageView.image = nil;
        
        self.reloadBtn.center = self.imageView.center;
        
        self.minimumZoomScale = 1.f;
        self.maximumZoomScale = 1.f;
    }
}

#pragma mark - Action

- (void)doReloadImageAction:(UIButton *)button {
    self.imageView.status = LBDetailImageInit;
    
    if (self.detailDelegate && [self.detailDelegate respondsToSelector:@selector(LBDetailScrollReloadImage:)]) {
        [self.detailDelegate LBDetailScrollReloadImage:self];
    }
}

#pragma mark - UIGestureRecognizer

- (void)singleTapOnImageView:(UITapGestureRecognizer *)singleTap {
    if (self.detailDelegate && [self.detailDelegate respondsToSelector:@selector(LBDetailScrollSingleTapOnImage:)]) {
        [self.detailDelegate LBDetailScrollSingleTapOnImage:self];
    }
}

- (void)doubleTapOnImageView:(UITapGestureRecognizer *)doubleTap {
    UIScrollView *imageScroll = (UIScrollView *)doubleTap.view.superview;
    if (imageScroll.zoomScale == imageScroll.maximumZoomScale) {
        [imageScroll setZoomScale:imageScroll.minimumZoomScale animated:YES];
    } else {
        [imageScroll setZoomScale:imageScroll.maximumZoomScale animated:YES];
    }
    
    if (self.detailDelegate && [self.detailDelegate respondsToSelector:@selector(LBDetailScrollDoubleTapOnImage:zoomUp:)]) {
        [self.detailDelegate LBDetailScrollDoubleTapOnImage:self zoomUp:imageScroll.scrollEnabled];
    }
}

- (void)longPressOnImageView:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if (self.detailDelegate && [self.detailDelegate respondsToSelector:@selector(LBDetailScrollLongPressOnImage:)]) {
            [self.detailDelegate LBDetailScrollLongPressOnImage:self];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIEdgeInsets inserts = [self edgeInsetFor:self.imageView.frame.size];
    self.imageView.center = CGPointMake(scrollView.contentSize.width/2.f + inserts.left, scrollView.contentSize.height/2.f + inserts.top);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

#pragma mark - Calculate

- (CGFloat)minScaleFor:(UIImage *)image {
    CGFloat minScale = 1.f;
    
    CGSize imageSize = image.size;
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    
    //Scale image to view's size by checking aspect ratio.
    if (imageSize.height > viewSize.height * LBImageScrollLargeImageP) {
        if (imageSize.width > viewSize.width * LBImageScrollLargeImageP) {
            CGFloat imageP = imageSize.width/imageSize.height;
            CGFloat viewP = viewSize.width/viewSize.height;
            
            if (viewP > imageP) {
                CGFloat pImageHeight = viewSize.width * imageSize.height / imageSize.width;
                if (pImageHeight > viewSize.height * LBImageScrollLargeImageP) {
                    //Scale width (A long image).
                    minScale = viewSize.width/imageSize.width;
                } else {
                    //Scale height.
                    minScale = viewSize.height/imageSize.height;
                }
            } else {
                CGFloat pImageWidth = viewSize.height * imageSize.width / imageSize.height;
                if (pImageWidth > viewSize.width * LBImageScrollLargeImageP) {
                    //Scale height (A wide imge).
                    minScale = viewSize.height/imageSize.height;
                } else {
                    //Scale width.
                    minScale = viewSize.width/imageSize.width;
                }
            }
        } else if (imageSize.width > viewSize.width && imageSize.width <= viewSize.width * LBImageScrollLargeImageP) {
            CGFloat scaleHeight = viewSize.width * imageSize.height / imageSize.width;
            if (scaleHeight > viewSize.height * LBImageScrollLargeImageP) {
                //Scale width (A long image).
                minScale = viewSize.width/imageSize.width;
            } else {
                //Scale height.
                minScale = viewSize.height/imageSize.height;
            }
        } else {
            //Scale width (A long image).
            minScale = viewSize.width/imageSize.width;
        }
    } else if (imageSize.height > viewSize.height && imageSize.height <= viewSize.height * LBImageScrollLargeImageP) {
        if (imageSize.width > viewSize.width * LBImageScrollLargeImageP) {
            CGFloat scaleWidth = viewSize.height * imageSize.width / imageSize.height;
            if (scaleWidth > viewSize.width * LBImageScrollLargeImageP) {
                //Scale height (A wide imge).
                minScale = viewSize.height/imageSize.height;
            } else {
                //Scale width.
                minScale = viewSize.width/imageSize.width;
            }
        } else if (imageSize.width > viewSize.width && imageSize.width <= viewSize.width * LBImageScrollLargeImageP) {
            CGFloat imageP = imageSize.width/imageSize.height;
            CGFloat viewP = viewSize.width/viewSize.height;
            
            if (viewP > imageP) {
                //Scale height.
                minScale = viewSize.height/imageSize.height;
            } else {
                //Scale width.
                minScale = viewSize.width/imageSize.width;
            }
        } else {
            //Scale height.
            minScale = viewSize.height/imageSize.height;
        }
    } else {
        if (imageSize.width > viewSize.width * LBImageScrollLargeImageP) {
            //Scale height (A wide imge).
            minScale = viewSize.height/imageSize.height;
        } else if (imageSize.width > viewSize.width && imageSize.width <= viewSize.width * LBImageScrollLargeImageP) {
            //Scale width.
            minScale = viewSize.width/imageSize.width;
        } else {
            //Small image.
            CGFloat pWidth = viewSize.width/imageSize.width;
            CGFloat pHeight = viewSize.height/imageSize.height;
            
            if (pWidth > pHeight) {
                minScale = pHeight;
            } else {
                minScale = pWidth;
            }
        }
    }
    
    return minScale;
}

- (UIEdgeInsets)edgeInsetFor:(CGSize)imageSize {
    UIEdgeInsets resultEdgeInsert = UIEdgeInsetsZero;
    
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    
    if (imageSize.height > viewSize.height * LBImageScrollLargeImageP) {
        if (imageSize.width > viewSize.width * LBImageScrollLargeImageP) {
            CGFloat imageP = imageSize.width/imageSize.height;
            CGFloat viewP = viewSize.width/viewSize.height;
            
            if (viewP > imageP) {
                CGFloat pImageHeight = viewSize.width * imageSize.height / imageSize.width;
                if (pImageHeight > viewSize.height * LBImageScrollLargeImageP) {
                    resultEdgeInsert.left = 0;
                    resultEdgeInsert.top = 0;
                } else {
                    CGFloat left = (viewSize.width - imageSize.width)/2.f;
                    
                    resultEdgeInsert.left = left>0?left:0;
                    resultEdgeInsert.top = 0;
                }
            } else {
                CGFloat pImageWidth = viewSize.height * imageSize.width / imageSize.height;
                if (pImageWidth > viewSize.width * LBImageScrollLargeImageP) {
                    resultEdgeInsert.left = 0;
                    resultEdgeInsert.top = 0;
                } else {
                    CGFloat top = (viewSize.height - imageSize.height)/2.f;
                    
                    resultEdgeInsert.left = 0;
                    resultEdgeInsert.top = top>0?top:0;
                }
            }
            
        } else if (imageSize.width > viewSize.width && imageSize.width <= viewSize.width * LBImageScrollLargeImageP) {
            CGFloat scaleHeight = viewSize.width * imageSize.height / imageSize.width;
            if (scaleHeight > viewSize.height * LBImageScrollLargeImageP) {
                resultEdgeInsert.left = 0;
                resultEdgeInsert.top = 0;
            } else {
                CGFloat left = (viewSize.width - imageSize.width)/2.f;
                
                resultEdgeInsert.left = left>0?left:0;
                resultEdgeInsert.top = 0;
            }
        } else {
            CGFloat left = (viewSize.width - imageSize.width)/2.f;
            
            resultEdgeInsert.left = left>0?left:0;
            resultEdgeInsert.top = 0;
        }
    } else if (imageSize.height > viewSize.height && imageSize.height <= viewSize.height * LBImageScrollLargeImageP) {
        if (imageSize.width > viewSize.width * LBImageScrollLargeImageP) {
            CGFloat scaleWidth = viewSize.height * imageSize.width / imageSize.height;
            if (scaleWidth > viewSize.width * LBImageScrollLargeImageP) {
                resultEdgeInsert.left = 0;
                resultEdgeInsert.top = 0;
            } else {
                CGFloat top = (viewSize.height - imageSize.height)/2.f;
                
                resultEdgeInsert.left = 0;
                resultEdgeInsert.top = top>0?top:0;
            }
        } else if (imageSize.width > viewSize.width && imageSize.width <= viewSize.width * LBImageScrollLargeImageP) {
            CGFloat imageP = imageSize.width/imageSize.height;
            CGFloat viewP = viewSize.width/viewSize.height;
            if (viewP > imageP) {
                CGFloat left = (viewSize.width - imageSize.width)/2.f;
                
                resultEdgeInsert.left = left>0?left:0;
                resultEdgeInsert.top = 0;
            } else {
                CGFloat top = (viewSize.height - imageSize.height)/2.f;
                
                resultEdgeInsert.left = 0;
                resultEdgeInsert.top = top>0?top:0;
            }
        } else {
            CGFloat left = (viewSize.width - imageSize.width)/2.f;
            
            resultEdgeInsert.left = left>0?left:0;
            resultEdgeInsert.top = 0;
        }
    } else {
        if (imageSize.width > viewSize.width * LBImageScrollLargeImageP) {
            CGFloat top = (viewSize.height - imageSize.height)/2.f;
            resultEdgeInsert.left = 0;
            resultEdgeInsert.top = top>0?top:0;
        } else if (imageSize.width > viewSize.width && imageSize.width <= viewSize.width * LBImageScrollLargeImageP) {
            CGFloat top = (viewSize.height - imageSize.height)/2.f;
            resultEdgeInsert.left = 0;
            resultEdgeInsert.top = top>0?top:0;
        } else {
            CGFloat left = (viewSize.width - imageSize.width)/2.f;
            CGFloat top = (viewSize.height - imageSize.height)/2.f;
            resultEdgeInsert.left = left>0?left:0;
            resultEdgeInsert.top = top>0?top:0;
        }
    }
    
    return resultEdgeInsert;
}

@end
