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
