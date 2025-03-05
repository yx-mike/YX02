//
//  CYLineLayout.h
//  自定义流水布局
//
//  Created by 葛聪颖 on 15/11/13.
//  Copyright © 2015年 聪颖不聪颖. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYLineLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) CGFloat minScale;
/// 卡片透出的大小
@property (nonatomic, assign) CGFloat maxTranslationX;

@end
