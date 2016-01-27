//
//  Visual1_ViewController.m
//  mylink
//
//  Created by JeongMin Ji on 2014. 11. 11..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import "Visual1_ViewController.h"
#import "PageContentViewController.h"

#define URL1 @"http://jeejjang.cafe24.com/link/kakao_img_thumb.jsp?id=%@"
#define URL2 @"http://jeejjang.cafe24.com/link/kakao_nick.jsp?id=%@"

@interface Visual1_ViewController ()
-(void)drawResultImgs;
-(PageContentViewController *)viewControllerAtIndex:(NSUInteger)index;
-(UIImage*)circularScaleAndCropImage:(UIImage*)image frame:(CGRect)frame;
-(void)myKakaoImgDownloadThread;
@end

@implementation Visual1_ViewController
@synthesize first, linkResult_array2, linkName, pageIndex;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    //pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height); //Change the size of page view controller for paging indicator
    [self addChildViewController:pageViewController];
    [self.view addSubview:pageViewController.view];
    [pageViewController didMoveToParentViewController:self];
    pageViewController.dataSource = self;
    pageViewController.delegate = self;
    isKakaoLogin = first.isKakaoLogin;
    pageIndex = 0;
    [indicator startAnimating];
    [NSThread detachNewThreadSelector:@selector(drawResultImgs) toTarget:self withObject:nil];
    //[self drawResultImgs];
}









-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    if(first.isKakaoLogin && !isKakaoLogin) //로그인 => 새로 그리기
    {
        isKakaoLogin = first.isKakaoLogin;
        [indicator startAnimating];
        [NSThread detachNewThreadSelector:@selector(myKakaoImgDownloadThread) toTarget:self withObject:nil];
    }
    else if(!first.isKakaoLogin && isKakaoLogin) //로그아웃 => 지우기
    {
        isKakaoLogin = first.isKakaoLogin;
        UIBezierPath *path;
        for(int i=0; i<[img_array count]; i++)
        {
            UIImage *resultImg = [img_array objectAtIndex:i];
            float width = resultImg.size.width;
            float height = resultImg.size.height;
            if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 2.0f);
            else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 3.0f);
            else UIGraphicsBeginImageContext(CGSizeMake(width, height));
            [resultImg drawInRect:CGRectMake(0.0f, 0.0f, width, height)];
            //erase
            [[UIColor whiteColor] setFill];
            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(160.0f-31.0f, 80.0f-31.0f, 62.0f, 62.0f)];
            [path fill];
            //draw
            [[UIColor blueColor] setFill];
            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(160.0f-30.0f, 80.0f-30.0f, 60.0f, 60.0f)];
            [path fill];
            //circle
            [[UIColor grayColor] setStroke];
            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(160.0f-30.0f, 80.0f-30.0f, 60.0f, 60.0f)];
            [path setLineWidth:2.0f];
            [path stroke];
            UIImage *resultImg2 = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [img_array replaceObjectAtIndex:i withObject:resultImg2];
        }
        PageContentViewController *startingViewController = [self viewControllerAtIndex:pageIndex];
        NSArray *viewControllers = @[startingViewController];
        [pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
}








