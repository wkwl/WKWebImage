//
//  CollectionViewCell.m
//  WKWebImage
//
//  Created by 77 on 2017/5/27.
//  Copyright © 2017年 77. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
         self.backgroundColor = [UIColor redColor];
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = CGRectMake(0, 0, 180, 180);
        [self.contentView addSubview:_imageView];
//
    }
    return self;
}
@end
