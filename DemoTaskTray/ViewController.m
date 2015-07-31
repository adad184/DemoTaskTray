//
//  ViewController.m
//  MMTaskSwitcher
//
//  Created by Ralph Li on 7/22/15.
//  Copyright (c) 2015 LJC. All rights reserved.
//

#import "ViewController.h"
#import <iCarousel/iCarousel.h>

@interface ViewController ()
<
iCarouselDelegate,
iCarouselDataSource
>

@property (nonatomic, strong) iCarousel *carousel;

@property (nonatomic, assign) CGSize cardSize;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGFloat cardWidth = [UIScreen mainScreen].bounds.size.width*5.0f/7.0f;
    self.cardSize = CGSizeMake(cardWidth, cardWidth*16.0f/9.0f);
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"3.jpg"]];
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:visualEffectView];
    
    self.carousel = [[iCarousel alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:self.carousel];
    self.carousel.delegate = self;
    self.carousel.dataSource = self;
    self.carousel.type = iCarouselTypeCustom;
    self.carousel.bounceDistance = 0.2f;
    self.carousel.viewpointOffset = CGSizeMake(-cardWidth/5.0f, 0);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return 15;
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    return self.cardSize.width;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    switch (option) {
        case iCarouselOptionVisibleItems:
        {
            return 7;
        }

            //可以打开这里看一下效果
//        case iCarouselOptionWrap:
//        {
//            return YES;
//        }
            
        default:
            break;
    }
    
    return value;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UIView *cardView = view;
    
    if ( !cardView )
    {
        cardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.cardSize.width, self.cardSize.height)];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:cardView.bounds];
        [cardView addSubview:imageView];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.backgroundColor = [UIColor whiteColor];
        imageView.tag = [@"image" hash];
        
        cardView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:imageView.frame cornerRadius:5.0f].CGPath;
        cardView.layer.shadowRadius = 3.0f;
        cardView.layer.shadowColor = [UIColor blackColor].CGColor;
        cardView.layer.shadowOpacity = 0.5f;
        cardView.layer.shadowOffset = CGSizeMake(0, 0);
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame = imageView.bounds;
        layer.path = [UIBezierPath bezierPathWithRoundedRect:imageView.bounds cornerRadius:5.0f].CGPath;
        imageView.layer.mask = layer;
    }
    
    UIImageView *imageView = (UIImageView*)[cardView viewWithTag:[@"image" hash]];
    imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg",index%5+1]];
    
    
    
    return cardView;
}

- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    CGFloat scale = [self scaleByOffset:offset];
    CGFloat translation = [self translationByOffset:offset];
    
    return CATransform3DScale(CATransform3DTranslate(transform, translation * self.cardSize.width, 0, offset), scale, scale, 1.0f);
}

- (void)carouselDidScroll:(iCarousel *)carousel
{
    for ( UIView *view in carousel.visibleItemViews)
    {
        CGFloat offset = [carousel offsetForItemAtIndex:[carousel indexOfItemView:view]];
        
        if ( offset < -3.0 )
        {
            view.alpha = 0.0f;
        }
        else if ( offset < -2.0f)
        {
            view.alpha = offset + 3.0f;
        }
        else
        {
            view.alpha = 1.0f;
        }
    }
}

//形变是线性的就ok了
- (CGFloat)scaleByOffset:(CGFloat)offset
{
    return offset*0.04f + 1.0f;
}

//位移通过得到的公式来计算
- (CGFloat)translationByOffset:(CGFloat)offset
{
    CGFloat z = 5.0f/4.0f;
    CGFloat n = 5.0f/8.0f;
    
    //z/n是临界值 >=这个值时 我们就把itemView放到比较远的地方不让他显示在屏幕上就可以了
    if ( offset >= z/n )
    {
        return 2.0f;
    }
    
    return 1/(z-n*offset)-1/z;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    //点击可删除itemView
//    [carousel removeItemAtIndex:index animated:YES];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end

