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
+ (instancetype)shared;


- (NSArray *)getRates;
- (NSArray *)getTransactions;

@end

NS_ASSUME_NONNULL_END
