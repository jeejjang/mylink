//
//  Visual2_ViewController.m
//  mylink
//
//  Created by JeongMin Ji on 2014. 11. 24..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//


#import "Visual2_ViewController.h"
#import "Visual2_2_ViewController.h"
#import "UserInfo_ViewController.h"

#define URL1 @"http://jeejjang.cafe24.com/link/kakao_img_thumb.jsp?id=%@"
#define URL2 @"http://jeejjang.cafe24.com/link/idtophone_1.jsp?id=%@"
//#define URL3 @"http://jeejjang.cafe24.com/link/rank_num.jsp?id=%@"

@interface Visual2_ViewController ()
-(void)drawResultImgs;
-(void)tapped:(UITapGestureRecognizer *)gesture;
-(void)tappedTarget:(UITapGestureRecognizer *)gesture;
-(void)tappedThread:(NSNumber *)num;
-(void)myKakaoImgDownloadThread;
-(void)stepperPressed:(id)sender;
-(void)btnDelClicked:(id)sender;
-(void)combinations:(NSMutableArray *)result1 arg1:(int)start arg2:(int)n arg3:(int)k arg4:(int)maxK;
-(UIImage*)circularScaleAndCropImage:(UIImage*)image frame:(CGRect)frame;
-(void)reloadCellImage:(NSIndexPath *)indexPath;
@end

@implementation Visual2_ViewController
@synthesize first, linkResult_array2, linkNames_array2;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    scrollView_visual2.delegate = self;
    //Tap gesture
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedTarget:)];
    tap2.numberOfTapsRequired = 2;
    [scrollView_visual2 addGestureRecognizer:tap2];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    tap.numberOfTapsRequired = 1;
    [scrollView_visual2 addGestureRecognizer:tap];
    [tap requireGestureRecognizerToFail:tap2]; //tap과 tap2를 구분
    targetNum_array = [NSMutableArray array];
    img_not = [UIImage imageNamed:@"not"];
    //tableView_visual2
    btn_del = nil;
    img_del = [UIImage imageNamed:@"del2"];
    tableView_visual2 = nil;
    prePt = CGPointMake(-1.0f, -1.0f);
    outer_ids_array = [NSMutableArray array];
    outer_order_array = [NSMutableArray array];
    tv_ids_array = [NSMutableArray array];
    tv_relations_array = [NSMutableArray array];
    //tv_results_array = [NSMutableArray array];
    //tv_ranks_array = [NSMutableArray array];
    tv_downloaderQueue = [[NSOperationQueue alloc] init];
    tv_imagePool = [NSMutableDictionary dictionary];
    tv_curI = -2; tv_curJ = -2;
    //Kakao
    isKakaoLogin = first.isKakaoLogin;
    //init
    int sortNum = (int)[linkResult_array2 count];
    NSMutableArray *ids_array = [NSMutableArray arrayWithCapacity:sortNum];   //ids_array: linkResult_array2에서 id만을 가져와서 만든 set 배열(목적id는 제외)
    for(NSArray *array in linkResult_array2)
    {
        NSMutableSet *set = [NSMutableSet set];
        NSArray *array2 = [array objectAtIndex:0];
        for(NSArray *array3 in array2)
        {
            for(int i=0; i<[array3 count]-1; i++)
            {
                [set addObject:[array3 objectAtIndex:i]];
            }
        }
        [ids_array addObject:set];
    }
    //result_order
    NSMutableArray *result1 = [NSMutableArray array];
    for(int i=sortNum; i>1; i--)
    {
        [self combinations:result1 arg1:1 arg2:(sortNum+1) arg3:1 arg4:i];
    }
    //re-ordering
    result_order = [NSMutableArray arrayWithCapacity:sortNum-1];
    NSUInteger cnt = [[result1 objectAtIndex:0] count];
    NSMutableArray *temp = [NSMutableArray array];
    for(int i=0; i<[result1 count]; i++)
    {
        NSArray *array = [result1 objectAtIndex:i];
        if([array count]==cnt)
        {
            [temp addObject:array];
        }
        else
        {
            [result_order addObject:[NSArray arrayWithArray:temp]];
            [temp removeAllObjects];
            cnt = [array count];
            [temp addObject:array];
        }
        if(([result1 count]-1)==i)
        {
            [result_order addObject:[NSArray arrayWithArray:temp]];
        }
    }
    //result_nodes
    NSMutableSet *set1 = [NSMutableSet setWithSet:[ids_array objectAtIndex:0]];
    for(int i=1; i<[ids_array count]; i++)
    {
        [set1 intersectSet:[ids_array objectAtIndex:i]];
    }
    result_nodes1 = [NSMutableArray arrayWithObject:set1];
    result_nodes2 = [NSMutableArray arrayWithCapacity:sortNum-1];
    for(NSArray *array in result_order)
    {
        NSMutableArray *temp1 = [NSMutableArray arrayWithCapacity:[array count]];
        for(NSArray *array2 in array)
        {
            NSMutableSet *temp_set = [NSMutableSet setWithSet:[ids_array objectAtIndex:([[array2 objectAtIndex:0] intValue]-2)]];
            for(int i=1; i<[array2 count]; i++)
            {
                [temp_set intersectSet:[ids_array objectAtIndex:([[array2 objectAtIndex:i] intValue]-2)]];
            }
            [temp1 addObject:temp_set];
        }
        [result_nodes2 addObject:temp1];
    }
    result_nodes3 = [NSMutableArray arrayWithCapacity:sortNum+1];
    [result_nodes3 addObject:[NSSet setWithObject:[NSString stringWithFormat:@"%ld",first.myid]]];
    for(NSArray *array in linkResult_array2)
    {
        NSSet *set = [NSSet setWithObject:[[[array objectAtIndex:0] objectAtIndex:0] lastObject]];
        [result_nodes3 addObject:set];
    }
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
        float x = [[[pos_array3 objectAtIndex:0] objectAtIndex:0] floatValue];
        float y = [[[pos_array3 objectAtIndex:0] objectAtIndex:1] floatValue];
        NSMutableArray *resultImg_array2 = [NSMutableArray arrayWithCapacity:[resultImg_array count]];
        for(int i=0; i<[resultImg_array count]; i++)
        {
            UIImage *resultImg2 = [resultImg_array objectAtIndex:i];
            float width = resultImg2.size.width;
            float height = resultImg2.size.height;
            if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 2.0f);
            else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 3.0f);
            else UIGraphicsBeginImageContext(CGSizeMake(width, height));
            [resultImg2 drawInRect:CGRectMake(0.0f, 0.0f, width, height)];
            //erase
            [[UIColor whiteColor] setFill];
            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x-30.0f, y-30.0f, 60.0f, 60.0f)];
            [path fill];
            //draw
            [[UIColor blueColor] setFill];
            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x-30.0f, y-30.0f, 60.0f, 60.0f)];
            [path fill];
            //circle
            [[UIColor grayColor] setStroke];
            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x-30.0f, y-30.0f, 60.0f, 60.0f)];
            [path setLineWidth:2.0f];
            [path stroke];
            [resultImg_array2 addObject:UIGraphicsGetImageFromCurrentImageContext()];
            UIGraphicsEndImageContext();
        }
        int imgCnt = 0;
        for(UIImage *img in resultImg_array2)
        {
            [resultImg_array replaceObjectAtIndex:imgCnt withObject:img];
            imgCnt++;
        }
        resultImg = [resultImg_array objectAtIndex:stepper.value];
        [imageView_visual2 setImage:resultImg];
        [imagePool removeObjectForKey:[NSString stringWithFormat:@"%ld",first.myid]];
    }
}








-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    [scrollView_visual2 setContentInset:UIEdgeInsetsZero];
    [scrollView_visual2 setScrollIndicatorInsets:UIEdgeInsetsZero];
    /*
    if(tableView_visual2)
    {
        [self.view bringSubviewToFront:tableView_visual2];
        [tableView_visual2 setContentInset:UIEdgeInsetsZero];
        [tableView_visual2 setScrollIndicatorInsets:UIEdgeInsetsZero];
    }
    */
}















