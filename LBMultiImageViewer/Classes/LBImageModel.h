//
//  LBImageModel.h
//  MultiImageViewer
//
//  Created by 赵立波 on 2018/2/11.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSUInteger, LBImageType) {
    LBImageLocal = 0,
    LBImageRemote = 1,
    LBImageVideo = 2
};

@interface LBImageModel : NSObject

@property (nonatomic, assign, readonly) LBImageType imageType;
@property (nonatomic, copy, readonly) PHAsset *localPHAsset;
@property (nonatomic, copy, readonly) NSURL *localAssetURL;
@property (nonatomic, copy, readonly) NSString *remoteURLStr;

@property (nonatomic, strong) UIImage *defaultImage;

- (instancetype)initWithImage:(UIImage *)image;

- (instancetype)initWithLocalPHAsset:(PHAsset *)localPHAsset;
- (instancetype)initWithLocalAssetURL:(NSURL *)localAssetURL;
- (instancetype)initWithRemoteURLStr:(NSString *)remoteURLStr;

- (instancetype)initWithVideoPreviewImage:(UIImage *)image;
- (instancetype)initWithVideoRemotePreviewImageURLStr:(NSString *)remoteURLStr;

@end
