//
//  ThirdViewController.m
//  mylink
//
//  Created by JeongMin Ji on 2014. 12. 1..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//


#define VER @"1.0.14"


#import "ThirdViewController.h"
#import "MoreCell_Des.h"
#import "UserRankViewController.h"
#import "BlindSMSViewController.h"
#import "NodeBuyViewController.h"
#import "UserAuthor_ViewController.h"
#import "IntroViewController.h"

#define LINKRESULTS @"Documents/mylink_results.plist"
#define LINKIMGS @"Documents/mylink_imgs.plist"
#define LINKIMGSIZES @"Documents/mylink_imgsizes.plist"
#define LINKPHONES @"Documents/mylink_phones.plist"
#define LINKNAMES @"Documents/mylink_names.plist"
#define LINKCLICKS @"Documents/mylink_clicks.plist"
#define LINKSORTS @"Documents/mylink_sorts.plist"
#define LINKDATES @"Documents/mylink_dates.plist"
#define LINKPOS @"Documents/mylink_pos.plist"
#define IMGS @"Documents/imgs/"

#define URL2 @"http://jeejjang.cafe24.com/link/rank_num.jsp?id=%ld"
#define URL3 @"http://jeejjang.cafe24.com/link/link_ver_ios.jsp"
#define URL4 @"http://jeejjang.cafe24.com/link/address_del2.jsp?myid=%ld"
#define URL5 @"http://jeejjang.cafe24.com/link/node_info.jsp?myid=%ld"
#define URL6 @"http://jeejjang.cafe24.com/link/node_minus.jsp?myid=%ld&node=%d"
#define URL7 @"http://jeejjang.cafe24.com/link/noresult_del2.jsp?myid=%ld"

@interface ThirdViewController ()
-(void)updateThread;
-(void)reloadCell:(NSIndexPath *)indexPath;
@end

@implementation ThirdViewController
@synthesize first;
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    //image
    more_blind = [UIImage imageNamed:@"more_blind"];
    more_node = [UIImage imageNamed:@"more_node"];
    more_up = [UIImage imageNamed:@"more_up"];
    more_up2 = [UIImage imageNamed:@"more_up2"];
    more_version = [UIImage imageNamed:@"more_version"];
    more_story = [UIImage imageNamed:@"more_story"];
    more_privacy = [UIImage imageNamed:@"more_privacy"];
    more_email = [UIImage imageNamed:@"more_email"];
    more_out = [UIImage imageNamed:@"more_out"];
    //init
    myNumOfRelations = @"";
    version = @"";
}







-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //현재 나의 노드 개수, 검색 횟수 refresh
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:0],[NSIndexPath indexPathForRow:2 inSection:0],nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    //관계지수, node, 버전정보 update
    [NSThread detachNewThreadSelector:@selector(updateThread) toTarget:self withObject:nil];
}








-(void)updateThread
{
    //node
    NSString *temp = [NSString stringWithFormat:URL5, first.myid];
    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    if(result)
    {
        if(![[result objectForKey:@"node"] isEqualToString:@"-1"])
        {
            first.node = [[result objectForKey:@"node"] intValue];
            [self performSelectorOnMainThread:@selector(reloadCell:) withObject:[NSIndexPath indexPathForRow:1 inSection:0] waitUntilDone:NO];
        }
    }
    //현재 나의 관계지수
    temp = [NSString stringWithFormat:URL2, first.myid];
    id result2 = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    if(result2)
    {
        if(![[result2 objectForKey:@"result"] isEqualToString:@"-1"])
        {
            myNumOfRelations = [NSString stringWithString:[result2 objectForKey:@"result"]];
            first.rank = [myNumOfRelations intValue];
            [self performSelectorOnMainThread:@selector(reloadCell:) withObject:[NSIndexPath indexPathForRow:0 inSection:1] waitUntilDone:NO];
        }
    }
    //version
    result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:URL3]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    if(result)
    {
        if(![[result objectForKey:@"result"] isEqualToString:@"-1"])
        {
            NSString *temp = [NSString stringWithString:[result objectForKey:@"result"]];
            if([temp isEqualToString:VER])
            {
                version = [NSString stringWithFormat:@"%@(최신버전)",VER];
            }
            else
            {
                version = [NSString stringWithFormat:@"%@(최신버전아님)",VER];
            }
            [self performSelectorOnMainThread:@selector(reloadCell:) withObject:[NSIndexPath indexPathForRow:0 inSection:2] waitUntilDone:NO];
        }
    }
}
-(void)reloadCell:(NSIndexPath *)indexPath
{
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}









