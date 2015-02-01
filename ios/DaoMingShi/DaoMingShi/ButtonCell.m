//
//  ButtonCell.m
//  DaoMingShi
//
//  Created by Qihe Bian on 1/31/15.
//  Copyright (c) 2015 machupicchu. All rights reserved.
//

#import "ButtonCell.h"

@implementation ButtonCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setButton:(UIButton *)button {
    if (self.button) {
        [self.button removeFromSuperview];
    }
    if (button  ) {
        [self.contentView addSubview:button];
    }
    _button = button;
}
@end
