//
//  BlindSMSViewController.m
//  mylink
//
//  Created by JeongMin Ji on 2015. 1. 2..
//  Copyright (c) 2015년 ZANDA. All rights reserved.
//

#import "BlindSMSViewController.h"
#import "BlindCell.h"
#import "UserSelectViewController.h"
#import "PhoneLoadViewController.h"
#import "HistoryCell.h"

#define REP_PHONE1 @"050"
#define REP_PHONE2 @"6050"
#define REP_PHONE3 @"0114"
//#define EUCKRENCODING -2147481280
#define TITLES @"Documents/load_titles.plist"
#define TEXTS @"Documents/load_texts.plist"
#define PHONES @"Documents/load_phones.plist"
#define DATES @"Documents/load_dates.plist"
#define SENDS_HIS @"Documents/history_sends.plist"
#define NAMES_HIS @"Documents/history_names.plist"
#define DATES_HIS @"Documents/history_dates.plist"
#define TEXTS_HIS @"Documents/history_texts.plist"


#define URL1 @"http://jeejjang.cafe24.com/link/blindsend.jsp?rphone=%@&sphone1=%@&sphone2=%@&sphone3=%@&msg=%@&type=%@&date=%@&time=%@"
#define URL2 @"http://jeejjang.cafe24.com/link/node_minus.jsp?myid=%ld&node=%d"

@interface BlindSMSViewController ()
//-(void)textView_senderValueChanged:(id)sender;
-(void)receiverViewTapped:(UITapGestureRecognizer *)tap;
-(void)receiverTapped;
-(void)dismissAlertView:(UIAlertView *)alert;
-(void)delBtnClicked:(id)sender;
-(void)touchScreenTapped:(UITapGestureRecognizer *)tap;
-(void)hisDelBtnClicked:(id)sender;
-(void)keyboardWillShow:(NSNotification *)noti;
-(void)keyboardWillHide;
-(void)btnInputClicked:(id)sender;
-(void)btnInputClicked2:(NSArray *)array;
-(NSString *)stringByReplacingforJSON:(NSString *)str;
@end

