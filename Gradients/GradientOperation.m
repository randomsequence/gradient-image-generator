//
//  GradientOperation.m
//  Gradients
//
//  Created by Johnnie Walker on 05/02/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import "GradientOperation.h"

@import CoreText;

@interface GradientOperation ()
@property (nonatomic, strong, readwrite) UIImage *outputImage;
@property (nonatomic, getter = isExecuting) BOOL executing;
@property (nonatomic, getter = isFinished) BOOL finished;
@property (nonatomic, getter = isCancelled) BOOL cancelled;
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

NSString* hexValuesFromUIColor(UIColor *color);
NSString* hexValuesFromUIColor(UIColor *color) {
    
    if (!color) {
        return nil;
    }
    
    if (color == [UIColor whiteColor]) {
        // Special case, as white doesn't fall into the RGB color space
        return @"ffffff";
    }
    
    CGFloat red;
    CGFloat blue;
    CGFloat green;
    CGFloat alpha;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    int redDec = (int)(red * 255);
    int greenDec = (int)(green * 255);
    int blueDec = (int)(blue * 255);
    
    NSString *returnString = [NSString stringWithFormat:@"%02x%02x%02x", (unsigned int)redDec, (unsigned int)greenDec, (unsigned int)blueDec];
    
    return returnString;
    
}

void drawTextForColor(CGContextRef context, UIColor *color, CGRect bounds, CGFloat height);
void drawTextForColor(CGContextRef context, UIColor *color, CGRect bounds, CGFloat height) {
    CGContextSaveGState(context);
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"Courier", 400.0f, NULL);
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                (__bridge id)fontRef, (NSString *)kCTFontAttributeName,
                                (id)[color CGColor], (NSString *)(kCTForegroundColorAttributeName),
                                nil];
    CFRelease(fontRef);
    
    NSString *string = [[NSString alloc] initWithFormat:@"#%@", hexValuesFromUIColor(color)];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    
    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)(attributedString));
    CGRect lineRect = CTLineGetBoundsWithOptions(line, 0);
    CGContextSetTextPosition(context, (CGRectGetWidth(bounds)-lineRect.size.width)/2, (CGRectGetHeight(bounds)*height)-(lineRect.size.height/2)); // 6-1
    CTLineDraw(line, context);
    CFRelease(line);
    CGContextRestoreGState(context);
}


@implementation GradientOperation

- (instancetype)initWithColors:(NSArray *)colors saveToCameraRoll:(BOOL)save index:(NSUInteger)index
{
    self = [super init];
    if (self) {
        _colors = colors;
        _saveToCameraRoll = save;
        _index = index;
    }
    return self;
}

- (void)dealloc
{
    
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)finish {
    self.executing = NO;
    self.finished = YES;
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
        [self finish];
    } else {
        
        size_t width = 2448;
        size_t height = 3264;
        
        CGRect bounds = (CGRect) {CGPointZero, CGSizeMake(width, height)};
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     width,
                                                     height,
                                                     8,
                                                     width*4,
                                                     colorSpace,
                                                     (CGBitmapInfo) kCGImageAlphaPremultipliedFirst);
        CGColorSpaceRelease(colorSpace);
        
        UIColor *startColor = nil;
        UIColor *endColor = nil;
        if (self.colors.count > 1) {
            startColor = [self.colors firstObject];
            endColor = [self.colors lastObject];
            drawLinearGradient(context, bounds, startColor.CGColor, endColor.CGColor);
        }

        if (nil != startColor) drawTextForColor(context, startColor, bounds, 0.75);
        if (nil != endColor) drawTextForColor(context, endColor, bounds, 0.25);
        
		CGImageRef imageRef = CGBitmapContextCreateImage(context);
        UIImage *outputImage = [[UIImage alloc] initWithCGImage:imageRef];
		CGImageRelease(imageRef);
        
        self.outputImage = outputImage;
        
        CGContextRelease(context);
        
        if (self.saveToCameraRoll)
            UIImageWriteToSavedPhotosAlbum(outputImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        else
            [self finish];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (nil != error)
        NSLog(@"save to camera roll error: %@", error);
    
    [self finish];
}


@end
