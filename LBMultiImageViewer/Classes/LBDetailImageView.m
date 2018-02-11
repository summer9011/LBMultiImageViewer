//
//  LBDetailImageView.m
//  MultiImageViewer
//
//  Created by 赵立波 on 2017/10/11.
//

#import "LBDetailImageView.h"

@implementation LBDetailImageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.status = LBDetailImageInit;
    }
    return self;
}

@end
