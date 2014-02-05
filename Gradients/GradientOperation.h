//
//  GradientOperation.h
//  Gradients
//
//  Created by Johnnie Walker on 05/02/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GradientOperation : NSOperation
@property (nonatomic, strong, readonly) UIImage *outputImage;
@property (nonatomic, strong, readonly) NSArray *colors;
- (instancetype)initWithColors:(NSArray *)colors;
@end
