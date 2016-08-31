//
//  ViewController.m
//  SegmentControl
//
//  Created by Антон Кудряшов on 31/08/16.
//  Copyright © 2016 Anton Kudryashov. All rights reserved.
//

#import "ViewController.h"

#import "SegmentControl.h"

@interface ViewController () <SegmentControlDelegate, SegmentControlDataSource>

@property (nonatomic, weak) IBOutlet SegmentControl* sc;
@property (nonatomic, strong) NSArray* titles;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sc.bubbleRadius = 10;
}

- (NSArray *)titles
{
    if (!_titles) {
        _titles = @[@"f", @"secoooooond", @"third"];
    }
    return _titles;
}

#pragma mark - SegmentControlDataSource

- (NSUInteger)numberOfSegmentsInSegmentControl:(SegmentControl *)segmentControl
{
    return self.titles.count;
}

- (NSString *)segmentControl:(SegmentControl *)segmentControl titleAtIndex:(NSUInteger)index
{
    return self.titles[index];
}

#pragma mark - SegmentControlDelegate

- (void)segmentControl:(SegmentControl *)segmentControl didSelectSegmentAtIndex:(NSUInteger)indx
{
    NSLog(@"segment %@ is selected", @(indx));
}

@end
