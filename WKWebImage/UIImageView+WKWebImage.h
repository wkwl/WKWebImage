//
//  UIImageView+WKWebImage.h
//  WKWebImage
//
//  Created by 77 on 2017/5/27.
//  Copyright © 2017年 77. All rights reserved.
//

//入口封装，提供对外获取图片的接口，回调取到的图
#import <UIKit/UIKit.h>

@interface UIImageView (WKWebImage)
- (void)wkw_setImageUrlString:(NSString *)urlString placeholderImage:(UIImage *)placeholder;
@end
