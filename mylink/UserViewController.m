//
//  UserViewController.m
//  mylink
//
//  Created by JeongMin Ji on 2014. 11. 4..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import "UserViewController.h"


@interface UserViewController ()

@end

@implementation UserViewController
@synthesize second, flag, name_dic, phone_dic, myLinkID_dic;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    tableView_user.delegate = self;
    tableView_user.dataSource = self;
    //init
    sectionTitles = [NSArray array];
}




-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    sectionTitles = [[name_dic allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    sectionIndexTitles = [NSMutableArray array];
    for(NSString *str in sectionTitles)
    {
        [sectionIndexTitles addObject:str];
        [sectionIndexTitles addObject:@""];
    }
}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    [tableView_user setContentInset:UIEdgeInsetsZero];
    [tableView_user setScrollIndicatorInsets:UIEdgeInsetsZero];
}






-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView2
{
    return [sectionTitles count];
}
-(CGFloat)tableView:(UITableView *)tableView2 heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}
-(NSInteger)tableView:(UITableView *)tableView2 numberOfRowsInSection:(NSInteger)section
{
    return [[name_dic objectForKey:[sectionTitles objectAtIndex:section]] count];
}
-(NSString *)tableView:(UITableView *)tableView2 titleForHeaderInSection:(NSInteger)section
{
    return [sectionTitles objectAtIndex:section];
}
-(UITableViewCell *)tableView:(UITableView *)tableView2 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView_user dequeueReusableCellWithIdentifier:@"CELL_USER"];
    if(nil==cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CELL_USER"];
    }
    cell.textLabel.text = [[name_dic objectForKey:[sectionTitles objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [[phone_dic objectForKey:[sectionTitles objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    return cell;
}
//section index titles
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView2
{
    return sectionIndexTitles;
}
-(NSInteger)tableView:(UITableView *)tableView2 sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [sectionTitles indexOfObject:title];
}
//cell selection
-(void)tableView:(UITableView *)tableView2 didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(1==flag)
    {
        NSString *phone = [[phone_dic objectForKey:[sectionTitles objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        second.phone1 = [NSString stringWithString:phone];
        second.btn_search2.enabled = YES;
        second.textField1.textColor = [UIColor blackColor];
        second.textField1.text = [NSString stringWithString:phone];
        second.label1.text = [NSString stringWithString:[[name_dic objectForKey:[sectionTitles objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]];
    }
    else
    {
        /*
        NSString *phone = [[phone_dic objectForKey:[sectionTitles objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        second.phone2 = [NSString stringWithString:phone];
        second.isTextField2OK = YES;
        if((0!=second.phone1.length && second.isTextField1OK) || 0==second.phone1.length) second.btn_search2.enabled = YES;
        else second.btn_search2.enabled = NO;
        second.textField2.textColor = [UIColor blackColor];
        second.textField2.text = [NSString stringWithString:phone];
        second.label2.text = [NSString stringWithString:[[name_dic objectForKey:[sectionTitles objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]];
        */
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}







- (IBAction)cancelClicked:(id)sender
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