#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(0==section) return 4;
    else if(1==section) return 2;
    else if(2==section) return 4;
    else return 1;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(1==section) return @"관계 분석";
    else return nil;
}
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(0==section) return @"검색 횟수는 1시간마다 1개씩 자동으로 채워집니다";
    else return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(1==indexPath.section && 0==indexPath.row) return 60.0f;
    else return 44.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(0==indexPath.section)
    {
        if(0==indexPath.row)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MORE1_1"];
            if(nil==cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MORE1_1"];
            cell.imageView.image = more_blind;
            cell.textLabel.text = @"블라인드 문자 보내기";
            cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
            cell.detailTextLabel.text = @"보내는 사람의 번호를 바꾸어서 문자를 보낼 수 있습니다";
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:10.0f];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        else if(1==indexPath.row)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MORE1_2"];
            if(nil==cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MORE1_2"];
            cell.imageView.image = more_node;
            cell.textLabel.text = @"노드 구입하기";
            cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
            if(first.node>=0) cell.detailTextLabel.text = [NSString stringWithFormat:@"현재 %d 노드", first.node];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
            cell.detailTextLabel.textColor = [UIColor darkGrayColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        else if(2==indexPath.row)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MORE1_3"];
            if(nil==cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MORE1_3"];
            cell.imageView.image = more_up;
            cell.textLabel.text = @"검색 횟수 리필 (3노드)";
            cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"현재 %d회", first.curSearchNum];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0f];
            cell.detailTextLabel.textColor = [UIColor darkGrayColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        else
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MORE1_4"];
            if(nil==cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MORE1_4"];
            cell.imageView.image = more_up2;
            cell.textLabel.text = @"최대 검색 횟수 +1 (10노드)";
            cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"현재 %d회", first.maxSearchNum];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0f];
            cell.detailTextLabel.textColor = [UIColor darkGrayColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }
    else if(1==indexPath.section)
    {
        if(0==indexPath.row)
        {
            MoreCell_Des *cell = [tableView dequeueReusableCellWithIdentifier:@"MORE_RELATION"];
            cell.cell_label_num.text = myNumOfRelations;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MORE2_2"];
            if(nil==cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MORE2_2"];
            cell.textLabel.text = @"내가 아는 사람들의 관계지수";
            cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
            cell.imageView.image = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }
    else if(2==indexPath.section)
    {
        if(0==indexPath.row)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MORE3_1"];
            if(nil==cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MORE3_1"];
            cell.imageView.image = more_version;
            cell.textLabel.text = @"버전 정보";
            cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
            cell.detailTextLabel.text = version;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
            cell.detailTextLabel.textColor = [UIColor darkGrayColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else if(1==indexPath.row)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MORE3_2"];
            if(nil==cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MORE3_2"];
            cell.imageView.image = more_story;
            cell.textLabel.text = @"마이링크 소개";
            cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        else if(2==indexPath.row)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MORE3_3"];
            if(nil==cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MORE3_3"];
            cell.imageView.image = more_privacy;
            cell.textLabel.text = @"개인정보 이용 안내";
            cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        else
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MORE3_4"];
            if(nil==cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MORE3_4"];
            cell.imageView.image = more_email;
            cell.textLabel.text = @"관리자에게 이메일 보내기";
            cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MORE4_1"];
        if(nil==cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MORE4_1"];
        cell.imageView.image = more_out;
        cell.textLabel.text = @"마이링크 탈퇴하기";
        cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
        cell.detailTextLabel.text = @"나의 관계정보가 모두 삭제되고, 앱이 초기화 됩니다";
        cell.detailTextLabel.font = [UIFont systemFontOfSize:11.0f];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
}
















//cell selection
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(0==indexPath.section && 0==indexPath.row) //블라인드 문자보내기
    {
        BlindSMSViewController *blind = [self.storyboard instantiateViewControllerWithIdentifier:@"BLIND"];
        blind.first = first;
        blind.flag = 2;
        blind.text_receiver = @"";
        [self presentViewController:blind animated:YES completion:nil];
    }
    else if(0==indexPath.section && 1==indexPath.row) //노드 구입하기
    {
        NodeBuyViewController *node = [self.storyboard instantiateViewControllerWithIdentifier:@"NODE"];
        node.first = first;
        node.third = self;
        [self presentViewController:node animated:YES completion:nil];
    }
    else if(0==indexPath.section && 2==indexPath.row) //검색 가능 횟수 채우기
    {
        if(first.curSearchNum!=first.maxSearchNum)
        {
            if(first.node<3)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"노드가 부족합니다!" message:nil delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"검색 횟수 리필" message:@"3노드로 구매하시겠습니까?" delegate:self cancelButtonTitle:@"취 소" otherButtonTitles:@"확 인", nil];
                [alert show];
            }
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"현재 완전히 채워져 있습니다" message:nil delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
            [alert show];
        }
    }
    else if(0==indexPath.section && 3==indexPath.row) //최대 검색 횟수 +1
    {
        if(first.node<10)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"노드가 부족합니다!" message:nil delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"최대 검색 횟수 +1" message:@"10노드로 구매하시겠습니까?" delegate:self cancelButtonTitle:@"취 소" otherButtonTitles:@"확 인", nil];
            [alert show];
        }
    }
    else if(1==indexPath.section && 1==indexPath.row) //현재 내가 아는 사람들의 관계지수
    {
        UserRankViewController *rank = [self.storyboard instantiateViewControllerWithIdentifier:@"USERRANK"];
        rank.myid = first.myid;
        rank.myLinkID_dic = first.myLinkID_dic;
        rank.name_dic = first.name_dic;
        [self presentViewController:rank animated:YES completion:nil];
    }
    else if(2==indexPath.section && 1==indexPath.row) //마이링크 소개
    {
        IntroViewController *intro = [self.storyboard instantiateViewControllerWithIdentifier:@"INTRO"];
        intro.str_url = @"http://m.blog.naver.com/jeejjang/220548493007";
        [self presentViewController:intro animated:YES completion:nil];
    }
    else if(2==indexPath.section && 2==indexPath.row) //개인정보 이용 안내
    {
        UserAuthor_ViewController *author = [self.storyboard instantiateViewControllerWithIdentifier:@"USERAUTHOR"];
        [self presentViewController:author animated:YES completion:nil];
    }
    else if(2==indexPath.section && 3==indexPath.row)//관리자에게 이메일 보내기
    {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc]init];
        picker.mailComposeDelegate = self;
        if ([MFMailComposeViewController canSendMail])
        {
            [picker setToRecipients:[NSArray arrayWithObjects:@"mylink.linker@gmail.com", nil]];  //받는 사람(배열의 형태로 넣어도 됩니다. )
            //[picker setSubject:nil];  //제목
            //[picker setMessageBody:nil isHTML:NO];     //내용
            [self presentViewController:picker animated:YES completion:nil];
        }
    }
    else if(3==indexPath.section && 0==indexPath.row)  //마이링크 탈퇴하기
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"마이링크 탈퇴" message:@"정말로 탈퇴하시겠습니까?" delegate:self cancelButtonTitle:@"취 소" otherButtonTitles:@"확 인", nil];
        [alert show];
    }
}




//email delegate
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:  // 취소.
        {
            break;
        }
        case MFMailComposeResultFailed: // 실패.
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"메시지 전송 실패" message:@"잠시 후에 다시 시도하세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
            [alert show];
            break;
        }
        case MFMailComposeResultSent:   //성공.
        {
            break;
        }
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];    
}





