//
//  SegmentControl.m
//  _
//
//  Created by Anton Kudryashov on 24/06/15.
//  Copyright (c) 2015 Improve Digital. All rights reserved.
//

#import "SegmentControl.h"

@interface SegmentButton : UIButton
@end
@implementation SegmentButton

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customInitialization];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInitialization];
    }
    return self;
}

- (void)customInitialization
{
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
}

@end

@interface SegmentControl ()
{
    UIFont* _currentFont;
}

@property (nonatomic, strong) NSArray* segments;
@property (nonatomic, weak) UIView* selectedBubble;

@end

@implementation SegmentControl

#pragma mark - Initialization
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customInitialization];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInitialization];
    }
    return self;
}

- (void)customInitialization
{
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark - properties
- (void)setDataSource:(id<SegmentControlDataSource>)dataSource
{
    _dataSource = dataSource;
    [self reloadData];
}

- (UIView *)selectedBubble
{
    if (!_selectedBubble) {
        UIView* selectedBubble = [UIView new];
        selectedBubble.backgroundColor = self.tintColor;
        [self addSubview:selectedBubble];
        [self sendSubviewToBack:selectedBubble];
        _selectedBubble = selectedBubble;
    }
    return _selectedBubble;
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    self.selectedBubble.backgroundColor = tintColor;
    for (UIButton* btn in self.segments) {
        [btn setTitleColor:tintColor forState:UIControlStateNormal];
    }
}

- (UIFont *)currentFont
{
    if (!_currentFont) {
        _currentFont = [UIFont systemFontOfSize:14];
    }
    return _currentFont;
}
- (void)setCurrentFont:(UIFont *)currentFont
{
    _currentFont = currentFont;
    [self setNeedsDisplay];
}

- (void)setBubbleRadius:(CGFloat)bubbleRadius
{
    _bubbleRadius = bubbleRadius;
    self.selectedBubble.layer.cornerRadius = self.bubbleRadius;
    [self invalidateIntrinsicContentSize];
}

#pragma mark - reloading
- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    [self reloadData];
}

- (void)reloadData
{
    for (UIButton* old in self.segments) {
        [old removeFromSuperview];
    }
    self.segments = nil;
    for (NSUInteger i = 0; i < [self.dataSource numberOfSegmentsInSegmentControl:self]; i++) {
        SegmentButton* btn = [SegmentButton new];
        btn.tag = i;
        [btn.titleLabel setFont:self.currentFont];
        [btn setTitle:[self titleAtIndex:i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:self.tintColor forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self insertSubview:btn aboveSubview:self.selectedBubble];
        self.segments = self.segments ? [self.segments arrayByAddingObject:btn] : @[btn];
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self invalidateIntrinsicContentSize];
    self.currentSegment = MIN(self.segments.count - 1, self.currentSegment);
}

- (SegmentButton*)segmentAtIndex:(NSUInteger)index
{
    return index < self.segments.count ? self.segments[index] : nil;
}

- (void)segmentAction:(SegmentButton*)segment
{
    self.currentSegment = segment.tag;
}

- (void)setCurrentSegment:(NSUInteger)currentSegment
{
    SegmentButton* oldSegment = [self segmentAtIndex:_currentSegment];
    oldSegment.selected = NO;
    SegmentButton* newSegment = [self segmentAtIndex:currentSegment];
    BOOL differ = _currentSegment != currentSegment;
    _currentSegment = currentSegment;
    if (differ) {
        if ([self.delegate respondsToSelector:@selector(segmentControl:didSelectSegmentAtIndex:)]) {
            [self.delegate segmentControl:self didSelectSegmentAtIndex:currentSegment];
        }
        [UIView animateWithDuration:0.15 animations:^{
            [self updateSelectedBubblePosition];
        } completion:^(BOOL finished) {
            newSegment.selected = YES;
        }];
    }
    else {
        newSegment.selected = YES;
    }
}

- (NSString*)titleAtIndex:(NSUInteger)index
{
    return [self.dataSource segmentControl:self titleAtIndex:index];
}

#pragma mark - layout stuff
- (CGFloat)widthOfSegmentAtIndex:(NSUInteger)index
{
    NSString* title = [self titleAtIndex:index];
    if (!title) {
        NSAssert(NO, @"Title is nil");
        return 0;
    }
    // calculate width of text by using attiruted text
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:title
                                                                         attributes:@{NSFontAttributeName: self.currentFont}];
    CGSize constrainedToSize = CGSizeMake(CGFLOAT_MAX, self.currentFont.pointSize + 4);
    return ceilf([attributedText boundingRectWithSize:constrainedToSize
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                              context:nil].size.width) + 1 + 2*self.bubbleRadius;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.segments.count > 0) {
        CGSize size = [self intrinsicContentSize];
        CGFloat height = size.height;
        CGFloat x = 0;
        for (SegmentButton* segment in self.segments) {
            CGRect frame = segment.frame;
            frame.origin.x = x;
            frame.origin.y = 0;
            frame.size.width = [self widthOfSegmentAtIndex:segment.tag];
            frame.size.height = height;
            segment.frame = frame;
            x+= frame.size.width;
        }
        [self updateSelectedBubblePosition];
    }
}

- (void)updateSelectedBubblePosition
{
    SegmentButton* btn = [self segmentAtIndex:self.currentSegment];
    CGFloat bubbleHeight = MAX(2*self.bubbleRadius, btn.titleLabel.font.pointSize);
    CGRect bubbleFrame = self.selectedBubble.frame;
    bubbleFrame.origin.x = btn.frame.origin.x;
    bubbleFrame.origin.y = (btn.frame.size.height - bubbleHeight)/2;
    bubbleFrame.size.width = btn.frame.size.width;
    bubbleFrame.size.height = bubbleHeight;
    self.selectedBubble.frame = bubbleFrame;
}

- (CGSize)intrinsicContentSize
{
    CGFloat width = 0;
    for (NSUInteger i=0; i < [self.dataSource numberOfSegmentsInSegmentControl:self]; i++) {
        width += [self widthOfSegmentAtIndex:i];
    }
    return (CGSize){width, 2*self.currentFont.pointSize};
}

@end
