//
//  ViewController.m
//  MMTaskSwitcher
//
//  Created by Ralph Li on 7/22/15.
//  Copyright (c) 2015 LJC. All rights reserved.
//

#import "ViewController.h"
#import <iCarousel/iCarousel.h>

@interface iCarousel(LJC)

- (void)depthSortViews;

@end

@implementation iCarousel(LJC)

NSComparisonResult compareViewIndex(UIView *view1, UIView *view2, iCarousel *carousel)
{
    NSInteger index1 = [carousel indexOfItemView:view1];
    NSInteger index2 = [carousel indexOfItemView:view2];
    
    NSLog(@"%ld %ld",index1,index2);
    
    return (index1>index2)? NSOrderedAscending: NSOrderedDescending;
}

- (void)depthSortViews
{
    NSDictionary *itemViews = [self valueForKey:@"_itemViews"];
    UIView *contentView = [self valueForKey:@"_contentView"];
    
    for (UIView *view in [[itemViews allValues] sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))compareViewIndex context:(__bridge void *)self])
    {
        [contentView sendSubviewToBack:view.superview];
    }
}

@end

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
    
    
    self.cardSize = CGSizeMake(500*9/16, 500);
    self.view.backgroundColor = [UIColor blackColor];
    
    self.carousel = [[iCarousel alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:self.carousel];
    self.carousel.delegate = self;
    self.carousel.dataSource = self;
    self.carousel.type = iCarouselTypeCustom;
    self.carousel.bounceDistance = 0.2f;
    self.carousel.viewpointOffset = CGSizeMake(-([UIScreen mainScreen].bounds.size.width - self.cardSize.width)/2, 0);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return 15;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UIView *cardView = view;
    
    if ( !cardView )
    {
        cardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.cardSize.width, self.cardSize.height)];
        cardView.tag = index;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectInset(cardView.bounds, 3, 3)];
        [cardView addSubview:imageView];
        imageView.tag = index;
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg",index%5+1]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        cardView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:imageView.frame cornerRadius:5.0f].CGPath;
        cardView.layer.shadowRadius = 3.0f;
        cardView.layer.shadowColor = [UIColor blackColor].CGColor;
        cardView.layer.shadowOpacity = 0.5f;
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame = imageView.bounds;
        layer.path = [UIBezierPath bezierPathWithRoundedRect:imageView.bounds cornerRadius:5.0f].CGPath;
        imageView.layer.mask = layer;
    }
    
    return cardView;
}

- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    
    CGFloat scale = [self scaleByOffset:offset];
    CGFloat translation = [self translationByOffset:offset];
    
//    NSLog(@"offset:%f scale:%f translation:%f",offset,scale,translation);
    
    return CATransform3DScale(CATransform3DTranslate(transform, translation * 270, 0, 0), scale, scale, 1.0f);
}

- (void)carouselDidScroll:(iCarousel *)carousel
{
    for ( UIView *view in carousel.visibleItemViews) {
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

- (CGFloat)scaleByOffset:(CGFloat)offset
{
    return offset*0.04f + 1.0f;
}

- (CGFloat)translationByOffset:(CGFloat)offset
{
    CGFloat z = 5.0f/4.0f;
    CGFloat n = 5.0f/8.0f;
    
    if ( offset >= z/n )
    {
        return 2.0f;
    }
    
    return 1/(z-n*offset)-1/z;
    
    return 0.0f;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    [carousel removeItemAtIndex:index animated:YES];
}

@end