-(void)drawResultImgs
{
    resultImg_array = [NSMutableArray array];
    int sortNum = (int)[linkResult_array2 count]; //nC1 노드 개수:sortNum+1
    //Draw
    UIFont *font = [UIFont systemFontOfSize:12.0f];
    NSMutableParagraphStyle *style_title = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style_title.alignment = NSTextAlignmentCenter;
    NSDictionary *att_title = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style_title, NSForegroundColorAttributeName:[UIColor colorWithRed:25.0f/255.0f green:116.0f/255.0f blue:0.0f alpha:1.0f]};
    font = [UIFont systemFontOfSize:30.0f];
    NSMutableParagraphStyle *style_num = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style_num.alignment = NSTextAlignmentCenter;
    NSDictionary *att_num = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style_num, NSForegroundColorAttributeName:[UIColor orangeColor]};
    float width_half, height_half;
    width_half = height_half = 30.0f+(80.0f+60.0f)*sortNum+50.0f;
    UIBezierPath *path;
    if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width_half*2.0f,height_half*2.0f), NO, 2.0f);
    else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width_half*2.0f,height_half*2.0f), NO, 3.0f);
    else UIGraphicsBeginImageContext(CGSizeMake(width_half*2.0f, height_half*2.0f));
    int numOfNodes;
    float radius;
    float angle_inter;
    float angle_offset;
    //(1)kakao image download
    imagePool = [NSMutableDictionary dictionary];
    UIImage *empty = [UIImage imageNamed:@"empty2"];
    NSString *my_id = [NSString stringWithFormat:@"%ld",first.myid];
    //me & others
    NSMutableArray *ids_array = [NSMutableArray array];
    [ids_array addObject:my_id];
    for(NSArray *array in linkResult_array2)
    {
        [ids_array addObject:[[[array objectAtIndex:0] objectAtIndex:0] lastObject]];
    }
    for(NSString *str_id in ids_array)
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
    /*
    //(1-1)rank download
    rankPool = [NSMutableDictionary dictionary];
    for(int i=1; i<[ids_array count]; i++)
    {
        NSString *str_id = [ids_array objectAtIndex:i];
        if([rankPool objectForKey:str_id]) continue;
        else
        {
            NSString *temp = [NSString stringWithFormat:URL3, str_id];
            id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
            if(result)
            {
                [rankPool setObject:[result objectForKey:@"result"] forKey:str_id];
            }
        }
    }
    */
    //(2)lines -> resultImg_array
    //nC1
    numOfNodes = sortNum+1;
    pos_array3 = [NSMutableArray arrayWithCapacity:numOfNodes];
    radius = (80.0f+60.0f)*(numOfNodes-1);
    angle_offset = -M_PI/2.0f;
    angle_inter = (M_PI*2.0f)/(float)numOfNodes;
    for(int i=0; i<numOfNodes; i++)
    {
        [pos_array3 addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:radius*cos(angle_offset+angle_inter*(float)i)+width_half], [NSNumber numberWithFloat:radius*sin(angle_offset+angle_inter*(float)i)+height_half], nil]];
    }
    //nCn
    pos_array1 = [NSMutableArray arrayWithCapacity:1];
    if([[result_nodes1 objectAtIndex:0] count]>0)
    {
        [pos_array1 addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:width_half], [NSNumber numberWithFloat:height_half], nil]];
        path = [UIBezierPath bezierPath];
        [[UIColor blackColor] setStroke];
        [path setLineWidth:3.0f];
        for(NSArray *array in pos_array3)
        {
            [path moveToPoint:CGPointMake(width_half, height_half)];
            [path addLineToPoint:CGPointMake([[array objectAtIndex:0] floatValue], [[array objectAtIndex:1] floatValue])];
            [path stroke];
        }
        [resultImg_array addObject:UIGraphicsGetImageFromCurrentImageContext()];
        UIGraphicsEndImageContext();
        if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width_half*2.0f,height_half*2.0f), NO, 2.0f);
        else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width_half*2.0f,height_half*2.0f), NO, 3.0f);
        else UIGraphicsBeginImageContext(CGSizeMake(width_half*2.0f, height_half*2.0f));
    }
    else
    {
        [pos_array1 addObject:[NSMutableArray array]];
    }
    //nCn-1 -> nC2
    pos_array2 = [NSMutableArray arrayWithCapacity:[result_nodes2 count]];
    for(int i=0; i<[result_nodes2 count]; i++)
    {
        NSArray *array = [result_nodes2 objectAtIndex:i];
        NSArray *array2 = [result_order objectAtIndex:i];
        numOfNodes = (int)[array count];
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:numOfNodes];
        radius = (80.0f+60.0f)*(float)(i+1);
        angle_offset = -M_PI/2.0f+M_PI*5.0f/36.0f*(float)(i+1);
        angle_inter = (M_PI*2.0f)/(float)numOfNodes;
        BOOL isLines = NO;
        for(int j=0; j<numOfNodes; j++)
        {
            if([[array objectAtIndex:j] count]>0)
            {
                path = [UIBezierPath bezierPath];
                [[UIColor blackColor] setStroke];
                [path setLineWidth:3.0f];
                //position
                float x = radius*cos(angle_offset+angle_inter*(float)j)+width_half;
                float y = radius*sin(angle_offset+angle_inter*(float)j)+height_half;
                [temp addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:x], [NSNumber numberWithFloat:y], nil]];
                //lines
                float x2 = [[[pos_array3 objectAtIndex:0] objectAtIndex:0] floatValue];
                float y2 = [[[pos_array3 objectAtIndex:0] objectAtIndex:1] floatValue];
                [path moveToPoint:CGPointMake(x, y)];
                [path addLineToPoint:CGPointMake(x2, y2)];
                [path stroke];
                for(NSString *str in [array2 objectAtIndex:j])
                {
                    int num = [str intValue]-1;
                    x2 = [[[pos_array3 objectAtIndex:num] objectAtIndex:0] floatValue];
                    y2 = [[[pos_array3 objectAtIndex:num] objectAtIndex:1] floatValue];
                    [path moveToPoint:CGPointMake(x, y)];
                    [path addLineToPoint:CGPointMake(x2, y2)];
                    [path stroke];
                }
                isLines = YES;
            }
            else
            {
                [temp addObject:[NSMutableArray array]];
            }
        }
        [pos_array2 addObject:temp];
        if(isLines)
        {
            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(width_half-radius, height_half-radius, radius*2.0f, radius*2.0f)];
            [[UIColor colorWithWhite:0.4f alpha:1.0f] setStroke];
            [path setLineWidth:2.0f];
            float dash[] = {4,10};
            [path setLineDash:(CGFloat *)dash count:2 phase:1];
            [path stroke];
            [resultImg_array addObject:UIGraphicsGetImageFromCurrentImageContext()];
            UIGraphicsEndImageContext();
            if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width_half*2.0f,height_half*2.0f), NO, 2.0f);
            else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width_half*2.0f,height_half*2.0f), NO, 3.0f);
            else UIGraphicsBeginImageContext(CGSizeMake(width_half*2.0f, height_half*2.0f));
        }
    }
    UIGraphicsEndImageContext();
    //
    NSMutableArray *resultImg_array2 = [NSMutableArray arrayWithCapacity:[resultImg_array count]];
    for(UIImage *img in resultImg_array)
    {
        if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width_half*2.0f,height_half*2.0f), NO, 2.0f);
        else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width_half*2.0f,height_half*2.0f), NO, 3.0f);
        else UIGraphicsBeginImageContext(CGSizeMake(width_half*2.0f, height_half*2.0f));
        [img drawInRect:CGRectMake(0.0f, 0.0f, width_half*2.0f, height_half*2.0f)];
        //(1)Outer circle
        radius = (80.0f+60.0f)*(float)sortNum;
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(width_half-radius, height_half-radius, radius*2.0f, radius*2.0f)];
        [[UIColor colorWithWhite:0.8f alpha:1.0f] setStroke];
        [path setLineWidth:2.0f];
        //float dash[] = {4,10};
        //[path setLineDash:(CGFloat *)dash count:2 phase:1];
        [path stroke];
        //(2)nodes
        //nC1
        [[UIColor grayColor] setStroke];
        [[UIColor blueColor] setFill];
        for(NSArray *array in pos_array3)
        {
            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake([[array objectAtIndex:0] floatValue]-30.0f, [[array objectAtIndex:1] floatValue]-30.0f, 60.0f, 60.0f)];
            [path fill];
            [path setLineWidth:2.0f];
            [path stroke];
        }
        [[UIColor colorWithWhite:0.3f alpha:1.0f] setFill];
        //nCn
        if([[pos_array1 objectAtIndex:0] count]>0)
        {
            int number = (int)[[result_nodes1 objectAtIndex:0] count];
            int node_radius = 30.0f+(number-1)*2.0f;
            if(node_radius>50.0f) node_radius = 50.0f;
            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake([[[pos_array1 objectAtIndex:0] objectAtIndex:0] floatValue]-node_radius, [[[pos_array1 objectAtIndex:0] objectAtIndex:1] floatValue]-node_radius, node_radius*2.0f, node_radius*2.0f)];
            [path fill];
            [path setLineWidth:2.0f];
            [path stroke];
        }
        //nCn-1 -> nC2
        int cnt = 0;
        for(NSArray *array in pos_array2)
        {
            NSArray *array_result = [result_nodes2 objectAtIndex:cnt];
            cnt++;
            [[UIColor colorWithWhite:0.3f+0.15f*(float)cnt alpha:1.0f] setFill];
            int cnt2 = 0;
            for(NSArray *array2 in array)
            {
                if([array2 count]>0)
                {
                    int number = (int)[[array_result objectAtIndex:cnt2] count];
                    int node_radius = 30.0f+(number-1)*2.0f;
                    if(node_radius>50.0f) node_radius = 50.0f;
                    path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake([[array2 objectAtIndex:0] floatValue]-node_radius, [[array2 objectAtIndex:1] floatValue]-node_radius, node_radius*2.0f, node_radius*2.0f)];
                    [path fill];
                    [path setLineWidth:2.0f];
                    [path stroke];
                }
                cnt2++;
            }
        }
        //(3)number
        float x,y;
        if([[result_nodes1 objectAtIndex:0] count]>0)
        {
            x = [[[pos_array1 objectAtIndex:0] objectAtIndex:0] floatValue];
            y = [[[pos_array1 objectAtIndex:0] objectAtIndex:1] floatValue];
            [[NSString stringWithFormat:@"%d",(int)[[result_nodes1 objectAtIndex:0] count]] drawInRect:CGRectMake(x-30.0f, y-18.0f, 60.0f, 30.0f) withAttributes:att_num];
        }
        for(int i=0; i<[pos_array2 count]; i++)
        {
            NSArray *array = [pos_array2 objectAtIndex:i];
            NSArray *array2 = [result_nodes2 objectAtIndex:i];
            for(int j=0; j<[array2 count]; j++)
            {
                int number = (int)[[array2 objectAtIndex:j] count];
                if(0<number)
                {
                    x = [[[array objectAtIndex:j] objectAtIndex:0] floatValue];
                    y = [[[array objectAtIndex:j] objectAtIndex:1] floatValue];
                    [[NSString stringWithFormat:@"%d",number] drawInRect:CGRectMake(x-30.0f, y-18.0f, 60.0f, 30.0f) withAttributes:att_num];
                }
            }
        }
        //(4)name
        x = [[[pos_array3 objectAtIndex:0] objectAtIndex:0] floatValue]-50.0f;
        y = [[[pos_array3 objectAtIndex:0] objectAtIndex:1] floatValue]-50.0f;
        [@"나" drawInRect:CGRectMake(x, y, 100.0f, 20.0f) withAttributes:att_title];
        for(int i=1; i<[pos_array3 count]; i++)
        {
            x = [[[pos_array3 objectAtIndex:i] objectAtIndex:0] floatValue];
            y = [[[pos_array3 objectAtIndex:i] objectAtIndex:1] floatValue];
            [[linkNames_array2 objectAtIndex:i-1] drawInRect:CGRectMake(x-50.0f, y+35.0f, 100.0f, 20.0f) withAttributes:att_title];
        }
        //(5)result image update
        for(int i=0; i<[ids_array count]; i++)
        {
            NSString *str_id = [ids_array objectAtIndex:i];
            if([imagePool objectForKey:str_id])
            {
                //position
                x = [[[pos_array3 objectAtIndex:i] objectAtIndex:0] floatValue];
                y = [[[pos_array3 objectAtIndex:i] objectAtIndex:1] floatValue];
                //erase
                [[UIColor whiteColor] setFill];
                path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x-30.0f, y-30.0f, 60.0f, 60.0f)];
                [path fill];
                //image
                UIImage *img2 = [self circularScaleAndCropImage:[imagePool objectForKey:str_id] frame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
                [img2 drawInRect:CGRectMake(x-30.0f, y-30.0f, 60.0f, 60.0f)];
                //circle
                [[UIColor colorWithRed:254.0f/255.0f green:218.0f/255.0f blue:12.0f/255.0f alpha:1.0f] setStroke];
                path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x-30.0f, y-30.0f, 60.0f, 60.0f)];
                [path setLineWidth:2.0f];
                [path stroke];
            }
        }
        [resultImg_array2 addObject:UIGraphicsGetImageFromCurrentImageContext()];
        UIGraphicsEndImageContext();
    }
    int imgCnt = 0;
    for(UIImage *img in resultImg_array2)
    {
        [resultImg_array replaceObjectAtIndex:imgCnt withObject:img];
        imgCnt++;
    }
    //[imagePool removeAllObjects];
    //imagePool = nil;
    resultImg = [resultImg_array lastObject];
    [indicator stopAnimating];
    imageView_visual2 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width_half*2.0f, height_half*2.0f)];
    [scrollView_visual2 addSubview:imageView_visual2];
    [scrollView_visual2 setContentSize:imageView_visual2.frame.size];
    //이미지 크기에 따라 줌 배율 변경
    float ratio = self.view.frame.size.width / imageView_visual2.frame.size.width;
    if(ratio<0.2f) ratio = 0.2f;
    else if(ratio>1.5f) ratio = 1.5f;
    [scrollView_visual2 setZoomScale:ratio];
    [imageView_visual2 performSelectorOnMainThread:@selector(setImage:) withObject:resultImg waitUntilDone:YES];
    //stepper
    stepper = [[UIStepper alloc] init];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:stepper];
    [stepper setMaximumValue:[resultImg_array count]-1];
    [stepper setValue:[resultImg_array count]-1];
    [stepper addTarget:self action:@selector(stepperPressed:) forControlEvents:UIControlEventValueChanged];
}









