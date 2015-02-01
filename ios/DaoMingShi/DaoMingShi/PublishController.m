//
//  PublishController.m
//  DaoMingShi
//
//  Created by Qihe Bian on 1/31/15.
//  Copyright (c) 2015 machupicchu. All rights reserved.
//

#import "PublishController.h"
#import "RSKImageCropper.h"
#import "MBProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "CameraHelper.h"
#import "UIImage+Resize.h"
#import <AVOSCloud/AVOSCloud.h>
#import "PhotoCell.h"
#import "InfoCell.h"
#import "ButtonCell.h"
#import "FormDataItem.h"
#import "ResultController.h"

@interface PublishController () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, RSKImageCropViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *headView;
@property (nonatomic, strong) AVFile *photo;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, weak) UIDatePicker *datePicker;
@end

@implementation PublishController

- (void)loadView {
    [super loadView];
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

}

- (UITableView *)tableView {
    if (!_tableView) {
        [self loadView];
    }
    return  _tableView;
}

//name
//gender enum 男 女 基 蕾丝 通吃
//birthday
//favorite 娱乐 IT 创业
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    {
        FormDataItem *item = [[FormDataItem alloc] init];
        item.title = @"姓名";
        item.key = @"name";
        item.type = FormTypeText;
        [data addObject:item];
    }
    {
        FormDataItem *item = [[FormDataItem alloc] init];
        item.title = @"性别";
        item.key = @"gender";
        item.type = FormTypeSheet;
        item.optionValues = @[@"男", @"女", @"基", @"蕾丝", @"通吃"];
        [data addObject:item];
    }
    {
        FormDataItem *item = [[FormDataItem alloc] init];
        item.title = @"生日";
        item.key = @"birthday";
        item.type = FormTypeDate;
        [data addObject:item];
    }
    {
        FormDataItem *item = [[FormDataItem alloc] init];
        item.title = @"领域";
        item.key = @"domain";
        item.type = FormTypeSheet;
        AVQuery *query = [AVQuery queryWithClassName:@"tag"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSMutableSet *optionValues = [[NSMutableSet alloc] init];
            for (AVObject *object in objects) {
                NSString *name = [object objectForKey:@"name"];
                [optionValues addObject:name];
            }
            NSMutableArray *values = [[NSMutableArray alloc] init];
            for (NSString *name in optionValues) {
                [values addObject:name];
            }
            item.optionValues = values;
            [self.tableView reloadData];
        }];
        [data addObject:item];
    }
    self.data = data;
//    originX = rect.size.width/2 - 150;
//    originY += 140;
//    width = 300;
//    height = 40;
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, width, height)];
//    label.font = [UIFont systemFontOfSize:24];
//    label.textColor = [UIColor greenColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:label];
//    self.nameLabel = label;
//    
//    originY += 80;
//    UIImage *image = [[UIImage imageNamed:@"blue_expand_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.frame = CGRectMake(originX, originY, width, height);
//    [button setBackgroundImage:image forState:UIControlStateNormal];
//    image = [[UIImage imageNamed:@"blue_expand_highlight"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
//    [button setBackgroundImage:image forState:UIControlStateHighlighted];
//    image = [[UIImage imageNamed:@"blue_expand_highlight"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
//    [button setBackgroundImage:image forState:UIControlStateDisabled];
//    [button setTitle:@"退出登录" forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    //    button.userInteractionEnabled = YES;
//    [button addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        // For insetting with a navigation bar
        CGRect rect = self.navigationController.navigationBar.frame;
        UIEdgeInsets insets = UIEdgeInsetsMake(CGRectGetMaxY(rect), 0, CGRectGetHeight(self.tabBarController.tabBar.bounds), 0);
        self.tableView.contentInset = insets;
        self.tableView.scrollIndicatorInsets = insets;
    }
}

- (void)editHeadPhoto:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    actionSheet.tag = -1;
    [actionSheet showInView:self.view];
}

- (void)tap:(id)sender {
    [self.tableView endEditing:YES];
}

- (void)dismissImagePickerController {
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [self.navigationController popToViewController:self animated:YES];
    }
}

