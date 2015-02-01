//
//  PhotoCell.m
//  DaoMingShi
//
//  Created by Qihe Bian on 1/31/15.
//  Copyright (c) 2015 machupicchu. All rights reserved.
//

#import "PhotoCell.h"
#import "UIImageView+WebCache.h"

@implementation PhotoCell

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
- (void)setPhotoView:(UIImageView *)photoView {
    if (self.photoView) {
        [self.photoView removeFromSuperview];
    }
    if (photoView) {
        [self.contentView addSubview:photoView];
    }
    _photoView = photoView;
}

@end
