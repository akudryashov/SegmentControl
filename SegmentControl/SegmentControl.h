//
//  SegmentControl.h
//  _
//
//  Created by Anton Kudryashov on 24/06/15.
//  Copyright (c) 2015 Improve Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SegmentControl;

@protocol SegmentControlDelegate <NSObject>

@optional
- (void)segmentControl:(nonnull SegmentControl*)segmentControl didSelectSegmentAtIndex:(NSUInteger)indx;

@end

@protocol SegmentControlDataSource <NSObject>

- (NSUInteger)numberOfSegmentsInSegmentControl:(nonnull SegmentControl*)segmentControl;
- (nonnull NSString*)segmentControl:(nonnull SegmentControl*)segmentControl titleAtIndex:(NSUInteger)index;

@end

@interface SegmentControl : UIView

@property (nonatomic, strong, readwrite, null_resettable) UIFont* currentFont;

@property (nonatomic, readwrite) CGFloat bubbleRadius;
@property (nonatomic, readwrite) NSUInteger currentSegment;
@property (nonatomic, weak, nullable) IBOutlet id<SegmentControlDataSource> dataSource;
@property (nonatomic, weak, nullable) IBOutlet id<SegmentControlDelegate> delegate;

- (void)reloadData;

@end
