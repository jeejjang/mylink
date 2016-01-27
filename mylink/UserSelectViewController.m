//
//  UserSelectViewController.m
//  mylink
//
//  Created by JeongMin Ji on 2015. 1. 6..
//  Copyright (c) 2015년 ZANDA. All rights reserved.
//

#import "UserSelectViewController.h"

@interface UserSelectViewController ()
-(void)updateButtonStates;
@end

@implementation UserSelectViewController
@synthesize blind, name_dic, phone_dic;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tableView_user.delegate = self;
    tableView_user.dataSource = self;
    //init
    sectionTitles = [NSArray array];
    //[tableView_user setEditing:YES animated:NO];
    btnSelect.enabled = NO;
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
-(UIView *)tableView:(UITableView *)tableView2 viewForHeaderInSection:(NSInteger)section
{
    UIView *tempView = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,30)];
    tempView.backgroundColor = [UIColor whiteColor];
    UILabel *tempLabel = [[UILabel alloc]initWithFrame:CGRectMake(45,0,250,30)];
    tempLabel.backgroundColor = [UIColor clearColor];
    tempLabel.textColor = [UIColor blackColor];
    tempLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
    tempLabel.text = [sectionTitles objectAtIndex:section];
    [tempView addSubview:tempLabel];
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 1.0f)];
    imageView1.backgroundColor = [UIColor lightGrayColor];
    imageView1.alpha = 0.5f;
    [tempView addSubview:imageView1];
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 29.0f, self.view.frame.size.width, 1.0f)];
    imageView2.backgroundColor = [UIColor lightGrayColor];
    imageView2.alpha = 0.5f;
    [tempView addSubview:imageView2];
    return tempView;
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
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateButtonStates];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self updateButtonStates];
}
-(void)updateButtonStates
{
    selectedCell_array = [tableView_user indexPathsForSelectedRows];
    [btnSelect setTitle:[NSString stringWithFormat:@"선택(%d)",(int)[selectedCell_array count]]];
    if([selectedCell_array count]>0) btnSelect.enabled = YES;
    else btnSelect.enabled = NO;
}










- (IBAction)btnSelectClicked:(id)sender
{
    for(NSIndexPath *indexPath in selectedCell_array)
    {
        NSString *name = [[name_dic objectForKey:[sectionTitles objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        NSString *phone = [[phone_dic objectForKey:[sectionTitles objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        [blind.texts_array addObject:[NSString stringWithString:name]];
        [blind.phones_array addObject:[NSString stringWithString:phone]];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [blind.tableView_receiver reloadData];
    }];
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
