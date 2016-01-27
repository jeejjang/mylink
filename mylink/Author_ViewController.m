//
//  Author_ViewController.m
//  mylink
//
//  Created by JeongMin Ji on 2014. 9. 26..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import "Author_ViewController.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"

//#define ADDRESSBOOK @"Documents/mylink_address.plist"
#define URL1 @"http://jeejjang.cafe24.com/link/smssend1.jsp?phone=%@"
#define URL2 @"http://jeejjang.cafe24.com/link/smssend2.jsp?phone=%@&num=%@"
#define URL3 @"http://jeejjang.cafe24.com/link/register.jsp?phone='%@'"
#define URL4 @"http://jeejjang.cafe24.com/link/noresult_del2.jsp?myid=%ld"
#define LINKCLICKS @"Documents/mylink_clicks.plist"


@interface Author_ViewController ()
-(void)SMSConfirm;
-(void)SMSConfirm2;
-(void)noresultDelThread;
-(void)textFieldShouldReturnMethod;
-(UIToolbar *)accessoryView;
-(void)authorNumClicked;
-(void)textFieldChanged:(UITextField *)textField;
@end

@implementation Author_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}





-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}





-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"mylinkid"]) //<2> 앱을 재실행한 경우
    {
        UITabBarController *tabbar = (UITabBarController *)[self.storyboard instantiateViewControllerWithIdentifier:@"TABBAR"];
        FirstViewController *first = (FirstViewController *)[[[tabbar viewControllers] objectAtIndex:0] topViewController];
        myid = (long)[[defaults objectForKey:@"mylinkid"] longLongValue];
        first.tabbar = tabbar;
        first.myid = myid;
        phone = (NSString *)[defaults objectForKey:@"mylinkphone"];
        first.myPhone = phone;
        first.isFirst = NO;
        SecondViewController *second = (SecondViewController *)[[[tabbar viewControllers] objectAtIndex:1] topViewController];
        second.tabbar = tabbar;
        second.first = first;
        ThirdViewController *third = (ThirdViewController *)[[[tabbar viewControllers] objectAtIndex:2] topViewController];
        third.first = first;
        //class
        first.second = second;
        first.third = third;
        //badge
        int cnt2 = (int)[UIApplication sharedApplication].applicationIconBadgeNumber;
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:LINKCLICKS];
        if([manager fileExistsAtPath:filePath])
        {
            NSArray *linkClicks_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKCLICKS]];
            int cnt = cnt2;
            for(NSString *str in linkClicks_array)
            {
                if([str isEqualToString:@"0"]) cnt++;
            }
            if(cnt>0)
            {
                [[[tabbar viewControllers] objectAtIndex:1] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d",cnt];
            }
            else
            {
                [[[tabbar viewControllers] objectAtIndex:1] tabBarItem].badgeValue = nil;
            }
        }
        else
        {
            [[[tabbar viewControllers] objectAtIndex:1] tabBarItem].badgeValue = nil;
            //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        }
        [self presentViewController:tabbar animated:NO completion:^{
            NSString *flag = [defaults objectForKey:@"backfetch_id"];
            if(![flag isEqualToString:@"0"])
            {
                tabbar.selectedIndex = 1;
                //second.selectId_back = [NSString stringWithString:flag];
            }
            NSString *flag2 = [defaults objectForKey:@"push_id"];
            if(![flag2 isEqualToString:@"0"])
            {
                tabbar.selectedIndex = 1;
                //second.selectId_back = [NSString stringWithString:flag];
            }
        }];
    }
    else //(1)앱을 처음 시작하는 경우
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldShouldReturnMethod)];
        tap.numberOfTapsRequired = 1;
        [self.view addGestureRecognizer:tap];
        textField_phone.delegate = self;
        textField_phone.inputAccessoryView = [self accessoryView];
        [textField_phone addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        textView_author.text = @"\n1. 마이링크는 사용자의 동의를 통해 주소록에 등록된 전화번호와 이름에만 합법적으로 접근하며, 이 외에 어떠한 정보에도 접근하지 않습니다.\n\n2. 관계검색은 단지 전화번호만 이용하며, 내 주소록에 등록된 어떠한 전화번호도 타인이 알 수 없습니다.\n\n3. 관계정보는 주소록의 이름을 사용하며, 이 관계이름은 앱 안에서 항상 수정 및 삭제가 가능합니다.\n\n4. 공개를 원하지 않는 관계는 숨김기능을 통해 완전히 감출 수 있습니다.\n\n5. 마이링크를 통해 카카오에 로그인한 상태에서만 다른사람에게 카카오 정보가 공개됩니다.\n- 카카오톡 닉네임, 프로필 사진, 카카오 스토리 닉네임, 생일, 프로필사진, 배경사진, 가장 최근의 공개글";
        view_screen.hidden = YES;
    }
}