//Kakao
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
            if(image)
            {
                [imagePool setObject:image forKey:my_id];
            }
            else
            {
                image = [UIImage imageNamed:@"empty2"];
                [imagePool setObject:image forKey:my_id];
            }
        }
        else return;
    }
    else return;
    //result image update
    UIBezierPath *path;
    NSMutableArray *resultImg_array2 = [NSMutableArray arrayWithCapacity:[resultImg_array count]];
    float x = [[[pos_array3 objectAtIndex:0] objectAtIndex:0] floatValue];
    float y = [[[pos_array3 objectAtIndex:0] objectAtIndex:1] floatValue];
    for(int i=0; i<[resultImg_array count]; i++)
    {
        UIImage *resultImg2 = [resultImg_array objectAtIndex:i];
        float width = resultImg2.size.width;
        float height = resultImg2.size.height;
        if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 2.0f);
        else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 3.0f);
        else UIGraphicsBeginImageContext(CGSizeMake(width, height));
        [resultImg2 drawInRect:CGRectMake(0.0f, 0.0f, width, height)];
        //erase
        [[UIColor whiteColor] setFill];
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x-30.0f, y-30.0f, 60.0f, 60.0f)];
        [path fill];
        //draw
        UIImage *image2 = [self circularScaleAndCropImage:image frame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
        [image2 drawInRect:CGRectMake(x-30.0f, y-30.0f, 60.0f, 60.0f)];
        //circle
        [[UIColor colorWithRed:254.0f/255.0f green:218.0f/255.0f blue:12.0f/255.0f alpha:1.0f] setStroke];
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x-30.0f, y-30.0f, 60.0f, 60.0f)];
        [path setLineWidth:2.0f];
        [path stroke];
        [resultImg_array2 addObject:UIGraphicsGetImageFromCurrentImageContext()];
        UIGraphicsEndImageContext();
    }
    int imgCnt = 0;
    for(UIImage *img in resultImg_array2)
    {
        [resultImg_array replaceObjectAtIndex:imgCnt withObject:img];
        imgCnt++;
    }
    resultImg = [resultImg_array objectAtIndex:stepper.value];
    [imageView_visual2 performSelectorOnMainThread:@selector(setImage:) withObject:resultImg waitUntilDone:YES];
    [indicator stopAnimating];
}





