//Draw result images
-(void)drawResultImgs
{
    numOfImgs = (int)[[linkResult_array2 objectAtIndex:0] count];
    img_array = [NSMutableArray arrayWithCapacity:numOfImgs];
    pos_array = [NSMutableArray arrayWithCapacity:numOfImgs];
    //[1]Draw image
    UIImage *arrow1 = [UIImage imageNamed:@"arrow1.png"];
    UIImage *arrow2 = [UIImage imageNamed:@"arrow2.png"];
    UIFont *font = [UIFont systemFontOfSize:13.0f];
    NSMutableParagraphStyle *style_out = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style_out.alignment = NSTextAlignmentRight;
    NSDictionary *att_out = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style_out};
    NSMutableParagraphStyle *style_in = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style_in.alignment = NSTextAlignmentLeft;
    NSDictionary *att_in = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style_in};
    NSMutableParagraphStyle *style_title = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style_title.alignment = NSTextAlignmentCenter;
    NSDictionary *att_title = @{NSFontAttributeName:[UIFont systemFontOfSize:17.0f], NSParagraphStyleAttributeName:style_title, NSForegroundColorAttributeName:[UIColor colorWithRed:25.0f/255.0f green:116.0f/255.0f blue:0.0f alpha:1.0f]};
    NSMutableParagraphStyle *style_rank = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style_rank.alignment = NSTextAlignmentCenter;
    NSDictionary *att_rank = @{NSFontAttributeName:[UIFont systemFontOfSize:12.0f], NSParagraphStyleAttributeName:style_rank, NSForegroundColorAttributeName:[UIColor colorWithRed:0.0f green:128.0f/255.0f blue:1.0f alpha:1.0f]};
    float width = 320.0f;
    for(int i=0; i<numOfImgs; i++)
    {
        NSMutableArray *pos_array2 = [NSMutableArray arrayWithCapacity:([[[linkResult_array2 objectAtIndex:0] objectAtIndex:i] count]+1)];
        float nodeNum = (float)([[[linkResult_array2 objectAtIndex:0] objectAtIndex:i] count]-1); //s와 e를 제외한 개수
        float height = 100.0f + 120.0f + 60.0f*nodeNum + 44.0f*(nodeNum+1) + 5.0f*(2.0f*nodeNum+2.0f) + 37.0f;
        if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 2.0f);
        else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 3.0f);
        else UIGraphicsBeginImageContext(CGSizeMake(width, height));
        //(1)s
        [[UIColor grayColor] setStroke];
        [[UIColor blueColor] setFill];
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(130.0f, 50.0f, 60.0f, 60.0f)];
        [pos_array2 addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:160.0f], [NSNumber numberWithFloat:80.0f], nil]];
        [path setLineWidth:2.0f];
        [path fill];
        [path stroke];
        float curX = 130.0f;
        float curY = 110.0f;
        [@"나" drawInRect:CGRectMake(130.0f, 25.0f, 60.0f, 20.0f) withAttributes:att_title];
        NSArray *resultOut_array = [[linkResult_array2 objectAtIndex:1] objectAtIndex:i];
        NSArray *resultIn_array = [[linkResult_array2 objectAtIndex:2] objectAtIndex:i];
        //(2)arrow & node
        for(int i=0; i<(int)nodeNum; i++)
        {
            //out & in
            NSString *str_out = [resultOut_array objectAtIndex:i];
            if(![str_out isEqualToString:@"null"])
            {
                [str_out drawInRect:CGRectMake(curX-110.0f, curY+17.0f, 100.0f, 20.0f) withAttributes:att_out];
                [arrow1 drawInRect:CGRectMake(curX+5.0f, curY+5.0f, 10.0f, 44.0f)];
            }
            NSString *str_in = [resultIn_array objectAtIndex:i];
            if(![str_in isEqualToString:@"null"])
            {
                [str_in drawInRect:CGRectMake(curX+70.0f, curY+17.0f, 100.0f, 20.0f) withAttributes:att_in];
                [arrow2 drawInRect:CGRectMake(curX+45.0f, curY+5.0f, 10.0f, 44.0f)];
            }
            [[UIColor grayColor] setStroke];
            [[UIColor whiteColor] setFill];
            curY += 49.0f;
            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(curX, curY+5.0f, 60.0f, 60.0f)];
            [pos_array2 addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:curX+30.0f], [NSNumber numberWithFloat:curY+5.0f+30.0f], nil]];
            [path setLineWidth:2.0f];
            [path fill];
            [path stroke];
            curY += 65.0f;
        }
        //(3)last arrow
        //out & in
        NSString *str_out = [resultOut_array lastObject];
        if(![str_out isEqualToString:@"null"])
        {
            [str_out drawInRect:CGRectMake(curX-110.0f, curY+17.0f, 100.0f, 20.0f) withAttributes:att_out];
            [arrow1 drawInRect:CGRectMake(curX+5.0f, curY+5.0f, 10.0f, 44.0f)];
        }
        NSString *str_in = [resultIn_array lastObject];
        if(![str_in isEqualToString:@"null"])
        {
            [str_in drawInRect:CGRectMake(curX+70.0f, curY+17.0f, 100.0f, 20.0f) withAttributes:att_in];
            [arrow2 drawInRect:CGRectMake(curX+45.0f, curY+5.0f, 10.0f, 44.0f)];
        }
        curY += 49.0f;
        //(4) e
        [[UIColor grayColor] setStroke];
        [[UIColor blueColor] setFill];
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(curX, curY+5.0f, 60.0f, 60.0f)];
        [pos_array2 addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:curX+30.0f], [NSNumber numberWithFloat:curY+5.0f+30.0f], nil]];
        [path setLineWidth:2.0f];
        [path fill];
        [path stroke];
        [linkName drawInRect:CGRectMake(curX-40, curY+80.0f, 140.0f, 20.0f) withAttributes:att_title];
        UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [img_array addObject:resultImg];
        [pos_array addObject:pos_array2];
    }
    //[2]kakao image download
    NSMutableDictionary *imagePool = [NSMutableDictionary dictionary];
    UIImage *empty = [UIImage imageNamed:@"empty2"];
    //me
    NSString *my_id = [NSString stringWithFormat:@"%ld",first.myid];
    NSString *temp = [NSString stringWithFormat:URL1, my_id];
    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    if(result)
    {
        if([[result objectForKey:@"result"] isEqualToString:@"0"])
        {
            [imagePool setObject:empty forKey:my_id];
        }
        else if([[result objectForKey:@"result"] isEqualToString:@"1"])
        {
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[result objectForKey:@"url"]]]];
            if(image)
            {
                [imagePool setObject:image forKey:my_id];
            }
            else
            {
                [imagePool setObject:empty forKey:my_id];
            }
        }
    }
    //others
    NSArray *ids_array = [linkResult_array2 objectAtIndex:0];
    for(int i=0; i<[ids_array count]; i++)
    {
        NSArray *ids_array2 = [ids_array objectAtIndex:i];
        for(NSString *str_id in ids_array2)
        {
            if([imagePool objectForKey:str_id]) continue;
            else
            {
                NSString *temp = [NSString stringWithFormat:URL1, str_id];
                id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
                if(result)
                {
                    if([[result objectForKey:@"result"] isEqualToString:@"0"])
                    {
                        [imagePool setObject:empty forKey:str_id];
                    }
                    else if([[result objectForKey:@"result"] isEqualToString:@"1"])
                    {
                        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[result objectForKey:@"url"]]]];
                        if(image)
                        {
                            [imagePool setObject:image forKey:str_id];
                        }
                        else
                        {
                            [imagePool setObject:empty forKey:str_id];
                        }
                    }
                }
            }
        }
    }
    //[3]rank(others)
    NSMutableDictionary *rankPool = [NSMutableDictionary dictionary];
    for(int i=0; i<[ids_array count]; i++)
    {
        NSArray *ids_array2 = [ids_array objectAtIndex:i];
        for(NSString *str_id in ids_array2)
        {
            if([rankPool objectForKey:str_id]) continue;
            else
            {
                NSString *temp = [NSString stringWithFormat:URL2, str_id];
                id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
                if(result)
                {
                    if(![[result objectForKey:@"result"] isEqualToString:@"null"]) [rankPool setObject:[result objectForKey:@"result"] forKey:str_id];
                }
            }
        }
    }
    //[4]result image update
    UIBezierPath *path;
    for(int i=0; i<[img_array count]; i++)
    {
        UIImage *resultImg = [img_array objectAtIndex:i];
        float width = resultImg.size.width;
        float height = resultImg.size.height;
        if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 2.0f);
        else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 3.0f);
        else UIGraphicsBeginImageContext(CGSizeMake(width, height));
        [resultImg drawInRect:CGRectMake(0.0f, 0.0f, width, height)];
        //me
        //(1)position
        float x = [[[[pos_array objectAtIndex:i] objectAtIndex:0] objectAtIndex:0] floatValue];
        float y = [[[[pos_array objectAtIndex:i] objectAtIndex:0] objectAtIndex:1] floatValue];
        if([imagePool objectForKey:my_id])
        {
            //(2)erase
            [[UIColor whiteColor] setFill];
            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x-35.0f, y-35.0f, 70.0f, 70.0f)];
            [path fill];
            //image
            UIImage *img2 = [self circularScaleAndCropImage:[imagePool objectForKey:my_id] frame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
            [img2 drawInRect:CGRectMake(x-30.0f, y-30.0f, 60.0f, 60.0f)];
            //(3)circle
            [[UIColor colorWithRed:254.0f/255.0f green:218.0f/255.0f blue:12.0f/255.0f alpha:1.0f] setStroke];
            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x-30.0f, y-30.0f, 60.0f, 60.0f)];
            [path setLineWidth:2.0f];
            [path stroke];
        }
        //rank
        //NSString *str_rank = [NSString stringWithFormat:@"%d",first.rank];
        //[str_rank drawInRect:CGRectMake(x-30.0f, y+30.0f, 60.0f, 15.0f) withAttributes:att_rank];
        //others
        NSArray *ids_array2 = [ids_array objectAtIndex:i];
        for(int j=0; j<[ids_array2 count]; j++)
        {
            NSString *str_id = [ids_array2 objectAtIndex:j];
            //(1)position
            float x = [[[[pos_array objectAtIndex:i] objectAtIndex:j+1] objectAtIndex:0] floatValue];
            float y = [[[[pos_array objectAtIndex:i] objectAtIndex:j+1] objectAtIndex:1] floatValue];
            if([imagePool objectForKey:str_id])
            {
                //(2)erase
                [[UIColor whiteColor] setFill];
                path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x-35.0f, y-35.0f, 70.0f, 70.0f)];
                [path fill];
                //image
                UIImage *img2 = [self circularScaleAndCropImage:[imagePool objectForKey:str_id] frame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
                [img2 drawInRect:CGRectMake(x-30.0f, y-30.0f, 60.0f, 60.0f)];
                //(3)circle
                [[UIColor colorWithRed:254.0f/255.0f green:218.0f/255.0f blue:12.0f/255.0f alpha:1.0f] setStroke];
                path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x-30.0f, y-30.0f, 60.0f, 60.0f)];
                [path setLineWidth:2.0f];
                [path stroke];
            }
            //rank
            if([rankPool objectForKey:str_id])
            {
                NSString *str_rank2 = [rankPool objectForKey:str_id];
                //if([str_rank2 intValue]>0) [str_rank2 drawInRect:CGRectMake(x-100.0f, y+30.0f, 200.0f, 15.0f) withAttributes:att_rank];
                [str_rank2 drawInRect:CGRectMake(x-100.0f, y+30.0f, 200.0f, 15.0f) withAttributes:att_rank];
            }
        }
        resultImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [img_array replaceObjectAtIndex:i withObject:resultImg];
    }
    [imagePool removeAllObjects];
    imagePool = nil;
    [indicator stopAnimating];
    //init
    //page number
    if(numOfImgs>10)
    {
        pageCtrl.hidden = YES;
        [pageLabel setText:[NSString stringWithFormat:@"%d / %d",1,numOfImgs]];
    }
    else
    {
        pageView.hidden = YES;
        if(1==numOfImgs)
        {
            pageCtrl.hidden = YES;
        }
        else
        {
            pageCtrl.userInteractionEnabled = NO;
            pageCtrl.numberOfPages = numOfImgs;
            pageCtrl.currentPage = 0;
        }
    }
    //PageContentViewController
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}