@implementation BlindSMSViewController
@synthesize first, flag, phone_receiver, text_receiver, tableView_receiver, texts_array, phones_array;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //sender
    //textView_sender.delegate = self;
    //[textView_sender addTarget:self action:@selector(textView_senderValueChanged:) forControlEvents:UIControlEventEditingChanged];
    //receiver
    textView_receiver.delegate = self;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(receiverViewTapped:)];
    [view_receiver addGestureRecognizer:tap2];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0.0f, 0.0f, 240.0f, 330.0f)]; //shadow in view_receiver2
    [view_receiver2.layer setMasksToBounds:NO];
    [view_receiver2.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [view_receiver2.layer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
    [view_receiver2.layer setShadowOpacity:1.0f];
    [view_receiver2.layer setShadowRadius:3.5f];
    [view_receiver2.layer setShadowPath:shadowPath.CGPath];
    tableView_receiver.delegate = self;
    tableView_receiver.dataSource = self;
    textField_receiver.delegate =self;
    texts_array = [NSMutableArray array];
    phones_array = [NSMutableArray array];
    //reservation
    shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0.0f, 0.0f, 300.0f, 310.0f)]; //shadow in view_date2
    [view_date2.layer setMasksToBounds:NO];
    [view_date2.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [view_date2.layer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
    [view_date2.layer setShadowOpacity:1.0f];
    [view_date2.layer setShadowRadius:3.5f];
    [view_date2.layer setShadowPath:shadowPath.CGPath];
    //SMS
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height-47.0f, self.view.frame.size.width, 47.0f)];
    //containerView.backgroundColor = [UIColor colorWithRed:228.0f/255.0f green:228.0f/255.0f blue:228.0f/255.0f alpha:1.0f];;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_sms"]];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [containerView addSubview:imageView];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:containerView];
    //(1)label
    //label_type = [[UILabel alloc] initWithFrame:CGRectMake(1.0f, 10.0f, 29.0f, 13.0f)];
    //label_type.textColor = [UIColor darkGrayColor];
    //label_type.font = [UIFont systemFontOfSize:10.0f];
    //label_type.textAlignment = NSTextAlignmentCenter;
    //label_type.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    //[containerView addSubview:label_type];
    //label_percent = [[UILabel alloc] initWithFrame:CGRectMake(1.0f, 25.0f, 29.0f, 13.0f)];
    //label_percent.textColor = [UIColor darkGrayColor];
    //label_percent.font = [UIFont systemFontOfSize:10.0f];
    //label_percent.textAlignment = NSTextAlignmentCenter;
    //label_percent.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    //[containerView addSubview:label_percent];
    //(2)textView
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(5.0f, 7.0f, self.view.frame.size.width-70.0f, 40.0f)];
    textView.isScrollable = YES;
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 5;
    // you can also set the maximum height in points with maxHeight
    //textView.maxHeight = 100.0f;
    //textView.returnKeyType = UIReturnKeyDone; //just as an example
    textView.internalTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.font = [UIFont systemFontOfSize:15.0f];
    textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    //textView.placeholder = @"1노드 사용";
    textView.text = @"";
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [containerView addSubview:textView];
    //(3)inputBtn
    inputBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    inputBtn.frame = CGRectMake(self.view.frame.size.width-60.0f, 7.0f, 57.0f, 34.0f);
    inputBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [inputBtn setTitle:@"전 송" forState:UIControlStateNormal];
    inputBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [inputBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [inputBtn setBackgroundColor:[UIColor orangeColor]];
    [inputBtn addTarget:self action:@selector(btnInputClicked:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:inputBtn];
    //(4)keyboard down
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchScreenTapped:)];
    [view_touchScreen addGestureRecognizer:tap];
    //init
    //receiver
    view_receiver.hidden = YES;
    [textView_receiver setText:text_receiver];
    if(0==flag || 1==flag)
    {
        textView_receiver.enabled = NO;
        textView_receiver.alpha = 0.5f;
        [texts_array addObject:phone_receiver];
    }
    else //임의의 사람에게 보내는 경우
    {
        textView_receiver.enabled = YES;
        textView_receiver.alpha = 1.0f;
        [textView_receiver addTarget:self action:@selector(receiverTapped) forControlEvents:UIControlEventTouchDown];
        phone_receiver = @"";
    }
    //reservation
    view_date.hidden = YES;
    [label_time setText:@""];
    str_date = @"";
    str_time = @"";
    //SMS
    //smsType = @"";
    //label_type.text = @"단문";
    //label_percent.text = @"0%";
    //inputBtn
    inputBtn.enabled = NO;
    inputBtn.alpha = 0.5f;
    //node
    nodes = 0;
    [label_node setText:[NSString stringWithFormat:@"%d 노드 사용 (/%d 노드)",nodes, first.node]];
    //history
    tableView_history.delegate = self;
    tableView_history.dataSource = self;
    tableView_history.estimatedRowHeight = 80.0f;
    tableView_history.rowHeight = UITableViewAutomaticDimension;
    //img_arrow = [UIImage imageNamed:@"arrowr"];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:NAMES_HIS];
    if([manager fileExistsAtPath:filePath])
    {
        names_history_array = [NSMutableArray arrayWithContentsOfFile:filePath];
        sends_history_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:SENDS_HIS]];
        dates_history_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:DATES_HIS]];
        texts_history_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:TEXTS_HIS]];
    }
    else
    {
        names_history_array = [NSMutableArray array];
        sends_history_array = [NSMutableArray array];
        dates_history_array = [NSMutableArray array];
        texts_history_array = [NSMutableArray array];
    }
    if(0==[names_history_array count]) tableView_history.hidden = YES;
}







-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    //font size fit
    if(0==flag || 1==flag)
    {
        CGFloat fontSize = 13.0f;
        while (true)
        {
            NSDictionary *att = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
            CGSize size = [text_receiver sizeWithAttributes:att];
            NSLog(@"%f", textView_receiver.frame.size.width);
            if(size.width>textView_receiver.frame.size.width)
            {
                fontSize -= 1.0f;
                if(fontSize<=8.0f) break;
            }
            else
            {
                break;
            }
        }
        textView_receiver.font = [UIFont systemFontOfSize:fontSize];
    }
    [self.view bringSubviewToFront:containerView];
    [tableView_history reloadData];
}











//sender
/*
- (IBAction)btnMyPhoneClicked:(id)sender
{
    [textView_sender setText:first.myPhone];
}
-(void)textView_senderValueChanged:(id)sender
{
    NSString *temp = [[textView_sender.text stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if(temp.length<4 || temp.length>12)
    {
        [textView_sender setTextColor:[UIColor redColor]];
    }
    else
    {
        [textView_sender setTextColor:[UIColor blackColor]];
    }
}
*/
/*
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField==textView_sender)
    {
        NSString *temp = [[textView_sender.text stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        if(temp.length<4 || temp.length>12)
        {
            [textView_sender setTextColor:[UIColor redColor]];
        }
        else
        {
            [textView_sender setTextColor:[UIColor blackColor]];
        }
    }
    return YES;
}
*/



