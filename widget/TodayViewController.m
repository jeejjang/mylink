//
//  TodayViewController.m
//  widget
//
//  Created by JeongMin Ji on 2015. 9. 1..
//  Copyright (c) 2015년 ZANDA. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

#define URL1 @"http://jeejjang.cafe24.com/link/phonetoid_1.jsp?phone='%@'"
#define URL2 @"http://jeejjang.cafe24.com/link/linksearch_1.jsp?s=%ld&e=%ld"


@interface TodayViewController () <NCWidgetProviding>
-(void)searchOneToOneThread:(NSString *)phone;
-(void)reload_serverError;
-(void)reload_nosearched;
-(void)reload_searched:(NSString *)text;
-(void)appBtnClicked:(id)sender;
@end

@implementation TodayViewController
@synthesize today_label1, today_label2, today_appBtn;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [today_appBtn addTarget:self action:@selector(appBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self setPreferredContentSize:CGSizeMake(0.0f, 67.0f)]; //<-> 105.0f
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.zandamobile.mylink7"];
    NSNumber *myid_num = [sharedDefaults objectForKey:@"today_mylinkid"];
    if(myid_num)
    {
        [today_label1 setText:@"전화번호를 복사한 후 아래로 당겨보세요"];
        [today_label2 setText:@"('01'로 시작하는 번호만 가능)"];
        myid = (long)[myid_num longLongValue];
    }
    else
    {
        [today_label1 setText:@"전화번호 인증 후 이용할 수 있습니다"];
        [today_label2 setText:@""];
        myid = 0;
    }
    today_appBtn.hidden = YES;
}




- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    if(myid>0)
    {
        NSString *str_now = [UIPasteboard generalPasteboard].string;
        if(str_now.length>0)
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *str_pre = [defaults objectForKey:@"today_prestring"];
            if((nil==str_pre) || (![str_pre isEqualToString:str_now]))
            {
                [defaults setObject:str_now forKey:@"today_prestring"];
                [defaults synchronize];
                NSString *phone1 = [[[str_now stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""];
                if(0!=phone1.length)
                {
                    NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
                    NSRange nond = [phone1 rangeOfCharacterFromSet:nonDigits];
                    if(0==nond.length) //only digit
                    {
                        NSUInteger phone_length = [phone1 length];
                        if(phone_length>=10 && phone_length<=11) //전화번호 길이가 10과 11사이일 때
                        {
                            if([[phone1 substringWithRange:NSMakeRange(0,2)] isEqualToString:@"01"]) //전화번호가 01로 시작할 때
                            {
                                //search!
                                NSString *temp1 = [phone1 substringToIndex:3];
                                NSRange r;
                                NSString *temp3;
                                if(11==[phone1 length])
                                {
                                    r = NSMakeRange(3, 4);
                                    temp3 = [phone1 substringFromIndex:7];
                                }
                                else
                                {
                                    r = NSMakeRange(3, 3);
                                    temp3 = [phone1 substringFromIndex:6];
                                }
                                NSString *temp2 = [phone1 substringWithRange:r];
                                NSString *phone1_show = [NSString stringWithFormat:@"%@-%@-%@", temp1, temp2, temp3];
                                [today_label1 setText:phone1_show];
                                [today_label2 setText:@"검색 중..."];
                                //search
                                [NSThread detachNewThreadSelector:@selector(searchOneToOneThread:) toTarget:self withObject:phone1];
                                completionHandler(NCUpdateResultNewData);
                            }
                            else completionHandler(NCUpdateResultNoData);
                        }
                        else completionHandler(NCUpdateResultNoData);
                    }
                    else completionHandler(NCUpdateResultNoData);
                }
                else completionHandler(NCUpdateResultNoData);
            }
            else completionHandler(NCUpdateResultNoData);
        }
        else completionHandler(NCUpdateResultNoData);
    }
    else completionHandler(NCUpdateResultNoData);
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
}














//빠른 검색(thread)
-(void)searchOneToOneThread:(NSString *)phone
{
    //today_phone = [NSString stringWithString:phone];
    NSString *temp = [NSString stringWithFormat:URL1, phone];
    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    if(result)
    {
        NSString *inputId_str = [result objectForKey:@"id"];
        long inputId = (long)[inputId_str longLongValue];
        if(0==inputId) //(1)만약 실패한 경우
        {
            [self performSelectorOnMainThread:@selector(reload_serverError) withObject:nil waitUntilDone:YES];
        }
        else //(2)등록된 번호일 경우
        {
            //(2-2)searching
            NSString *temp1 = [NSString stringWithFormat:URL2 ,myid, inputId];
            id result1 = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp1]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
            if(result1)
            {
                int check = [[result1 objectForKey:@"check"] intValue];
                if(-3==check) //(1) connection error
                {
                    [self performSelectorOnMainThread:@selector(reload_serverError) withObject:nil waitUntilDone:YES];
                }
                else if(check<=0) //(2) 링크결과가 없는 경우
                {
                    [self performSelectorOnMainThread:@selector(reload_nosearched) withObject:nil waitUntilDone:YES];
                }
                else //(3) 결과를 찾은 경우
                {
                    NSDictionary *result2 = [result1 objectForKey:@"link"];
                    NSMutableArray *resultOut_array2 = [NSMutableArray arrayWithCapacity:check];
                    for(NSDictionary *dic in result2)
                    {
                        //out
                        NSDictionary *dic_out = [dic objectForKey:@"out"];
                        for(NSDictionary *dic_name in dic_out)
                        {
                            [resultOut_array2 addObject:(NSString *)[dic_name objectForKey:@"name"]];
                        }
                        break;
                    }
                    NSMutableString *str = [NSMutableString string];
                    [str appendString:@": 나의 "];
                    for(int i=0; i<[resultOut_array2 count]; i++)
                    {
                        NSString *name = [resultOut_array2 objectAtIndex:i];
                        if([name isEqualToString:@"null"]) [str appendString:@"'..'"];
                        else [str appendFormat:@"'%@'", name];
                        if(i!=[resultOut_array2 count]-1)
                        {
                            [str appendString:@"의 "];
                        }
                    }
                    [self performSelectorOnMainThread:@selector(reload_searched:) withObject:str waitUntilDone:YES];
                }
            }
            else
            {
                [self performSelectorOnMainThread:@selector(reload_serverError) withObject:nil waitUntilDone:YES];
            }
        }
    }
    else
    {
        [self performSelectorOnMainThread:@selector(reload_serverError) withObject:nil waitUntilDone:YES];
    }
}


//in main thread
-(void)reload_serverError
{
    [today_label2 setText:@": 서버상태 오류 - 잠시 후에 다시 시도하세요"];
}
-(void)reload_nosearched
{
    [today_label2 setText:@": 링크를 찾지 못했습니다"];
}
-(void)reload_searched:(NSString *)text
{
    [self setPreferredContentSize:CGSizeMake(0.0f, 105.0f)]; //<-> 67.0f
    [today_label2 setText:text];
    [today_appBtn setTitle:@"마이링크앱에서 자세히 검색하기" forState:UIControlStateNormal];
}









-(void)appBtnClicked:(id)sender
{
    NSURL *openURL = [NSURL URLWithString:@"kakao444395c38c45f21530dd0cdc6620a378://home"];
    [self.extensionContext openURL:openURL completionHandler:nil];
}













//animate when widget's height changes
-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        //[today_label2 setFont:[UIFont systemFontOfSize:14.0f]];
        today_appBtn.hidden = NO;
    } completion:nil];
}



//set margin size
- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)margins
{
    margins.left = 10.0f;
    margins.bottom = 5.0f;
    return margins;
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
