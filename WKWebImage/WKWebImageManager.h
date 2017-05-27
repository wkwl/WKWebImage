//
//  WKWebImageManager.h
//  WKWebImage
//
//  Created by 77 on 2017/5/27.
//  Copyright © 2017年 77. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^WKWImageCompleteBlock)(UIImage *image,NSError *error,BOOL isDownloadFinish);

@interface WKWebImageManager : NSObject
//有缓存图片时，通过它来显示缓存图片
@property (nonatomic, retain) UIImageView *Imagiview;

- (void)loadImageByUrl:(NSString *)urlString completeBlock:(WKWImageCompleteBlock)completeBlock;
+(instancetype)shareImanager;
@end