//Tap Gesture
-(void)tapped:(UITapGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:imageView_visual2];
    float x,y;
    //[1]pos_array1
    if([[pos_array1 objectAtIndex:0] count]>0)
    {
        x = [[[pos_array1 objectAtIndex:0] objectAtIndex:0] floatValue];
        y = [[[pos_array1 objectAtIndex:0] objectAtIndex:1] floatValue];
        if(point.x>x-33.0f && point.x<x+33.0f && point.y>y-33.0f && point.y<y+33.0f)
        {
            if(point.x>prePt.x-33.0f && point.x<prePt.x+33.0f && point.y>prePt.y-33.0f && point.y<prePt.y+33.0f) //만약 이전에 클릭했던 같은 노드이면
            {
                tableView_visual2.hidden = NO;
            }
            else
            {
                //create tableView_visual2
                prePt = CGPointMake(x, y);
                NSMutableArray *ids_array = [NSMutableArray arrayWithCapacity:[[result_nodes1 objectAtIndex:0] count]];
                for(NSString *str in [result_nodes1 objectAtIndex:0])
                {
                    [ids_array addObject:str];
                }
                [tv_ids_array removeAllObjects];
                [tv_relations_array removeAllObjects];
                //[tv_results_array removeAllObjects];
                //[tv_ranks_array removeAllObjects];
                [outer_order_array removeAllObjects];
                [outer_ids_array removeAllObjects];
                int numOfAllOuter = (int)[linkResult_array2 count];
                //outer_order_array = [NSMutableArray arrayWithCapacity:numOfAllOuter];
                //outer_ids_array = [NSMutableArray arrayWithCapacity:numOfAllOuter];
                for(int i=0; i<numOfAllOuter; i++)
                {
                    [outer_order_array addObject:[NSString stringWithFormat:@"%d",i]];
                    [outer_ids_array addObject:[[result_nodes3 objectAtIndex:i+1] anyObject]];
                }
                tv_curI = -1;
                tv_curJ = -1;
                //tv_ids_array = [NSMutableArray arrayWithCapacity:[ids_array count]];
                //tv_relations_array = [NSMutableArray arrayWithCapacity:[ids_array count]];
                //tv_results_array = [NSMutableArray arrayWithCapacity:[ids_array count]];
                //tv_ranks_array = [NSMutableArray arrayWithCapacity:[ids_array count]];
                for(NSString *str_id in ids_array)
                {
                    [tv_ids_array addObject:[NSString stringWithString:str_id]];
                    //배열에서 가장 짧은 str_id 선택
                    int minK = 100;
                    //NSArray *id_array;
                    NSArray *out_array;
                    //NSArray *in_array;
                    for(int i=0; i<[linkResult_array2 count]; i++)
                    {
                        NSArray *array_id = [[linkResult_array2 objectAtIndex:i] objectAtIndex:0];
                        for(int j=0; j<[array_id count]; j++)
                        {
                            NSArray *array1= [array_id objectAtIndex:j];
                            for(int k=0; k<[array1 count]; k++)
                            {
                                if(k<minK && [str_id isEqualToString:[array1 objectAtIndex:k]])
                                {
                                    minK = k;
                                    //id_array = [array1 subarrayWithRange:NSMakeRange(0, k+1)];
                                    out_array = [ [[[linkResult_array2 objectAtIndex:i] objectAtIndex:1] objectAtIndex:j] subarrayWithRange:NSMakeRange(0, k+1) ];
                                    //in_array = [ [[[linkResult_array2 objectAtIndex:i] objectAtIndex:2] objectAtIndex:j] subarrayWithRange:NSMakeRange(0, k+1) ];
                                }
                            }
                        }
                    }
                    //[tv_results_array addObject:[NSArray arrayWithObjects:id_array, out_array, in_array, nil]];
                    NSMutableString *str = [NSMutableString string];
                    [str appendString:@"나의 "];
                    for(int i=0; i<[out_array count]; i++)
                    {
                        NSString *name = [out_array objectAtIndex:i];
                        if([name isEqualToString:@"null"]) [str appendString:@"'..'"];
                        else [str appendString:[NSString stringWithFormat:@"'%@'",name]];
                        if(i==[out_array count]-1)
                        {
                            break;
                        }
                        else [str appendString:@"의 "];
                    }
                    [tv_relations_array addObject:[NSString stringWithString:str]];
                    /*
                    //rank
                    if([rankPool objectForKey:str_id])
                    {
                        [tv_ranks_array addObject:[rankPool objectForKey:str_id]];
                    }
                    else
                    {
                        [tv_ranks_array addObject:@"-1"];
                    }
                    */
                }
                //draw resultImg2
                int sortNum = (int)[linkResult_array2 count]; //nC1 노드 개수:sortNum+1
                [targetNum_array removeAllObjects];
                for(int i=0; i<sortNum; i++)
                {
                    [targetNum_array addObject:[NSString stringWithFormat:@"%d", i+2]];
                }
                float width_half, height_half;
                width_half = height_half = 30.0f+(80.0f+60.0f)*sortNum+50.0f;
                UIBezierPath *path;
                if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width_half*2.0f,height_half*2.0f), NO, 2.0f);
                else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width_half*2.0f,height_half*2.0f), NO, 3.0f);
                else UIGraphicsBeginImageContext(CGSizeMake(width_half*2.0f, height_half*2.0f));
                [resultImg drawInRect:CGRectMake(0.0f, 0.0f, width_half*2.0f, height_half*2.0f)];
                //(1)lines
                path = [UIBezierPath bezierPath];
                [[UIColor redColor] setStroke];
                [path setLineWidth:4.0f];
                for(NSArray *array in pos_array3)
                {
                    float x2 = [[array objectAtIndex:0] floatValue];
                    float y2 = [[array objectAtIndex:1] floatValue];
                    [path moveToPoint:CGPointMake(x, y)];
                    [path addLineToPoint:CGPointMake(x2, y2)];
                    [path stroke];
                }
                //(2)nodes
                [[UIColor redColor] setStroke];
                [[UIColor blueColor] setFill];
                for(NSArray *array in pos_array3)
                {
                    path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake([[array objectAtIndex:0] floatValue]-30.0f, [[array objectAtIndex:1] floatValue]-30.0f, 60.0f, 60.0f)];
                    [path fill];
                    [path setLineWidth:3.0f];
                    [path stroke];
                }
                [[UIColor colorWithWhite:0.3f alpha:1.0f] setFill];
                int number = (int)[[result_nodes1 objectAtIndex:0] count];
                int node_radius = 30.0f+(number-1)*2.0f;
                if(node_radius>50.0f) node_radius = 50.0f;
                path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x-node_radius, y-node_radius, node_radius*2.0f, node_radius*2.0f)];
                [path fill];
                [path setLineWidth:3.0f];
                [path stroke];
                //(3)number
                UIFont *font = [UIFont systemFontOfSize:30.0f];
                NSMutableParagraphStyle *style_num = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                style_num.alignment = NSTextAlignmentCenter;
                NSDictionary *att_num = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style_num, NSForegroundColorAttributeName:[UIColor orangeColor]};
                if([[result_nodes1 objectAtIndex:0] count]>0)
                {
                    [[NSString stringWithFormat:@"%d",(int)[[result_nodes1 objectAtIndex:0] count]] drawInRect:CGRectMake(x-30.0f, y-18.0f, 60.0f, 30.0f) withAttributes:att_num];
                }
                //(4)kakao image update
                NSMutableArray *ids_array2 = [NSMutableArray arrayWithCapacity:[pos_array3 count]];
                [ids_array2 addObject:[NSString stringWithFormat:@"%ld",first.myid]];
                for(NSArray *array in linkResult_array2)
                {
                    [ids_array2 addObject:[[[array objectAtIndex:0] objectAtIndex:0] lastObject]];
                }
                for(int i=0; i<[ids_array2 count]; i++)
                {
                    NSString *str_id = [ids_array2 objectAtIndex:i];
                    if([imagePool objectForKey:str_id])
                    {
                        //position
                        float x2 = [[[pos_array3 objectAtIndex:i] objectAtIndex:0] floatValue];
                        float y2 = [[[pos_array3 objectAtIndex:i] objectAtIndex:1] floatValue];
                        //erase
                        [[UIColor whiteColor] setFill];
                        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x2-30.0f, y2-30.0f, 60.0f, 60.0f)];
                        [path fill];
                        //image
                        UIImage *img2 = [self circularScaleAndCropImage:[imagePool objectForKey:str_id] frame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
                        [img2 drawInRect:CGRectMake(x2-30.0f, y2-30.0f, 60.0f, 60.0f)];
                        //circle
                        [[UIColor redColor] setStroke];
                        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x2-30.0f, y2-30.0f, 60.0f, 60.0f)];
                        [path setLineWidth:3.0f];
                        [path stroke];
                    }
                }
                UIImage *resultImg2 = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                [imageView_visual2 setImage:resultImg2];
                //tableView_visual2
                float table_height = (44.0f*(float)[ids_array count]) > 150.0f ? 150.0f : (44.0f*(float)[ids_array count]);
                if(tableView_visual2) //기존의 tableView_visual2가 있으면 초기화
                {
                    [tableView_visual2 removeFromSuperview];
                    tableView_visual2 = nil;
                }
                tableView_visual2 = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height-table_height, self.view.frame.size.width, table_height) style:UITableViewStylePlain];
                tableView_visual2.dataSource = self;
                tableView_visual2.delegate = self;
                [self.view addSubview:tableView_visual2];
                tableView_visual2.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.3f];
                tableView_visual2.hidden = NO;
                [tableView_visual2 setContentOffset:CGPointZero animated:YES];
                [tableView_visual2 reloadData];
                if(btn_del)
                {
                    [btn_del removeFromSuperview];
                    btn_del = nil;
                }
                btn_del = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-33.0f, self.view.frame.size.height-table_height-33.0f, 30.0f, 30.0f)];
                [btn_del setImage:img_del forState:UIControlStateNormal];
                [btn_del addTarget:self action:@selector(btnDelClicked:) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:btn_del];
            }
            return;
        }
    }
    //[2]pos_array3
    for(int i=0; i<[pos_array3 count]; i++)
    {
        NSArray *array = [pos_array3 objectAtIndex:i];
        x = [[array objectAtIndex:0] floatValue];
        y = [[array objectAtIndex:1] floatValue];
        if(point.x>x-33.0f && point.x<x+33.0f && point.y>y-33.0f && point.y<y+33.0f)
        {
            if(0==i) //만약 내 자신이면 => 변화 없음
            {
                //draw
                UIImage *curImg = imageView_visual2.image;
                float width = curImg.size.width;
                float height = curImg.size.height;
                if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 2.0f);
                else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 3.0f);
                else UIGraphicsBeginImageContext(CGSizeMake(width, height));
                [curImg drawInRect:CGRectMake(0.0f, 0.0f, width, height)];
                [img_not drawInRect:CGRectMake(x-30.0f, y-30.0f, 60.0f, 60.0f)];
                UIImage *curImg2 = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                //animation
                CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
                crossFade.duration = 1.0f;
                crossFade.fromValue = (id)curImg2.CGImage;
                crossFade.toValue = (id)(curImg.CGImage);
                [imageView_visual2.layer addAnimation:crossFade forKey:@"animateContents"];
                imageView_visual2.image = curImg;
            }
            else //만약 내 자신이 아니면
            {
                NSString *str_index = [NSString stringWithFormat:@"%d", i+1];
                if([targetNum_array containsObject:str_index])
                {
                    [targetNum_array removeObject:str_index];
                }
                else
                {
                    [targetNum_array addObject:[NSString stringWithString:str_index]];
                }
                //draw
                if([targetNum_array count]>0) //targetNum_array가 존재할 경우에 draw
                {
                    int sortNum = (int)[linkResult_array2 count]; //nC1 노드 개수:sortNum+1
                    if(sortNum==[targetNum_array count]) //center
                    {
                        if([[pos_array1 objectAtIndex:0] count]>0)
                        {
                            //x,y 좌표를 새로고침
                            x = [[[pos_array1 objectAtIndex:0] objectAtIndex:0] floatValue];
                            y = [[[pos_array1 objectAtIndex:0] objectAtIndex:1] floatValue];
                            prePt = CGPointMake(x, y);
                            //create tableView_visual2
                            NSMutableArray *ids_array = [NSMutableArray arrayWithCapacity:[[result_nodes1 objectAtIndex:0] count]];
                            for(NSString *str in [result_nodes1 objectAtIndex:0])
                            {
                                [ids_array addObject:str];
                            }
                            [tv_ids_array removeAllObjects];
                            [tv_relations_array removeAllObjects];
                            //[tv_results_array removeAllObjects];
                            //[tv_ranks_array removeAllObjects];
                            [outer_order_array removeAllObjects];
                            [outer_ids_array removeAllObjects];
                            int numOfAllOuter = (int)[linkResult_array2 count];
                            //outer_order_array = [NSMutableArray arrayWithCapacity:numOfAllOuter];
                            //outer_ids_array = [NSMutableArray arrayWithCapacity:numOfAllOuter];
                            for(int i=0; i<numOfAllOuter; i++)
                            {
                                [outer_order_array addObject:[NSString stringWithFormat:@"%d",i]];
                                [outer_ids_array addObject:[[result_nodes3 objectAtIndex:i+1] anyObject]];
                            }
                            tv_curI = -1;
                            tv_curJ = -1;
                            //tv_ids_array = [NSMutableArray arrayWithCapacity:[ids_array count]];
                            //tv_relations_array = [NSMutableArray arrayWithCapacity:[ids_array count]];
                            //tv_results_array = [NSMutableArray arrayWithCapacity:[ids_array count]];
                            //tv_ranks_array = [NSMutableArray arrayWithCapacity:[ids_array count]];
                            for(NSString *str_id in ids_array)
                            {
                                [tv_ids_array addObject:[NSString stringWithString:str_id]];
                                //배열에서 가장 짧은 str_id 선택
                                int minK = 100;
                                //NSArray *id_array;
                                NSArray *out_array;
                                //NSArray *in_array;
                                for(int i=0; i<[linkResult_array2 count]; i++)
                                {
                                    NSArray *array_id = [[linkResult_array2 objectAtIndex:i] objectAtIndex:0];
                                    for(int j=0; j<[array_id count]; j++)
                                    {
                                        NSArray *array1= [array_id objectAtIndex:j];
                                        for(int k=0; k<[array1 count]; k++)
                                        {
                                            if(k<minK && [str_id isEqualToString:[array1 objectAtIndex:k]])
                                            {
                                                minK = k;
                                                //id_array = [array1 subarrayWithRange:NSMakeRange(0, k+1)];
                                                out_array = [ [[[linkResult_array2 objectAtIndex:i] objectAtIndex:1] objectAtIndex:j] subarrayWithRange:NSMakeRange(0, k+1) ];
                                                //in_array = [ [[[linkResult_array2 objectAtIndex:i] objectAtIndex:2] objectAtIndex:j] subarrayWithRange:NSMakeRange(0, k+1) ];
                                            }
                                        }
                                    }
                                }
                                //[tv_results_array addObject:[NSArray arrayWithObjects:id_array, out_array, in_array, nil]];
                                NSMutableString *str = [NSMutableString string];
                                [str appendString:@"나의 "];
                                for(int i=0; i<[out_array count]; i++)
                                {
                                    NSString *name = [out_array objectAtIndex:i];
                                    if([name isEqualToString:@"null"]) [str appendString:@"'..'"];
                                    else [str appendString:[NSString stringWithFormat:@"'%@'",name]];
                                    if(i==[out_array count]-1)
                                    {
                                        break;
                                    }
                                    else [str appendString:@"의 "];
                                }
                                [tv_relations_array addObject:[NSString stringWithString:str]];
                                /*
                                //rank
                                if([rankPool objectForKey:str_id])
                                {
                                    [tv_ranks_array addObject:[rankPool objectForKey:str_id]];
                                }
                                else
                                {
                                    [tv_ranks_array addObject:@"-1"];
                                }
                                */
                            }
                            //draw resultImg2
                            float width_half, height_half;
                            width_half = height_half = 30.0f+(80.0f+60.0f)*sortNum+50.0f;
                            UIBezierPath *path;
                            if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width_half*2.0f,height_half*2.0f), NO, 2.0f);
                            else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width_half*2.0f,height_half*2.0f), NO, 3.0f);
                            else UIGraphicsBeginImageContext(CGSizeMake(width_half*2.0f, height_half*2.0f));
                            [resultImg drawInRect:CGRectMake(0.0f, 0.0f, width_half*2.0f, height_half*2.0f)];
                            //(1)lines
                            path = [UIBezierPath bezierPath];
                            [[UIColor redColor] setStroke];
                            [path setLineWidth:4.0f];
                            for(NSArray *array in pos_array3)
                            {
                                float x2 = [[array objectAtIndex:0] floatValue];
                                float y2 = [[array objectAtIndex:1] floatValue];
                                [path moveToPoint:CGPointMake(x, y)];
                                [path addLineToPoint:CGPointMake(x2, y2)];
                                [path stroke];
                            }
                            //(2)nodes
                            [[UIColor redColor] setStroke];
                            [[UIColor blueColor] setFill];
                            for(NSArray *array in pos_array3)
                            {
                                path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake([[array objectAtIndex:0] floatValue]-30.0f, [[array objectAtIndex:1] floatValue]-30.0f, 60.0f, 60.0f)];
                                [path fill];
                                [path setLineWidth:3.0f];
                                [path stroke];
                            }
                            [[UIColor colorWithWhite:0.3f alpha:1.0f] setFill];
                            int number = (int)[[result_nodes1 objectAtIndex:0] count];
                            int node_radius = 30.0f+(number-1)*2.0f;
                            if(node_radius>50.0f) node_radius = 50.0f;
                            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x-node_radius, y-node_radius, node_radius*2.0f, node_radius*2.0f)];
                            [path fill];
                            [path setLineWidth:3.0f];
                            [path stroke];
                            //(3)number
                            UIFont *font = [UIFont systemFontOfSize:30.0f];
                            NSMutableParagraphStyle *style_num = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                            style_num.alignment = NSTextAlignmentCenter;
                            NSDictionary *att_num = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style_num, NSForegroundColorAttributeName:[UIColor orangeColor]};
                            if([[result_nodes1 objectAtIndex:0] count]>0)
                            {
                                [[NSString stringWithFormat:@"%d",(int)[[result_nodes1 objectAtIndex:0] count]] drawInRect:CGRectMake(x-30.0f, y-18.0f, 60.0f, 30.0f) withAttributes:att_num];
                            }
                            //(4)kakao image update
                            NSMutableArray *ids_array2 = [NSMutableArray arrayWithCapacity:[pos_array3 count]];
                            [ids_array2 addObject:[NSString stringWithFormat:@"%ld",first.myid]];
                            for(NSArray *array in linkResult_array2)
                            {
                                [ids_array2 addObject:[[[array objectAtIndex:0] objectAtIndex:0] lastObject]];
                            }
                            for(int i=0; i<[ids_array2 count]; i++)
                            {
                                NSString *str_id = [ids_array2 objectAtIndex:i];
                                if([imagePool objectForKey:str_id])
                                {
                                    //position
                                    float x2 = [[[pos_array3 objectAtIndex:i] objectAtIndex:0] floatValue];
                                    float y2 = [[[pos_array3 objectAtIndex:i] objectAtIndex:1] floatValue];
                                    //erase
                                    [[UIColor whiteColor] setFill];
                                    path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x2-30.0f, y2-30.0f, 60.0f, 60.0f)];
                                    [path fill];
                                    //image
                                    UIImage *img2 = [self circularScaleAndCropImage:[imagePool objectForKey:str_id] frame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
                                    [img2 drawInRect:CGRectMake(x2-30.0f, y2-30.0f, 60.0f, 60.0f)];
                                    //circle
                                    [[UIColor redColor] setStroke];
                                    path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x2-30.0f, y2-30.0f, 60.0f, 60.0f)];
                                    [path setLineWidth:3.0f];
                                    [path stroke];
                                }
                            }
                            UIImage *resultImg2 = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            [imageView_visual2 setImage:resultImg2];
                            //tableView_visual2
                            float table_height = (44.0f*(float)[ids_array count]) > 150.0f ? 150.0f : (44.0f*(float)[ids_array count]);
                            if(tableView_visual2) //기존의 tableView_visual2가 있으면 초기화
                            {
                                [tableView_visual2 removeFromSuperview];
                                tableView_visual2 = nil;
                            }
                            tableView_visual2 = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height-table_height, self.view.frame.size.width, table_height) style:UITableViewStylePlain];
                            tableView_visual2.dataSource = self;
                            tableView_visual2.delegate = self;
                            [self.view addSubview:tableView_visual2];
                            tableView_visual2.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.3f];
                            tableView_visual2.hidden = NO;
                            [tableView_visual2 setContentOffset:CGPointZero animated:YES];
                            [tableView_visual2 reloadData];
                            if(btn_del)
                            {
                                [btn_del removeFromSuperview];
                                btn_del = nil;
                            }
                            btn_del = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-33.0f, self.view.frame.size.height-table_height-33.0f, 30.0f, 30.0f)];
                            [btn_del setImage:img_del forState:UIControlStateNormal];
                            [btn_del addTarget:self action:@selector(btnDelClicked:) forControlEvents:UIControlEventTouchUpInside];
                            [self.view addSubview:btn_del];
                        }
                        else
                        {
                            [targetNum_array removeObject:str_index];
                            //draw
                            UIImage *curImg = imageView_visual2.image;
                            float width = curImg.size.width;
                            float height = curImg.size.height;
                            if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 2.0f);
                            else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 3.0f);
                            else UIGraphicsBeginImageContext(CGSizeMake(width, height));
                            [curImg drawInRect:CGRectMake(0.0f, 0.0f, width, height)];
                            [img_not drawInRect:CGRectMake(x-30.0f, y-30.0f, 60.0f, 60.0f)];
                            UIImage *curImg2 = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            //animation
                            CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
                            crossFade.duration = 1.0f;
                            crossFade.fromValue = (id)curImg2.CGImage;
                            crossFade.toValue = (id)(curImg.CGImage);
                            [imageView_visual2.layer addAnimation:crossFade forKey:@"animateContents"];
                            imageView_visual2.image = curImg;
                        }
                    }//if center node
                    else
                    {
                        int index_j = -1;
                        int index_k = -1;
                        NSSet *set_target = [NSSet setWithArray:targetNum_array];
                        for(int j=0; j<[result_order count]; j++)
                        {
                            NSArray *array = [result_order objectAtIndex:j];
                            if([[array objectAtIndex:0] count] == [targetNum_array count])
                            {
                                index_j = j;
                                for(int k=0; k<[array count]; k++)
                                {
                                    NSSet *set = [NSSet setWithArray:[array objectAtIndex:k]];
                                    if([set isEqualToSet:set_target])
                                    {
                                        index_k = k;
                                        break;
                                    }
                                    
                                }
                                if(index_k>-1) break;
                            }
                        }
                        if(0==[[[pos_array2 objectAtIndex:index_j] objectAtIndex:index_k] count])  //만약 존재하지 않는 경우
                        {
                            if([targetNum_array containsObject:str_index])
                            {
                                [targetNum_array removeObject:str_index];
                            }
                            else
                            {
                                [targetNum_array addObject:[NSString stringWithString:str_index]];
                            }
                            //draw
                            UIImage *curImg = imageView_visual2.image;
                            float width = curImg.size.width;
                            float height = curImg.size.height;
                            if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 2.0f);
                            else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 3.0f);
                            else UIGraphicsBeginImageContext(CGSizeMake(width, height));
                            [curImg drawInRect:CGRectMake(0.0f, 0.0f, width, height)];
                            [img_not drawInRect:CGRectMake(x-30.0f, y-30.0f, 60.0f, 60.0f)];
                            UIImage *curImg2 = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            //animation
                            CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
                            crossFade.duration = 1.0f;
                            crossFade.fromValue = (id)curImg2.CGImage;
                            crossFade.toValue = (id)(curImg.CGImage);
                            [imageView_visual2.layer addAnimation:crossFade forKey:@"animateContents"];
                            imageView_visual2.image = curImg;
                        }
                        else
                        {
                            //x,y 좌표를 새로고침
                            x = [[[[pos_array2 objectAtIndex:index_j] objectAtIndex:index_k] objectAtIndex:0] floatValue];
                            y = [[[[pos_array2 objectAtIndex:index_j] objectAtIndex:index_k] objectAtIndex:1] floatValue];
                            prePt = CGPointMake(x, y);
                            //create tableView_visual2
                            NSMutableArray *ids_array = [NSMutableArray arrayWithCapacity:[[[result_nodes2 objectAtIndex:index_j] objectAtIndex:index_k] count]];
                            for(NSString *str in [[result_nodes2 objectAtIndex:index_j] objectAtIndex:index_k])
                            {
                                [ids_array addObject:str];
                            }
                            [tv_ids_array removeAllObjects];
                            [tv_relations_array removeAllObjects];
                            //[tv_results_array removeAllObjects];
                            //[tv_ranks_array removeAllObjects];
                            [outer_order_array removeAllObjects];
                            [outer_ids_array removeAllObjects];
                            tv_curI = index_j;
                            tv_curJ = index_k;
                            //tv_ids_array = [NSMutableArray arrayWithCapacity:[ids_array count]];
                            //tv_relations_array = [NSMutableArray arrayWithCapacity:[ids_array count]];
                            //tv_results_array = [NSMutableArray arrayWithCapacity:[ids_array count]];
                            //tv_ranks_array = [NSMutableArray arrayWithCapacity:[ids_array count]];
                            NSArray *order_array = [[result_order objectAtIndex:index_j] objectAtIndex:index_k];
                            //outer_ids_array = [NSMutableArray arrayWithCapacity:[order_array count]];
                            //outer_order_array = [NSMutableArray arrayWithCapacity:[order_array count]];
                            for(NSString *str_order in order_array)
                            {
                                int index = [str_order intValue] - 2;
                                [outer_order_array addObject:[NSString stringWithFormat:@"%d", index]];
                                [outer_ids_array addObject:[[result_nodes3 objectAtIndex:index+1] anyObject]];
                            }
                            for(NSString *str_id in ids_array)
                            {
                                [tv_ids_array addObject:[NSString stringWithString:str_id]];
                                //배열에서 가장 짧은 str_id 선택
                                int minK = 100;
                                //NSArray *id_array;
                                NSArray *out_array;
                                //NSArray *in_array;
                                for(NSString *str_order in order_array)
                                {
                                    int index = [str_order intValue] - 2;
                                    NSArray *array_id = [[linkResult_array2 objectAtIndex:index] objectAtIndex:0];
                                    for(int i2=0; i2<[array_id count]; i2++)
                                    {
                                        NSArray *array1= [array_id objectAtIndex:i2];
                                        for(int j2=0; j2<[array1 count]; j2++)
                                        {
                                            if(j2<minK && [str_id isEqualToString:[array1 objectAtIndex:j2]])
                                            {
                                                minK = j2;
                                                //id_array = [array1 subarrayWithRange:NSMakeRange(0, j2+1)];
                                                out_array = [ [[[linkResult_array2 objectAtIndex:index] objectAtIndex:1] objectAtIndex:i2] subarrayWithRange:NSMakeRange(0, j2+1) ];
                                                //in_array = [ [[[linkResult_array2 objectAtIndex:index] objectAtIndex:2] objectAtIndex:i2] subarrayWithRange:NSMakeRange(0, j2+1) ];
                                            }
                                        }
                                    }
                                }
                                //[tv_results_array addObject:[NSArray arrayWithObjects:id_array, out_array, in_array, nil]];
                                NSMutableString *str = [NSMutableString string];
                                [str appendString:@"나의 "];
                                for(int i2=0; i2<[out_array count]; i2++)
                                {
                                    NSString *name = [out_array objectAtIndex:i2];
                                    if([name isEqualToString:@"null"]) [str appendString:@"'..'"];
                                    else [str appendString:[NSString stringWithFormat:@"'%@'",name]];
                                    if(i2==[out_array count]-1)
                                    {
                                        break;
                                    }
                                    else [str appendString:@"의 "];
                                }
                                [tv_relations_array addObject:[NSString stringWithString:str]];
                                /*
                                //rank
                                if([rankPool objectForKey:str_id])
                                {
                                    [tv_ranks_array addObject:[rankPool objectForKey:str_id]];
                                }
                                else
                                {
                                    [tv_ranks_array addObject:@"-1"];
                                }
                                */
                            }
                            //draw resultImg2
                            float width_half, height_half;
                            width_half = height_half = 30.0f+(80.0f+60.0f)*sortNum+50.0f;
                            UIBezierPath *path;
                            if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width_half*2.0f,height_half*2.0f), NO, 2.0f);
                            else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width_half*2.0f,height_half*2.0f), NO, 3.0f);
                            else UIGraphicsBeginImageContext(CGSizeMake(width_half*2.0f, height_half*2.0f));
                            [resultImg drawInRect:CGRectMake(0.0f, 0.0f, width_half*2.0f, height_half*2.0f)];
                            NSArray *array_order = [[result_order objectAtIndex:index_j] objectAtIndex:index_k];
                            //(1)lines
                            path = [UIBezierPath bezierPath];
                            [[UIColor redColor] setStroke];
                            [path setLineWidth:4.0f];
                            float x2 = [[[pos_array3 objectAtIndex:0] objectAtIndex:0] floatValue];
                            float y2 = [[[pos_array3 objectAtIndex:0] objectAtIndex:1] floatValue];
                            [path moveToPoint:CGPointMake(x, y)];
                            [path addLineToPoint:CGPointMake(x2, y2)];
                            [path stroke];
                            //[targetNum_array removeAllObjects];
                            for(NSString *str in array_order)
                            {
                                //[targetNum_array addObject:[NSString stringWithString:str]];
                                int num = [str intValue]-1;
                                x2 = [[[pos_array3 objectAtIndex:num] objectAtIndex:0] floatValue];
                                y2 = [[[pos_array3 objectAtIndex:num] objectAtIndex:1] floatValue];
                                [path moveToPoint:CGPointMake(x, y)];
                                [path addLineToPoint:CGPointMake(x2, y2)];
                                [path stroke];
                            }
                            //(2)nodes
                            [[UIColor redColor] setStroke];
                            [[UIColor colorWithWhite:0.3f+0.15f*(float)(index_j+1) alpha:1.0f] setFill];
                            int number = (int)[[[result_nodes2 objectAtIndex:index_j] objectAtIndex:index_k] count];
                            int node_radius = 30.0f+(number-1)*2.0f;
                            if(node_radius>50.0f) node_radius = 50.0f;
                            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x-node_radius, y-node_radius, node_radius*2.0f, node_radius*2.0f)];
                            [path fill];
                            [path setLineWidth:3.0f];
                            [path stroke];
                            [[UIColor blueColor] setFill];
                            x2 = [[[pos_array3 objectAtIndex:0] objectAtIndex:0] floatValue];
                            y2 = [[[pos_array3 objectAtIndex:0] objectAtIndex:1] floatValue];
                            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x2-30.0f, y2-30.0f, 60.0f, 60.0f)];
                            [path fill];
                            [path setLineWidth:3.0f];
                            [path stroke];
                            for(NSString *str in array_order)
                            {
                                int num = [str intValue]-1;
                                x2 = [[[pos_array3 objectAtIndex:num] objectAtIndex:0] floatValue];
                                y2 = [[[pos_array3 objectAtIndex:num] objectAtIndex:1] floatValue];
                                path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x2-30.0f, y2-30.0f, 60.0f, 60.0f)];
                                [path fill];
                                [path setLineWidth:3.0f];
                                [path stroke];
                            }
                            //(3)number
                            UIFont *font = [UIFont systemFontOfSize:30.0f];
                            NSMutableParagraphStyle *style_num = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                            style_num.alignment = NSTextAlignmentCenter;
                            NSDictionary *att_num = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style_num, NSForegroundColorAttributeName:[UIColor orangeColor]};
                            if([[[result_nodes2 objectAtIndex:index_j] objectAtIndex:index_k] count]>0)
                            {
                                [[NSString stringWithFormat:@"%d",(int)[[[result_nodes2 objectAtIndex:index_j] objectAtIndex:index_k] count]] drawInRect:CGRectMake(x-30.0f, y-18.0f, 60.0f, 30.0f) withAttributes:att_num];
                            }
                            //(4)kakao image update
                            NSMutableArray *ids_array2 = [NSMutableArray arrayWithCapacity:[pos_array3 count]];
                            [ids_array2 addObject:[NSString stringWithFormat:@"%ld",first.myid]];
                            for(NSArray *array in linkResult_array2)
                            {
                                [ids_array2 addObject:[[[array objectAtIndex:0] objectAtIndex:0] lastObject]];
                            }
                            NSString *str_id = [ids_array2 objectAtIndex:0];
                            if([imagePool objectForKey:str_id])
                            {
                                //position
                                x2 = [[[pos_array3 objectAtIndex:0] objectAtIndex:0] floatValue];
                                y2 = [[[pos_array3 objectAtIndex:0] objectAtIndex:1] floatValue];
                                //erase
                                [[UIColor whiteColor] setFill];
                                path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x2-30.0f, y2-30.0f, 60.0f, 60.0f)];
                                [path fill];
                                //image
                                UIImage *img2 = [self circularScaleAndCropImage:[imagePool objectForKey:str_id] frame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
                                [img2 drawInRect:CGRectMake(x2-30.0f, y2-30.0f, 60.0f, 60.0f)];
                                //circle
                                [[UIColor redColor] setStroke];
                                path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x2-30.0f, y2-30.0f, 60.0f, 60.0f)];
                                [path setLineWidth:3.0f];
                                [path stroke];
                            }
                            for(NSString *str in array_order)
                            {
                                int num = [str intValue]-1;
                                NSString *str_id = [ids_array2 objectAtIndex:num];
                                if([imagePool objectForKey:str_id])
                                {
                                    //position
                                    x2 = [[[pos_array3 objectAtIndex:num] objectAtIndex:0] floatValue];
                                    y2 = [[[pos_array3 objectAtIndex:num] objectAtIndex:1] floatValue];
                                    //erase
                                    [[UIColor whiteColor] setFill];
                                    path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x2-30.0f, y2-30.0f, 60.0f, 60.0f)];
                                    [path fill];
                                    //image
                                    UIImage *img2 = [self circularScaleAndCropImage:[imagePool objectForKey:str_id] frame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
                                    [img2 drawInRect:CGRectMake(x2-30.0f, y2-30.0f, 60.0f, 60.0f)];
                                    //circle
                                    [[UIColor redColor] setStroke];
                                    path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x2-30.0f, y2-30.0f, 60.0f, 60.0f)];
                                    [path setLineWidth:3.0f];
                                    [path stroke];
                                }
                            }
                            UIImage *resultImg2 = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            [imageView_visual2 setImage:resultImg2];
                            //tableView_visual2
                            float table_height = (44.0f*(float)[ids_array count]) > 150.0f ? 150.0f : (44.0f*(float)[ids_array count]);
                            if(tableView_visual2) //기존의 tableView_visual2가 있으면 초기화
                            {
                                [tableView_visual2 removeFromSuperview];
                                tableView_visual2 = nil;
                            }
                            tableView_visual2 = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height-table_height, self.view.frame.size.width, table_height) style:UITableViewStylePlain];
                            tableView_visual2.dataSource = self;
                            tableView_visual2.delegate = self;
                            [self.view addSubview:tableView_visual2];
                            tableView_visual2.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.3f];
                            tableView_visual2.hidden = NO;
                            [tableView_visual2 setContentOffset:CGPointZero animated:YES];
                            [tableView_visual2 reloadData];
                            if(btn_del)
                            {
                                [btn_del removeFromSuperview];
                                btn_del = nil;
                            }
                            btn_del = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-33.0f, self.view.frame.size.height-table_height-33.0f, 30.0f, 30.0f)];
                            [btn_del setImage:img_del forState:UIControlStateNormal];
                            [btn_del addTarget:self action:@selector(btnDelClicked:) forControlEvents:UIControlEventTouchUpInside];
                            [self.view addSubview:btn_del];
                        }
                    }
                }
                else
                {
                    [imageView_visual2 setImage:resultImg];
                    prePt = CGPointMake(-1.0f, -1.0f);
                    [targetNum_array removeAllObjects];
                    tableView_visual2.hidden = YES;
                    if(btn_del) btn_del.hidden = YES;
                    tv_curI = -2;
                    tv_curJ = -2;
                }
            }//if(i>0)
            return;
        }
    }
    //[3]pos_array2
    for(int i=0; i<[pos_array2 count]; i++)
    {
        NSArray *array1 = [pos_array2 objectAtIndex:i];
        for(int j=0; j<[array1 count]; j++)
        {
            NSArray *array2 = [array1 objectAtIndex:j];
            if(0==[array2 count]) continue;
            x = [[array2 objectAtIndex:0] floatValue];
            y = [[array2 objectAtIndex:1] floatValue];
            if(point.x>x-33.0f && point.x<x+33.0f && point.y>y-33.0f && point.y<y+33.0f)
            {
                if(point.x>prePt.x-33.0f && point.x<prePt.x+33.0f && point.y>prePt.y-33.0f && point.y<prePt.y+33.0f) //만약 이전에 클릭했던 같은 노드이면
                {
                    tableView_visual2.hidden = NO;
                    btn_del.hidden = NO;
                }
                else
                {
                    //create tableView_visual2
                    prePt = CGPointMake(x, y);
                    NSMutableArray *ids_array = [NSMutableArray arrayWithCapacity:[[[result_nodes2 objectAtIndex:i] objectAtIndex:j] count]];
                    for(NSString *str in [[result_nodes2 objectAtIndex:i] objectAtIndex:j])
                    {
                        [ids_array addObject:str];
                    }
                    [tv_ids_array removeAllObjects];
                    [tv_relations_array removeAllObjects];
                    //[tv_results_array removeAllObjects];
                    //[tv_ranks_array removeAllObjects];
                    [outer_order_array removeAllObjects];
                    [outer_ids_array removeAllObjects];
                    tv_curI = i;
                    tv_curJ = j;
                    //tv_ids_array = [NSMutableArray arrayWithCapacity:[ids_array count]];
                    //tv_relations_array = [NSMutableArray arrayWithCapacity:[ids_array count]];
                    //tv_results_array = [NSMutableArray arrayWithCapacity:[ids_array count]];
                    //tv_ranks_array = [NSMutableArray arrayWithCapacity:[ids_array count]];
                    NSArray *order_array = [[result_order objectAtIndex:i] objectAtIndex:j];
                    //outer_ids_array = [NSMutableArray arrayWithCapacity:[order_array count]];
                    //outer_order_array = [NSMutableArray arrayWithCapacity:[order_array count]];
                    for(NSString *str_order in order_array)
                    {
                        int index = [str_order intValue] - 2;
                        [outer_order_array addObject:[NSString stringWithFormat:@"%d", index]];
                        [outer_ids_array addObject:[[result_nodes3 objectAtIndex:index+1] anyObject]];
                    }
                    for(NSString *str_id in ids_array)
                    {
                        [tv_ids_array addObject:[NSString stringWithString:str_id]];
                        //배열에서 가장 짧은 str_id 선택
                        int minK = 100;
                        //NSArray *id_array;
                        NSArray *out_array;
                        //NSArray *in_array;
                        for(NSString *str_order in order_array)
                        {
                            int index = [str_order intValue] - 2;
                            NSArray *array_id = [[linkResult_array2 objectAtIndex:index] objectAtIndex:0];
                            for(int i2=0; i2<[array_id count]; i2++)
                            {
                                NSArray *array1= [array_id objectAtIndex:i2];
                                for(int j2=0; j2<[array1 count]; j2++)
                                {
                                    if(j2<minK && [str_id isEqualToString:[array1 objectAtIndex:j2]])
                                    {
                                        minK = j2;
                                        //id_array = [array1 subarrayWithRange:NSMakeRange(0, j2+1)];
                                        out_array = [ [[[linkResult_array2 objectAtIndex:index] objectAtIndex:1] objectAtIndex:i2] subarrayWithRange:NSMakeRange(0, j2+1) ];
                                        //in_array = [ [[[linkResult_array2 objectAtIndex:index] objectAtIndex:2] objectAtIndex:i2] subarrayWithRange:NSMakeRange(0, j2+1) ];
                                    }
                                }
                            }
                        }
                        //[tv_results_array addObject:[NSArray arrayWithObjects:id_array, out_array, in_array, nil]];
                        NSMutableString *str = [NSMutableString string];
                        [str appendString:@"나의 "];
                        for(int i2=0; i2<[out_array count]; i2++)
                        {
                            NSString *name = [out_array objectAtIndex:i2];
                            if([name isEqualToString:@"null"]) [str appendString:@"'..'"];
                            else [str appendString:[NSString stringWithFormat:@"'%@'",name]];
                            if(i2==[out_array count]-1)
                            {
                                break;
                            }
                            else [str appendString:@"의 "];
                        }
                        [tv_relations_array addObject:[NSString stringWithString:str]];
                        /*
                        //rank
                        if([rankPool objectForKey:str_id])
                        {
                            [tv_ranks_array addObject:[rankPool objectForKey:str_id]];
                        }
                        else
                        {
                            [tv_ranks_array addObject:@"-1"];
                        }
                        */
                    }
                    //draw resultImg2
                    int sortNum = (int)[linkResult_array2 count]; //nC1 노드 개수:sortNum+1
                    float width_half, height_half;
                    width_half = height_half = 30.0f+(80.0f+60.0f)*sortNum+50.0f;
                    UIBezierPath *path;
                    if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width_half*2.0f,height_half*2.0f), NO, 2.0f);
                    else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width_half*2.0f,height_half*2.0f), NO, 3.0f);
                    else UIGraphicsBeginImageContext(CGSizeMake(width_half*2.0f, height_half*2.0f));
                    [resultImg drawInRect:CGRectMake(0.0f, 0.0f, width_half*2.0f, height_half*2.0f)];
                    NSArray *array_order = [[result_order objectAtIndex:i] objectAtIndex:j];
                    //(1)lines
                    path = [UIBezierPath bezierPath];
                    [[UIColor redColor] setStroke];
                    [path setLineWidth:4.0f];
                    float x2 = [[[pos_array3 objectAtIndex:0] objectAtIndex:0] floatValue];
                    float y2 = [[[pos_array3 objectAtIndex:0] objectAtIndex:1] floatValue];
                    [path moveToPoint:CGPointMake(x, y)];
                    [path addLineToPoint:CGPointMake(x2, y2)];
                    [path stroke];
                    [targetNum_array removeAllObjects];
                    for(NSString *str in array_order)
                    {
                        [targetNum_array addObject:[NSString stringWithString:str]];
                        int num = [str intValue]-1;
                        x2 = [[[pos_array3 objectAtIndex:num] objectAtIndex:0] floatValue];
                        y2 = [[[pos_array3 objectAtIndex:num] objectAtIndex:1] floatValue];
                        [path moveToPoint:CGPointMake(x, y)];
                        [path addLineToPoint:CGPointMake(x2, y2)];
                        [path stroke];
                    }
                    //(2)nodes
                    [[UIColor redColor] setStroke];
                    [[UIColor colorWithWhite:0.3f+0.15f*(float)(i+1) alpha:1.0f] setFill];
                    int number = (int)[[[result_nodes2 objectAtIndex:i] objectAtIndex:j] count];
                    int node_radius = 30.0f+(number-1)*2.0f;
                    if(node_radius>50.0f) node_radius = 50.0f;
                    path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x-node_radius, y-node_radius, node_radius*2.0f, node_radius*2.0f)];
                    [path fill];
                    [path setLineWidth:3.0f];
                    [path stroke];
                    [[UIColor blueColor] setFill];
                    x2 = [[[pos_array3 objectAtIndex:0] objectAtIndex:0] floatValue];
                    y2 = [[[pos_array3 objectAtIndex:0] objectAtIndex:1] floatValue];
                    path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x2-30.0f, y2-30.0f, 60.0f, 60.0f)];
                    [path fill];
                    [path setLineWidth:3.0f];
                    [path stroke];
                    for(NSString *str in array_order)
                    {
                        int num = [str intValue]-1;
                        x2 = [[[pos_array3 objectAtIndex:num] objectAtIndex:0] floatValue];
                        y2 = [[[pos_array3 objectAtIndex:num] objectAtIndex:1] floatValue];
                        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x2-30.0f, y2-30.0f, 60.0f, 60.0f)];
                        [path fill];
                        [path setLineWidth:3.0f];
                        [path stroke];
                    }
                    //(3)number
                    UIFont *font = [UIFont systemFontOfSize:30.0f];
                    NSMutableParagraphStyle *style_num = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                    style_num.alignment = NSTextAlignmentCenter;
                    NSDictionary *att_num = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style_num, NSForegroundColorAttributeName:[UIColor orangeColor]};
                    if([[[result_nodes2 objectAtIndex:i] objectAtIndex:j] count]>0)
                    {
                        [[NSString stringWithFormat:@"%d",(int)[[[result_nodes2 objectAtIndex:i] objectAtIndex:j] count]] drawInRect:CGRectMake(x-30.0f, y-18.0f, 60.0f, 30.0f) withAttributes:att_num];
                    }
                    //(4)kakao image update
                    NSMutableArray *ids_array2 = [NSMutableArray arrayWithCapacity:[pos_array3 count]];
                    [ids_array2 addObject:[NSString stringWithFormat:@"%ld",first.myid]];
                    for(NSArray *array in linkResult_array2)
                    {
                        [ids_array2 addObject:[[[array objectAtIndex:0] objectAtIndex:0] lastObject]];
                    }
                    NSString *str_id = [ids_array2 objectAtIndex:0];
                    if([imagePool objectForKey:str_id])
                    {
                        //position
                        x2 = [[[pos_array3 objectAtIndex:0] objectAtIndex:0] floatValue];
                        y2 = [[[pos_array3 objectAtIndex:0] objectAtIndex:1] floatValue];
                        //erase
                        [[UIColor whiteColor] setFill];
                        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x2-30.0f, y2-30.0f, 60.0f, 60.0f)];
                        [path fill];
                        //image
                        UIImage *img2 = [self circularScaleAndCropImage:[imagePool objectForKey:str_id] frame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
                        [img2 drawInRect:CGRectMake(x2-30.0f, y2-30.0f, 60.0f, 60.0f)];
                        //circle
                        [[UIColor redColor] setStroke];
                        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x2-30.0f, y2-30.0f, 60.0f, 60.0f)];
                        [path setLineWidth:3.0f];
                        [path stroke];
                    }
                    for(NSString *str in array_order)
                    {
                        int num = [str intValue]-1;
                        NSString *str_id = [ids_array2 objectAtIndex:num];
                        if([imagePool objectForKey:str_id])
                        {
                            //position
                            x2 = [[[pos_array3 objectAtIndex:num] objectAtIndex:0] floatValue];
                            y2 = [[[pos_array3 objectAtIndex:num] objectAtIndex:1] floatValue];
                            //erase
                            [[UIColor whiteColor] setFill];
                            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x2-30.0f, y2-30.0f, 60.0f, 60.0f)];
                            [path fill];
                            //image
                            UIImage *img2 = [self circularScaleAndCropImage:[imagePool objectForKey:str_id] frame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
                            [img2 drawInRect:CGRectMake(x2-30.0f, y2-30.0f, 60.0f, 60.0f)];
                            //circle
                            [[UIColor redColor] setStroke];
                            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x2-30.0f, y2-30.0f, 60.0f, 60.0f)];
                            [path setLineWidth:3.0f];
                            [path stroke];
                        }
                    }
                    UIImage *resultImg2 = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    [imageView_visual2 setImage:resultImg2];
                    //tableView_visual2
                    float table_height = (44.0f*(float)[ids_array count]) > 150.0f ? 150.0f : (44.0f*(float)[ids_array count]);
                    if(tableView_visual2) //기존의 tableView_visual2가 있으면 초기화
                    {
                        [tableView_visual2 removeFromSuperview];
                        tableView_visual2 = nil;
                    }
                    tableView_visual2 = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height-table_height, self.view.frame.size.width, table_height) style:UITableViewStylePlain];
                    tableView_visual2.dataSource = self;
                    tableView_visual2.delegate = self;
                    [self.view addSubview:tableView_visual2];
                    tableView_visual2.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.3f];
                    tableView_visual2.hidden = NO;
                    [tableView_visual2 setContentOffset:CGPointZero animated:YES];
                    [tableView_visual2 reloadData];
                    if(btn_del)
                    {
                        [btn_del removeFromSuperview];
                        btn_del = nil;
                    }
                    btn_del = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-33.0f, self.view.frame.size.height-table_height-33.0f, 30.0f, 30.0f)];
                    [btn_del setImage:img_del forState:UIControlStateNormal];
                    [btn_del addTarget:self action:@selector(btnDelClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [self.view addSubview:btn_del];
                }
                return;
            }
        }
    }
    //다른 곳을 탭 했을 경우
    [imageView_visual2 setImage:resultImg];
    prePt = CGPointMake(-1.0f, -1.0f);
    [targetNum_array removeAllObjects];
    btn_del.hidden = YES;
    tableView_visual2.hidden = YES;
    tv_curI = -2;
    tv_curJ = -2;
}







