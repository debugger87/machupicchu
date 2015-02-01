//
//  InfoCell.m
//  DaoMingShi
//
//  Created by Qihe Bian on 1/31/15.
//  Copyright (c) 2015 machupicchu. All rights reserved.
//

#import "InfoCell.h"

@interface InfoCell ()
@property(nonatomic, weak)UIImageView *topView;
@property(nonatomic, weak)UIImageView *bottomView;
@property(nonatomic, weak)UIImageView *centerView;
@property(nonatomic, weak)UIImageView *seperatorView;
@end
@implementation InfoCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(int)type {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:self.frame];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        backgroundView.autoresizesSubviews = YES;
        
        CGFloat originY = 0;
        CGFloat centerHeight = self.frame.size.height;
        if (type == 1) {
            UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_top"]];
            view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            view.frame = CGRectMake((self.frame.size.width - view.frame.size.width)/2, originY, view.frame.size.width, view.frame.size.height);
            [backgroundView addSubview:view];
            originY = view.frame.size.height;
            centerHeight -= view.frame.size.height;
            self.topView = view;
        }
        if (type == 0 || type == 1) {
            UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_seprator"]];
            view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            view.frame = CGRectMake((self.frame.size.width - view.frame.size.width)/2, self.frame.size.height - view.frame.size.height, view.frame.size.width, view.frame.size.height);
            [backgroundView addSubview:view];
            centerHeight -= view.frame.size.height;
            self.seperatorView = view;
        }
        if (type == 2) {
            UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_bottom"]];
            view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            view.frame = CGRectMake((self.frame.size.width - view.frame.size.width)/2, self.frame.size.height - view.frame.size.height, view.frame.size.width, view.frame.size.height);
            [backgroundView addSubview:view];
            centerHeight -= view.frame.size.height;
            self.bottomView = view;
        }
        {
            UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_center"]];
            view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            view.frame = CGRectMake((self.frame.size.width - view.frame.size.width)/2, originY, view.frame.size.width, centerHeight);
            [backgroundView addSubview:view];
            self.centerView = view;
        }
        self.backgroundView = backgroundView;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 160, 10, self.frame.size.width/2 - 40, 30)];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:label];
        self.titleLabel = label;
    }
    return self;
}

- (void)setTextField:(UITextField *)textField {
    if (self.textField) {
        [self.textField removeFromSuperview];
    }
    if (textField) {
        [self.contentView addSubview:textField];
    }
    _textField = textField;
}

- (void)setDescriptionLabel:(UILabel *)descriptionLabel {
    if (self.descriptionLabel) {
        [self.descriptionLabel removeFromSuperview];
    }
    if (descriptionLabel) {
        [self.contentView addSubview:descriptionLabel];
    }
    _descriptionLabel = descriptionLabel;
}
@end
