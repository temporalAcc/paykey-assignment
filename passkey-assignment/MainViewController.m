//
//  MainViewController.m
//  passkey-assignment
//
//  Created by Igor Pivnyk on 31/05/2019.
//  Copyright © 2019 Igor Pivnyk. All rights reserved.
//

#import "MainViewController.h"



@interface MainViewController ()
@property (nonatomic, strong) NSArray *transactions;
@property (nonatomic, strong) PSKInfoView *infoView;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _infoView = [[PSKInfoView alloc] initWithFrame:self.tableView.frame];
    [self.tableView addSubview:_infoView];
    [_infoView showLoadingIndicator];
    typeof(self) __weak weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        typeof(self) __strong strongSelf = weakSelf;
        NSArray *allTransactions = [DataManager.shared getTransactions];
        sleep(3);
        if (allTransactions == nil || allTransactions.count == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.infoView showErrorMessage:@"No data"];
            });
        }
        else
        {
            strongSelf.transactions = [DataManager groupByKey:kPKASKU transactions:allTransactions];

            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.infoView hideLoadingIndicator];
                [strongSelf.tableView reloadData];
            });
        }
    });



}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _transactions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPKAMainCellReuseID forIndexPath:indexPath];
    NSString *titleForCell = _transactions[indexPath.row][kPKATransactionGroupTitle];
    NSUInteger transactionsCount = [_transactions[indexPath.row][kPKATransactionGroupTransactions] count];

    cell.textLabel.text = [NSString stringWithFormat:@"SKU: %@", titleForCell];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Tr. Count: %ld", transactionsCount];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellData = _transactions[indexPath.row];
    [self performSegueWithIdentifier:kPKADetailViewSegue
                              sender:@{
                                       @"title":cellData[kPKATransactionGroupTitle],
                                       @"data":cellData[kPKATransactionGroupTransactions]
                                       }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kPKADetailViewSegue])
    {
        DetailViewController *vc = (DetailViewController *)segue.destinationViewController;
        NSDictionary *data = (NSDictionary *)sender;
        vc.navigationItem.title = data[@"title"];
        vc.transactions = data[@"data"];
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}




@end