-(void)myKakaoImgDownloadThread
{
    UIImage *image;
    //kakao image download
    NSString *my_id = [NSString stringWithFormat:@"%ld",first.myid];
    NSString *temp = [NSString stringWithFormat:URL1, my_id];
    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    if(result)
    {
        if([[result objectForKey:@"result"] isEqualToString:@"0"])
        {
            image = [UIImage imageNamed:@"empty2"];
        }
        else if([[result objectForKey:@"result"] isEqualToString:@"1"])
        {
            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[result objectForKey:@"url"]]]];
        }
        else return;
    }
    else return;
    //result image update
    UIBezierPath *path;
    for(int i=0; i<[img_array count]; i++)
    {
        UIImage *resultImg = [img_array objectAtIndex:i];
        float width = resultImg.size.width;
        float height = resultImg.size.height;
        if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 2.0f);
        else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 3.0f);
        else UIGraphicsBeginImageContext(CGSizeMake(width, height));
        [resultImg drawInRect:CGRectMake(0.0f, 0.0f, width, height)];
        //erase
        [[UIColor whiteColor] setFill];
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(160.0f-31.0f, 80.0f-31.0f, 62.0f, 62.0f)];
        [path fill];
        //draw
        UIImage *image2 = [self circularScaleAndCropImage:image frame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
        [image2 drawInRect:CGRectMake(160.0f-30.0f, 80.0f-30.0f, 60.0f, 60.0f)];
        //circle
        [[UIColor colorWithRed:254.0f/255.0f green:218.0f/255.0f blue:12.0f/255.0f alpha:1.0f] setStroke];
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(160.0f-30.0f, 80.0f-30.0f, 60.0f, 60.0f)];
        [path setLineWidth:2.0f];
        [path stroke];
        UIImage *resultImg2 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [img_array replaceObjectAtIndex:i withObject:resultImg2];
    }
    [indicator stopAnimating];
    PageContentViewController *startingViewController = [self viewControllerAtIndex:pageIndex];
    NSArray *viewControllers = @[startingViewController];
    [pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}




















