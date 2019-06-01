//
//  DetailViewController.m
//  passkey-assignment
//
//  Created by Igor Pivnyk on 31/05/2019.
//  Copyright © 2019 Igor Pivnyk. All rights reserved.
//

#import "DetailViewController.h"



@interface DetailViewController ()
@property (nonatomic, strong)NSArray *groupedTransactions;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _groupedTransactions = [DataManager groupByKey:kPKACurrency transactions:_transactions];
    if (_groupedTransactions == nil || _groupedTransactions.count == 0)
        [self showMessage:@"No transactions"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _groupedTransactions.count ?: 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_groupedTransactions[section][kPKATransactionGroupTransactions] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _groupedTransactions[section][kPKATransactionGroupTitle];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPKADetailCellReuseID forIndexPath:indexPath];
    NSDictionary *cellData = _groupedTransactions[indexPath.section][kPKATransactionGroupTransactions][indexPath.row];
    double valueInGPB = [DataManager.shared convertCurrencyFrom:cellData[kPKACurrency] to:@"GBP" amount:[cellData[kPKAAmount] doubleValue]];
    cell.textLabel.text = [NSString stringWithFormat:@"Amount in GPB: %.2f", valueInGPB];
    cell.detailTextLabel.text = @"";
    
    return cell;
}

- (void)showMessage:(NSString *)message
{
    PSKInfoView *infoView = [[PSKInfoView alloc] initWithFrame:self.tableView.frame];
    [self.tableView addSubview:infoView];
    [infoView showErrorMessage:message];
}

@end