-(void)tappedTarget:(UITapGestureRecognizer *)gesture //목적 노드를 선택했을 경우(더블탭)
{
    CGPoint point = [gesture locationInView:imageView_visual2];
    float x,y;
    //[2]pos_array3
    for(int i=0; i<[pos_array3 count]; i++)
    {
        NSArray *array = [pos_array3 objectAtIndex:i];
        x = [[array objectAtIndex:0] floatValue];
        y = [[array objectAtIndex:1] floatValue];
        if(point.x>x-33.0f && point.x<x+33.0f && point.y>y-33.0f && point.y<y+33.0f)
        {
            if(0==i) //내 자신
            {
                UserInfo_ViewController *user = [self.storyboard instantiateViewControllerWithIdentifier:@"USERINFO"];
                user.first = first;
                user.flag = 0;
                user.user_id = (long)[[[result_nodes3 objectAtIndex:i] anyObject] longLongValue];
                [self.navigationController pushViewController:user animated:YES];
            }
            else
            {
                NSString *str_id = [[result_nodes3 objectAtIndex:i] anyObject];
                NSDictionary *myLinkID_dic = [NSDictionary dictionaryWithDictionary:first.myLinkID_dic];
                NSString *key;
                int index = -1;
                BOOL isBreak = NO;
                for(NSString *str in [myLinkID_dic allKeys])
                {
                    NSArray *array = [myLinkID_dic objectForKey:str];
                    for(int i=0; i<[array count]; i++)
                    {
                        if([str_id isEqualToString:[array objectAtIndex:i]])
                        {
                            key = [NSString stringWithString:str];
                            index = i;
                            isBreak = YES;
                            break;
                        }
                    }
                    if(isBreak) break;
                }
                if(index>-1)    //주소록에 있는 관계
                {
                    UserInfo_ViewController *user = [self.storyboard instantiateViewControllerWithIdentifier:@"USERINFO"];
                    user.first = first;
                    user.flag = 1;
                    user.user_id = (long)[str_id longLongValue];
                    NSString *phone = [[first.phone_dic objectForKey:key] objectAtIndex:index];
                    NSString *temp1 = [phone substringToIndex:3];
                    NSRange r;
                    NSString *temp3;
                    if(11==[phone length])
                    {
                        r = NSMakeRange(3, 4);
                        temp3 = [phone substringFromIndex:7];
                    }
                    else
                    {
                        r = NSMakeRange(3, 3);
                        temp3 = [phone substringFromIndex:6];
                    }
                    NSString *temp2 = [phone substringWithRange:r];
                    user.phone = [NSString stringWithFormat:@"%@-%@-%@", temp1, temp2, temp3];
                    user.name = [[first.name_dic objectForKey:key] objectAtIndex:index];;
                    user.relationName = [[first.relationName_dic objectForKey:key] objectAtIndex:index];
                    [self.navigationController pushViewController:user animated:YES];
                }
                else    //기타 관계
                {
                    [indicator startAnimating];
                    //[NSThread detachNewThreadSelector:@selector(tappedThread:) toTarget:self withObject:[NSNumber numberWithInt:i]];
                    [self tappedThread:[NSNumber numberWithInt:i]];
                }
            }
            break;
        }
    }
}


