//
//  WKWebImageDownloader.h
//  WKWebImage
//
//  Created by 77 on 2017/5/27.
//  Copyright © 2017年 77. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void(^WKWImageDownloadCompleteBlock)(UIImage *image,NSError *error,BOOL isDownloadFinish);

@interface WKWebImageDownloader : NSObject
@property (nonatomic, readonly) NSUInteger currentDownloadCount;

+ (instancetype)shareDownLoader;

- (void)downLoadImageUrl:(NSString *)urlString completeBlock:(WKWImageDownloadCompleteBlock)completeBlock;
@end