//Paging
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    /*
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    if ((index == 0) || (index == NSNotFound)) return nil;
    index--;
    return [self viewControllerAtIndex:index];
    */
    if(1==numOfImgs)
    {
        return nil;
    }
    else
    {
        NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
        if(index == NSNotFound) return nil;
        if(0==index)
        {
            return [self viewControllerAtIndex:numOfImgs-1];
        }
        else
        {
            index--;
            return [self viewControllerAtIndex:index];
        }
    }
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    /*
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    if (index == NSNotFound) return nil;
    index++;
    if (index == numOfImgs) return nil;
    return [self viewControllerAtIndex:index];
    */
    if(1==numOfImgs)
    {
        return nil;
    }
    else
    {
        NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
        if(index == NSNotFound) return nil;
        if((numOfImgs-1)==index)
        {
            return [self viewControllerAtIndex:0];
        }
        else
        {
            index++;
            return [self viewControllerAtIndex:index];
        }
    }
}
-(PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if ((numOfImgs == 0) || (index >= numOfImgs)) return nil;
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.first = first;
    pageContentViewController.visual1 = self;
    pageContentViewController.visual2_2 = nil;
    pageContentViewController.pageIndex = index;
    pageContentViewController.image = [img_array objectAtIndex:index];
    pageContentViewController.ids_array = [NSMutableArray arrayWithArray:[[linkResult_array2 objectAtIndex:0] objectAtIndex:index]];
    [pageContentViewController.ids_array insertObject:[NSString stringWithFormat:@"%ld",first.myid] atIndex:0];
    pageContentViewController.out_array = [NSArray arrayWithArray:[[linkResult_array2 objectAtIndex:1] objectAtIndex:index]];
    pageContentViewController.pos_array = [NSArray arrayWithArray:[pos_array objectAtIndex:index]];
    return pageContentViewController;
}
-(void)pageViewController:(UIPageViewController *)pageViewController2 didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    PageContentViewController *pageContentViewController = [pageViewController2.viewControllers objectAtIndex:0];
    int index = (int)pageContentViewController.pageIndex;
    if(numOfImgs>10)
    {
        [pageLabel setText:[NSString stringWithFormat:@"%d / %d",index+1,numOfImgs]];
    }
    else
    {
        pageCtrl.currentPage = index;
    }
}
//page index
/*
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return numOfImgs;
}
- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}
*/










