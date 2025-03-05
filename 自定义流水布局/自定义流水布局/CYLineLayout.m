//
//  CYLineLayout.m
//  自定义流水布局
//
//  Created by 葛聪颖 on 15/11/13.
//  Copyright © 2015年 聪颖不聪颖. All rights reserved.
//

#import "CYLineLayout.h"


@interface CYLineLayout ()

@property (nonatomic, assign) CGFloat maxDeltaABS;

/// 卡片到屏幕边上的距离
@property (nonatomic, assign) CGFloat maxInset;

@end

@implementation CYLineLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.minScale = 0.7;
    }
    return self;
}

/**
 * 当collectionView的显示范围发生改变的时候，是否需要重新刷新布局
 * 一旦重新刷新布局，就会重新调用下面的方法：
 1.prepareLayout
 2.layoutAttributesForElementsInRect:方法
 */
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
//    NSLog(@"yx02: newBounds=%@", NSStringFromCGRect(newBounds));
    return YES;
}

/**
 * 用来做布局的初始化操作（不建议在init方法中进行布局的初始化操作）
 */
- (void)prepareLayout
{
    [super prepareLayout];
    
    // 水平滚动
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    CGFloat collectionWidth = self.collectionView.frame.size.width;
    CGFloat cellWidth = self.itemSize.width;
    
    // 设置内边距
    CGFloat inset = (collectionWidth - cellWidth) * 0.5;
    self.sectionInset = UIEdgeInsetsMake(0, inset, 0, inset);

    self.minimumLineSpacing = 0;
    self.minimumInteritemSpacing = 0;
    
    self.maxDeltaABS = self.minimumLineSpacing + cellWidth;
    
    if (self.maxTranslationX > inset) {
        self.maxTranslationX = inset - 10;
        
        if (self.maxTranslationX < 0) {
            self.maxTranslationX = inset / 2;
        }
    }
    self.maxInset = inset;
}

/**
 UICollectionViewLayoutAttributes *attrs;
 1.一个cell对应一个UICollectionViewLayoutAttributes对象
 2.UICollectionViewLayoutAttributes对象决定了cell的frame
 */
/**
 * 这个方法的返回值是一个数组（数组里面存放着rect范围内所有元素的布局属性）
 * 这个方法的返回值决定了rect范围内所有元素的排布（frame）
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // 获得super已经计算好的布局属性
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    CGFloat minDeltaABS = MAXFLOAT;
    UICollectionViewLayoutAttributes *topAttrs;
    
    // 在原有布局属性的基础上，进行微调
    for (UICollectionViewLayoutAttributes *attrs in array) {
        attrs.zIndex = 0;
        
        // cell的中心点x 和 collectionView最中心点的x值 的间距
        CGFloat delta = attrs.center.x - (self.collectionView.contentOffset.x + self.collectionView.frame.size.width * 0.5);
        CGFloat deltaABS = ABS(delta);
        
        if (!topAttrs || deltaABS < minDeltaABS) {
            minDeltaABS = deltaABS;
            topAttrs = attrs;
        }
        
        CGPoint oldOrigin = attrs.frame.origin;
        CGSize oldSize = attrs.frame.size;
        
        CGFloat a = deltaABS / self.maxDeltaABS;
        CGFloat b = 0;
        if (a > 1) {
            a = 1;
            b = deltaABS - self.maxDeltaABS;
        }
        
        CGFloat scale = 1 - (1 - self.minScale) * a;
        // 新的size
        CGSize size = CGSizeMake(oldSize.width * scale, oldSize.height * scale);
        // 设置缩放比例
        CGAffineTransform scaleTF = CGAffineTransformMakeScale(scale, scale);
        
        CGFloat maxTranslationX = self.maxInset - self.maxTranslationX;
        CGFloat translationX = 0;
        if (delta > 0) {
            translationX = a * (maxTranslationX - (oldSize.width - size.width) * 0.5);
        } else if (delta == 0) {
            translationX = 0;
            b = 0;
        } else {
            translationX = a * ((oldSize.width - size.width) * 0.5 - maxTranslationX);
        }
        /// 补偿，防止后面的cell靠太近
        CGFloat translationXE = b * scale * (delta > 0 ? 1 : -1);
        // 设置平移
        CGAffineTransform translationTF = CGAffineTransformMakeTranslation(translationX + translationXE, 0);
        
        attrs.transform = CGAffineTransformConcat(scaleTF, translationTF);
        
        if (attrs.indexPath.row == 3) {
            NSLog(@"yx02: card(%ld)-delta=%f", (long)attrs.indexPath.row, delta);
            NSLog(@"yx02: card(%ld)-frame=%@", (long)attrs.indexPath.row, NSStringFromCGRect(attrs.frame));
        }
    }
    
    topAttrs.zIndex = 1;
    
    return array;
}

/**
 * 这个方法的返回值，就决定了collectionView停止滚动时的偏移量
 * 停止滚动后，定位一个最近的cell，让其剧中
 */
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    // 计算出最终显示的矩形框
    CGRect rect;
    rect.origin.y = 0;
    rect.origin.x = proposedContentOffset.x;
    rect.size = self.collectionView.frame.size;
    
    // 获得super已经计算好的布局属性
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    // 计算collectionView最中心点的x值
    CGFloat centerX = proposedContentOffset.x + self.collectionView.frame.size.width * 0.5;
    
    // 存放最小的间距值
    CGFloat minDelta = MAXFLOAT;
    for (UICollectionViewLayoutAttributes *attrs in array) {
        if (ABS(minDelta) > ABS(attrs.center.x - centerX)) {
            minDelta = attrs.center.x - centerX;
        }
    }
    
    // 修改原有的偏移量
    proposedContentOffset.x += minDelta;
    return proposedContentOffset;
}

@end
