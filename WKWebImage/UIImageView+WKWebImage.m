//
//  UIImageView+WKWebImage.m
//  WKWebImage
//
//  Created by 77 on 2017/5/27.
//  Copyright © 2017年 77. All rights reserved.
//
#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
#endif


#import "UIImageView+WKWebImage.h"
#import "WKWebImageDownloader.h"
#import "WKW_WebImageCache.h"
#import "WKWebImageManager.h"
@implementation UIImageView (WKWebImage)
- (void)wkw_setImageUrlString:(NSString *)urlString placeholderImage:(UIImage *)placeholder {
    if (!urlString) {
        return;
    }
    if (placeholder) {
        self.image = placeholder;
    }
    __weak __typeof(self)wself = self;
    
  WKWebImageManager *session = [WKWebImageManager shareImanager];
    session.Imagiview = self;
    [session loadImageByUrl:urlString completeBlock:^(UIImage *image, NSError *error, BOOL isDownloadFinish) {

        __strong __typeof (wself) sself = wself;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if (image && !error && isDownloadFinish) {
                
                UIImageView *imageView = (UIImageView *)sself;
                imageView.image = image;
                
                //加载完下载完成的图片后，缓存一份到缓存中
                [[WKW_WebImageCache sharedCache] saveImage:image forkey:urlString];
                [sself setNeedsLayout];
            } else {
                
                
            }
        });
        
    }];
    

}
@end
