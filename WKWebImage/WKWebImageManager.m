//
//  WKWebImageManager.m
//  WKWebImage
//
//  Created by 77 on 2017/5/27.
//  Copyright © 2017年 77. All rights reserved.
//

#import "WKWebImageManager.h"
#import "WKW_WebImageCache.h"
#import "WKWebImageDownloader.h"

@interface WKWebImageManager ()
@property (nonatomic, retain) WKWebImageDownloader *downloader;
@property (nonatomic, retain) WKW_WebImageCache    *cache;
@end

@implementation WKWebImageManager

+(instancetype)shareImanager {
    static dispatch_once_t once;
    static id manager;
    dispatch_once(&once,^{
        manager = self.new;
    });
    return manager;
}

-(instancetype)init {
    if (self = [super init]) {
        _downloader = [WKWebImageDownloader shareDownLoader];
        _cache = [WKW_WebImageCache sharedCache];
    }
    return self;
}


- (void)loadImageByUrl:(NSString *)urlString completeBlock:(WKWImageCompleteBlock)completeBlock {
    if (!urlString) {
        completeBlock(nil,nil,NO);
        return;
    }
    UIImage *Image =[self.cache imageFromCacheForKey:urlString];
    if (!Image) {
        [self.downloader downLoadImageUrl:urlString completeBlock:^(UIImage *image, NSError *error, BOOL isDownloadFinish) {
            if (image && !error && isDownloadFinish) {
                completeBlock(image, error, isDownloadFinish);
            } else {
                completeBlock(image, error, isDownloadFinish);
            }

        }];
    }else{
        //显示缓存图片
        _Imagiview.image = Image;
    }
}

@end