- (void)keyboardDidShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
    int height = MIN(keyboardSize.height,keyboardSize.width);
    int width = MAX(keyboardSize.height,keyboardSize.width);
    CGRect rect = self.navigationController.navigationBar.frame;
    UIEdgeInsets insets = UIEdgeInsetsMake(CGRectGetMaxY(rect), 0, height, 0);
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
}

- (void)keyboardDidHide:(NSNotification *)notification{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
    int height = 0;
    int width = MAX(keyboardSize.height,keyboardSize.width);
    CGRect rect = self.navigationController.navigationBar.frame;
    UIEdgeInsets insets = UIEdgeInsetsMake(CGRectGetMaxY(rect), 0, height, 0);
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
}

- (void)nextStep:(id)sender {
    ResultController *controller = [[ResultController alloc] init];
    controller.data = self.data;
    
    AVObject *object = [AVObject objectWithClassName:@"profile"];
    for (FormDataItem *item in self.data) {
        [object setObject:item.value forKey:item.key];
    }
    [object setObject:self.photo forKey:@"photo"];
    controller.profile = object;
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self.navigationController pushViewController:controller animated:YES];
        }
    }];
}
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.data.count;
    } else if (section == 2) {
        return 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    if (section == 0) {
        return 200;
    } else if (section == 1) {
        return 50;
    } else if (section == 2) {
        return 50;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    int type = 0;
    if (section == 1) {
        NSInteger count = [self tableView:tableView numberOfRowsInSection:indexPath.section];
        if (indexPath.row == 0) {
            type = 1;
        } else if (indexPath.row == count - 1) {
            type = 2;
        } else {
            type = 0;
        }
    }
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%d_%d", @"CellIdentifier", (int)section, type];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        if (section == 0) {
            cell = [[PhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            PhotoCell *photoCell = (PhotoCell *)cell;
            CGRect rect = tableView.frame;
            CGFloat originX = rect.size.width/2 - 65;
            CGFloat originY = 10;
            CGFloat width = 130;
            CGFloat height = 130;
            UIImageView *headView = self.headView;
            if (!headView) {
                headView = [[UIImageView alloc] initWithFrame:CGRectMake(originX, originY, width, height)];
                [headView sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"head_default"]];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editHeadPhoto:)];
                [headView addGestureRecognizer:tap];
                [headView setUserInteractionEnabled:YES];
                self.headView = headView;
            }
            photoCell.photoView = headView;
        } else if (section == 1) {
            cell = [[InfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier type:type];
        } else if (section == 2) {
            cell = [[ButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(tableView.frame.size.width/2 - 50, 10, 100, 40);
            [button setBackgroundColor:[UIColor grayColor]];
            [button setTitle:@"下一步" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(nextStep:) forControlEvents:UIControlEventTouchUpInside];
            [(ButtonCell *)cell setButton:button];
            
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
 
    } else if (indexPath.section == 1) {
        FormDataItem *item = [self.data objectAtIndex:indexPath.row];
        InfoCell *infoCell = (InfoCell *)cell;
        [infoCell.titleLabel setText:item.title];
        if (item.type == FormTypeText) {
            UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(tableView.frame.size.width/2 - 10, 10, 120, 30)];
            field.delegate = self;
            field.tag = indexPath.row;
            field.text = item.value;
            infoCell.textField = field;
        } else {
            infoCell.textField = nil;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width/2 - 10, 10, 120, 30)];
            label.text = [item.value description];
            infoCell.descriptionLabel = label;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.datePicker) {
        [self.datePicker removeFromSuperview];
        self.datePicker = nil;
    }
    [self.tableView endEditing:YES];
    if (indexPath.section == 1) {
        FormDataItem *item = [self.data objectAtIndex:indexPath.row];
        if (item.type == FormTypeSheet) {
            UIActionSheet *actionSheet = nil;
            if ([item.key isEqualToString:@"gender"]) {
                actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择性别" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            } else if ([item.key isEqualToString:@"domain"]) {
                actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择领域" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            }
            for (NSString *v in item.optionValues) {
                [actionSheet addButtonWithTitle:v];
            }
            actionSheet.delegate = self;
            actionSheet.tag = indexPath.row;
            [actionSheet showInView:self.view];
        } else if (item.type == FormTypeDate) {
            UIDatePicker *datePicker = nil;
            if ([item.key isEqualToString:@"birthday"]) {
                datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 200, self.view.frame.size.width, 200)];
                datePicker.datePickerMode = UIDatePickerModeDate;
                datePicker.backgroundColor = [UIColor whiteColor];
            }
            if (item.value) {
                datePicker.date = item.value;
            }
            [datePicker addTarget:self action:@selector(datePicked:) forControlEvents:UIControlEventValueChanged];
            datePicker.tag = indexPath.row;
            self.datePicker = datePicker;
            [self.view addSubview:datePicker];
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    UITableViewCell *cell;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier
        cell = (UITableViewCell *) textField.superview.superview;
        
    } else {
        // Load resources for iOS 7 or later
        cell = (UITableViewCell *) textField.superview.superview.superview;
        // TextField -> UITableVieCellContentView -> (in iOS 7!)ScrollView -> Cell!
    }
    CGRect rect = self.navigationController.navigationBar.frame;
    UIEdgeInsets insets = UIEdgeInsetsMake(CGRectGetMaxY(rect), 0, CGRectGetHeight(self.tabBarController.tabBar.bounds), 0);
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    if (self.datePicker) {
        [self.datePicker removeFromSuperview];
        self.datePicker = nil;
    }
    UITableViewCell *cell;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier
        cell = (UITableViewCell *) textField.superview.superview;
        
    } else {
        // Load resources for iOS 7 or later
        cell = (UITableViewCell *) textField.superview.superview.superview;
        // TextField -> UITableVieCellContentView -> (in iOS 7!)ScrollView -> Cell!
    }
    CGRect rect = self.navigationController.navigationBar.frame;
    UIEdgeInsets insets = UIEdgeInsetsMake(CGRectGetMaxY(rect), 0, CGRectGetHeight(self.tabBarController.tabBar.bounds), 0);
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    FormDataItem *item = [self.data objectAtIndex:textField.tag];
    item.value = textField.text;
    [self.tableView reloadData];
}

