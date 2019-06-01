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

// Public Methods

- (NSArray *)getRates
{
    NSArray *files = [self getDataFor:DataTypeRates];
    NSArray *result = [self parseJSONFilesFrom:files];
    return result;
}

- (NSArray *)getTransactions
{
    NSArray *files = [self getDataFor:DataTypeTransactions];
    NSArray *result = [self parseJSONFilesFrom:files];
    sleep(3);
    return result;
}


+ (NSArray *)filterTransactionsArray:(NSArray *)transactions ByParameter:(PSKFilterParameter)parameter andValue:(NSString *)value
{
    NSPredicate *filterPredicate;
    switch (parameter) {
        case PSKFilterParameterSKU:
            filterPredicate = [NSPredicate predicateWithFormat:@"SELF.sku == %@", value];
            break;
        case PSKFilterParameterCurrency:
            filterPredicate = [NSPredicate predicateWithFormat:@"SELF.currency == %@", value];
            break;
        default:
            break;
    }

    NSArray *result = [transactions filteredArrayUsingPredicate:filterPredicate];
    return result;
}

+ (NSArray *)groupByKey:(NSString *)key transactions:(NSArray *)transactions
{
    NSMutableArray *existingEntriesForKey = [NSMutableArray array];
    for (NSDictionary *transaction in transactions)
    {
        NSString *currency = transaction[key];
        if ([existingEntriesForKey containsObject:currency])
            continue;
        else
            [existingEntriesForKey addObject:currency];
    }

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




- (double)convertFrom:(NSString *)first to:(NSString *)second amount:(double)amount
{
    if ([first isEqualToString:second])
        return amount;

    double ratio = [self getApropriateRateFor:first and:second];

    return amount * ratio;
}

- (double)getApropriateRateFor:(NSString *)first and:(NSString *)second
{
    if ([first isEqualToString:second]) return 1.0;
    NSArray *rates = [self getRates];
    NSPredicate *straightSearchPredicate = [NSPredicate predicateWithFormat:@"(SELF.from == %@) AND (SELF.to == %@)", first, second];
    NSPredicate *reverveSearchPredicate = [NSPredicate predicateWithFormat:@"(SELF.from == %@) AND (SELF.to == %@)", second, first];

    NSArray *straight = [rates filteredArrayUsingPredicate:straightSearchPredicate];
    NSArray *reverse = [rates filteredArrayUsingPredicate:reverveSearchPredicate];
    if (straight.count == 0 && reverse.count == 0)
    {

        // This is ugly, I know that....

        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF.to == %@", second];
        NSArray *arrayFrom  = [rates filteredArrayUsingPredicate:pred];

        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF.from == %@", first];
        NSArray *arrayTo = [rates filteredArrayUsingPredicate:pred1];

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

        double firstToIntersectRation = [self getApropriateRateFor:first and:intersectCurrency];
        double intersectToSecondRation = [self getApropriateRateFor:intersectCurrency and:second];
        return intersectToSecondRation * firstToIntersectRation;
    }

    return straight.count == 0 ? 1 / [reverse.firstObject[@"rate"] doubleValue] : [straight.firstObject[@"rate"] doubleValue];
}


// Private methods


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

- (NSArray *)parseJSONFilesFrom:(NSArray *)filesToParse
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
