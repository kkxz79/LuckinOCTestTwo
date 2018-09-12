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
#import "LuckinURLSessionViewController.h"
#import "LuckinAFNViewController.h"
#import "LuckinXZNetworkViewController.h"


@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(nonatomic,strong)UICollectionViewFlowLayout * layout;
@property(nonatomic,strong)UICollectionView * collectionView;
@property(nonatomic,strong)NSArray * imageArray;

@property(nonatomic,strong)UIButton * buttonOne;
@property(nonatomic,strong)UIButton * buttonTwo;
@property(nonatomic,strong)UIButton * buttonThree;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithTitle:@"Session" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonAction)];
    self.navigationItem.rightBarButtonItem = barButton;
    [self createSubViews];
    [self createAutoLayout];
}

-(void)rightButtonAction
{
    LuckinURLSessionViewController * sessionVC = [[LuckinURLSessionViewController alloc] init];
    [self.navigationController pushViewController:sessionVC animated:YES];
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
    
    [self.view addSubview: self.buttonOne];
    [self.view addSubview: self.buttonTwo];
    [self.view addSubview: self.buttonThree];
    
}
-(void)createAutoLayout
{
     __weak __typeof(self)myself = self;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(myself.view).with.insets(UIEdgeInsetsMake(0.0f, 0.0f, 100.0f, 0.0f));
    }];
    [self.buttonOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(myself.collectionView.mas_bottom).offset(25.0f);
        make.centerX.mas_equalTo(myself.view.mas_centerX);
    }];
    [self.buttonTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(myself.buttonOne.mas_top);
        make.right.mas_equalTo(myself.buttonOne.mas_left).offset(-40.0f);
    }];
    [self.buttonThree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(myself.buttonOne.mas_top);
        make.left.mas_equalTo(myself.buttonOne.mas_right).offset(40.0f);
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

#pragma mark - private methods
-(void)afnClick
{
    LuckinAFNViewController * afnVC = [[LuckinAFNViewController alloc] init];
    [self.navigationController pushViewController:afnVC animated:YES];
}
-(void)customOneClick
{
    LuckinXZNetworkViewController * xzNetVC = [[LuckinXZNetworkViewController alloc] init];
    [self.navigationController pushViewController:xzNetVC animated:YES];
}

-(void)customTwoClick
{
    
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

@synthesize buttonOne = _buttonOne;
-(UIButton *)buttonOne
{
    if(_buttonOne == nil){
        _buttonOne = [UIButton buttonWithType:UIButtonTypeSystem];
        [_buttonOne setTitle:@"AFN" forState:UIControlStateNormal];
        [_buttonOne.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_buttonOne setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_buttonOne addTarget:self action:@selector(afnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonOne;
}

@synthesize buttonTwo = _buttonTwo;
-(UIButton *)buttonTwo
{
    if(_buttonTwo == nil){
        _buttonTwo = [UIButton buttonWithType:UIButtonTypeSystem];
        [_buttonTwo setTitle:@"CustomOne" forState:UIControlStateNormal];
        [_buttonTwo.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_buttonTwo setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_buttonTwo addTarget:self action:@selector(customOneClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonTwo;
}

@synthesize buttonThree = _buttonThree;
-(UIButton *)buttonThree
{
    if(_buttonThree == nil){
        _buttonThree = [UIButton buttonWithType:UIButtonTypeSystem];
        [_buttonThree setTitle:@"CustomTwo" forState:UIControlStateNormal];
        [_buttonThree.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_buttonThree setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_buttonThree addTarget:self action:@selector(customTwoClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonThree;
}

@end
