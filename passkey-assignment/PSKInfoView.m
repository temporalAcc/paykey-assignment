//
//  PSKInfoView.m
//  passkey-assignment
//
//  Created by Igor Pivnyk on 31/05/2019.
//  Copyright © 2019 Igor Pivnyk. All rights reserved.
//

#import "PSKInfoView.h"

@interface PSKInfoView ()
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UILabel *label;

@end


@implementation PSKInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.tag = 1000;
        self.backgroundColor = UIColor.whiteColor;

        _label = [UILabel new];
        _label.hidden = YES;
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_label];
        [_label.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        [_label.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;

    }
    return self;
}


- (void)showErrorMessage:(NSString *)message
{
    self.hidden = NO;
    if ([self.superview isKindOfClass:UITableView.class])
    {
        UITableView *superView = (UITableView *)self.superview;
        superView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }

    _label.text = message;
    _label.hidden = NO;
}

- (void)hideError
{
    _label.text = @"";
    _label.hidden = YES;
    self.hidden = YES;
    if ([self.superview isKindOfClass:UITableView.class])
    {
        UITableView *superView = (UITableView *)self.superview;
        superView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    [self removeFromSuperview];
}

@end
