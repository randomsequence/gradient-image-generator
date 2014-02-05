//
//  SaveImageOperation.h
//  Gradients
//
//  Created by Johnnie Walker on 05/02/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SaveImageOperation : NSOperation
@property (nonatomic, strong, readonly) UIImage *image;
- (instancetype)initWithImage:(UIImage *)image;
@end