-(void)tappedThread:(NSNumber *)num
{
    int clickedIndex = [num intValue];
    UserInfo_ViewController *user = [self.storyboard instantiateViewControllerWithIdentifier:@"USERINFO"];
    user.first = first;
    user.flag = 2;
    user.user_id = (long)[[[result_nodes3 objectAtIndex:clickedIndex] anyObject] longLongValue];
    //user.name
    NSArray *out_array = [[[linkResult_array2 objectAtIndex:clickedIndex-1] objectAtIndex:1] objectAtIndex:0];
    NSMutableString *str = [NSMutableString string];
    [str appendString:@"나의 "];
    for(int i=0; i<[out_array count]; i++)
    {
        NSString *name = [out_array objectAtIndex:i];
        if([name isEqualToString:@"null"]) [str appendString:@"'...'"];
        else [str appendFormat:@"'%@'", name];
        if(i!=[out_array count]-1)
        {
            [str appendString:@"의 "];
        }
    }
    user.name = [NSString stringWithString:str];
    //user.phone
    NSString *temp = [NSString stringWithFormat:URL2, [[result_nodes3 objectAtIndex:clickedIndex] anyObject]];
    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    if(result)
    {
        NSString *str_temp = [result objectForKey:@"phone"];
        if((![str_temp isEqualToString:@"0"]) && (![str_temp isEqualToString:@"-1"]))
        {
            user.phone = [NSString stringWithString:str_temp];
        }
        [indicator stopAnimating];
        [self.navigationController pushViewController:user animated:YES];
    }
    else
    {
        [indicator stopAnimating];
    }
}
-(void)btnDelClicked:(id)sender
{
    btn_del.hidden = YES;
    tableView_visual2.hidden = YES;
}




