//image in circle shape
-(UIImage*)circularScaleAndCropImage:(UIImage*)image frame:(CGRect)frame
{
    // This function returns a newImage, based on image, that has been:
    // - scaled to fit in (CGRect) rect
    // - and cropped within a circle of radius: rectWidth/2
    
    //Create the bitmap graphics context
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(frame.size.width, frame.size.height), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //Get the width and heights
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGFloat rectWidth = frame.size.width;
    CGFloat rectHeight = frame.size.height;
    //Calculate the scale factor
    CGFloat scaleFactorX = rectWidth/imageWidth;
    CGFloat scaleFactorY = rectHeight/imageHeight;
    //Calculate the centre of the circle
    CGFloat imageCentreX = rectWidth/2;
    CGFloat imageCentreY = rectHeight/2;
    // Create and CLIP to a CIRCULAR Path
    // (This could be replaced with any closed path if you want a different shaped clip)
    CGFloat radius = rectWidth/2;
    CGContextBeginPath (context);
    CGContextAddArc (context, imageCentreX, imageCentreY, radius, 0, 2*M_PI, 0);
    CGContextClosePath (context);
    CGContextClip (context);
    //Set the SCALE factor for the graphics context
    //All future draw calls will be scaled by this factor
    CGContextScaleCTM (context, scaleFactorX, scaleFactorY);
    // Draw the IMAGE
    CGRect myRect = CGRectMake(0, 0, imageWidth, imageHeight);
    [image drawInRect:myRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}










- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
