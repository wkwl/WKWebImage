//
//  ViewController.m
//  WKWebImage
//
//  Created by 77 on 2017/5/27.
//  Copyright © 2017年 77. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCell.h"
#import "WKW_WebImageCache.h"
#import "UIImageView+WKWebImage.h"
@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *mainCollectionView;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createUI];
    [self.view addSubview:_mainCollectionView];
}


- (void)createUI {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 100);
    layout.itemSize =CGSizeMake(180, 180);
     [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    _mainCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    [_mainCollectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    _mainCollectionView.delegate = self;
    _mainCollectionView.dataSource = self;
    _mainCollectionView.backgroundColor = [UIColor clearColor];

}
//http://img.ivsky.com/img/tupian/pre/201704/22/pugongying-003.jpg


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}


//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(180, 180);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://img.ivsky.com/img/tupian/pre/201704/22/pugongying-00%ld.jpg", indexPath.row+6];
    [cell.imageView wkw_setImageUrlString:urlStr placeholderImage:nil];
    
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
