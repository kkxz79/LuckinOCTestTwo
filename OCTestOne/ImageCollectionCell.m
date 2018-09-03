//
//  ImageCollectionCell.m
//  CollectionViewDemo
//
//  Created by kkxz on 16/8/17.
//  Copyright © 2016年 kkxz. All rights reserved.
//

#import "ImageCollectionCell.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"

@implementation ImageCollectionCell

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor whiteColor];
        [self createSubViews];
        [self createAutoLayout];
    }
    return self;
}

-(void)createSubViews
{
    [self addSubview:self.iconImage];
}

-(void)createAutoLayout
{
    __weak ImageCollectionCell * myself = self;
    [self.iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(myself).with.insets(UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f));
    }];
}

-(void)setCellContentImageWith:(NSString*)imagePath
{
    [self.iconImage sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:nil options:SDWebImageRetryFailed];
}

#pragma mark - lazy init
@synthesize iconImage = _iconImage;
-(UIImageView *)iconImage
{
    if(_iconImage == nil){
        _iconImage = [[UIImageView alloc] init];
        _iconImage.backgroundColor = [UIColor whiteColor];
    }
    return _iconImage;
}
@end
