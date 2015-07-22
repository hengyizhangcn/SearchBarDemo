//
//  SearchViewController.h
//  SearchBarDemo
//
//  Created by hengyizhang on 7/21/15.
//  Copyright (c) 2015 deppon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  SearchStaffDelegate;

@interface SearchViewController : UIViewController

@property (nonatomic, assign) NSMutableArray *resultMutableArray; //搜索选择结果数组
@property (nonatomic, assign) id<SearchStaffDelegate> delegate;

@end


@protocol SearchStaffDelegate <NSObject>

- (void)searchStaff:(NSArray *)staffMutableArray;

@end