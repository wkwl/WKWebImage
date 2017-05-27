//
//  WKW_WebImageCache.h
//  WKWebImage
//
//  Created by 77 on 2017/5/27.
//  Copyright © 2017年 77. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WKW_WebImageCache : NSObject
+(instancetype)sharedCache;
- (void)saveImage:(UIImage *)image forkey:(NSString *)key;
-(UIImage *)imageFromCacheForKey:(NSString *)key;
@end
