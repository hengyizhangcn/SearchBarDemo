//
//  SearchViewController.m
//  SearchBarDemo
//
//  Created by hengyizhang on 7/21/15.
//  Copyright (c) 2015 deppon. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchTableViewCell.h"
#define APPW self.view.bounds.size.width
#define APPH self.view.bounds.size.height

@interface SearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>{
    UISearchBar *_searchBar;
    UITableView *_resultTableView; //搜索选择结果表格 在最下层
    UITableView *_searchTableView; //搜索表格视图 在上层
    UIButton *_envelopViewBtn;
    
    NSMutableArray *_searchMutableArray; //搜索结果数组
    NSMutableArray *_emailsChooseMutableArray; //用于保存选择员工的邮箱，用于创建日程
    BOOL _isSearchTableViewAdd; //是否添加了搜索表格视图
    
    UIView *_statusBarView;
    UIView *_loadingView; //加载框
    
    NSUInteger _currentCount; //当前数量
}

@end

@implementation SearchViewController
//@synthesize resultMutableArray = self.resultMutableArray;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_resultTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"人员搜索";
    self.navigationController.navigationBar.backgroundColor = [UIColor blueColor];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonItemAction)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    
    //初始化数组
//    self.resultMutableArray = [[NSMutableArray alloc] initWithObjects:nil];
    _searchMutableArray = [[NSMutableArray alloc] initWithObjects:nil];
    _emailsChooseMutableArray = [[NSMutableArray alloc] initWithObjects:nil];
    
    //初始化网络请求对象
    
    _currentCount = 0;
    _isSearchTableViewAdd = NO;
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, APPW, 44)];
    _searchBar.placeholder = @"请输入工号/姓名/手机号";
    _searchBar.barStyle = UIBarMetricsDefault;
    _searchBar.tintColor = [UIColor blueColor];
    _searchBar.translucent = YES;
    _searchBar.delegate = self;
    
    //搜索选择结果视图，从搜索表格过来
    _resultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, APPW, APPH - 44)];
    _resultTableView.delegate = self;
    _resultTableView.dataSource = self;
    _resultTableView.tag = 0;
    
    _resultTableView.tableHeaderView = _searchBar;
    [self.view addSubview:_resultTableView];
    
    _envelopViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 44, APPW, APPH - 44)];
    _envelopViewBtn.backgroundColor = [UIColor blackColor];
    _envelopViewBtn.alpha = 0.0f;
    [_envelopViewBtn addTarget:self action:@selector(clickEnvelopBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //搜索表格从网络获取数据
    _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, APPW, APPH - 64 - 48)];
    _searchTableView.delegate = self;
    _searchTableView.dataSource = self;
    _searchTableView.tag = 1;
}

- (void)rightBarButtonItemAction {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
 遮盖层响应事件
 */
- (void)clickEnvelopBtnAction:(UIButton *)button {
    [self envelopViewControl:0];
}

/*
 遮盖层视图控制
 用于添加遮盖层或者移除遮盖层
 */
- (void)envelopViewControl:(float)alpha {
    [UIView animateWithDuration:0.05 animations:^{
        _envelopViewBtn.alpha = alpha;
    }completion:^(BOOL finished) {
        if (alpha <= 0) { //移除遮盖层
            [_envelopViewBtn removeFromSuperview];
            [_searchBar setShowsCancelButton:NO animated:YES];
            [_searchBar resignFirstResponder];
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        } else { //添加遮盖层
            [_resultTableView addSubview:_envelopViewBtn];
            [_resultTableView bringSubviewToFront:_envelopViewBtn];
        }
    }];
}

#pragma mark UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [_searchBar setShowsCancelButton:YES animated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self envelopViewControl:0.3];
    
    _statusBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, APPW, 20)];
    _statusBarView.backgroundColor = [UIColor colorWithRed:50/255.0 green:60/255.0 blue:100/255.0 alpha:1.0];
    [self.view addSubview:_statusBarView];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [_statusBarView removeFromSuperview];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [_statusBarView removeFromSuperview];
    [_searchTableView removeFromSuperview];
    [_searchMutableArray removeAllObjects];
    [_searchTableView reloadData];
    [self envelopViewControl:0];
    
    _isSearchTableViewAdd = NO;
    searchBar.text = nil;
    [searchBar resignFirstResponder];
    [_resultTableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_loadingView removeFromSuperview];
    if (searchBar.text.length > 0) {
        if (!_isSearchTableViewAdd) {
            _isSearchTableViewAdd = YES;
            [self.view addSubview:_searchTableView];
        }
    } else {
        _isSearchTableViewAdd = NO;
        [_searchMutableArray removeAllObjects];
        [_searchTableView removeFromSuperview];
        [_searchTableView reloadData];
        [_resultTableView reloadData];
    }
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 0) {
        return self.resultMutableArray.count;
    } else {
        return _searchMutableArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"searchStaff";
    SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[SearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 0) {
        [_resultTableView reloadData];
    }
    else if (tableView.tag == 1) {
        
        [_searchTableView reloadData];
        
        NSLog(@"self.resultMutableArray:%@", self.resultMutableArray);
        NSLog(@"_emailsChooseMutableArray:%@", _emailsChooseMutableArray);
    }
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}


@end
