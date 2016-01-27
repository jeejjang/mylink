//
//  HiddenViewController.m
//  mylink
//
//  Created by JeongMin Ji on 2014. 10. 31..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import "HiddenViewController.h"
#import "HiddenCell2.h"

#define URL1 @"http://jeejjang.cafe24.com/link/address_add2.jsp?myid=%ld&id=%ld&name='%@'"

@interface HiddenViewController ()
-(void)addInFirstViewController;
-(void)btnShowClicked:(id)sender;
@end

@implementation HiddenViewController
@synthesize first, myid, name_hidden, phone_hidden, myLinkID_hidden;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tableView_hidden.delegate = self;
    tableView_hidden.dataSource = self;
}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    [tableView_hidden setContentInset:UIEdgeInsetsZero];
    [tableView_hidden setScrollIndicatorInsets:UIEdgeInsetsZero];
}






//tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [name_hidden count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0f;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"숨김관계는 링크찾기에서 검색되지 않습니다.\n숨김관계가 많으면 검색결과에 영향을 미칠 수 있습니다.";
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HiddenCell2 *cell = [tableView_hidden dequeueReusableCellWithIdentifier:@"HIDDEN2"];
    cell.label_name.text = [name_hidden objectAtIndex:indexPath.row];
    NSString *myPhone = [phone_hidden objectAtIndex:indexPath.row];
    NSString *temp1 = [myPhone substringToIndex:3];
    NSRange r;
    NSString *temp3;
    if(11==[myPhone length])
    {
        r = NSMakeRange(3, 4);
        temp3 = [myPhone substringFromIndex:7];
    }
    else
    {
        r = NSMakeRange(3, 3);
        temp3 = [myPhone substringFromIndex:6];
    }
    NSString *temp2 = [myPhone substringWithRange:r];
    cell.label_phone.text = [NSString stringWithFormat:@"%@-%@-%@", temp1, temp2, temp3];
    [cell.btn_show addTarget:self action:@selector(btnShowClicked:) forControlEvents:UIControlEventTouchUpInside];
    //cell.cell_id = indexPath.row;
    return cell;
}









-(void)btnShowClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    //HiddenCell2 *cell = (HiddenCell2 *)(btn.superview.superview);
    //curIndex = cell.cell_id;
    CGPoint point = [btn.superview convertPoint:btn.center toView:tableView_hidden];
    curIndex = [tableView_hidden indexPathForRowAtPoint:point].row;
    curPhone = [NSString stringWithString:[phone_hidden objectAtIndex:curIndex]];
    //curName = [NSString stringWithString:[name_hidden objectAtIndex:curIndex]];
    //curMyLinkID = [NSString stringWithString:[myLinkID_hidden objectAtIndex:curIndex]];
    //confirm
    BOOL isExist = NO;
    for(int i=0; i<[first.phone_hidden count]; i++)
    {
        NSString *phone = [first.phone_hidden objectAtIndex:i];
        if([phone isEqualToString:curPhone])
        {
            isExist = YES;
            curName = [NSString stringWithString:[first.name_hidden objectAtIndex:i]];
            curMyLinkID = [NSString stringWithString:[first.myLinkID_hidden objectAtIndex:i]];
            break;
        }
    }
    if(isExist)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:curName message:@"다시 보이게 하시겠습니까?" delegate:self cancelButtonTitle:@"취 소" otherButtonTitles:@"확 인", nil];
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"이미 삭제된 관계입니다" message:nil delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
        [name_hidden removeObjectAtIndex:curIndex];
        [phone_hidden removeObjectAtIndex:curIndex];
        [myLinkID_hidden removeObjectAtIndex:curIndex];
        [tableView_hidden reloadData];
        [alert show];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==alertView.firstOtherButtonIndex)
    {
        if(curIndex<=[name_hidden count])
        {
            [name_hidden removeObjectAtIndex:curIndex];
            [phone_hidden removeObjectAtIndex:curIndex];
            [myLinkID_hidden removeObjectAtIndex:curIndex];
            [tableView_hidden reloadData];
            [NSThread detachNewThreadSelector:@selector(addInFirstViewController) toTarget:self withObject:nil];
        }
    }
}
-(void)addInFirstViewController
{
    NSString *temp1 = [curName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *temp2 = [NSString stringWithFormat:URL1, myid, (long)[curMyLinkID longLongValue], temp1];
    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp2]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    NSString *curLogin;
    if(result)
    {
        if([[result objectForKey:@"result"] isEqualToString:@"1"])
        {
            curLogin = [NSString stringWithString:[result objectForKey:@"login"]];
            if(![curLogin isEqualToString:@"0"])
            {
                curLogin = [NSString stringWithString:[result objectForKey:@"url"]];
            }
        }
    }
    //update in FirstViewController
    [first addRelationInFirst:curName forPhone:curPhone forId:curMyLinkID forLogin:curLogin forIndex:curIndex];
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
