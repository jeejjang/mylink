//
//  PhoneLoadViewController.m
//  mylink
//
//  Created by JeongMin Ji on 2015. 6. 19..
//  Copyright (c) 2015년 ZANDA. All rights reserved.
//

#import "PhoneLoadViewController.h"
#import "PhoneLoadCell.h"

#define TITLES @"Documents/load_titles.plist"
#define TEXTS @"Documents/load_texts.plist"
#define PHONES @"Documents/load_phones.plist"
#define DATES @"Documents/load_dates.plist"

@interface PhoneLoadViewController ()

@end

@implementation PhoneLoadViewController
@synthesize blind;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tableView_phone.delegate = self;
    tableView_phone.dataSource = self;
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
    [tableView_phone reloadData];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    [tableView_phone setContentInset:UIEdgeInsetsZero];
    [tableView_phone setScrollIndicatorInsets:UIEdgeInsetsZero];
}








-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [titles_array count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhoneLoadCell *cell = [tableView_phone dequeueReusableCellWithIdentifier:@"PHONELOAD"];
    cell.label_title.text = [titles_array objectAtIndex:indexPath.row];
    NSArray *temp = [texts_arrayOfArray objectAtIndex:indexPath.row];
    if(1==[temp count]) cell.label_text.text = [temp objectAtIndex:0];
    else cell.label_text.text = [NSString stringWithFormat:@"'%@'외 %d명", [temp lastObject], (int)([temp count]-1)];
    cell.label_date.text = [dates_array objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}




-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [titles_array removeObjectAtIndex:indexPath.row];
    [texts_arrayOfArray removeObjectAtIndex:indexPath.row];
    [phones_arrayOfArray removeObjectAtIndex:indexPath.row];
    [dates_array removeObjectAtIndex:indexPath.row];
    [tableView_phone reloadData];
    //save in file
    [titles_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:TITLES] atomically:YES];
    [texts_arrayOfArray writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:TEXTS] atomically:YES];
    [phones_arrayOfArray writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:PHONES] atomically:YES];
    [dates_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:DATES] atomically:YES];
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSString *temp1 = [NSString stringWithString:[titles_array objectAtIndex:sourceIndexPath.row]];
    NSArray *temp2 = [NSArray arrayWithArray:[texts_arrayOfArray objectAtIndex:sourceIndexPath.row]];
    NSArray *temp3 = [NSArray arrayWithArray:[phones_arrayOfArray objectAtIndex:sourceIndexPath.row]];
    NSString *temp4 = [NSString stringWithString:[dates_array objectAtIndex:sourceIndexPath.row]];
    //remove
    [titles_array removeObjectAtIndex:sourceIndexPath.row];
    [texts_arrayOfArray removeObjectAtIndex:sourceIndexPath.row];
    [phones_arrayOfArray removeObjectAtIndex:sourceIndexPath.row];
    [dates_array removeObjectAtIndex:sourceIndexPath.row];
    //insert
    [titles_array insertObject:temp1 atIndex:destinationIndexPath.row];
    [texts_arrayOfArray insertObject:temp2 atIndex:destinationIndexPath.row];
    [phones_arrayOfArray insertObject:temp3 atIndex:destinationIndexPath.row];
    [dates_array insertObject:temp4 atIndex:destinationIndexPath.row];
    //save in file
    [titles_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:TITLES] atomically:YES];
    [texts_arrayOfArray writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:TEXTS] atomically:YES];
    [phones_arrayOfArray writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:PHONES] atomically:YES];
    [dates_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:DATES] atomically:YES];
}









//cell selection
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    curIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"리스트 불러오기" message:@"이 전화번호 리스트를 불러올까요?" delegate:self cancelButtonTitle:@"취 소" otherButtonTitles:@"확 인", nil];
    [alert show];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==alertView.firstOtherButtonIndex) //"확 인"
    {
        [blind.texts_array removeAllObjects];
        blind.texts_array = [NSMutableArray arrayWithArray:[texts_arrayOfArray objectAtIndex:curIndexPath.row]];
        [blind.phones_array removeAllObjects];
        blind.phones_array = [NSMutableArray arrayWithArray:[phones_arrayOfArray objectAtIndex:curIndexPath.row]];
        [self dismissViewControllerAnimated:YES completion:^{
            [blind.tableView_receiver reloadData];
            [blind.tableView_receiver setContentInset:UIEdgeInsetsZero];
            [blind.tableView_receiver setScrollIndicatorInsets:UIEdgeInsetsZero];
            [blind.tableView_receiver setContentOffset:CGPointMake(0.0f, 0.0f) animated:NO];
        }];
    }
}








- (IBAction)cancelClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)btnEditClicked:(id)sender
{
    tableView_phone.editing = !tableView_phone.editing;
    ((UIBarButtonItem *)sender).title = tableView_phone.editing? @"완 료" : @"편 집";
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
