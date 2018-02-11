//
//  LBImageModel.m
//  MultiImageViewer
//
//  Created by 赵立波 on 2018/2/11.
//

#import "LBImageModel.h"

@implementation LBImageModel

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

@end