//alertView
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:@"검색 횟수 리필"])
    {
        if(buttonIndex==alertView.firstOtherButtonIndex)
        {
            //node
            NSString *temp = [NSString stringWithFormat:URL6, first.myid, 3];
            id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
            if(result)
            {
                int temp2 = [[result objectForKey:@"node"] intValue];
                if(temp2 >= 0)
                {
                    first.node = temp2;
                }
            }
            //first
            if(first.timer_search)
            {
                [first.timer_search invalidate];
                first.timer_search = nil;
            }
            first.curSearchNum = first.maxSearchNum;
            first.searchNumSavedDate = [NSDate date];
            //save
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[NSNumber numberWithInt:first.curSearchNum] forKey:@"cursearch"];
            [defaults setObject:first.searchNumSavedDate forKey:@"searchsaveddate"];
            [defaults synchronize];
            //reload cell
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    else if([alertView.title isEqualToString:@"최대 검색 횟수 +1"])
    {
        if(buttonIndex==alertView.firstOtherButtonIndex)
        {
            //node
            NSString *temp = [NSString stringWithFormat:URL6, first.myid, 10];
            id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
            if(result)
            {
                int temp2 = [[result objectForKey:@"node"] intValue];
                if(temp2 >= 0)
                {
                    first.node = temp2;
                }
            }
            first.maxSearchNum += 1;
            first.curSearchNum += 1;
            //save
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[NSNumber numberWithInt:first.maxSearchNum] forKey:@"maxsearch"];
            [defaults setObject:[NSNumber numberWithInt:first.curSearchNum] forKey:@"cursearch"];
            [defaults synchronize];
            //reload cell
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    else if([alertView.title isEqualToString:@"마이링크 탈퇴"])
    {
        if(buttonIndex==alertView.firstOtherButtonIndex)
        {
            NSString *temp = [NSString stringWithFormat:URL4, first.myid];
            id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
            if(result)
            {
                if([[result objectForKey:@"result"] isEqualToString:@"1"])
                {
                    //delete from noresult table(delete push)
                    NSString *temp = [NSString stringWithFormat:URL7, first.myid];
                    [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
                    //카카오 로그아웃
                    [[KOSession sharedSession] logoutAndCloseWithCompletionHandler:^(BOOL success, NSError *error)
                     {
                         //
                     }];
                    //라이브러리 삭제
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults removeObjectForKey:@"mylinkid"];
                    //파일 삭제
                    NSFileManager *manager = [NSFileManager defaultManager];
                    [manager removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:LINKRESULTS] error:NULL];
                    [manager removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGS] error:NULL];
                    [manager removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGSIZES] error:NULL];
                    [manager removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:LINKPHONES] error:NULL];
                    [manager removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:LINKNAMES] error:NULL];
                    [manager removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:LINKCLICKS] error:NULL];
                    [manager removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:LINKSORTS] error:NULL];
                    [manager removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:LINKDATES] error:NULL];
                    [manager removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:LINKPOS] error:NULL];
                    [manager removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:IMGS] error:NULL];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }
        }
    }
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
