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
@property (nonatomic, strong) PSKInfoView *infoView; //info view for errors
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _infoView = [[PSKInfoView alloc] initWithFrame:self.tableView.frame];
    [self loadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _transactions.count ?: 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPKAMainCellReuseID forIndexPath:indexPath];
    /*
     _transactions array is filled with dictionaries with SKUNumber
     and corresponding array of transactions for that sku
     */
    NSString *SKUNumber = _transactions[indexPath.row][kPKATransactionGroupTitle];
    NSUInteger transactionsCount = [_transactions[indexPath.row][kPKATransactionGroupTransactions] count];

    cell.textLabel.text = [NSString stringWithFormat:@"SKU: %@", SKUNumber];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Tr. Count: %ld", transactionsCount];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellData = _transactions[indexPath.row];
    // getting data for selected product and triggering segue
    [self performSegueWithIdentifier:kPKADetailViewSegue
                              sender:@{
                                       @"title":cellData[kPKATransactionGroupTitle],
                                       @"data":cellData[kPKATransactionGroupTransactions]
                                       }];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kPKADetailViewSegue])
    {
        // passing data to detail view controller and setting its title
        DetailViewController *vc = (DetailViewController *)segue.destinationViewController;
        NSDictionary *data = (NSDictionary *)sender;
        vc.navigationItem.title = data[@"title"];
        vc.transactions = data[@"data"];
    }

}
- (IBAction)refresh:(UIRefreshControl *)sender {
    [_infoView hideError];
    [self loadData];
}

- (void)loadData
{
    [self.refreshControl beginRefreshing];
    /*
     In case we have slow data connetion or big file
     better to make loading asynchronous
     */

    // avoiding leaks (in dispatch it is not necessary, but i don't like warnings)
    typeof(self) __weak weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        typeof(self) __strong strongSelf = weakSelf;

        //getting data
        NSArray *allTransactions = [DataManager.shared getTransactions];

        // if no data recieved - showing error
        if (allTransactions == nil || allTransactions.count == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.refreshControl endRefreshing];
                [strongSelf.tableView addSubview:strongSelf.infoView];
                [strongSelf.infoView showErrorMessage:@"No data, pull to refresh"];
            });
        }
        else
        {
            // if data recieved grouping data by product number
            strongSelf.transactions = [DataManager groupByKey:kPKASKU transactions:allTransactions];

            // Update Table
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.refreshControl endRefreshing];
                [strongSelf.tableView reloadData];
            });
        }
    });
}

@end
