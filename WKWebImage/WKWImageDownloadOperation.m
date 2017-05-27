//
//  WKWImageDownloadOperation.m
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

#import "WKWImageDownloadOperation.h"

@interface WKWImageDownloadOperation ()<NSURLSessionTaskDelegate,NSURLSessionDelegate>

@property (nonatomic, retain)NSMutableArray *callbackBlocks;

@property (nonatomic, retain)NSMutableData *imageData;

@property (nonatomic, assign)BOOL isExecuting;
@property (assign, nonatomic) BOOL isFinished;

@property (nonatomic, retain)NSURLSession *unownedSession;

@property (nonatomic, retain)NSURLSession *ownSession;

@property (nonatomic, retain)dispatch_queue_t barrierQueue;

@end
@implementation WKWImageDownloadOperation
static NSString *const kCompletedBlock = @"kCompletedBlock";

-(instancetype)initWithRequest:(NSURLRequest *)request{
    self = [super init];
    if (self) {
        _request = [request copy];
        _callbackBlocks = [NSMutableArray new];
        _isExecuting = NO;
        _barrierQueue = dispatch_queue_create("com.wkw.WKWebImageDownloaderBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}
- (void)addCompletedBlock:(WKWImageDownloadCompleteBlock)completeBlock{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    if (completeBlock) {
        [dic setObject:completeBlock forKey:kCompletedBlock];
    }
    dispatch_barrier_async(_barrierQueue, ^{
        [self.callbackBlocks addObject:dic];
    });
    

}

- (NSArray *)callbackForKey:(NSString *)key {
    __block NSMutableArray *callbackArr = nil;
       callbackArr = [self.callbackBlocks valueForKey:key];
    return [callbackArr copy];
}

-(void)start {
    @synchronized (self) {
        if (self.isCancelled) {
            self.isFinished = YES;
            [self reset];
            return;
        }
        
        NSURLSession *session = self.unownedSession;
        if (!session) {
            NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
            sessionConfig.timeoutIntervalForRequest = 15;
            
            self.ownSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
            session = self.ownSession;
        }
        self.dataTask = [session dataTaskWithRequest:self.request];
        self.isExecuting = YES;
    }
    
    [self.dataTask resume];
    
    if (!self.dataTask) {
        NSLog(@"Connection can't be initialized:");
    }
}



- (BOOL)cancel:(nullable id)token {
    __block BOOL shouldCancel = NO;
    dispatch_barrier_sync(self.barrierQueue, ^{
        [self.callbackBlocks removeObjectIdenticalTo:token];
        if (self.callbackBlocks.count == 0) {
            shouldCancel = YES;
        }
    });
    if (shouldCancel) {
        [self cancel];
    }
    return shouldCancel;
}
-(void)cancel {
    @synchronized (self) {
        if (_isFinished) {
            return;
        }
        [super cancel];
        if (self.dataTask) {
            [self.dataTask cancel];
            if (_isExecuting) {
                _isExecuting = NO;
            }
            if (!_isFinished) {
                _isFinished = YES;
            }
            
        }
        [self reset];
    }
}

- (void)done {
    _isExecuting = NO;
    _isFinished = YES;
    [self reset];
}

-(void)reset{
    dispatch_barrier_sync(_barrierQueue, ^{
        [self.callbackBlocks removeAllObjects];
    });
    self.dataTask = nil;
    self.imageData = nil;
    if (self.ownSession) {
        [self.ownSession invalidateAndCancel];
        self.ownSession = nil;
    }
}


#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    if (![response respondsToSelector:@selector(statusCode)] || (((NSHTTPURLResponse *)response).statusCode < 400 && ((NSHTTPURLResponse *)response).statusCode != 304)) {
        
        NSInteger expected = response.expectedContentLength > 0 ? (NSInteger)response.expectedContentLength : 0;
        self.imageData = [[NSMutableData alloc] initWithCapacity:expected];
        
    }
    
    if (completionHandler) {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.imageData appendData:data];
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (error) {
        NSLog(@"Task data error:%@", [error description]);
       
    } else {
        if ([self callbackForKey:kCompletedBlock].count > 0) {
            if (self.imageData) {
                UIImage *image = [UIImage imageWithData:self.imageData];
                
                
                if (CGSizeEqualToSize(image.size, CGSizeZero)) {
                    
                } else {
                    [self callCompletionBlocksWithImage:image imageData:self.imageData error:nil finished:YES];
                }
            } else {
               
            }
        }
    }
    [self done];
}

- (void)callCompletionBlocksWithImage:(nullable UIImage *)image
                            imageData:(nullable NSData *)imageData
                                error:(nullable NSError *)error
                             finished:(BOOL)finished {
    NSArray<id> *completionBlocks = [self callbackForKey:kCompletedBlock];
   
    for (WKWImageDownloadCompleteBlock completedBlock in completionBlocks) {
        completedBlock(image, error, finished);
    }
  
}

@end
