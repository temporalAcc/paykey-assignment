//
//  PSKInfoView.h
//  passkey-assignment
//
//  Created by Igor Pivnyk on 31/05/2019.
//  Copyright © 2019 Igor Pivnyk. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PSKInfoView : UIView
- (void)showErrorMessage:(NSString *)message;
- (void)hideError;
@end

NS_ASSUME_NONNULL_END