//tableView_visual2
-(NSInteger)tableView:(UITableView *)tableView2 numberOfRowsInSection:(NSInteger)section
{
    return [tv_ids_array count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView2 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CELL_VISUAL2"];
    //cell.imageView
    cell.imageView.clipsToBounds = YES;
    NSString *str_id = [tv_ids_array objectAtIndex:indexPath.row];
    if([[tv_imagePool allKeys] containsObject:str_id])
    {
        UIImage *image = [tv_imagePool objectForKey:str_id];
        if([image isMemberOfClass:[UIImage class]]) cell.imageView.image = image;
        else cell.imageView.image = nil;
    }
    else
    {
        CellImageDownloader2 *down = [[CellImageDownloader2 alloc] init];
        down.delegate2 = self;
        down.indexPath = indexPath;
        down.str_id = [NSString stringWithString:str_id];
        down.indexI = tv_curI;
        down.indexJ = tv_curJ;
        [tv_downloaderQueue addOperation:down];
    }
    cell.textLabel.text = [tv_relations_array objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    /*
    NSString *str_rank = [tv_ranks_array objectAtIndex:indexPath.row];
    if([str_rank intValue]>0)
    {
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:11.0f];
        cell.detailTextLabel.text = str_rank;
    }
    */
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


//cell selection
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView_visual2 deselectRowAtIndexPath:indexPath animated:YES];
    Visual2_2_ViewController *visual2_2 = [self.storyboard instantiateViewControllerWithIdentifier:@"VISUAL2_2"];
    visual2_2.first = first;
    NSString *str_id = [tv_ids_array objectAtIndex:indexPath.row];
    NSMutableArray *linkResult_array3 = [NSMutableArray arrayWithCapacity:[outer_order_array count]]; //(1)results
    NSMutableArray *linkNames_array3 = [NSMutableArray arrayWithCapacity:[outer_order_array count]];  //(2)names
    for(NSString *str in outer_order_array)
    {
        NSArray *array = [linkResult_array2 objectAtIndex:[str intValue]];
        NSArray *array_id = [array objectAtIndex:0];
        NSArray *array_out = [array objectAtIndex:1];
        NSArray *array_in = [array objectAtIndex:2];
        NSMutableArray *array_id2 = [NSMutableArray array];
        NSMutableArray *array_out2 = [NSMutableArray array];
        NSMutableArray *array_in2 = [NSMutableArray array];
        for(int i=0; i<[array_id count]; i++)
        {
            NSArray *array_id3 = [array_id objectAtIndex:i];
            BOOL isBreak = NO;
            for(NSString *str2 in array_id3)
            {
                if([str_id isEqualToString:str2])
                {
                    isBreak = YES;
                    break;
                }
            }
            if(isBreak)
            {
                [array_id2 addObject:[NSArray arrayWithArray:array_id3]];
                [array_out2 addObject:[NSArray arrayWithArray:[array_out objectAtIndex:i]]];
                [array_in2 addObject:[NSArray arrayWithArray:[array_in objectAtIndex:i]]];
            }
        }
        [linkResult_array3 addObject:[NSArray arrayWithObjects:array_id2, array_out2, array_in2, nil]];
        [linkNames_array3 addObject:[linkNames_array2 objectAtIndex:[str intValue]]];
    }
    visual2_2.linkResult_array2 = [NSArray arrayWithArray:linkResult_array3];
    visual2_2.linkNames_array2 = [NSArray arrayWithArray:linkNames_array3];
    visual2_2.dup_id = [NSString stringWithString:str_id];
    [self.navigationController pushViewController:visual2_2 animated:YES];
}

















//stepper
-(void)stepperPressed:(id)sender
{
    if(!tableView_visual2.hidden)
    {
        tableView_visual2.hidden = YES;
        if(btn_del) btn_del.hidden = YES;
    }
    prePt = CGPointMake(-1.0f, -1.0f);
    resultImg = [resultImg_array objectAtIndex:stepper.value];
    [imageView_visual2 setImage:resultImg];
}

















//[etc methods]//
-(void)combinations:(NSMutableArray *)result1 arg1:(int)start arg2:(int)n arg3:(int)k arg4:(int)maxK
{
    int i;
    if(k>maxK && 1==v[1])
    {
        NSMutableArray *temp = [NSMutableArray array];
        for(i=2; i<=maxK; i++)
        {
            [temp addObject:[NSString stringWithFormat:@"%d", v[i]]];
        }
        [result1 addObject:temp];
        return;
    }
    for(i=start;i<=n; i++)
    {
        v[k] = i;
        [self combinations:result1 arg1:i+1 arg2:n arg3:k+1 arg4:maxK];
    }
}



//tableView_visual2
-(void)didFinishedDownload:(UIImage *)image at:(NSIndexPath *)indexPath forId:(NSString *)str_id forI:(int)indexI forJ:(int)indexJ
{
    if(image)
    {
        [tv_imagePool setObject:image forKey:str_id];
        if(tableView_visual2 && indexI==tv_curI && indexJ==tv_curJ)  //현재 테이블뷰를 reload
        {
            [self performSelectorOnMainThread:@selector(reloadCellImage:) withObject:indexPath waitUntilDone:YES];
        }
    }
    else [tv_imagePool setObject:[NSNull null] forKey:str_id];
}
-(void)reloadCellImage:(NSIndexPath *)indexPath
{
    [tableView_visual2 reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}





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



//zoom
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView_visual2;
}




- (void)didReceiveMemoryWarning {
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
