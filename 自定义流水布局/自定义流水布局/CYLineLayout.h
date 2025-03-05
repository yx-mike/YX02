//
//  CYLineLayout.h
//  自定义流水布局
//
//  Created by 葛聪颖 on 15/11/13.
//  Copyright © 2015年 聪颖不聪颖. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYLineLayout : UICollectionViewFlowLayout

/// 剧中卡片的左右两边的卡片缩放限制
@property (nonatomic, assign) CGFloat minScale;
/// 剧中卡片的左右两边的卡片的间距
@property (nonatomic, assign) CGFloat maxPaddingX;

@end