//receiver
-(void)receiverTapped   //textView_receiver를 터치했을 때
{
    [textView resignFirstResponder];
    [textView_receiver resignFirstResponder];
    //[textView_sender resignFirstResponder];
    containerView.hidden = YES;
    [UIView transitionWithView:view_receiver duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:nil];
    view_receiver.hidden = NO;
    [tableView_receiver reloadData];
    [tableView_receiver setContentInset:UIEdgeInsetsZero];
    [tableView_receiver setScrollIndicatorInsets:UIEdgeInsetsZero];
    [tableView_receiver setContentOffset:CGPointMake(0.0f, 0.0f) animated:NO];
}
-(void)receiverViewTapped:(UITapGestureRecognizer *)tap //view_receiver를 탭했을 때
{
    [textField_receiver resignFirstResponder];
}
- (IBAction)receiverAddClicked:(id)sender //'추가'
{
    //숫자와 '-'만 허용
    NSString *phone = [[textField_receiver.text stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if(0==phone.length)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"올바른 전화번호를 입력하세요!" message:nil delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        NSRange nond = [phone rangeOfCharacterFromSet:nonDigits];
        if(0!=nond.length)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"숫자만 입력하세요!" message:nil delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
            [alert show];
        }
        else //-> add
        {
            [texts_array addObject:[NSString stringWithString:textField_receiver.text]];
            [phones_array addObject:[NSString stringWithString:phone]];
            [tableView_receiver reloadData];
            textField_receiver.text = @"";
        }
    }
}
- (IBAction)receiverAddressClicked:(id)sender //'주소록'
{
    UserSelectViewController *select = [self.storyboard instantiateViewControllerWithIdentifier:@"SELECT"];
    select.blind = self;
    select.name_dic = [NSMutableDictionary dictionaryWithDictionary:first.name_dic];
    select.phone_dic = [NSMutableDictionary dictionaryWithDictionary:first.phone_dic];
    [self presentViewController:select animated:YES completion:nil];
}
- (IBAction)receiverLoadClicked:(id)sender //'리스트'불러오기
{
    PhoneLoadViewController *phone = [self.storyboard instantiateViewControllerWithIdentifier:@"PHONELOAD"];
    phone.blind = self;
    [self presentViewController:phone animated:YES completion:nil];
}
- (IBAction)receiverSaveClicked:(id)sender //'저장'
{
    [textField_receiver resignFirstResponder];
    if([texts_array count]>0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"리스트 저장하기" message:@"제목을 입력하세요" delegate:self cancelButtonTitle:@"취 소" otherButtonTitles:@"저 장", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"먼저 리스트에 번호를 추가하세요" message:nil delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
        [alert show];
    }
}
-(void)delBtnClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    CGPoint point = [btn.superview convertPoint:btn.center toView:tableView_receiver];
    int index = (int)([texts_array count]-[tableView_receiver indexPathForRowAtPoint:point].row-1); //reverse order
    [texts_array removeObjectAtIndex:index];
    [phones_array removeObjectAtIndex:index];
    [tableView_receiver reloadData];
}
- (IBAction)receiverCloseClicked:(id)sender //'닫기'
{
    if(1==[texts_array count]) textView_receiver.text = [texts_array objectAtIndex:0];
    else if([texts_array count]>1) textView_receiver.text = [NSString stringWithFormat:@"'%@'외 %d명", [texts_array lastObject], (int)([texts_array count]-1)];
    else textView_receiver.text = @"";
    [textField_receiver resignFirstResponder];
    view_receiver.hidden = YES;
    containerView.hidden = NO;
    //label_node
    /*
    NSUInteger bytes = [textView.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if(0==bytes)
    {
        nodes = 0;
        [label_node setText:[NSString stringWithFormat:@"%d 노드 (/%d 노드)",nodes, first.node]];
    }
    else if(bytes>0 && bytes<=120) //단문
    {
        nodes = (int)[texts_array count] * 1;
        [label_node setText:[NSString stringWithFormat:@"%d 노드 (/%d 노드)",nodes, first.node]];
    }
    else if(bytes>120 && bytes<=2500) //장문
    {
        nodes = (int)[texts_array count] * 2;
        [label_node setText:[NSString stringWithFormat:@"%d 노드 (/%d 노드)",nodes, first.node]];
    }
    else //초과 오류
    {
        nodes = 0;
        [label_node setText:[NSString stringWithFormat:@"%d 노드 (/%d 노드)",nodes, first.node]];
    }
    */
    nodes = (int)[texts_array count] * 1;
    [label_node setText:[NSString stringWithFormat:@"%d 노드 사용 (/%d 노드)",nodes, first.node]];
    if(nodes>first.node) [label_node setTextColor:[UIColor redColor]];
    else [label_node setTextColor:[UIColor darkGrayColor]];
}
//textView_receiver delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField==textView_receiver) return NO;
    else return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField==textField_receiver)
    {
        [textField_receiver resignFirstResponder];
    }
    return YES;
}









