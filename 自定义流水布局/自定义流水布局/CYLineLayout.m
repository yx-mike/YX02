//
//  CYLineLayout.m
//  自定义流水布局
//
//  Created by 葛聪颖 on 15/11/13.
//  Copyright © 2015年 聪颖不聪颖. All rights reserved.
//

#import "CYLineLayout.h"

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
    
    // 设置内边距
    CGFloat inset = (self.collectionView.frame.size.width - self.itemSize.width) * 0.5;
    self.sectionInset = UIEdgeInsetsMake(0, inset, 0, inset);

    self.minimumLineSpacing = 0;
    self.minimumInteritemSpacing = 0;
    
    CGFloat cellWidth = self.itemSize.width;
    
    /// 两个cell中，两个图片的间距
    self.maxTranslationX = (cellWidth - self.cellContentWidth) * 0.81;
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
    
    CGFloat collectionWidth = self.collectionView.frame.size.width;
    
    
    // 计算collectionView最中心点的x值
    CGFloat centerX = self.collectionView.contentOffset.x + collectionWidth * 0.5;
    
    CGFloat minDeltaABS = MAXFLOAT;
    UICollectionViewLayoutAttributes *topAttrs;
    
    // 在原有布局属性的基础上，进行微调
    for (UICollectionViewLayoutAttributes *attrs in array) {
        attrs.zIndex = 0;
        
        // cell的中心点x 和 collectionView最中心点的x值 的间距
        CGFloat delta = attrs.center.x - centerX;
        CGFloat deltaABS = ABS(delta);
        
        if (attrs.indexPath.row == 1) {
//            NSLog(@"yx02: card(1)-delta=%f", delta);
            NSLog(@"yx02: card(1)-frame=%@", NSStringFromCGRect(attrs.frame));
        }
        
        if (!topAttrs || deltaABS < minDeltaABS) {
            minDeltaABS = deltaABS;
            topAttrs = attrs;
        }
        
        CGFloat scale = 1;
        CGFloat translationX = 0;
        if (deltaABS >= collectionWidth) {
            scale = self.minScale;
            translationX = self.maxTranslationX * (delta > 0 ? -1 : 1);
        } else {
            CGFloat a = deltaABS / collectionWidth;
            
            scale = 1 - (1 - self.minScale) * a;
            translationX = a * self.maxTranslationX * (delta > 0 ? -1 : 1);
        }
        
        // 设置缩放比例
        CGAffineTransform scaleTF = CGAffineTransformMakeScale(scale, scale);
        // 设置平移
        CGAffineTransform translationTF = CGAffineTransformMakeTranslation(translationX, 0);
        
        attrs.transform = CGAffineTransformConcat(scaleTF, translationTF);
    }
    
    topAttrs.zIndex = 1;
    
    return array;
}

/**
 * 这个方法的返回值，就决定了collectionView停止滚动时的偏移量
 
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
