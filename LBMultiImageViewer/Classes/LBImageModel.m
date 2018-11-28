//
//  LBImageModel.m
//  MultiImageViewer
//
//  Created by 赵立波 on 2018/2/11.
//

#import "LBImageModel.h"

@implementation LBImageModel

- (instancetype)init {
    if (self = [super init]) {
        _imageType = LBImageLocal;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        _imageType = LBImageLocal;
        _defaultImage = image;
    }
    return self;
}

- (instancetype)initWithLocalPHAsset:(PHAsset *)localPHAsset {
    if (self = [super init]) {
        _imageType = LBImageLocal;
        _localPHAsset = localPHAsset;
    }
    return self;
}
- (instancetype)initWithLocalAssetURL:(NSURL *)localAssetURL {
    if (self = [super init]) {
        _imageType = LBImageLocal;
        _localAssetURL = localAssetURL;
    }
    return self;
}
- (instancetype)initWithRemoteURLStr:(NSString *)remoteURLStr {
    if (self = [super init]) {
        _imageType = LBImageRemote;
        _remoteURLStr = remoteURLStr;
    }
    return self;
}

- (instancetype)initWithVideoPreviewImage:(UIImage *)image {
    if (self = [super init]) {
        _imageType = LBImageVideo;
        _defaultImage = image;
    }
    return self;
}
- (instancetype)initWithVideoRemotePreviewImageURLStr:(NSString *)remoteURLStr {
    if (self = [super init]) {
        _imageType = LBImageVideo;
        _remoteURLStr = remoteURLStr;
    }
    return self;
}

@end