//alertView
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:@"리스트 저장하기"] && (buttonIndex==alertView.firstOtherButtonIndex))
    {
        NSMutableArray *titles_array;
        NSMutableArray *texts_arrayOfArray;
        NSMutableArray *phones_arrayOfArray;
        NSMutableArray *dates_array;
        //file load
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:TITLES];
        if([manager fileExistsAtPath:filePath])
        {
            //load from files
            titles_array = [NSMutableArray arrayWithContentsOfFile:filePath];
            texts_arrayOfArray = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:TEXTS]];
            phones_arrayOfArray = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:PHONES]];
            dates_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:DATES]];
        }
        else
        {
            titles_array = [NSMutableArray array];
            texts_arrayOfArray = [NSMutableArray array];
            phones_arrayOfArray = [NSMutableArray array];
            dates_array = [NSMutableArray array];
        }
        //save(역순)
        [titles_array insertObject:[alertView textFieldAtIndex:0].text atIndex:0];
        [texts_arrayOfArray insertObject:[NSArray arrayWithArray:texts_array] atIndex:0];
        [phones_arrayOfArray insertObject:[NSArray arrayWithArray:phones_array] atIndex:0];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy.MM.dd"];
        NSString *nowDate = [formatter stringFromDate:[NSDate date]];
        [dates_array insertObject:nowDate atIndex:0];
        [titles_array writeToFile:filePath atomically:YES];
        [texts_arrayOfArray writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:TEXTS] atomically:YES];
        [phones_arrayOfArray writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:PHONES] atomically:YES];
        [dates_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:DATES] atomically:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"저장되었습니다" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [alert show];
        [self performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:1.0f];
    }
    else if([alertView.title isEqualToString:@"이 항목을 삭제하시겠습니까?"] && (buttonIndex==alertView.firstOtherButtonIndex))
    {
        /*
        int index = (int)([names_history_array count]-index_history-1);
        HistoryCell *cell = (HistoryCell *)[tableView_history cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [cell.label_send removeFromSuperview];
        cell.label_send = nil;
        [cell.imageView removeFromSuperview];
        cell.imageView = nil;
        [cell.label_name removeFromSuperview];
        cell.label_name = nil;
        */
        [names_history_array removeObjectAtIndex:index_history];
        [dates_history_array removeObjectAtIndex:index_history];
        [sends_history_array removeObjectAtIndex:index_history];
        [texts_history_array removeObjectAtIndex:index_history];
        if(0==[names_history_array count]) tableView_history.hidden = YES;
        else [tableView_history performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        //files
        [names_history_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:NAMES_HIS] atomically:YES];
        [dates_history_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:DATES_HIS] atomically:YES];
        [sends_history_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:SENDS_HIS] atomically:YES];
        [texts_history_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:TEXTS_HIS] atomically:YES];
    }
    else if([alertView.title isEqualToString:@"전송하시겠습니까?"])
    {
        if(buttonIndex==alertView.firstOtherButtonIndex)
        {
            [indicator startAnimating];
            [NSThread detachNewThreadSelector:@selector(btnInputClicked2:) toTarget:self withObject:[NSArray arrayWithObjects:str_send1, str_send2, str_send3, nil]];
        }
        else
        {
            inputBtn.enabled = YES;
            inputBtn.alpha = 1.0f;
        }
    }
}
-(void)dismissAlertView:(UIAlertView *)alert
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}







//tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView==tableView_receiver) return 0.0f;
    else return 15.0f;
}
/*
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tableView==tableView_receiver) return nil;
    else return @"블라인드 문자 히스토리";
}
*/
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(tableView==tableView_receiver) return nil;
    else
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 15.0f)];
        headerView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:0.5f];
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 3.0f, self.view.frame.size.width-10.0f, 10.0f)];
        [headerLabel setText:@"블라인드 문자 히스토리"];
        [headerLabel setTextAlignment:NSTextAlignmentLeft];
        [headerLabel setTextColor:[UIColor darkGrayColor]];
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        [headerLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [headerView addSubview:headerLabel];
        return headerView;
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView==tableView_receiver) return [texts_array count];
    else return [names_history_array count];
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==tableView_receiver) return 44.0f;
    else return UITableViewAutomaticDimension;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==tableView_receiver)
    {
        //reverse order
        int index = (int)([texts_array count]-indexPath.row-1);
        BlindCell *cell = [tableView_receiver dequeueReusableCellWithIdentifier:@"BLINDCELL"];
        cell.label_num.text = [NSString stringWithFormat:@"%d", (int)(indexPath.row+1)];
        cell.label_phone.text = [texts_array objectAtIndex:index];
        [cell.btn_del addTarget:self action:@selector(delBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else
    {
        //reverse order
        int index = (int)([names_history_array count]-indexPath.row-1);
        HistoryCell *cell = [tableView_history dequeueReusableCellWithIdentifier:@"HISTORY"];
        cell.label_date.text = [dates_history_array objectAtIndex:index];
        cell.label_text.text = [texts_history_array objectAtIndex:index];
        //btn
        [cell.btn_del addTarget:self action:@selector(hisDelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.label_receiver.text = [names_history_array objectAtIndex:index];
        /*
        if(nil==cell.label_name)
        {
            NSString *str_send = [sends_history_array objectAtIndex:index];
            NSString *str_name = [names_history_array objectAtIndex:index];
            NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            style.lineBreakMode = NSLineBreakByTruncatingTail;
            style.alignment = NSTextAlignmentLeft;
            NSDictionary *att = @{NSFontAttributeName:[UIFont systemFontOfSize:14.0f], NSParagraphStyleAttributeName:style};
            CGSize size_send = [str_send sizeWithAttributes:att];
            float size_w = size_send.width;
            if(size_w>self.view.frame.size.width*0.40) size_w = self.view.frame.size.width*0.40;
            cell.label_send = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, 4.0f, size_w, 21.0f)];
            cell.label_send.font = [UIFont systemFontOfSize:14.0f];
            cell.label_send.textAlignment = NSTextAlignmentLeft;
            cell.label_send.textColor = [UIColor blackColor];
            cell.label_send.text = str_send;
            [cell.contentView addSubview:cell.label_send];
            cell.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0f+size_w+3.0f, 4.0f, 20.0f, 20.0f)];
            cell.imageView.image = img_arrow;
            [cell.contentView addSubview:cell.imageView];
            float temp_x = 8.0f+size_w+3.0f+20.0f+3.0f;
            cell.label_name = [[UILabel alloc] initWithFrame:CGRectMake(temp_x, 4.0f, self.view.frame.size.width-temp_x-3.0f, 21.0f)];
            cell.label_name.font = [UIFont systemFontOfSize:14.0f];
            cell.label_name.textAlignment = NSTextAlignmentLeft;
            cell.label_name.text = str_name;
            cell.label_name.textColor = [UIColor blackColor];
            [cell.contentView addSubview:cell.label_name];
        }
        */
        return cell;
    }
}










//history
-(void)hisDelBtnClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    CGPoint point = [btn.superview convertPoint:btn.center toView:tableView_history];
    index_history = (int)([names_history_array count]-[tableView_history indexPathForRowAtPoint:point].row-1); //reverse order
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"이 항목을 삭제하시겠습니까?" message:nil delegate:self cancelButtonTitle:@"취 소" otherButtonTitles:@"확 인", nil];
    [alert show];
}













//예약 설정 버튼
- (IBAction)reserveClicked:(id)sender
{
    [textView resignFirstResponder];
    [textView_receiver resignFirstResponder];
    //[textView_sender resignFirstResponder];
    [textField_receiver resignFirstResponder];
    [label_date setText:label_time.text];
    if([label_date.text isEqualToString:@""]) btn_del.enabled = NO;
    else btn_del.enabled = YES;
    picker_date.minimumDate = [NSDate dateWithTimeIntervalSinceNow:60.0f*12.0f];
    [picker_date setDate:[NSDate dateWithTimeIntervalSinceNow:60.0f*12.0f] animated:YES];
    view_receiver.hidden = YES;
    containerView.hidden = YES;
    view_date.hidden = NO;
}
- (IBAction)dateCancelClicked:(id)sender //[1]
{
    view_date.hidden = YES;
    containerView.hidden = NO;
}
- (IBAction)dateDeleteClicked:(id)sender //[2]
{
    str_date = @"";
    str_time = @"";
    [label_time setText:@""];
    [inputBtn setTitle:@"전 송" forState:UIControlStateNormal];
    view_date.hidden = YES;
    containerView.hidden = NO;
}
- (IBAction)dateSaveClicked:(id)sender //[3]
{
    NSDateFormatter *form1 = [[NSDateFormatter alloc] init];
    [form1 setDateFormat:@"yyyyMMdd"];
    str_date = [NSString stringWithString:[form1 stringFromDate:picker_date.date]];
    NSDateFormatter *form2 = [[NSDateFormatter alloc] init];
    [form2 setDateFormat:@"HHmm00"];
    str_time = [NSString stringWithString:[form2 stringFromDate:picker_date.date]];
    [label_time setText:[NSString stringWithFormat:@"%@년 %@월 %@일 %@시 %@분에 전송 예약됨", [str_date substringWithRange:NSMakeRange(0, 4)], [str_date substringWithRange:NSMakeRange(4, 2)], [str_date substringWithRange:NSMakeRange(6, 2)], [str_time substringWithRange:NSMakeRange(0, 2)], [str_time substringWithRange:NSMakeRange(2, 2)]]];
    [inputBtn setTitle:@"예약전송" forState:UIControlStateNormal];
    view_date.hidden = YES;
    containerView.hidden = NO;
}
















//HPGrowingTextViewDelegate(SMS)
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff2 = (growingTextView.frame.size.height - height);
    CGRect r = containerView.frame;
    r.size.height -= diff2;
    r.origin.y += diff2;
    containerView.frame = r;
}
- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    /*
    NSInteger bytes = [textView.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if(0==bytes)
    {
        inputBtn.alpha = 0.5f;
        inputBtn.enabled = NO;
        //smsType = @"";
        //label_type.text = @"단문";
        //label_percent.text = @"0%";
        nodes = 0;
        [label_node setText:[NSString stringWithFormat:@"%d 노드 (/%d 노드)",nodes, first.node]];
    }
    else if(bytes>0 && bytes<=110) //단문
    {
        inputBtn.alpha = 1.0f;
        inputBtn.enabled = YES;
        //smsType = @"";
        //label_type.text = @"단문";
        //float percent = (float)bytes/110.0f*100.0f;
        //label_percent.text = [NSString stringWithFormat:@"%d%%", (int)percent];
        nodes = (int)[texts_array count] * 1;
        [label_node setText:[NSString stringWithFormat:@"%d 노드 (/%d 노드)",nodes, first.node]];
    }
    else if(bytes>110 && bytes<=2300) //장문
    {
        inputBtn.alpha = 1.0f;
        inputBtn.enabled = YES;
        //smsType = @"L";
        //label_type.text = @"장문";
        //float percent = (float)bytes/2300.0f*100.0f;
        //label_percent.text = [NSString stringWithFormat:@"%d%%", (int)percent];
        nodes = (int)[texts_array count] * 2;
        [label_node setText:[NSString stringWithFormat:@"%d 노드 (/%d 노드)",nodes, first.node]];
    }
    else //초과 오류
    {
        inputBtn.alpha = 0.5f;
        inputBtn.enabled = NO;
        //smsType = @"";
        //label_type.text = @"장문";
        //float percent = (float)bytes/2300.0f*100.0f;
        //label_percent.text = [NSString stringWithFormat:@"%d%%", (int)percent];
        nodes = 0;
        [label_node setText:[NSString stringWithFormat:@"%d 노드 (/%d 노드)",nodes, first.node]];
    }
    */
    if(textView.text.length==0)
    {
        inputBtn.alpha = 0.5f;
        inputBtn.enabled = NO;
        nodes = 0;
        [label_node setText:[NSString stringWithFormat:@"%d 노드 사용 (/%d 노드)",nodes, first.node]];
    }
    else
    {
        inputBtn.alpha = 1.0f;
        inputBtn.enabled = YES;
        nodes = (int)[texts_array count] * 1;
        [label_node setText:[NSString stringWithFormat:@"%d 노드 사용 (/%d 노드)",nodes, first.node]];
    }
    if(nodes>first.node) [label_node setTextColor:[UIColor redColor]];
    else [label_node setTextColor:[UIColor darkGrayColor]];
}
/*
- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //textView에 어느 글을 쓰더라도 이 메소드를 호출합니다.
    if ([text isEqualToString:@"\n"])
    {
        // return키를 누루면 원래 줄바꿈이 일어나므로 \n을 입력하는데 \n을 입력하면 실행하게 합니다.
        [textView resignFirstResponder]; //키보드를 닫는 메소드입니다.
        return FALSE; //리턴값이 FALSE이면, 입력한 값이 입력되지 않습니다.
    }
    return TRUE; //평소에 경우에는 입력을 해줘야 하므로, TRUE를 리턴하면 TEXT가 입력됩니다.
}
*/








