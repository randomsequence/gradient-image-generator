//
//  SaveImageOperation.m
//  Gradients
//
//  Created by Johnnie Walker on 05/02/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import "SaveImageOperation.h"

@interface SaveImageOperation ()
@property (nonatomic, getter = isExecuting) BOOL executing;
@property (nonatomic, getter = isFinished) BOOL finished;
@property (nonatomic, getter = isCancelled) BOOL cancelled;
@end

@implementation SaveImageOperation

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        _image = image;
    }
    return self;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setCancelled:(BOOL)cancelled {
    [self willChangeValueForKey:@"isCancelled"];
    _cancelled = YES;
    [self didChangeValueForKey:@"isCancelled"];
}

- (void)cancel {
    [super cancel];
    self.cancelled = YES;
}


- (void)start {
    if (self.isCancelled) {
        self.executing = NO;
        self.finished = YES;
    } else {
        UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (nil != error)
        NSLog(@"save to camera roll error: %@", error);
    
    self.executing = NO;
    self.finished = YES;
}

@end
