//
//  UserRankViewController.m
//  mylink
//
//  Created by JeongMin Ji on 2014. 12. 29..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import "UserRankViewController.h"

#define URL1 @"http://jeejjang.cafe24.com/link/rank_num2.jsp?id=%ld"

@interface UserRankViewController ()
-(void)updateRankThread;
@end

@implementation UserRankViewController
@synthesize myid, name_dic, myLinkID_dic;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    tableView_user.delegate = self;
    tableView_user.dataSource = self;
    //init
    sectionTitles = [NSArray array];
    name_array = [NSMutableArray array];
    rank_array = [NSMutableArray array];
    segCtrl.selectedSegmentIndex = 0;
    //rank data
    rank_dic = [NSMutableDictionary dictionary];
    [NSThread detachNewThreadSelector:@selector(updateRankThread) toTarget:self withObject:nil];
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






-(void)updateRankThread
{
    NSMutableDictionary *id_dic = [NSMutableDictionary dictionary];
    NSString *temp = [NSString stringWithFormat:URL1, myid];
    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    if(result)
    {
        NSString *temp_str = [[result objectAtIndex:0] objectForKey:@"id"];
        if(![temp_str isEqualToString:@"0"] && ![temp_str isEqualToString:@"-1"])
        {
            for(NSDictionary *item in result)
            {
                if(![[item objectForKey:@"rank"] isEqualToString:@"0"]) [id_dic setObject:[item objectForKey:@"rank"] forKey:[item objectForKey:@"id"]];
            }
            //search
            for(NSString *str in [myLinkID_dic allKeys])
            {
                NSMutableArray *temp_array = [myLinkID_dic objectForKey:str];
                NSMutableArray *temp_array2 = [NSMutableArray arrayWithCapacity:[temp_array count]];
                for(int i=0; i<[temp_array count]; i++)
                {
                    NSString *item = [temp_array objectAtIndex:i];
                    if([id_dic objectForKey:item])
                    {
                        [temp_array2 addObject:[id_dic objectForKey:item]];
                        //지수순
                        [name_array addObject:[[name_dic objectForKey:str] objectAtIndex:i]];
                        [rank_array addObject:[NSString stringWithString:[id_dic objectForKey:item]]];
                        [id_dic removeObjectForKey:item];
                    }
                    else
                    {
                        [temp_array2 addObject:@"0"];
                    }
                }
                [rank_dic setObject:temp_array2 forKey:str];
            }
        }
    }
    //sort(지수순인 경우)
    for(int i=0; i<(int)[rank_array count]-1; i++)
    {
        for(int j=0; j<(int)[rank_array count]-1; j++)
        {
            NSString *str_rank1 = [rank_array objectAtIndex:j];
            NSString *str_rank2 = [rank_array objectAtIndex:j+1];
            if([str_rank1 intValue] < [str_rank2 intValue])
            {
                //switch
                NSString *name1 = [NSString stringWithString:[name_array objectAtIndex:j]];
                NSString *name2 = [NSString stringWithString:[name_array objectAtIndex:j+1]];
                [name_array replaceObjectAtIndex:j withObject:name2];
                [rank_array replaceObjectAtIndex:j withObject:[NSString stringWithString:str_rank2]];
                [name_array replaceObjectAtIndex:j+1 withObject:name1];
                [rank_array replaceObjectAtIndex:j+1 withObject:[NSString stringWithString:str_rank1]];
            }
        }
    }
    [tableView_user performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}













//tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView2
{
    if(0==segCtrl.selectedSegmentIndex)
    {
        return [sectionTitles count];
    }
    else
    {
        return 1;
    }
}
-(CGFloat)tableView:(UITableView *)tableView2 heightForHeaderInSection:(NSInteger)section
{
    if(0==segCtrl.selectedSegmentIndex)
    {
        return 30.0f;
    }
    else return 0.0f;
}
-(NSString *)tableView:(UITableView *)tableView2 titleForHeaderInSection:(NSInteger)section
{
    if(0==segCtrl.selectedSegmentIndex)
    {
        return [sectionTitles objectAtIndex:section];
    }
    else
    {
        return nil;
    }
}
-(NSInteger)tableView:(UITableView *)tableView2 numberOfRowsInSection:(NSInteger)section
{
    if(0==segCtrl.selectedSegmentIndex)
    {
        return [[name_dic objectForKey:[sectionTitles objectAtIndex:section]] count];
    }
    else
    {
        return [name_array count];
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView2 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView_user dequeueReusableCellWithIdentifier:@"CELL_USER"];
    if(nil==cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CELL_USER"];
    }
    if(0==segCtrl.selectedSegmentIndex)
    {
        cell.textLabel.text = [[name_dic objectForKey:[sectionTitles objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        NSString *temp = [[rank_dic objectForKey:[sectionTitles objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        if([temp intValue]>0) cell.detailTextLabel.text = temp;
        else cell.detailTextLabel.text = @"";
    }
    else
    {
        cell.textLabel.text = [name_array objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [rank_array objectAtIndex:indexPath.row];
    }
    return cell;
}
-(UIView *)tableView:(UITableView *)tableView2 viewForHeaderInSection:(NSInteger)section
{
    UIView *tempView = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,30)];
    if(0==segCtrl.selectedSegmentIndex)
    {
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
    }
    else
    {
        tempView.backgroundColor = [UIColor clearColor];
    }
    return tempView;
}
//section index titles
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView2
{
    if(0==segCtrl.selectedSegmentIndex)
    {
        return sectionIndexTitles;
    }
    else
    {
        return [NSArray array];
    }
}
-(NSInteger)tableView:(UITableView *)tableView2 sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [sectionTitles indexOfObject:title];
}








//segCtrl
- (IBAction)segCtrlValueChanged:(id)sender
{
    [tableView_user reloadData];
    [tableView_user setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
}




- (IBAction)cancelClicked:(id)sender
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
