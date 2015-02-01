//
//  ResultController.m
//  DaoMingShi
//
//  Created by Qihe Bian on 2/1/15.
//  Copyright (c) 2015 machupicchu. All rights reserved.
//

#import "ResultController.h"
#import "AFNetworking.h"
#import <AVOSCloud/AVOSCloud.h>

@interface ResultController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property(nonatomic, strong)NSMutableArray *templates;
@property(nonatomic, weak)UICollectionView *collectionView;
@property(nonatomic, weak)UIWebView *webView;
@end

@implementation ResultController

- (id)itemForKey:(NSString *)key {
    FormDataItem *resultItem = nil;
    for (FormDataItem *item in self.data) {
        if ([item.key isEqualToString:key]) {
            resultItem = item;
            break;
        }
    }
    return resultItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 100)];
    [self.view addSubview:webView];
    self.webView = webView;
    
    FormDataItem *domainItem = [self itemForKey:@"domain"];
    AVQuery *query = [AVQuery queryWithClassName:@"template"];
    [query whereKey:@"tags" equalTo:domainItem.value];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.templates = [objects mutableCopy];
        NSLog(@"%@", objects);
        [self.collectionView reloadData];
        if (objects.count > 0) {
            AVObject *template = [self.templates objectAtIndex:0];
            [self loadTemplate:template];
        }
    }];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(80, 36);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 100, self.view.frame.size.width, 100) collectionViewLayout:layout];
    collectionView.autoresizesSubviews = YES;
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    collectionView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:1.000];
    collectionView.userInteractionEnabled = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
}

- (void)loadTemplate:(AVObject *)template {
    NSString *tid = [template objectId];
    NSString *url = [NSString stringWithFormat:@"http://baijoke.avosapps.com/view/%@/%@", self.profile.objectId, template.objectId];
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"%@", string);
        [self.webView loadHTMLString:string baseURL:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [op start];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.templates.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    [[cell viewWithTag:1] removeFromSuperview];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    label.tag = 1;
    label.text = [[self.templates objectAtIndex:indexPath.item] objectForKey:@"name"];
    [cell.contentView addSubview:label];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AVObject *template = [self.templates objectAtIndex:indexPath.item];
    [self loadTemplate:template];
//    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
//    
//    LCMultiSelectItem *item = self.selectedItems[indexPath.item];
//    //删除某元素,实际上是告诉delegate去删除
//    if (self.delegate&&[self.delegate respondsToSelector:@selector(willDeleteRowWithItem:withMultiSelectedPanel:)]) {
//        [self.delegate willDeleteRowWithItem:item withMultiSelectedPanel:self];
//    }
//    //确定没了删掉
//    if ([self.selectedItems indexOfObject:item]==NSNotFound) {
//        [self updateConfirmButton];
//        [collectionView deleteItemsAtIndexPaths:@[indexPath]];
//    }
}

@end
