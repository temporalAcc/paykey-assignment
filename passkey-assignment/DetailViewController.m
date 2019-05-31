//
//  DetailViewController.m
//  passkey-assignment
//
//  Created by Igor Pivnyk on 31/05/2019.
//  Copyright © 2019 Igor Pivnyk. All rights reserved.
//

#import "DetailViewController.h"



@interface DetailViewController ()
@property (nonatomic, strong)NSArray *rates;
@property (nonatomic, strong)NSArray *groupedTransactions;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _rates = [DataManager.shared getRates];
    _groupedTransactions = [DataManager groupByKey:kPKACurrency transactions:_transactions];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _groupedTransactions.count;
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
    double valueInGPB = [DataManager.shared convertFrom:cellData[kPKACurrency] to:@"GBP" amount:[cellData[kPKAAmount] doubleValue]];
    cell.textLabel.text = [NSString stringWithFormat:@"Amount in GPB: %.2f", valueInGPB];
    cell.detailTextLabel.text = @"";
    
    return cell;
}


@end
