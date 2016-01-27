//
//  UserInfoImgZoom_ViewController.m
//  mylink
//
//  Created by JeongMin Ji on 2014. 10. 2..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import "UserInfoImgZoom_ViewController.h"

@interface UserInfoImgZoom_ViewController ()
-(void)scrollViewTapped:(UITapGestureRecognizer *)gesture;
@end

@implementation UserInfoImgZoom_ViewController
@synthesize image;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    scrollView_zoom.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped:)];
    [scrollView_zoom addGestureRecognizer:tap];
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    //size & position of imageview_zoom
    float img_w = image.size.width;
    float img_h = image.size.height;
    float ratio = self.view.frame.size.width / img_w;
    float img_w2 = self.view.frame.size.width;
    float img_h2 = img_h * ratio;
    imageView_zoom = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, (self.view.frame.size.height-img_h2)/2.0f, img_w2, img_h2)];
    [scrollView_zoom addSubview:imageView_zoom];
    imageView_zoom.image = image;
}



-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView_zoom;
}


-(void)scrollViewTapped:(UITapGestureRecognizer *)gesture
{
    if(button_zoom.hidden) button_zoom.hidden = NO;
    else button_zoom.hidden = YES;
}


- (IBAction)btnCancelClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
