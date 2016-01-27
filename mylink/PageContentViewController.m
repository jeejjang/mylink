//
//  PageContentViewController.m
//  mylink
//
//  Created by JeongMin Ji on 2015. 2. 25..
//  Copyright (c) 2015년 ZANDA. All rights reserved.
//

#import "PageContentViewController.h"
#import "UserInfo_ViewController.h"

#define URL2 @"http://jeejjang.cafe24.com/link/idtophone_1.jsp?id=%@"

@interface PageContentViewController ()
-(void)tapped:(UITapGestureRecognizer *)gesture;
-(void)tappedThread:(NSNumber *)num;
@end

@implementation PageContentViewController
@synthesize first, visual1, visual2_2, image, pageIndex, ids_array, out_array, pos_array;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    imageView = [[UIImageView alloc] initWithImage:image];
    gapX = (self.view.frame.size.width - image.size.width)/2.0f;
    imageView.frame = CGRectMake(gapX, 0.0f, image.size.width, image.size.height);
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 44.0f, self.view.frame.size.width, self.view.frame.size.height-44.0f)];
    [self.view addSubview:scrollView];
    [scrollView addSubview:imageView];
    [scrollView setContentSize:CGSizeMake(image.size.width+gapX*2.0f, image.size.height)];
    scrollView.delegate = self;
    //Tap gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [scrollView addGestureRecognizer:tap];
}




-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    [scrollView setContentInset:UIEdgeInsetsZero];
    [scrollView setScrollIndicatorInsets:UIEdgeInsetsZero];
}





-(void)tapped:(UITapGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:imageView];
    int clickedIndex = -1;
    for(int i=0; i<[pos_array count]; i++)
    {
        float x = [[[pos_array objectAtIndex:i] objectAtIndex:0] floatValue];
        float y = [[[pos_array objectAtIndex:i] objectAtIndex:1] floatValue];
        if(point.x>x-33.0f && point.x<x+33.0f && point.y>y-33.0f && point.y<y+33.0f)
        {
            clickedIndex = i;
            break;
        }
    }
    if(clickedIndex>-1)
    {
        if(visual1) visual1.pageIndex = (int)pageIndex;
        else visual2_2.pageIndex = (int)pageIndex;
        if(0==clickedIndex) //내 자신
        {
            UserInfo_ViewController *user = [self.storyboard instantiateViewControllerWithIdentifier:@"USERINFO"];
            user.first = first;
            user.flag = 0;
            user.user_id = (long)[[ids_array objectAtIndex:clickedIndex] longLongValue];
            [self.navigationController pushViewController:user animated:YES];
        }
        else
        {
            NSString *str_id = [ids_array objectAtIndex:clickedIndex];
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
                //[NSThread detachNewThreadSelector:@selector(tappedThread:) toTarget:self withObject:[NSNumber numberWithInt:clickedIndex]];
                [self tappedThread:[NSNumber numberWithInt:clickedIndex]];
            }
        }
    }
}



-(void)tappedThread:(NSNumber *)num
{
    int clickedIndex = [num intValue];
    UserInfo_ViewController *user = [self.storyboard instantiateViewControllerWithIdentifier:@"USERINFO"];
    user.first = first;
    user.flag = 2;
    user.user_id = (long)[[ids_array objectAtIndex:clickedIndex] longLongValue];
    //user.name
    NSMutableString *str = [NSMutableString string];
    [str appendString:@"나의 "];
    for(int i=0; i<clickedIndex; i++)
    {
        NSString *str_temp2 = [out_array objectAtIndex:i];
        if([str_temp2 isEqualToString:@"null"]) [str appendString:@"'..'"];
        else [str appendFormat:@"'%@'", str_temp2];
        if(i!=clickedIndex-1)
        {
            [str appendString:@"의 "];
        }
    }
    user.name = [NSString stringWithString:str];
    //user.phone
    NSString *temp = [NSString stringWithFormat:URL2, [ids_array objectAtIndex:clickedIndex]];
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
