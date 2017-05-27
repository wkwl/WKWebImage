//
//  WKWebImageDownloader.m
//  WKWebImage
//
//  Created by 77 on 2017/5/27.
//  Copyright © 2017年 77. All rights reserved.
//

#import "WKWebImageDownloader.h"
#import "WKWImageDownloadOperation.h"

@interface WKWebImageDownloader()

@property (nonatomic, strong) dispatch_queue_t barrierQueue;

@property (nonatomic, strong) NSOperationQueue *downloadQueue;

@property (nonatomic, strong) NSOperation *lastOperation;

@property (nonatomic, strong) NSMutableDictionary *URLoperations;

@end

@implementation WKWebImageDownloader
+ (instancetype)shareDownLoader {
    static dispatch_once_t once;
    static id downloader;
    dispatch_once(&once, ^{
        downloader = self.new;
    });
    return downloader;

}

-(instancetype)init {
    self = [super init];
    if (self) {
        _barrierQueue = dispatch_queue_create("com.wkw.WKWebImageDownloaderBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
        _downloadQueue = [[NSOperationQueue alloc] init];
        //_downloadQueue.maxConcurrentOperationCount = 8;
        _downloadQueue.name = @"com.wkw.WKWebImageDownloader";
        
        _URLoperations = [NSMutableDictionary new];
    }
    return self;
}

- (void)downLoadImageUrl:(NSString *)urlString completeBlock:(WKWImageDownloadCompleteBlock)completeBlock {
    if (!urlString) {
        if (completeBlock) {
            completeBlock(nil,nil,YES);
        }
        return;
    }
    WKWImageDownloadOperation*(^createDownloaderOperation)() = ^(){
        //2⃣️   // NSURLRequestReloadIgnoringLocalCacheData忽略缓存，重新请求
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
        // 是否等待之前的返回响应，然后再发送请求
        // YES, 表示不等待
        request.HTTPShouldUsePipelining = YES;
        
        WKWImageDownloadOperation *operation = [[WKWImageDownloadOperation alloc] initWithRequest:request];
        //设置任务优先级属性
        operation.queuePriority = NSURLSessionTaskPriorityHigh;
        
        [self.downloadQueue addOperation:operation];
        
        //将新操作作为原队列最后一个操作的依赖
        [self.lastOperation addDependency:operation];
        self.lastOperation = operation;
        
        return operation;
    };
    //先执行这个函数方法，即1⃣️里面的内容，再通过operation = createCallback()调用2⃣️里的内容。
    [self addCompletedBlock:completeBlock forUrl:urlString createCallback:createDownloaderOperation];
}

- (void)addCompletedBlock:(WKWImageDownloadCompleteBlock)completeBlock forUrl:(NSString *)urlStr createCallback:( /*1⃣️*/
           WKWImageDownloadOperation                                                                                                       *(^)())createCallback {
    //、dispatch_barrier_sync将自己的任务插入到队列的时候，需要等待自己的任务结束之后才会继续插入被写在它后面的任务，然后执行它们
    ////保证同一时间只有一个线程在运行
    dispatch_barrier_sync(self.barrierQueue, ^{
       WKWImageDownloadOperation  *operation = self.URLoperations[urlStr];
        if (!operation) {
            operation = createCallback();
            self.URLoperations[urlStr] = operation;
            
            __weak WKWImageDownloadOperation  *wo = operation;
            operation.completionBlock = ^{
                WKWImageDownloadOperation  *so = wo;
                if (!so) {
                    return;
                }
                if (self.URLoperations[urlStr] == so) {
                    // 操作已经结束了，移除该操作
                    [self.URLoperations removeObjectForKey:urlStr];
                }
            };
            [operation addCompletedBlock:completeBlock];
        }
    });
}

- (void)cancel:(NSString *)url {
    dispatch_barrier_sync(_barrierQueue, ^{
       WKWImageDownloadOperation  *op = self.URLoperations[url];
        BOOL canceled = [op cancel:url];
        if (canceled) {
            [self.URLoperations removeObjectForKey:url];
        }
    });
}

- (NSUInteger)currentDownloadCount {
    return _downloadQueue.operationCount;
}
@end
