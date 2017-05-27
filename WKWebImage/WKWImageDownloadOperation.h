//
//  WKWImageDownloadOperation.h
//  WKWebImage
//
//  Created by 77 on 2017/5/27.
//  Copyright © 2017年 77. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WKWImageDownloadOperation.h"
#import "WKWebImageDownloader.h"

@interface WKWImageDownloadOperation : NSOperation

@property(nonatomic, retain) NSURLRequest      *request;

@property(nonatomic, retain) NSURLSessionTask  *dataTask;

- (instancetype)initWithRequest:(NSURLRequest *)request;

- (void)addCompletedBlock:(WKWImageDownloadCompleteBlock)completeBlock;

- (BOOL)cancel:(id)token;
@end
