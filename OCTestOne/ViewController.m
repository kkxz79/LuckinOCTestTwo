//
//  ViewController.m
//  OCTestOne
//
//  Created by kkxz on 2018/8/31.
//  Copyright © 2018年 kkxz. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "ImageCollectionCell.h"

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(nonatomic,strong)UICollectionViewFlowLayout * layout;
@property(nonatomic,strong)UICollectionView * collectionView;
@property(nonatomic,strong)NSArray * imageArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    self.view.backgroundColor = [UIColor whiteColor];
    [self createSubViews];
    [self createAutoLayout];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)createSubViews
{
    [self.view addSubview:self.collectionView];
    //注册Cell类，否则会崩溃
    [self.collectionView registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:@"MyCollectionViewCell"];
}
-(void)createAutoLayout
{
    __weak ViewController * myself = self;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(myself.view).with.insets(UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f));
    }];
}

#pragma mark - UICollectionViewDataSource method
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageArray.count+1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIName = @"MyCollectionViewCell";
    ImageCollectionCell * cell = (ImageCollectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellIName forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    if(indexPath.row<9){
        [cell setCellContentImageWith:self.imageArray[indexPath.row]];
    }
    else{
        NSString * imagePath = [self pathForResource:@"luckinpic" ofType:@"jpg"];
        cell.iconImage.image = [UIImage imageNamed:imagePath];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate method
-(BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionCell * cell = (ImageCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor blueColor];
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if([NSStringFromSelector(action) isEqualToString:@"copy:"]
       ||[NSStringFromSelector(action) isEqualToString:@"paste:"]){
        return YES;
    }
    else{
        return NO;
    }
}

-(void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    NSLog(@"复制之后，可以插入一个新的cell");
}

//TODO:获取库图片
- (NSString *)pathForResource:(NSString *)resource ofType:(NSString *)type
{
    NSBundle *selfBundle = [NSBundle bundleForClass:[self class]];
    NSString *bundlePath = [selfBundle pathForResource:@"LuckinTimeDate" ofType:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
    return [resourceBundle pathForResource:resource ofType:type];
}


#pragma mark - UICollectionViewDelegateFlowLayout method
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGFloat normalSize = (self.view.frame.size.width - 20.0f)/3;
    return CGSizeMake(normalSize, 0.0f);
}

#pragma mark - lazy init
@synthesize layout = _layout;
-(UICollectionViewFlowLayout *)layout
{
    if(_layout == nil){
        _layout  = [[UICollectionViewFlowLayout alloc] init];
        [_layout setScrollDirection:UICollectionViewScrollDirectionVertical];//设置对齐方式
        _layout.minimumInteritemSpacing = 5.0f;//cell间距
        _layout.minimumLineSpacing = 5.0f;//cell行距
        _layout.sectionInset=UIEdgeInsetsMake(5, 5, 5, 5);//每项四周留空白空间
        CGFloat normalSize = (self.view.frame.size.width - 4*5.0f)/3;
        _layout.itemSize = CGSizeMake(normalSize, normalSize);
    }
    return _layout;
}

@synthesize collectionView = _collectionView;
-(UICollectionView *)collectionView
{
    if(_collectionView == nil){
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

@synthesize imageArray = _imageArray;
-(NSArray *)imageArray
{
    if(_imageArray == nil){
        _imageArray = @[@"http://pic.qqtn.com/up/2016-7/2016072011195241409.jpg",
                        @"http://www.poluoluo.com/qq/UploadFiles_7828/201607/2016072519540813.jpg",
                        @"http://scimg.jb51.net/allimg/150424/14-1504241635100-L.jpg",
                        @"http://img51.nipic.com/20131203/3822951_102602949000_1.jpg",
                        @"http://img05.tooopen.com/images/20150830/tooopen_sl_140756539841.jpg",
                        @"http://tupian.qqjay.com/160x160/u/2016/0101/10_155023_1.jpg",
                        @"http://tupian.qqjay.com/160x160/u/2015/1019/1_21410_7.jpg",
                        @"http://img73.nipic.com/file/20160420/20721554_193605692000_1.jpg",
                        @"http://img3.redocn.com/tupian/20111021/hulunbeiercaoyuanfengjing_407689_small.jpg",
                        ];
    }
    return _imageArray;
}

@end
