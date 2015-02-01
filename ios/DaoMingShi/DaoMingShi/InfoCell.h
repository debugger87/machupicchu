//
//  InfoCell.h
//  DaoMingShi
//
//  Created by Qihe Bian on 1/31/15.
//  Copyright (c) 2015 machupicchu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoCell : UITableViewCell
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, strong)UITextField *textField;
@property(nonatomic, strong)UILabel *descriptionLabel;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(int)type;

@end