//전송 버튼
-(void)btnInputClicked:(id)sender
{
    inputBtn.enabled = NO;
    inputBtn.alpha = 0.5f;
    if(nodes<=first.node)
    {
        //(1)보내는 사람 번호
        //NSString *send1 = REP_PHONE1;
        //NSString *send2 = REP_PHONE2;
        //NSString *send3 = REP_PHONE3;
        /*
        NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        NSString *temp = [[textView_sender.text stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        if(temp.length<4 || temp.length>12)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"보내는 사람 오류" message:@"보내는 사람의 번호는 4~12자리만 가능합니다" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
            [alert show];
            inputBtn.enabled = YES;
            inputBtn.alpha = 1.0f;
            return;
        }
        else
        {
            NSRange nond = [temp rangeOfCharacterFromSet:nonDigits];
            if(0!=nond.length)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"보내는 사람 오류" message:@"보내는 사람의 번호는 숫자만 입력하세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                [alert show];
                inputBtn.enabled = YES;
                inputBtn.alpha = 1.0f;
                return;
            }
            else
            {
                int str_length = (int)[temp length];
                send2 = [temp substringWithRange:NSMakeRange(str_length-2, 2)];
                send1 = [temp substringWithRange:NSMakeRange(0, str_length-2)];
                //if(temp.length>4) send3 = [temp substringFromIndex:4];
            }
        }
        */
        //(2)받는 사람 번호(flag가 2일때만)
        //flag가 0 or 1: phone_receiver
        if(2==flag)
        {
            if(0==[phones_array count])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"받는 사람 오류" message:@"받는 사람의 번호를 입력하세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                [alert show];
                inputBtn.enabled = YES;
                inputBtn.alpha = 1.0f;
                return;
            }
            else
            {
                phone_receiver = [phones_array componentsJoinedByString:@","];
            }
        }
        str_send1 = REP_PHONE1;
        str_send2 = REP_PHONE2;
        str_send3 = REP_PHONE3;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"전송하시겠습니까?" message:nil delegate:self cancelButtonTitle:@"취 소" otherButtonTitles:@"확 인", nil];
        [alert show];
    }
    else
    {
        inputBtn.enabled = NO;
        inputBtn.alpha = 0.5f;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"노드가 부족합니다!" message:nil delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
        [alert show];
    }
}
-(void)btnInputClicked2:(NSArray *)array
{
    NSString *send1 = [array objectAtIndex:0];
    NSString *send2 = [array objectAtIndex:1];
    NSString *send3 = [array objectAtIndex:2];
    NSMutableString *str_text = [NSMutableString stringWithString:@"[마이링크]\n"];
    [str_text appendString:[textView.text stringByReplacingOccurrencesOfString:@"됬" withString:@"됐"]];
    NSString *smsType;
    NSInteger bytes = [str_text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if(bytes<=110) smsType = @"";
    else smsType = @"L";
    NSString *temp = [NSString stringWithFormat:URL1, phone_receiver, send1, send2, send3, [self stringByReplacingforJSON:str_text], smsType, str_date, str_time];
    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    if(result)
    {
        NSString *str_temp = [result objectForKey:@"result"];
        if([str_temp isEqualToString:@"success"] || [str_temp isEqualToString:@"reserved"]) //success
        {
            [indicator stopAnimating];
            //node 감소
            NSString *temp = [NSString stringWithFormat:URL2, first.myid, nodes];
            id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
            if(result)
            {
                int temp2 = [[result objectForKey:@"node"] intValue];
                if(temp2 >= 0)
                {
                    first.node = temp2;
                }
            }
            //save in history
            [names_history_array addObject:[NSString stringWithString:textView_receiver.text]];
            [sends_history_array addObject:[NSString stringWithFormat:@"%@-%@-%@", REP_PHONE1, REP_PHONE2, REP_PHONE3]];
            if([str_date length]>0) //예약
            {
                NSString *str1 = [str_date substringWithRange:NSMakeRange(0, 4)];
                NSString *str2 = [str_date substringWithRange:NSMakeRange(4, 2)];
                NSString *str3 = [str_date substringWithRange:NSMakeRange(6, 2)];
                NSString *str4 = [str_time substringWithRange:NSMakeRange(0, 2)];
                NSString *str5 = [str_time substringWithRange:NSMakeRange(2, 2)];
                NSString *str = [NSString stringWithFormat:@"%@.%@.%@ %@:%@(예약)", str1, str2, str3, str4, str5];
                [dates_history_array addObject:str];
            }
            else
            {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy.MM.dd HH:mm"];
                NSString *nowDate = [formatter stringFromDate:[NSDate date]];
                [dates_history_array addObject:nowDate];
            }
            [texts_history_array addObject:[NSString stringWithString:textView.text]];
            //files
            [names_history_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:NAMES_HIS] atomically:YES];
            [dates_history_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:DATES_HIS] atomically:YES];
            [sends_history_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:SENDS_HIS] atomically:YES];
            [texts_history_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:TEXTS_HIS] atomically:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else //fail
        {
            if([str_temp isEqualToString:@"-105"])
            {
                [indicator stopAnimating];
                inputBtn.enabled = YES;
                inputBtn.alpha = 1.0f;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"예약시간 설정 오류" message:@"예약시간을 10분 후로 다시 설정해 주세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            }
            else if([str_temp isEqualToString:@"0004"])
            {
                if([smsType isEqualToString:@"L"]) //장문
                {
                    [indicator stopAnimating];
                    inputBtn.enabled = YES;
                    inputBtn.alpha = 1.0f;
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"메시지 길이 오류" message:@"메시지 길이가 초과되었습니다" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                }
                else //단문
                {
                    //2번째 시도(장문타입으로)
                    temp = [NSString stringWithFormat:URL1, phone_receiver, send1, send2, send3, [self stringByReplacingforJSON:str_text], @"L", str_date, str_time];
                    result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
                    if(result)
                    {
                        NSString *str_temp = [result objectForKey:@"result"];
                        if([str_temp isEqualToString:@"success"] || [str_temp isEqualToString:@"reserved"]) //success
                        {
                            [indicator stopAnimating];
                            //node 감소
                            NSString *temp = [NSString stringWithFormat:URL2, first.myid, nodes];
                            id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
                            if(result)
                            {
                                int temp2 = [[result objectForKey:@"node"] intValue];
                                if(temp2 >= 0)
                                {
                                    first.node = temp2;
                                }
                            }
                            //save in history
                            [names_history_array addObject:[NSString stringWithString:textView_receiver.text]];
                            [sends_history_array addObject:[NSString stringWithFormat:@"%@-%@-%@", REP_PHONE1, REP_PHONE2, REP_PHONE3]];
                            if([str_date length]>0) //예약
                            {
                                NSString *str1 = [str_date substringWithRange:NSMakeRange(0, 4)];
                                NSString *str2 = [str_date substringWithRange:NSMakeRange(4, 2)];
                                NSString *str3 = [str_date substringWithRange:NSMakeRange(6, 2)];
                                NSString *str4 = [str_time substringWithRange:NSMakeRange(0, 2)];
                                NSString *str5 = [str_time substringWithRange:NSMakeRange(2, 2)];
                                NSString *str = [NSString stringWithFormat:@"%@.%@.%@ %@:%@(예약)", str1, str2, str3, str4, str5];
                                [dates_history_array addObject:str];
                            }
                            else
                            {
                                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                [formatter setDateFormat:@"yyyy.MM.dd HH:mm"];
                                NSString *nowDate = [formatter stringFromDate:[NSDate date]];
                                [dates_history_array addObject:nowDate];
                            }
                            [texts_history_array addObject:[NSString stringWithString:textView.text]];
                            //files
                            [names_history_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:NAMES_HIS] atomically:YES];
                            [dates_history_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:DATES_HIS] atomically:YES];
                            [sends_history_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:SENDS_HIS] atomically:YES];
                            [texts_history_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:TEXTS_HIS] atomically:YES];
                            [self dismissViewControllerAnimated:YES completion:nil];
                        }
                        else //fail
                        {
                            [indicator stopAnimating];
                            inputBtn.enabled = YES;
                            inputBtn.alpha = 1.0f;
                            if([str_temp isEqualToString:@"-105"])
                            {
                                
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"예약시간 설정 오류" message:@"예약시간을 10분 후로 다시 설정해 주세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                            }
                            else if([str_temp isEqualToString:@"0004"])
                            {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"메시지 길이 오류" message:@"메시지 길이가 초과되었습니다" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                            }
                            else
                            {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"서버 오류" message:@"잠시 후에 다시 시도해 주세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                            }
                        }
                    }
                    else
                    {
                        [indicator stopAnimating];
                        inputBtn.enabled = YES;
                        inputBtn.alpha = 1.0f;
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"서버 오류" message:@"잠시 후에 다시 시도해 주세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                    }
                }
            }
            else
            {
                [indicator stopAnimating];
                inputBtn.enabled = YES;
                inputBtn.alpha = 1.0f;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"서버 오류" message:@"잠시 후에 다시 시도해 주세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            }
        }
    }
    else
    {
        [indicator stopAnimating];
        inputBtn.enabled = YES;
        inputBtn.alpha = 1.0f;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"서버 오류" message:@"잠시 후에 다시 시도해 주세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    }
}
-(NSString *)stringByReplacingforJSON:(NSString *)str
{
    NSString *str2 = [[[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    return [NSString stringWithString:str2];
}














//keyboard
-(void)touchScreenTapped:(UITapGestureRecognizer *)tap
{
    [textView resignFirstResponder];
    //[textView_sender resignFirstResponder];
    [textView_receiver resignFirstResponder];
}
-(void)keyboardWillShow:(NSNotification *)noti
{
    CGRect rect = [[[noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSInteger keyboardHeight = (NSInteger)rect.size.height;
    float height = containerView.frame.size.height;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35];
    containerView.frame = CGRectMake(0, self.view.frame.size.height-keyboardHeight-height, self.view.frame.size.width, height);
    [UIView commitAnimations];
}
-(void)keyboardWillHide
{
    float height = containerView.frame.size.height;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.15];
    containerView.frame = CGRectMake(0, self.view.frame.size.height-height, self.view.frame.size.width, height);
    [UIView commitAnimations];
}







//취소 버튼
- (IBAction)cancelClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [textView resignFirstResponder];
        [textView_sender resignFirstResponder];
        [textView_receiver resignFirstResponder];
        [textField_receiver resignFirstResponder];
    }];
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
