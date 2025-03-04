//
//  ViewController.m
//  自定义流水布局
//
//  Created by 葛聪颖 on 15/11/13.
//  Copyright © 2015年 聪颖不聪颖. All rights reserved.
//

#import "ViewController.h"
#import "CYLineLayout.h"
#import "CYPhotoCell.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@end

@implementation ViewController

static NSString * const CYPhotoId = @"photo";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat collectionWidth = self.view.frame.size.width;
    CGFloat collectionHeight = 315;
    
    CGFloat collectionCellWidth = collectionWidth;
    
    // 创建布局
    CYLineLayout *layout = [[CYLineLayout alloc] init];
    layout.cellContentWidth = 190;
    layout.minScale = 0.7;
    layout.itemSize = CGSizeMake(collectionCellWidth, 285);
    
    // 创建CollectionView
    CGRect frame = CGRectMake(0, 150, collectionWidth, collectionHeight);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.pagingEnabled = YES;
    [self.view addSubview:collectionView];
    
    // 注册
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CYPhotoCell class]) bundle:nil] forCellWithReuseIdentifier:CYPhotoId];
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CYPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CYPhotoId forIndexPath:indexPath];
    
    cell.imageName = [NSString stringWithFormat:@"%zd", indexPath.item + 1];
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"------%zd", indexPath.item);
}
@end
