//
//  ResultController.h
//  DaoMingShi
//
//  Created by Qihe Bian on 2/1/15.
//  Copyright (c) 2015 machupicchu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormDataItem.h"
#import <AVOSCloud/AVOSCloud.h>

@interface ResultController : UIViewController
@property(nonatomic, strong)NSArray *data;
@property(nonatomic, strong)AVObject *profile;
@end
