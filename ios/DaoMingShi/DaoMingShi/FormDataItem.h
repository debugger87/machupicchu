//
//  FormDataItem.h
//  DaoMingShi
//
//  Created by Qihe Bian on 1/31/15.
//  Copyright (c) 2015 machupicchu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    FormTypeText,
    FormTypeSheet,
    FormTypeDate,
} FormType;
@interface FormDataItem : NSObject
@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)NSString *key;
@property(nonatomic)FormType type;
@property(nonatomic, strong)id value;
@property(nonatomic, strong)NSArray *optionValues;
@end
