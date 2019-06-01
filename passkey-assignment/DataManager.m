//
//  DataManager.m
//  passkey-assignment
//
//  Created by Igor Pivnyk on 31/05/2019.
//  Copyright © 2019 Igor Pivnyk. All rights reserved.
//

#import "DataManager.h"

typedef NS_ENUM(NSUInteger, DataType)
{
    DataTypeRates,
    DataTypeTransactions
};

@implementation DataManager
+ (instancetype)shared
{
    static DataManager *sharedDM = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedDM = [DataManager new];
    });
    return sharedDM;
}

//MARK: Public Methods

/*
 to avoid nested completion handlers in case of dataManager become bigger,
 methods are synchronous. If data source is slow (eg: network)
 we should use dispatch_async on client side
*/
- (NSArray *)getRates
{
    NSArray *files = [self getDataFor:DataTypeRates];
    NSArray *result = [self parseDataFilesFrom:files];
    return result;
}

- (NSArray *)getTransactions
{
    NSArray *files = [self getDataFor:DataTypeTransactions];
    NSArray *result = [self parseDataFilesFrom:files];
    sleep(3); // sumulate loading
    return result;
}

/*
 Grouping method, it is clean, so it class method
 It groups array of transactions by some key (in our case they are SKU and currency)
 */
+ (NSArray *)groupByKey:(NSString *)key transactions:(NSArray *)transactions
{
    // Getting all possible entries
    NSMutableArray *existingEntriesForKey = [NSMutableArray array];
    for (NSDictionary *transaction in transactions)
    {
        NSString *entry = transaction[key];
        if ([existingEntriesForKey containsObject:entry])
            continue;
        else
            [existingEntriesForKey addObject:entry];
    }

    // filling array with dictionary for each entry
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *entry in existingEntriesForKey)
    {
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF.%@ == %@",key, entry];
        NSArray *transactionsByKey = [transactions filteredArrayUsingPredicate:searchPredicate];
        [result addObject:@{
                            kPKATransactionGroupTitle:entry,
                            kPKATransactionGroupTransactions:transactionsByKey
                            }];
    }
    return [result copy];
}




- (double)convertCurrencyFrom:(NSString *)first to:(NSString *)second amount:(double)amount
{
    if ([first isEqualToString:second])
        return amount;

    double ratio = [self getApropriateRateFor:first and:second];
    return amount * ratio;
}

//MARK: Private methods


- (double)getApropriateRateFor:(NSString *)first and:(NSString *)second
{
    // if currencies the same ratio is 1
    if ([first isEqualToString:second]) return 1.0;

    // get rates
    NSArray *rates = [self getRates];


    // Find out if there any straight or reverse pairs of currencies

    NSPredicate *straightSearchPredicate = [NSPredicate predicateWithFormat:@"(SELF.from == %@) AND (SELF.to == %@)", first, second];
    NSPredicate *reverveSearchPredicate = [NSPredicate predicateWithFormat:@"(SELF.from == %@) AND (SELF.to == %@)", second, first];
    NSArray *straight = [rates filteredArrayUsingPredicate:straightSearchPredicate];
    NSArray *reverse = [rates filteredArrayUsingPredicate:reverveSearchPredicate];

    // no pairs found...
    if (straight.count == 0 && reverse.count == 0)
    {

        // It is not the best solution, I know...

        //getting all currencies that can be directly converted to requied currency
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF.to == %@", second];
        NSArray *arrayFrom  = [rates filteredArrayUsingPredicate:pred];

        // getting all currencies to which our first currency can be converted
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF.from == %@", first];
        NSArray *arrayTo = [rates filteredArrayUsingPredicate:pred1];

        //finding out which currency is can be used as a bridge
        NSString *intersectCurrency;
        for (NSDictionary *pair in arrayFrom)
        {
            NSString *firstCurr = pair[@"from"];
            for (NSDictionary *secondPair in arrayTo)
            {
                NSString *secondCurr = secondPair[@"to"];
                if ([secondCurr isEqualToString:firstCurr]) intersectCurrency = firstCurr;
            }
        }

        /*
         Using recursion for that case if we have to use more bridge steps
         */

        //getting ratio for first-to-bridge currency
        double firstToIntersectRation = [self getApropriateRateFor:first and:intersectCurrency];

        //geting ratio for bridge-to-second currency
        double intersectToSecondRation = [self getApropriateRateFor:intersectCurrency and:second];

        //returning first-to-second ratio
        return intersectToSecondRation * firstToIntersectRation;
    }

    // if found straight pair - just return it ,if reverse pair return 1 / ratio value
    return straight.count == 0 ? 1 / [reverse.firstObject[@"rate"] doubleValue] : [straight.firstObject[@"rate"] doubleValue];
}




/*
 Here we are getting data files and return paths to all of them.
 Source could be disk, network, etc. Just need to change implementation appropriently
*/
- (NSArray *)getDataFor:(DataType)dataType
{
    NSPredicate *filterPreciate;
    switch (dataType) {
        case DataTypeRates:
            filterPreciate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"rates"];
            break;
        case DataTypeTransactions:
            filterPreciate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", @"transactions"];
            break;
        default:
            break;
    }
    NSArray *filesArray = [[NSBundle.mainBundle pathsForResourcesOfType:@"json" inDirectory:nil] filteredArrayUsingPredicate:filterPreciate];
    return filesArray;
}

/*
 parser for files. Could be JSON or any other format
*/
- (NSArray *)parseDataFilesFrom:(NSArray *)filesToParse
{
    NSMutableArray *result = [NSMutableArray array];

    for (NSString *path in filesToParse)
    {
        NSData *dataFromFile = [NSData dataWithContentsOfFile:path];
        NSError *err;
        NSArray *parsedData = [NSJSONSerialization JSONObjectWithData:dataFromFile options:NSJSONReadingAllowFragments error:&err];
        [result addObjectsFromArray:parsedData];
    }

    return [result copy];
}
@end
