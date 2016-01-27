//
//  IntroViewController.m
//  mylink
//
//  Created by JeongMin Ji on 2015. 10. 1..
//  Copyright © 2015년 ZANDA. All rights reserved.
//

#import "IntroViewController.h"

#define IMG_NUM 5
#define IMG_WIDTH 230
#define IMG_HEIGHT 466

@interface IntroViewController ()

@end

@implementation IntroViewController
@synthesize str_url;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:str_url]];
    [webView loadRequest:request];

}







-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [indicator startAnimating];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [indicator stopAnimating];
}





- (IBAction)btnCloseClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
