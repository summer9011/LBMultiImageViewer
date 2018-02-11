//
//  LBDetailImageView.h
//  MultiImageViewer
//
//  Created by 赵立波 on 2017/10/11.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LBDetailImageStatus) {
    LBDetailImageInit = 0,
    LBDetailImageLoading = 1,
    LBDetailImageLoaded = 2,
    LBDetailImageLoadFailed = 3
};

@interface LBDetailImageView : UIImageView

@property (nonatomic, assign) LBDetailImageStatus status;
@property (nonatomic, assign) CGFloat minScale;

@end
