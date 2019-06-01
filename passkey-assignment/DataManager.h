//
//  DataManager.h
//  passkey-assignment
//
//  Created by Igor Pivnyk on 31/05/2019.
//  Copyright © 2019 Igor Pivnyk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataManager : NSObject
// singleton property
+ (instancetype)shared;

- (NSArray *)getRates;
- (NSArray *)getTransactions;
- (double)convertCurrencyFrom:(NSString *)first to:(NSString *)second amount:(double)amount;
+ (NSArray *)groupByKey:(NSString *)key transactions:(NSArray *)transactions;

@end

NS_ASSUME_NONNULL_END
