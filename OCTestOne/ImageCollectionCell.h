//
//  ImageCollectionCell.h
//  CollectionViewDemo
//
//  Created by kkxz on 16/8/17.
//  Copyright © 2016年 kkxz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCollectionCell : UICollectionViewCell
@property(nonatomic,strong)UIImageView * iconImage;
-(void)setCellContentImageWith:(NSString*)imagePath;
@end