- (void)datePicked:(UIDatePicker *)datePicker {
    FormDataItem *item = [self.data objectAtIndex:datePicker.tag];
    item.value = datePicker.date;
    [self.tableView reloadData];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex                {
    if (actionSheet.tag >= 0) {
        if (buttonIndex < 0) {
            return;
        }
        FormDataItem *item = [self.data objectAtIndex:actionSheet.tag];
        item.value = [item.optionValues objectAtIndex:buttonIndex];
        [self.tableView reloadData];
    } else {
    if (buttonIndex == 0) {
        // 拍照
        if ([CameraHelper isCameraAvailable] && [CameraHelper doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([CameraHelper isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            //            [self.navigationController pushViewController:controller animated:YES];
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([CameraHelper isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            //            [self.navigationController pushViewController:controller animated:YES];
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
    }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image cropMode:RSKImageCropModeSquare cropSize:CGSizeMake(256, 256)];
    imageCropVC.delegate = self;
    [self dismissViewControllerAnimated:NO completion:^{
        [self.navigationController pushViewController:imageCropVC animated:YES];
    }];
}

#pragma mark - RSKImageCropViewControllerDelegate

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage
{
    UIImage *scaledImage = [croppedImage resizedImageToFitInSize:CGSizeMake(256, 256) scaleIfSmaller:NO];
    [self.headView setImage:scaledImage];
    //    [self.headView draw];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.labelText = @"正在上传";
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    //    hud.delegate = self;
    [hud show:YES];
    // Show the HUD while the provided method executes in a new thread
    //    [HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
    NSData *data = UIImagePNGRepresentation(scaledImage);
    AVFile *file = [AVFile fileWithName:@"photo.png" data:data];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [hud hide:YES];
//            [AVUser currentUser]. = file.url;
//            [[AVUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                if (succeeded) {
//                    [hud hide:YES];
//                } else {
//                    hud.labelText = @"上传失败";
//                    [hud hide:YES afterDelay:1];
//                }
//            }];
            self.photo = file;
        } else {
            hud.labelText = @"上传失败";
            [hud hide:YES afterDelay:1];
        }
    }];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