-(UIToolbar *)accessoryView
{
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 35.0f)];
    toolBar.tintColor = [UIColor darkGrayColor];
    toolBar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],[[UIBarButtonItem alloc] initWithTitle:@"인증번호 발송" style:UIBarButtonItemStylePlain target:self action:@selector(authorNumClicked)],nil];
    [[toolBar.items objectAtIndex:1] setTintColor:[UIColor colorWithRed:0.0f green:128.0f/255.0f blue:1.0f alpha:1.0f]];
    [[toolBar.items objectAtIndex:1] setEnabled:NO];
    return toolBar;
}
-(void)authorNumClicked
{
    [textField_phone resignFirstResponder];
     //'-',space remove
     phone = [[textField_phone.text stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
     if(0==phone.length)
     {
         return;
     }
     NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
     NSRange nond = [phone rangeOfCharacterFromSet:nonDigits];
     if(0!=nond.length)
     {
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"올바른 전화번호를 입력하세요!" message:nil delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
         [alert show];
     }
     else
     {
         //check if '01' & its length
         NSUInteger phone_length = [phone length];
         if([[phone substringWithRange:NSMakeRange(0,2)] isEqualToString:@"01"] && phone_length>=10 && phone_length<=11)
         {
             NSString *temp1 = [NSString stringWithFormat:URL1, phone];
             id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp1]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
             if(result)
             {
                 if([[result objectForKey:@"result"] isEqualToString:@"success"])
                 {
                     //send complete
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"인증번호 발송 완료" message:@"받은 인증번호를 입력하세요" delegate:self cancelButtonTitle:@"취 소" otherButtonTitles:@"확 인", nil];
                     alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                     [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
                     //[alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeDecimalPad;
                     [alert show];
                 }
                 else
                 {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"서버상태가 좋지 않습니다!" message:@"잠시 후에 다시 시도해 주세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                     [alert show];
                 }
             }
             else
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"서버상태가 좋지 않습니다!" message:@"잠시 후에 다시 시도해 주세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                 [alert show];
             }
         }
         else
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"올바른 전화번호를 입력하세요!" message:nil delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
             [alert show];
         }
    }
}









//alertView
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:@"인증번호 발송 완료"])
    {
        if(buttonIndex==alertView.firstOtherButtonIndex)    //확인
        {
            phone_num = [[alertView textFieldAtIndex:0].text stringByReplacingOccurrencesOfString:@" " withString:@""];
            [indicator startAnimating];
            [NSThread detachNewThreadSelector:@selector(SMSConfirm) toTarget:self withObject:nil];
        }
    }
}







-(void)SMSConfirm
{
    NSString *temp = [NSString stringWithFormat:URL2, phone, phone_num];
    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    if(result)
    {
        int temp1 = [[result objectForKey:@"result"] intValue];
        [indicator stopAnimating];
        if(1==temp1)   //correct
        {
            //(1-1)Receive ID
            NSString *temp = [NSString stringWithFormat:URL3, phone];
            id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
            if(result)
            {
                myid = (long)[[result objectForKey:@"result"] longLongValue];
                if(myid>0) //success
                {
                    [self performSelectorOnMainThread:@selector(SMSConfirm2) withObject:nil waitUntilDone:YES];
                }
            }
        }
        else if(0==temp1)   //incorrect
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"인증번호가 틀렸습니다!" message:nil delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        }
    }
    else
    {
        [indicator stopAnimating];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"서버상태가 좋지 않습니다!" message:@"잠시 후에 다시 시도해 주세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    }
}
-(void)SMSConfirm2
{
    //(1-2) Save in file
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithLong:myid] forKey:@"mylinkid"];
    [defaults setObject:phone forKey:@"mylinkphone"];
    //background fetch
    [defaults setObject:[NSNumber numberWithInt:1000] forKey:@"lastimgnum"]; //imgNum
    [defaults synchronize];
    //today widget
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.zandamobile.mylink7"];
    [sharedDefaults setObject:[NSNumber numberWithLong:myid] forKey:@"today_mylinkid"];
    //[sharedDefaults setObject:[NSArray array] forKey:@"today_phone"];
    [sharedDefaults synchronize];
    UITabBarController *tabbar = (UITabBarController *)[self.storyboard instantiateViewControllerWithIdentifier:@"TABBAR"];
    FirstViewController *first = (FirstViewController *)[[[tabbar viewControllers] objectAtIndex:0] topViewController];
    first.tabbar = tabbar;
    first.myid = myid;
    first.myPhone = phone;
    first.isFirst = YES;
    SecondViewController *second = (SecondViewController *)[[[tabbar viewControllers] objectAtIndex:1] topViewController];
    second.tabbar = tabbar;
    second.first = first;
    ThirdViewController *third = (ThirdViewController *)[[[tabbar viewControllers] objectAtIndex:2] topViewController];
    third.first = first;
    //class
    first.second = second;
    first.third = third;
    [[[tabbar viewControllers] objectAtIndex:1] tabBarItem].badgeValue = nil;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    //refresh noresult table
    [NSThread detachNewThreadSelector:@selector(noresultDelThread) toTarget:self withObject:nil];
    [self presentViewController:tabbar animated:YES completion:nil];
}
-(void)noresultDelThread
{
    NSString *temp = [NSString stringWithFormat:URL4, myid];
    [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
}









//textField_phone
-(void)textFieldChanged:(UITextField *)textField
{
    if([textField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length >= 10 && [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length <= 11) [[toolBar.items objectAtIndex:1] setEnabled:YES];
    else [[toolBar.items objectAtIndex:1] setEnabled:NO];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField_phone resignFirstResponder];
    return YES;
}
-(void)textFieldShouldReturnMethod
{
    [textField_phone resignFirstResponder];
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
