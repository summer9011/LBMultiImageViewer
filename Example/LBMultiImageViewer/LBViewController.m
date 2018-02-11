//
//  LBViewController.m
//  MultiImageViewer
//
//  Created by summer9011 on 02/11/2018.
//  Copyright (c) 2018 summer9011. All rights reserved.
//

#import "LBViewController.h"
#import <Photos/Photos.h>
#import "LBMultiImageViewer.h"

@interface LBViewController () <LBImageScrollDelegate>

@property (nonatomic, weak) LBImageScrollView *imageScroll;

@property (nonatomic, strong) NSMutableArray<LBImageModel *> *images;
@property (nonatomic, assign) NSUInteger currentImageIndex;

@end

@implementation LBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.images = [NSMutableArray array];
    self.currentImageIndex = 0;
    
    //Set few remote images.
    NSArray<NSString *> *remoteImages = @[
                                          @"https://www.cesarsway.com/sites/newcesarsway/files/styles/large_article_preview/public/Natural-Dog-Law-2-To-dogs%2C-energy-is-everything.jpg?itok=Z-ujUOUr",
                                          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1518337109975&di=07a8c69a4be3d6036a17ca4933913dea&imgtype=0&src=http%3A%2F%2Fimg.pconline.com.cn%2Fimages%2Fphotoblog%2F7%2F5%2F6%2F9%2F7569444%2F20101%2F27%2F1264577134300.jpg",
                                          @"https://www.3ders.org/images/3D-Printing-how-long-till-the-revolution-Infographic.jpg",
                                          @"https://cdn.shopify.com/s/files/1/1324/6367/collections/Why_all_dogs_love_us_close_up_large.jpg?v=1487160259",
                                          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1518337137498&di=455dae0b1734a12e06e93d89a9de60ad&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2F42166d224f4a20a44fbd2ee29a529822720ed077.jpg"
                                          ];
    [remoteImages enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LBImageModel *image = [[LBImageModel alloc] initWithRemoteURLStr:obj];
        [self.images addObject:image];
    }];
    
    //Get images from local album.
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.fetchLimit = 20;
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithOptions:options];
    [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LBImageModel *image = [[LBImageModel alloc] initWithLocalPHAsset:obj];
        [self.images addObject:image];
    }];
    [self didChangeImageView:self.currentImageIndex];
    
    //Create views.
    self.view.backgroundColor = [UIColor colorWithRed:61/255.f green:60/255.f blue:63/255.f alpha:1.f];
    LBImageScrollView *imageScroll = [[LBImageScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds imageIndex:self.currentImageIndex];
    imageScroll.imageScrollDelegate = self;
    [imageScroll showInView:self.view];
    self.imageScroll = imageScroll;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.imageScroll reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - LBImageScrollDelegate

- (NSUInteger)numberOfItems {
    return self.images.count;
}

- (LBImageModel *)imageModelForIndex:(NSUInteger)index {
    return self.images[index];
}

- (void)didSingleTapImageWithIndex:(NSUInteger)index {
    NSLog(@"didSingleTapImageWithIndex: %ld", index);
}

- (void)didDoubleTapImageWithIndex:(NSUInteger)index zoomUp:(BOOL)isZoomUp {
    NSLog(@"didDoubleTapImageWithIndex: %ld, zoomUp: %d", index, isZoomUp);
}

- (void)didLongPressImageWithIndex:(NSUInteger)index {
    NSLog(@"didLongPressImageWithIndex: %ld", index);
}

- (void)didChangeImageView:(NSUInteger)index {
    self.currentImageIndex = index;
    self.title = [NSString stringWithFormat:@"%ld/%ld", (self.currentImageIndex + 1), self.images.count];
    
    NSLog(@"didChangeImageView: %ld", index);
}

- (void)didReloadImageScroll {
    NSLog(@"didReloadImageScroll");
}

- (void)imageViewBeginLoad {
    NSLog(@"imageViewBeginLoad");
}

- (void)imageViewLoadSuccess {
    NSLog(@"imageViewLoadSuccess");
}

@end
