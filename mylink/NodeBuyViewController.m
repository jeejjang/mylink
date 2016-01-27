//
//  NodeBuyViewController.m
//  mylink
//
//  Created by JeongMin Ji on 2015. 1. 8..
//  Copyright (c) 2015년 ZANDA. All rights reserved.
//
#import "NodeBuyViewController.h"

#define MYLINK1 @"com.zandamobile.mylink1"
#define MYLINK2 @"com.zandamobile.mylink2"
#define MYLINK3 @"com.zandamobile.mylink3"
#define MYLINK5 @"com.zandamobile.mylink5"
#define MYLINK10 @"com.zandamobile.mylink10"
#define NODE1 10
#define NODE2 21
#define NODE3 32
#define NODE5 55
#define NODE10 120

#define URL1 @"http://jeejjang.cafe24.com/link/node_plus.jsp?myid=%ld&node=%d"

@interface NodeBuyViewController ()
-(void)updateNodes:(NSString *)str_id;
@end

@implementation NodeBuyViewController
@synthesize first, third;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tableView_node.delegate = self;
    tableView_node.dataSource = self;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [label_curNode setText:[NSString stringWithFormat:@"현재 %d 노드", first.node]];
    //In App Purchase
    if ([SKPaymentQueue canMakePayments]) // 스토어가 사용 가능하다면
    {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];	// Observer를 등록한다.
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"결제 오류" message:@"잠시 후에 다시 시도하세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
            [alert show];
        }];
    }
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    [tableView_node setContentInset:UIEdgeInsetsZero];
    [tableView_node setScrollIndicatorInsets:UIEdgeInsetsZero];
}






//tableView
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"각 판매금액은 애플의 현재 가격 책정 매트릭스를 따르고 있습니다";
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView2
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView2 numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView_node dequeueReusableCellWithIdentifier:@"CELL_ID"];
    if(nil==cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CELL_ID"];
    if(0==indexPath.row)
    {
        cell.textLabel.text = @"10 노드";
        cell.detailTextLabel.text = @"$1.09";
    }
    else if(1==indexPath.row)
    {
        cell.textLabel.text = @"20+1 노드";
        cell.detailTextLabel.text = @"$2.19";
    }
    else if(2==indexPath.row)
    {
        cell.textLabel.text = @"30+2 노드";
        cell.detailTextLabel.text = @"$3.29";
    }
    else if(3==indexPath.row)
    {
        cell.textLabel.text = @"50+5 노드";
        cell.detailTextLabel.text = @"$5.49";
    }
    else
    {
        cell.textLabel.text = @"100+20 노드";
        cell.detailTextLabel.text = @"$10.99";
    }
    cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:17.0f];
    cell.detailTextLabel.textColor = [UIColor redColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}







//In App Purchase
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    tableView_node.userInteractionEnabled = NO;
    tableView_node.alpha = 0.5f;
    SKProductsRequest *productRequest;
    if(0==indexPath.row) //10 노드
    {
        productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:MYLINK1]];
    }
    else if(1==indexPath.row) //20+1 노드
    {
        productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:MYLINK2]];
    }
    else if(2==indexPath.row) //30+2 노드
    {
        productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:MYLINK3]];
    }
    else if(3==indexPath.row) //50+5 노드
    {
        productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:MYLINK5]];
    }
    else //100+20 노드
    {
        productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:MYLINK10]];
    }
    productRequest.delegate = self;
    [productRequest start];
}
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    if([response.products count] > 0)
    {
        SKProduct *product = [response.products objectAtIndex:0];
        NSLog(@"Title : %@", product.localizedTitle);
        NSLog(@"Description : %@", product.localizedDescription);
        NSLog(@"Price : %@", product.price);
        //Item 결제 요청 하기
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else
    {
        tableView_node.userInteractionEnabled = YES;
        tableView_node.alpha = 1.0f;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"결제 오류" message:@"잠시 후에 다시 시도하세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
        [alert show];
    }
    /*
    if( [response.invalidProductIdentifiers count] > 0 ) {
        NSString *invalidString = [response.invalidProductIdentifiers objectAtIndex:0];
        NSLog(@"Invalid Identifiers : %@", invalidString);
    }
    */
}
//새로운 거래가 발생되거나 갱신될때 호출
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                NSLog(@"SKPaymentTransactionStatePurchased");
                NSLog(@"Trasaction Identifier : %@", transaction.transactionIdentifier);
                NSLog(@"Trasaction Date : %@", transaction.transactionDate);
                // update stones
                [self updateNodes:transaction.payment.productIdentifier];
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"SKPaymentTransactionStateFailed");
                NSLog(@"%@", transaction.error);
                tableView_node.userInteractionEnabled = YES;
                tableView_node.alpha = 1.0f;
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                break;
            default:
                tableView_node.userInteractionEnabled = YES;
                tableView_node.alpha = 1.0f;
                break;
        }
    }
}
-(void)updateNodes:(NSString *)str_id
{
    //서버에 node값 update
    int numOfNodes;
    if([str_id isEqualToString:MYLINK1]) numOfNodes = NODE1;
    else if([str_id isEqualToString:MYLINK2]) numOfNodes = NODE2;
    else if([str_id isEqualToString:MYLINK3]) numOfNodes = NODE3;
    else if([str_id isEqualToString:MYLINK5]) numOfNodes = NODE5;
    else numOfNodes = NODE10;
    NSString *temp = [NSString stringWithFormat:URL1, first.myid, numOfNodes];
    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    if(result)
    {
        int temp2 = [[result objectForKey:@"node"] intValue];
        if(temp2 >= 0)
        {
            first.node = temp2;
        }
    }
    [label_curNode setText:[NSString stringWithFormat:@"현재 %d 노드", first.node]];
    tableView_node.userInteractionEnabled = YES;
    tableView_node.alpha = 1.0f;
}










- (IBAction)btnCloseClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
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
