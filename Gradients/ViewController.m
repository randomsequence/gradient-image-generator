//
//  ViewController.m
//  Gradients
//
//  Created by Johnnie Walker on 05/02/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import "ViewController.h"
#import "GradientOperation.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *saveSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *generateButton;
- (IBAction)generateAction:(id)sender;

@end

@implementation ViewController {
    NSOperationQueue *_queue;
    NSOperationQueue *_writeQueue;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _queue = [NSOperationQueue new];
    _queue.maxConcurrentOperationCount = 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)generateAction:(id)sender {
    
    NSUInteger count = 1024;
    
    __weak ViewController *weakSelf = self;
    
    NSOperation *groupOperation = [NSOperation new];
    groupOperation.completionBlock = ^{
        weakSelf.generateButton.enabled = YES;
        weakSelf.saveSwitch.enabled = YES;
    };

    self.generateButton.enabled = NO;
    self.saveSwitch.enabled = NO;
    
    BOOL saveToCameraRoll = self.saveSwitch.isOn;
    
    __weak NSOperation *weakGroupOperation = groupOperation;
    for (NSUInteger i=0; i<count; i++) @autoreleasepool {
        UIColor *startColor = [UIColor colorWithHue:((float) i/count) saturation:((float) (count - i)/count) brightness:0.8 alpha:1.0];
        UIColor *endColor = [UIColor colorWithHue:((float) (count - i)/count) saturation:1.0 brightness:((float) i/count) alpha:1.0];
        
        GradientOperation *op = [[GradientOperation alloc] initWithColors:@[startColor, endColor] saveToCameraRoll:saveToCameraRoll index:i];
        __weak GradientOperation *weakOp = op;
        op.completionBlock = ^{
            [weakGroupOperation removeDependency:weakOp];
            UIImage *outputImage = weakOp.outputImage;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [weakSelf.imageView setImage:outputImage];
            }];
        };
        [groupOperation addDependency:op];
    }
    
    for (NSOperation *op in groupOperation.dependencies)
        [_queue addOperation:op];
    [_queue addOperation:groupOperation];
    
}
@end
