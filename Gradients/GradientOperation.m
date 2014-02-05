//
//  GradientOperation.m
//  Gradients
//
//  Created by Johnnie Walker on 05/02/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import "GradientOperation.h"

@interface GradientOperation ()
@property (nonatomic, strong, readwrite) UIImage *outputImage;
@end

void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor);
void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

@implementation GradientOperation

- (instancetype)initWithColors:(NSArray *)colors
{
    self = [super init];
    if (self) {
        _colors = colors;
    }
    return self;
}

- (void)main {
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    
    UIGraphicsBeginImageContext(bounds.size);
    
    if (self.colors.count > 1) {
        UIColor *startColor = [self.colors firstObject];
        UIColor *endColor = [self.colors lastObject];
        drawLinearGradient(UIGraphicsGetCurrentContext(), bounds, startColor.CGColor, endColor.CGColor);
    }
    
    self.outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();    
}

@end
